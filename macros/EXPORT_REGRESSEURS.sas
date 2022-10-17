
/*

macro d export des regresseurs vers des fichiers textes adaptes a l utilitaire dos
de win-x12.
Cette macro prend 2 parametres :
	- nbt : nombre de regroupements, de fichiers sas don.regcjo_no.
	- sortie : lieu de stockage des fichiers textes crees

*/




%macro export_regr(rep_sortie=Z:\dossiers\regroupements_cjo\IPI,per=&periodicite.);

proc sql noprint;
 select count(*) into :nbt from don.jeu_reg;
quit;

%do k=1 %to &nbt.;

data _null_;
 set don.jeu_reg(obs=&k. keep=jeureg);
 call symput("jeureg",compress(jeureg));
run;

proc iml;
 use don.&jeureg.;
 read all into x[C=nvar];
 close don.&jeureg.;

 nvar=nvar[loc(index(nvar,"contr")>0)];
 nvar=compress(nvar)+" ";
 nvar=t(nvar);

 call symput("vars",rowcat(nvar));

quit;

%let nbvars=%eval(%length(&vars.)-%length(%sysfunc(compress(&vars.)))+1);


filename f "&rep_sortie.\&jeureg..txt";

/*data export;
 merge don.regcjo_&k.(keep=date &vars. in=a) don.ipi_modif(keep=vertical lpyear rename=(vertical=date));
 by date;
 if a;
 date2=compress(year(date)!!put(month(date),z2.));
 drop date;
 rename date2=date;
run;*/

data export;
 merge don.&jeureg.(keep=date &vars. nbdays);
 %if %upcase(&per.)=M %then %do;
 date2=compress(year(date)!!put(month(date),z2.));
 %end;
 %else %do;
 date2=compress(year(date)!!put(qtr(date),z2.));
 %end;
 drop date;
 rename date2=date nbdays=lpyear;
run;

data _null_;
 file f;
 set export;
 format x $10.;
 if _n_=1 then do;
  x="date";
  put x $6. +1 @;
  %do nv=1 %to &nbvars.;
   x="%scan(&vars.,&nv.,"" "")";
   put x $ +1 @;
   %end;
   x="lpyear";
   put x $;
 end;
 if _n_=1 then do;
  x=repeat("-",6);
  put x $6. +1 @;
  %do nv=1 %to &nbvars.;
   y=repeat("-",23);
   put y $ +1 @;
   %end;
   put y $;
 end;
 put date $6. +1 @;
 %do nv=1 %to &nbvars.;
   put %scan(&vars.,&nv.," ") E23. +1 @;
  %end;
  put lpyear E23.;
run;

%end;

%mend export_regr;
