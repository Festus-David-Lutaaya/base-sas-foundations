/* Lesson 1: how a SAS program is built, libraries and data sets
   steps and step boundaries, syntax rules, LIBNAME, two-level names,
   WORK, PROC CONTENTS, dictionary tables

   A program is a list of steps. Each step is a DATA step or a PROC step,
   and it ends at RUN; or QUIT; (or when the next step starts).

     raw data --DATA step--> SAS data set --PROC step--> report or new data set */

/* the rules
   - every statement ends with a semicolon
   - not case sensitive (except values inside quotes)
   - free format: spacing and line breaks do not matter
   - comments: block style like this one, or  * statement style ;
   - names: up to 32 characters, letter or underscore first */

* this is also a comment, it ends at the semicolon;

/* global statements work outside steps and stay in force */
options nodate nonumber msglevel=i;
title 'Lesson 1';

/* a DATA step makes a data set */
data work.people;
  input name $ age;
  datalines;
Amina 30
Brian 28
Grace 27
;
run;

/* a PROC step does something with it */
proc print data=work.people;
run;

/* librefs point at folders. WORK is temporary: emptied when SAS closes */
libname proj "&root/data";   /* &root comes from 00_setup.sas */

data proj.people;            /* two-level name: libref.dataset  -> permanent */
  set work.people;
run;

/* one-level names mean WORK */
data people2;                /* same as work.people2 */
  set proj.people;
run;

/* libraries that are always there
   WORK     temporary
   SASHELP  example data and SAS metadata
   SASUSER  your profile, templates */

/* what is in a data set: variables, types, lengths, formats, labels */
proc contents data=sashelp.class;
run;

proc contents data=sashelp.class varnum short;   /* names in column order */
run;

/* everything in a library */
proc contents data=sashelp._all_ nods;
run;

/* the dictionary tables describe every library, table and column.
   Useful for code that adapts itself to the data. */
proc sql;
  select memname, nobs, nvar
  from dictionary.tables
  where libname = 'SASHELP' and memname in ('CLASS', 'CARS', 'HEART');

  select name, type, length, format, label
  from dictionary.columns
  where libname = 'SASHELP' and memname = 'HEART';
quit;

/* the same views as data sets: sashelp.vtable, sashelp.vcolumn */
proc print data=sashelp.vcolumn(where=(libname='SASHELP' and memname='CLASS')) noobs;
  var name type length;
run;

/* only two data types: numeric (8 bytes, holds dates too) and character */

title;

/* Try it:
   1. Make a library called mine pointing at a folder of your own.
   2. Copy sashelp.cars into it and run PROC CONTENTS on the copy.
   3. Use dictionary.columns to list only its character variables. */
