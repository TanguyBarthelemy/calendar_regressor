%macro INITIALISE_CJO(chemin_macros_cjo=,stockage_cjo=,andeb=,anfin=,periodicite=);

 /* Attention : les dates de d?but et de fin sont indiqu?es en dur car on veut ?tre sur d'avoir les m?mes r?gresseurs CJO pour tous les
     indices lors de la campagne annuelle 2011 */
%let andeb=1990;
%let anfin=2030;

%if &periodicite.=T %then %let periodicite=Q;
%else %let periodicite=M;

option notes;
option noxwait xsync;

%if %sysfunc(fileexist("&stockage_cjo.\regresseurs"))=0 %then %do;
 %sysexec md "&stockage_cjo.\regresseurs";
%end;

%if %sysfunc(fileexist("&stockage_cjo.\exec"))=0 %then %do;
 %sysexec md "&stockage_cjo.\exec";
%end;

%inc "&chemin_macros_cjo.\macros\FrenchCalendar.sas";
%inc "&chemin_macros_cjo.\macros\creecjo.sas";

libname don "&stockage_cjo.\regresseurs";

%let anfinavg=%eval(&andeb.+2799);

/* periode de calcul de la moyenne de long terme a verifier */

%Calendar(START=&andeb.,END=&anfin.,OUT=FrenchCalendar,
          STARTM=&andeb.,ENDM=&anfinavg.,STAT=&periodicite.);

/* calcul de la table dans le cas de series trimestrielles */

%if &periodicite.=Q %then %do;

proc means data=FrenchCalendar_c noprint nway;
 var _numeric_;
 class year qtr;
 output out=FrenchCalendar_c(drop=_type_ _freq_ month date) sum=;
run;quit;

data FrenchCalendar_c;
 set FrenchCalendar_c;
 format date date7.;
 date=yyq(year,qtr);
run;

%end;

%creecjo(Tab=FrenchCalendar_c,Gin1=0, Gin2=1, Gin3=1, Gin4=1, Gin5=1, Gin6=1, Gin7=0,Goff1=0, Goff2=0, Goff3=0, Goff4=0, Goff5=0, Goff6=0, Goff7=0,
         sortie=don.reg1) ;
%creecjo(Tab=FrenchCalendar_c,Gin1=0, Gin2=1, Gin3=1, Gin4=1, Gin5=1, Gin6=1, Gin7=2,Goff1=0, Goff2=0, Goff3=0, Goff4=0, Goff5=0, Goff6=0, Goff7=0,
         sortie=don.reg2) ;
%creecjo(Tab=FrenchCalendar_c,Gin1=0, Gin2=1, Gin3=2, Gin4=2, Gin5=2, Gin6=2, Gin7=3,Goff1=0, Goff2=0, Goff3=0, Goff4=0, Goff5=0, Goff6=0, Goff7=0,
         sortie=don.reg3) ;
%creecjo(Tab=FrenchCalendar_c,Gin1=0, Gin2=1, Gin3=2, Gin4=3, Gin5=4, Gin6=5, Gin7=0,Goff1=0, Goff2=0, Goff3=0, Goff4=0, Goff5=0, Goff6=0, Goff7=0,
         sortie=don.reg5) ;
%creecjo(Tab=FrenchCalendar_c,Gin1=0, Gin2=1, Gin3=2, Gin4=3, Gin5=4, Gin6=5, Gin7=6,Goff1=0, Goff2=0, Goff3=0, Goff4=0, Goff5=0, Goff6=0, Goff7=0,
         sortie=don.reg6) ;

data don.jeu_reg;
 format regres $100.;
 jeureg="reg1";
 regres="ac1 LY";
 output;
 jeureg="reg2";
 regres="ac1 ac2 LY";
 output;
 jeureg="reg3";
 regres="ac1 ac2 ac3 LY";
 output;
 jeureg="reg5";
 regres="ac1 ac2 ac3 ac4 ac5 LY";
 output;
 jeureg="reg6";
 regres="ac1 ac2 ac3 ac4 ac5 ac6 LY";
 output;
run;


%inc "&chemin_macros_cjo.\macros\export_regresseurs.sas";
%inc "&chemin_macros_cjo.\macros\NOM_CJO.sas";

%export_regr(rep_sortie=&stockage_cjo.\regresseurs);

data _null_;
 set don.jeu_reg end=fin;
 format max nbjeux best12.;
 retain max nbjeux 0;
 nbreg=length(regres)-length(compress(regres,"c"));
 nbjeux+1;
 if nbreg>max then max=nbreg;
 if fin then do;
  call symput("max",max);
  call symput("nbjeux",nbjeux);
 end;
run;

%NOM_CJO(max=&max.,nbjeux=&nbjeux.);

proc datasets lib=work memtype=data nolist;
 delete frenchcalendar: meansbis tfrenchcalendar_c tsumgroup sumgroup;
run;quit; 


%mend INITIALISE_CJO;






/*exemple de lancement*/
/*mensuel*/
%INITIALISE_CJO(chemin_macros_cjo=V:\DG75-L120\desaisonnalisation\regresseurs JO,stockage_cjo=U:\RUN_CJO,andeb=,anfin=,periodicite=m);
libname demipont "V:\DG75-L120\desaisonnalisation\regresseurs JO";
data demipont.reg_JO;
set Tab_regs;
run;
proc export data=demipont.reg_JO
outfile="V:\DG75-L120\desaisonnalisation\regresseurs JO\reg_cjo_m_tmp.xls"
DBMS=XLS replace;
run;

/*trimestriel*/
%INITIALISE_CJO(chemin_macros_cjo=V:\DG75-L120\desaisonnalisation\regresseurs JO,stockage_cjo=U:\RUN_CJO,andeb=,anfin=,periodicite=T);
data demipont.reg_JO_trim;
set Tab_regs;
run;
proc export data=demipont.reg_JO_trim
outfile="V:\DG75-L120\desaisonnalisation\regresseurs JO\reg_cjo_t_tmp.xls"
DBMS=XLS replace;
run;
