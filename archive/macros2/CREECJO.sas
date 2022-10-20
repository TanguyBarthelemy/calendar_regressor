/***********************************************************************/

/* On part des 14 variables calendaires de base issues de la macro %Calendar de DL
(lundis non fériés,….dimanches non fériés, lundis fériés,…, dimanches fériés) et on 
 effectue les transformations suivantes : regroupement de variables, contraste par rapport
 à un ensemble de jours choisis par l'utilisateur.
 Il faut attribuer à chaque variable un numéro de groupe autre que 0 et attribuer 0 comme numéro de groupe
 à toutes les variables faisant partie du groupe de contraste */

/*
LIBNAME store  "N:\Unites\E301dsct\E320_ICA\kit_section_methodo\macros\SASstore";
OPTIONS MSTORED SASMSTORE=store;
%Calendar(START=1990,END=2015,OUT=FrenchCalendar,
          STARTM=1990,ENDM=4789,STAT=m);
*/

%include 'Z:\macros\FrenchCalendar.sas';
%Calendar(START=1990,END=2030,OUT=FrenchCalendar,STARTM=1980,ENDM=4789,STAT=m,WORD=,DEBUG=yes);

libname cjo  "Z:\output_calendar_sas\cjo";

OPTIONS notes mprint;

*libname cal_fr "Z:\output_calendar_sas\French Calendar" ;
*libname tcal_fr "Z:\output_calendar_sas\tcal" ;
*libname cjo_out "Z:\output_calendar_sas\CJO";

%macro CREECJO(Tab=FrenchCalendar,Gin1=0, Gin2=1, Gin3=1, Gin4=1, Gin5=1, Gin6=1, Gin7=1,Goff1=0, Goff2=0, Goff3=0, Goff4=0, Goff5=0, Goff6=0, Goff7=0,
               sortie=regcjo);

data cjo.tab1;
set &tab;
run;

DATA &tab; set &tab;
  format date /*MONYY.;*/ MMYYS7.;/*on change le format car sinon il y a confusion entre 01/1980 et 01/2080 car avec le format MONYY. on a 0180 et 0180*/ 
run;

data cjo.tab2;
set &tab;
run;

PROC TRANSPOSE DATA=&tab OUT=t&tab;
  VAR in1-in7 off1-off7;
  ID date;
RUN;

data cjo.tab3;
set t&tab;
run;

/* recuperation des variables a regrouper */

DATA t&tab; SET t&tab;
  Gname="G"!!_name_;
  Group=symget(Gname);
RUN;

data cjo.tab4;
set t&tab;
run;

/* somme des nombres de jours correspondants */

PROC MEANS DATA= t&tab NOPRINT;
  CLASS group;
  VAR _numeric_;
  OUTPUT OUT=sumgroup SUM=;
RUN;

data cjo.tab5;
set sumgroup;
run;

DATA sumgroup; SET sumgroup;
  BY group;
  /* recuperation du nombre de regresseurs */
  IF last.group THEN CALL SYMPUT("nbgroup",group);
  group="REG"!!group;
  /* calcul du nombre de jours (variable longueur du mois) */
  if _TYPE_=0 THEN group="Nbdays";
  /* calcul du nombre de variables regroupees dans chaque groupe */
  CALL SYMPUT(group,_freq_);
RUN;

data cjo.tab6;
set sumgroup;
run;

PROC TRANSPOSE DATA=sumgroup(DROP=_TYPE_ _FREQ_) OUT=tsumgroup;
  VAR _numeric_;
  ID group;
RUN;

data cjo.tab7;
set tsumgroup;
run;

  /* Calcul des variables en contraste */ 
DATA &sortie; MERGE tsumgroup &tab(KEEP=date);
  %do i=1 %to &nbgroup;
    REG&i._contr=REG&i-(&&REG&i/&REG0)*REG0;
  %end;
  DROP _name_;
RUN;

data cjo.tab8;
set &sortie;
run;

%mend CREECJO;


%CREECJO(Tab=FrenchCalendar_c, 
		Gin1=0, Gin2=1, Gin3=1, Gin4=1, Gin5=1, Gin6=1, Gin7=0, 
		Goff1=0, Goff2=0, Goff3=0, Goff4=0, Goff5=0, Goff6=0, Goff7=0,
		sortie=regcjo);

