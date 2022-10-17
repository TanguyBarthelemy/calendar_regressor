

/* renomme les jeux de regresseurs afin de pouvoir tous les importer dans Demetra + */


%macro nom_cjo(max=7,nbjeux=9);

data noms_reg;
 set don.jeu_reg;
 nreg=compress(tranwrd(jeureg,"cjo_",""));
 %do k=1 %to &max.;
  regres=tranwrd(regres,"ac&k.",compress(nreg!!"_ac&k."));
 %end; 	
 regres=tranwrd(regres,"lpyear",compress(nreg!!"_lpy"));
run;

data _null_;
    set don.jeu_reg;
	retain n 0;
	n+1;
	call symput(compress("tregcjo"!!n),compress(jeureg));
 run;
  

proc iml;
 use noms_reg;
 read all var _char_ into x;
 close noms_reg;

 %do k=1 %to &nbjeux.;

   
   use don.&&tregcjo&k.;
   read all into regs[C=names];
   close don.&&tregcjo&k.;
  
   names=lowcase(names);
   index1=loc((index(names,"_contr")>0));
   index2=loc((index(names,"nbdays")>0));

   regs=regs[,index1]||regs[,index2];

   names=x[&k.,];
   call symput("x",rowcat(names));

   names={&x.};

   create regs&k. from regs[C=names];
   append from regs;

%end;

quit; 

data tab_regs;
 merge don.&tregcjo1.(keep=date)
 %do k=1 %to &nbjeux.;
   regs&k.
 %end;
 ;
run;

proc sql;
 drop table
   %do k=1 %to %eval(&nbjeux.-1);
   regs&k.,
   %end;
   regs&nbjeux.;
quit;

%mend nom_cjo;
