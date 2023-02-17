%MACRO Calendar(START=,END=,OUT=,STARTM=,ENDM=,STAT=,PER=,WORD=,DEBUG=);

 /******************************************************************************/
 /* Macro Calendar : Calendar of working and non-working days for France.      */
 /******************************************************************************/
 /* This macro generates the trading-day regressors, taking into account the   */
 /* specificities of the national calendar.                                    */
 /* Day-of-Week regressors are computed as well as contrasts. A centered       */
 /* version of the regressors is also computed by removing the mean by month,  */
 /* in order to cancel the seasonal part of the calendar effect.               */
 /* WARNING: it is very difficult to design a "general" program as most of     */
 /*          national calendars have exceptions, special days .... I tried     */
 /*          but did not succeed.                                              */
 /* REMARK:  We derive all kind of days and some of them could appear curious, */
 /*          as the concept of "Sundays in" and "Sundays off". But do not      */
 /*          forget that in Muslim countries for example, Sunday is an usual   */
 /*          day. In some other countries, shopping centers are open 7 days a  */
 /*          week.                                                             */
 /*----------------------------------------------------------------------------*/
 /* Author: Dominique LADIRAY (22MAY2004 )  Last Modification: 07JUL2009       */
 /******************************************************************************/
 /* MACRO PARAMETERS                                                           */
 /******************************************************************************/
 /*                                                                            */
 /* OUT     = Name of the SAS datasets containing the output TD regressors.    */
 /*           2 datasets are created: one with the "raw regressors" (OUT) and  */
 /*           another with the centered regressors (in order to remove the     */
 /*           seasonal part of the calendar effect.                            */
 /*           The datasets contain the following variables:                    */
 /*           date= SAS date (first day of the month)                          */
 /*           year= year                                                       */
 /*           month= month  (or quarter)                                       */
 /*           nbday= number of days of the month                               */
 /*           Day1= Sunday                                                     */
 /*           Day2= Monday                                                     */
 /*           Day3= Tuesday                                                    */
 /*           Day4= Wednesday                                                  */
 /*           Day5= Thursday                                                   */
 /*           Day6= Friday                                                     */
 /*           Day7= Saturday                                                   */
 /*           Off1= Sunday off                                                 */
 /*           Off2= Monday off                                                 */
 /*           Off3= Tuesday off                                                */
 /*           Off4= Wednesday off                                              */
 /*           Off5= Thursday off                                               */
 /*           Off6= Friday off                                                 */
 /*           Off7= Saturday off                                               */
 /*           In1 = Sunday in                                                  */
 /*           In2 = Monday in                                                  */
 /*           In3 = Tuesday in                                                 */
 /*           In4 = Wednesday in                                               */
 /*           In5 = Thursday in                                                */
 /*           In6 = Friday in                                                  */
 /*           In7 = Saturday in                                                */
 /*           TD1 = Monday contrast (Day2-Day1)                                */
 /*           TD2 = Tuesday contrast (Day3-Day1)                               */
 /*           TD3 = Wednesday contrast (Day4-Day1)                             */
 /*           TD4 = Thursday contrast (Day5-Day1)                              */
 /*           TD5 = Friday contrast (Day6-Day1)                                */
 /*           TD6 = Saturday contrast (Day7-Day1)                              */
 /*           WD  = Weekday contrast (TD2+TD3+TD4+TD5+TD6)-5*(TD1+TD7)/2       */  
 /*           PH  = Public Holiday, except Sat. & Sun.                         */
 /*           TD  = Trading Week Days  (Sum of working M,T,W,T,F)              */  
 /*           LeapYear  = Leap Year                                            */   
 /*           Monday, Tuesday, Wednesday, Thursday, Friday, Saturday           */
 /*           (one contrast regressor for each day of the week)  and a         */
 /*           WeekDay contrast regressor                                       */
 /*           Friday_B, Monday_B and Bridges: Bridge variables.                */
 /* START   = starting date for the evaluation of the regressors               */
 /* END     = ending date for the evaluation of the regressors                 */
 /* STARTM  = starting year for the computation of the average TD effect.      */
 /* ENDM    = ending year for the computation of the average TD effect.        */
 /* STAT    = Ask for some statistics on trading days (M for monthly statistics*/
 /*           Q for quarterly statistics). Statistics are computed on the      */
 /*           [START to END] period.                                           */
 /* DEBUG   = Debugging option                                                 */
 /*                                                                            */
 /******************************************************************************/
 /* REFERENCES :                                                               */
 /*                                                                            */
 /*                                                                            */
 /******************************************************************************/

 %IF (&debug NE) %THEN %DO;
  OPTIONS MPRINT NOTES NOXWAIT;
 %END;
 %ELSE %DO;
  OPTIONS NOMPRINT NONOTES NOSOURCE2 NOXWAIT;
 %END;

 /******************************************************************************/
 /* SASNOM Macro, to check if a name is a valid SAS name                       */
 /******************************************************************************/

 %MACRO sasnom(_IN_=,TYPE=);
  %GLOBAL _ret_;
  %LET _ret_=0;
  %IF &SYSVER < 7 %THEN %LET max=8;%ELSE %LET max=32;
  %LET table=%UPCASE(%TRIM(&_in_));
  %IF (%UPCASE(&type) EQ DATASET) %THEN %DO;
   %LET index=%INDEX(&table,.);
   %IF (&index GT 1) %THEN %DO;
    %LET lib=%SUBSTR(&table,1,&index-1);
    %LET table=%SUBSTR(&table,&index+1);
    %LET c1=%LENGTH(&lib);
    %LET c2=%VERIFY(%SUBSTR(&lib,1,1),'_ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    %LET c3=%VERIFY(&lib,'_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    %IF ((&c1 > &max) OR (&c2 > 0) OR (&c3 > 0)) %THEN %LET _ret_=1;
   %END;
  %END;
  %LET c1=%LENGTH(&table);
  %LET c2=%VERIFY(%SUBSTR(&table,1,1),'_ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  %LET c3=%VERIFY(&table,'_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  %IF ((&c1 > &max) OR (&c2 > 0) OR (&c3 > 0)) %THEN %LET _ret_=1;
 %MEND;

 /******************************************************************************/
 /* Reading and checking of parameters                                         */
 /******************************************************************************/

 /* Checking parameter out                                                     */
 /******************************************************************************/

 %IF (%LENGTH(&out ) EQ 0) %THEN %LET out = _regressor_ ;
 %ELSE %DO;
  %IF (%LENGTH(%QSCAN(%BQUOTE(&out ),2,%STR( ))) NE 0) %THEN %DO;
   %PUT ERROR: You must precise just one value for the out (&out ) parameter;
   %GOTO finmacro;
  %END;
  %sasnom(_IN_=&out ,TYPE=DATASET);
  %IF (&_ret_ NE 0) %THEN %DO;
   %PUT ERROR: The out (&out ) parameter must be a valid SAS dataset name;
   %GOTO finmacro;
  %END;
 %END;

 /* Checking parameter start                                                   */
 /******************************************************************************/

 %IF (%LENGTH(&start ) EQ 0) %THEN %DO;
  %PUT ERROR: The start parameter must be precised;
  %GOTO finmacro;
 %END;
 %ELSE %DO;
  %IF (%LENGTH(%QSCAN(%BQUOTE(&start ),2,%STR( ))) NE 0) %THEN %DO;
   %PUT ERROR: You must precise just one value for the start (&start ) parameter;
   %GOTO finmacro;
  %END;
  %IF (%DATATYP(&start ) EQ CHAR) %THEN %DO;
   %PUT ERROR: The start (&start ) parameter must be numeric;
   %GOTO finmacro;
  %END;
 %END;

 /* Checking parameter end                                                     */
 /******************************************************************************/

 %IF (%LENGTH(&end ) EQ 0) %THEN %DO;
  %PUT ERROR: The end parameter must be precised;
  %GOTO finmacro;
 %END;
 %ELSE %DO;
  %IF (%LENGTH(%QSCAN(%BQUOTE(&end ),2,%STR( ))) NE 0) %THEN %DO;
   %PUT ERROR: You must precise just one value for the end (&end ) parameter;
   %GOTO finmacro;
  %END;
  %IF (%DATATYP(&end ) EQ CHAR) %THEN %DO;
   %PUT ERROR: The end (&end ) parameter must be numeric;
   %GOTO finmacro;
  %END;
  %IF (&end LE &start) %THEN %DO;
   %PUT ERROR: The end (&end ) parameter must be greater than the start (&start) parameter;
   %GOTO finmacro;
  %END;
 %END;

 /* Checking parameter startm                                                  */
 /******************************************************************************/

 %IF (%LENGTH(&startm ) EQ 0) %THEN %LET startm=&start;
 %ELSE %DO;
  %IF (%LENGTH(%QSCAN(%BQUOTE(&startm ),2,%STR( ))) NE 0) %THEN %DO;
   %PUT ERROR: You must precise just one value for the startm (&startm ) parameter;
   %GOTO finmacro;
  %END;
  %IF (%DATATYP(&startm ) EQ CHAR) %THEN %DO;
   %PUT ERROR: The startm (&startm ) parameter must be numeric;
   %GOTO finmacro;
  %END;
 %END;

 /* Checking parameter endm                                                    */
 /******************************************************************************/

 %IF (%LENGTH(&endm ) EQ 0) %THEN %LET endm=&end;
 %ELSE %DO;
  %IF (%LENGTH(%QSCAN(%BQUOTE(&endm ),2,%STR( ))) NE 0) %THEN %DO;
   %PUT ERROR: You must precise just one value for the endm (&endm ) parameter;
   %GOTO finmacro;
  %END;
  %IF (%DATATYP(&endm ) EQ CHAR) %THEN %DO;
   %PUT ERROR: The endm (&endm ) parameter must be numeric;
   %GOTO finmacro;
  %END;
  %IF (&endm LE &startm) %THEN %DO;
   %PUT ERROR: The endm (&endm ) parameter must be greater than the startm (&startm) parameter;
   %GOTO finmacro;
  %END;
 %END;

 /* Checking parameter stat                                                    */
 /******************************************************************************/

 %LET stat=%UPCASE(&stat);
 %IF (%LENGTH(&stat ) NE 0) %THEN %DO;
  %IF (%LENGTH(%QSCAN(%BQUOTE(&stat ),2,%STR( ))) NE 0) %THEN %DO;
   %PUT ERROR: You must precise just one value for the stat (&stat ) parameter;
   %GOTO finmacro;
  %END;
  %IF (%DATATYP(&stat ) EQ NUM) %THEN %DO;
   %PUT ERROR: The stat (&stat ) parameter must be character;
   %GOTO finmacro;
  %END;
  %ELSE %IF ((&stat NE M) AND (&stat NE Q)) %THEN %DO;
   %PUT ERROR: The stat (&stat ) parameter must be choosen among (M Q);
   %GOTO finmacro;
  %END;
 %END;

 /******************************************************************************/
 /* Controls end, Macro begins                                                 */
 /******************************************************************************/

  %IF (&end < &start) %THEN %DO;
   %PUT ERROR: The start parameter must be smaller or equal to the end parameter;
   %GOTO finmacro;
  %END;
  %LET clean=;

  DATA &out;
   LENGTH Date 5 year month qtr NbDays Day1-Day7 Off1-Off7 In1-In7 TD1-TD6 WD Monday_B Friday_B PH TD Bridges LeapYear WeekDays 8 EasterG $ 9;
   KEEP Date year month qtr NbDays Day1-Day7 Off1-Off7 In1-In7 TD1-TD6 WD Monday_B Friday_B PH TD Bridges LeapYear EasterG WeekDays;
   ARRAY days(7) Day1-Day7;
   ARRAY Off(7) Off1-Off7;
   ARRAY in(7)  In1-In7;
   ARRAY Tdays(6)  TD1-TD6;
   LABEL
    Day1="# Sunday"
    Day2="# Monday"
    Day3="# Tuesday"
    Day4="# Wednesday"
    Day5="# Thursday"
    Day6="# Friday"
    Day7="# Saturday"
    Off1="# Sunday off"
    Off2="# Monday off"
    Off3="# Tuesday off"
    Off4="# Wednesday off"
    Off5="# Thursday off"
    Off6="# Friday off"
    Off7="# Saturday off"
    In1="# Sunday in"
    In2="# Monday in"
    In3="# Tuesday in"
    In4="# Wednesday in"
    In5="# Thursday in"
    In6="# Friday in"
    In7="# Saturday in"
    Monday_B='# Monday bridge'
    Friday_B='# Friday bridge'
    PH="Public Holidays, except Sat. & Sun."
    TD='Trading Week Days'
    LeapYear='Leap Year'
    EasterG='Easter date'
    ;
   Firstyear=MIN(&start,&startm);
   Lastyear=MAX(&end,&endm);
   Date=MDY(12,1,Firstyear-1);
   DO k=1 TO (Lastyear-Firstyear+1)*12;
    Date=INTNX('month',date,1);
    Year=YEAR(date);
    Month=MONTH(date);
    Qtr=QTR(date);
    Nbdays=INTNX('month',date,1)-date;
    DO i=1 TO DIM(days);
     days(i)=0;
     off(i)=0;
     in(i)=0;
    END;
    DO i=1 TO NbDays;
     jj=WEEKDAY(date+i-1);
     days(jj)=days(jj)+1;
    END;

    /* Paques, Ascension, Pentec?te */

    G = MOD(year,19);
    C = INT(year/100);
    H = MOD(C - INT(C/4) - INT((8*C+13)/25) + 19*G + 15,30);
    I = H - INT(H/28)*(1 - INT(H/28)*INT(29/(H + 1))*INT((21 - G)/11));
    J = MOD((year + INT(year/4) + I + 2 - C + INT(C/4)),7);
    L = I - J;
    mois = 3 + INT((L + 40)/44);
    jour = L + 28 - 31*INT(mois/4);
    deaster=MDY(mois,jour,year);     /* Dimanche de P?ques */
    EasterG=PUT(deaster,DATE9.);
    jascen=deaster+39;               /* Jeudi de l'Ascension */
    lpent=deaster+50;                /* Lundi de Pentec?te */

    /* Lundi de P?ques    */
    IF (MONTH(deaster+1)=month) 
     THEN Off(WEEKDAY(deaster+1))=Off(WEEKDAY(deaster+1))+1;
     ELSE EasterG=' ';

    /* Jeudi de l'Ascension; 39 jours apr?s le dimanche de P?ques */
    /* Attention, peut tomber un 1 ou 8 mai !                     */
    IF ((MONTH(jascen)=month) AND (jascen^=MDY(5,1,year)) AND (jascen^=MDY(5,8,year))) 
     THEN Off(WEEKDAY(jascen))=Off(WEEKDAY(jascen))+1;

    /* Lundi de Pentec?te; 11 jours apr?s l'ascencion; 50 jours apr?s P?ques */
    /* Attention, RAFFARIN en 2005. Ici poids de 0.5                         */
    IF (MONTH(lpent)=month) THEN DO;
      IF (year^=2005) 
       THEN Off(WEEKDAY(lpent))=Off(WEEKDAY(lpent))+1;
       ELSE Off(WEEKDAY(lpent))=Off(WEEKDAY(lpent))+0.5;
    END;

    /* premier janvier */
    a=WEEKDAY(MDY(1,1,year));
    IF (month=1) THEN Off(a)=Off(a)+1;

    /* F?te du Travail ; Premier Mai mais f?t?e depuis 1947 seulement */
    a=WEEKDAY(MDY(5,1,year));
    IF ((month=5) AND (year>=1947)) THEN Off(a)=Off(a)+1;

    /* Armistice de 1945 ; Huit Mai mais f?t?e depuis 1982 seulement */
    a=WEEKDAY(MDY(5,8,year));
    IF ((month=5) AND (year>=1982)) THEN Off(a)=Off(a)+1;

    /* 14 juillet      */
    a=WEEKDAY(MDY(7,14,year));
    IF (month=7) THEN Off(a)=Off(a)+1;

    /* Assomption */
    a=WEEKDAY(MDY(8,15,year));
    IF (month=8) THEN Off(a)=Off(a)+1;

    /* Toussaint */
    a=WEEKDAY(MDY(11,1,year));
    IF (month=11) THEN Off(a)=Off(a)+1;

    /* Armistice de 1918 ; f?t?e depuis 1922 */
    a=WEEKDAY(MDY(11,11,year));
    IF ((month=11)  AND (year>=1922)) THEN Off(a)=Off(a)+1;

    /* Noel */
    a=WEEKDAY(MDY(12,25,year));
    IF (month=12) THEN Off(a)=Off(a)+1;

    Monday_B=Off3;                       /* Bridges                               */
    Friday_B=Off5;
    Bridges=Off3+Off5;

    LeapYear=0;                          /* Leap Year regressor                   */
    IF (month=2) THEN DO;
     LeapYear=-0.25;
     IF (MOD(year,4)=0 & MOD(year,100) NE 0) OR MOD(year,400)=0 THEN LeapYear=0.75;
    END; 

    DO i=1 TO 7;                         /* Days in (including Bridges)           */
     in(i)=days(i)-off(i);
    END;

    DO i=1 TO 6;                         /* Usual TD regressors (contrasts)       */
     Tdays(i)=days(i+1)-days(1);
    END;
    WD=SUM(OF day2-day6) - 5*(Day1+Day7)/2;

    PH=SUM(OF Off2-Off6);                /* Public holidays (except Sat. & Sun.)  */
    TD=SUM(OF In2-In6);                  /* Working weekdays (except Sat. & Sun.) */
    WeekDays=TD - 5*(PH+Day1+Day7)/2;    /* Week Day contrast                    */
    OUTPUT;
   END;
  RUN;

  /* Centering: we remove the mean by month from each basic regressor (in order to remove  */
  /* the seasonal part of the Calendar effect).                                            */
  /* And we construct some other regressors.                                               */

  PROC SORT DATA=&out OUT=sorted;
   BY month;
  RUN;
  PROC MEANS DATA=sorted NOPRINT;
   WHERE &startm <= year <= &endm; 
   VAR Day1-Day7 Off1-Off7;
   CLASS month;
   OUTPUT OUT=means MEAN=mean1-mean14; 
  RUN;
  DATA meansbis;
   SET means;
  RUN;
  %LET clean= &clean sorted means;
  
  DATA &out._C;
   MERGE sorted means(FIRSTOBS=2 DROP=_type_ _freq_);
   BY month;
   DROP i mean1-mean14;
   ARRAY all(*) Day1-Day7 Off1-Off7;
   ARRAY meanx(*) mean1-mean14;
   DO i=1 TO DIM(all);
    all(i)=all(i)-meanx(i);
   END;
   ARRAY days(7) Day1-Day7;
   ARRAY off(7)  Off1-Off7;
   ARRAY in(7)   In1-In7;
   ARRAY Tdays(6)  TD1-TD6;
   ARRAY reg(6)  Monday Tuesday Wednesday Thursday Friday Saturday;
   DO i=1 TO 7;                         /* Days in (including Bridges)           */
    in(i)=days(i)-off(i);
   END;
   PH=SUM(OF Off2-Off6);                /* Public holidays (except Sat. & Sun.)  */
   TD=SUM(OF In2-In6);                  /* Working weekdays (except Sat. & Sun.) */
   DO i=1 TO 6;                         /* Day of the week contrasts             */
    reg(i)=in(i+1)-(Day1+PH+Off7);
   END;
   WeekDays=TD - 5*(PH+Day1+Day7)/2;    /* Week Day contrast                     */
   DO i=1 TO 6;                         /* Usual TD regressors (contrasts)       */
    Tdays(i)=days(i+1)-days(1);
   END;
   WD=SUM(OF day2-day6) - 5*(Day1+Day7)/2;

   IF (&start <= year <= &end);
  RUN; 
  PROC SORT DATA=&out._C;
   BY year month;
  RUN;
  DATA &out;
   SET &out;
   IF (&start <= year <= &end);
  RUN;


  /* A few tables and statistics */

  %IF (&stat NE) %THEN %DO;
   %IF (&stat EQ M) %THEN %DO;
    %LET crit=month;
    %LET nb=12;
   %END;
   %ELSE %DO;
    %LET crit=qtr;
    %LET nb=4;
   %END;
   DATA _null_;
    LENGTH list $ 100;
    list=' ';
    DO i=1 TO &nb;
     list=COMPRESS(LEFT(TRIM(list)) || ";&stat" || PUT(i,2.));
    END;
    CALL SYMPUT('varlist',LEFT(TRIM(list)));
   RUN;
   PROC MEANS DATA=&out(KEEP=year &crit NbDays PH Off1-Off7 In1-In7 TD) SUM NOPRINT;
    WHERE &start <= year <= &end; 
    BY year &crit;
    OUTPUT OUT=stat1(DROP= _type_ _freq_) SUM=;
   RUN;
   PROC MEANS DATA=stat1 MEAN NOPRINT;
    CLASS &crit;
    OUTPUT OUT=stat2(DROP=year _type_ _freq_) MEAN=;
   RUN;
   PROC TRANSPOSE DATA=stat2(FIRSTOBS=2) OUT=&out._1 PREFIX=&stat;
   RUN;
   PROC PRINT DATA=&out._1;
    FORMAT &stat.1-&stat.&nb 5.2;
   RUN;
   %LET clean= &clean stat1 stat2;

   %IF (%LENGTH(&word) NE 0) %THEN %DO;
    DATA _null_;
     FILE PRINT;
     SET &out._1;
     ARRAY stat(&nb) &stat.1-&stat.&nb;
     DO i=1 TO &nb;
      stat(i)=ROUND(stat(i),0.01);
     END;
     IF (_label_ = ' ') THEN DO;
      %IF (&stat EQ M) %THEN %DO;
       DO i=1,3 TO 12;
        stat(i)=INT(stat(i));
       END;
      %END;
      %ELSE %DO;
       DO i=2 TO 4;
        stat(i)=INT(stat(i));
       END;
      %END;
     END;
     IF _n_=1 THEN PUT "&varlist";
     PUT _label_ (&stat.1-&stat.&nb)(';');
    RUN;
   %END;
   PROC TRANSPOSE DATA=stat1 OUT=&out._2 PREFIX=&stat;
    VAR TD;
    BY year;
   RUN;
   %IF (%LENGTH(&word) NE 0) %THEN %DO;
    DATA _null_;
     FILE PRINT;
     SET &out._2;
     IF _n_=1 THEN PUT "&varlist";
     PUT year (&stat.1-&stat.&nb)(';' 5.0);
    RUN;
   %END;
  %END;

  %IF (%LENGTH(&debug) EQ 0) %THEN %DO;
   PROC DATASETS LIBRARY=work NOLIST;
    DELETE &clean;
    RUN;
   QUIT;
  %END;

  %finmacro:
%MEND;
/*
options nomprint nocenter ls=250;
*options mprint nocenter notes ls=250;
%Calendar(START=1980,END=2015,OUT=FrenchCalendar,STARTM=1980,ENDM=4779,STAT=q,WORD=,DEBUG=yes);
*/
