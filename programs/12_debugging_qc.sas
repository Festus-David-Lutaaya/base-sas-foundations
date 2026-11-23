/* Lesson 12: debugging, the log, and checking your work
   reading the log, dangerous NOTEs, PUTLOG, limiting rows,
   PROC COMPARE for double programming, the common pitfalls

   Read the log in this order: ERROR, then WARNING, then NOTE.
   Some NOTEs are bugs in disguise:
     Missing values were generated            arithmetic hit a missing value
     Invalid data for X in line               text in a numeric field
     Character values have been converted     use INPUT() yourself
     Numeric values have been converted       use PUT() yourself
     WORK.X has 0 observations                a filter or merge removed everything
     MERGE ... repeats of BY values           many-to-many merge, result is wrong
     Variable X is uninitialized              usually a typo
     The query requires remerging             SQL mixed a summary with rows */

/* each of these produces one of those NOTEs. Run them and read the log. */
data note_missing;
  set sashelp.heart(obs=20);
  ratio = cholesterol / diastolic;
run;

data note_convert;
  x = '12';
  y = x * 2;            /* character converted to numeric */
run;

data note_uninit;
  set sashelp.class;
  bmi = 703 * wieght / height**2;   /* typo */
run;

/* PUTLOG: write to the log from inside the DATA step.
   Starting with WARNING: or ERROR: colours it and makes it easy to find */
data check;
  set sashelp.heart;
  if not missing(systolic) and systolic > 250 then
    putlog 'WARNING: implausible systolic ' _n_= systolic=;
  if _n_ <= 2 then putlog _all_;
run;

/* work on a few rows while developing.
   Prefer the data set option: it only affects that step.
   options obs=100; affects everything until you set obs=max. */
data dev;
  set sashelp.heart(obs=100);
run;

/* check syntax without running anything */
/* options obs=0 noreplace;  ...code...  options obs=max replace; */

/* quick validation after every derivation */
proc means data=sashelp.heart n nmiss min max;
  var ageatstart cholesterol systolic;
run;

proc freq data=sashelp.heart nlevels;
  tables sex status / missing;
run;

/* PROC COMPARE: the tool for double programming QC.
   A second programmer makes the same data set independently,
   then COMPARE should report no differences. */
data prod;
  set sashelp.class;
  bmi = round(703 * weight / height**2, 0.1);
run;

data qc;
  set sashelp.class;
  bmi = round(weight / (height * 0.0254)**2 * 0.4536, 0.1);   /* metric version */
run;

/* 703 is a rounded conversion factor, so expect a few BMIs to differ
   by 0.1. That is exactly the kind of thing QC is meant to find. */
proc compare base=prod compare=qc listall criterion=0.001 method=absolute;
  id name;
run;

/* the macro variable &sysinfo is 0 when the data sets match */
%put COMPARE result: &sysinfo;

/* pitfalls worth remembering
   1  character length is fixed by first use: set LENGTH first
   2  missing is smaller than any number: if x < 5 catches missing
   3  one OUTPUT statement turns off the automatic one
   4  many-to-many MERGE is silently wrong: use SQL
   5  same-named variables in MERGE: the right one wins
   6  NODUPKEY without DUPOUT= loses rows without a trace
   7  options obs= left on: later runs use only part of the data
   8  LAG inside IF skips rows
   9  '&var' in single quotes does not resolve
   10 a format does not round the value, ROUND() does
   11 missing RUN; or QUIT; lets the next step run into this one
   12 two-digit years: read four-digit years with yymmdd10. or date9.
   13 PROC IMPORT type guessing: use guessingrows=max and check CONTENTS
   14 _N_ counts iterations, not output rows
   15 TITLE, WHERE, OPTIONS and ODS settings stay on until you change them */

/* Try it:
   Make a QC copy of work.adsl's BMI (00_setup.sas) yourself from weight
   and height, and PROC COMPARE it against the original. */
