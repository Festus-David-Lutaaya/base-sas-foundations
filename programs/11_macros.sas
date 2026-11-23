/* Lesson 11: the macro facility
   %LET and &var, quoting, automatic macro variables, CALL SYMPUTX,
   %MACRO with parameters, %IF and %DO, macro functions, scope, debugging

   Macros only write text. That text is then read as normal SAS code.
   Keep that in mind and most macro surprises make sense. */

/* macro variables */
%let study = STUDY-001;
%let cutoff = 100;

title "Study &study: students over &cutoff lb";   /* double quotes: resolves */
proc print data=sashelp.class;
  where weight > &cutoff;
run;
title;

/* single quotes do NOT resolve: compare the two titles */
title1 'Single quotes: &study';
title2 "Double quotes: &study";
proc print data=sashelp.class(obs=1); run;
title;

/* a dot ends the name when text follows */
%let yr = 2026;
data class_&yr._clean;       /* class_2026_clean */
  set sashelp.class;
run;

/* automatic macro variables */
%put Today: &sysdate9  SAS: &sysver  OS: &sysscp  Last data set: &syslast;

/* from data to macro variables */
proc means data=sashelp.class noprint;
  var weight;
  output out=wstats mean=mean;
run;

data _null_;
  set wstats;
  call symputx('mean_wt', put(mean, 6.1));
run;
%put Mean weight is &mean_wt;

/* a macro with parameters */
%macro summary(data=, var=, by=);
  proc means data=&data n mean std min max maxdec=1;
    %if %length(&by) > 0 %then %do;
      class &by;
    %end;
    var &var;
  run;
%mend summary;

%summary(data=sashelp.class, var=height weight)
%summary(data=sashelp.class, var=height weight, by=sex)

/* %DO loops write repeated code */
%macro by_year(start=, stop=);
  %do y = &start %to &stop;
    title "Stocks in &y";
    proc means data=sashelp.stocks(where=(year(date) = &y)) mean maxdec=1;
      class stock;
      var close;
    run;
  %end;
  title;
%mend;
%by_year(start=2003, stop=2005)

/* loop over a list of words */
%macro each(list=);
  %local i word;
  %do i = 1 %to %sysfunc(countw(&list));
    %let word = %scan(&list, &i);
    proc freq data=sashelp.heart;
      tables &word / missing;
    run;
  %end;
%mend;
%each(list=status sex smoking_status)

/* macro functions */
%let txt = Hello SAS;
%put %upcase(&txt) %length(&txt) %scan(&txt, 2) %substr(&txt, 1, 5);
%put %eval(5 + 3) %sysevalf(5 / 3) %sysfunc(today(), yymmdd10.);

/* quoting: hide commas, semicolons and so on from the macro processor */
%let label = %str(Age, years);
%put &label;
%let msg = %nrstr(Drug A & B);     /* & not treated as a macro reference */
%put &msg;

/* scope: %LOCAL keeps a macro's variables to itself */
%let i = outside;
%macro scope_demo;
  %local i;
  %let i = inside;
  %put inside the macro: &i;
%mend;
%scope_demo
%put outside the macro: &i;

/* debugging: see the code a macro writes */
options mprint mlogic symbolgen;
%summary(data=sashelp.class, var=age)
options nomprint nomlogic nosymbolgen;

/* list all your macro variables */
%put _user_;

/* Try it:
   Write %freq_by(data=, var=, by=) that runs PROC FREQ of var by the
   by-variable, and only adds a CHISQ option when a parameter test=yes. */
