/* Lesson 2: getting data in and out
   DATALINES, INFILE + INPUT (list, column, formatted, modified list),
   PROC IMPORT, SET, PROC EXPORT, ODS / FILE for writing */

/* list input: values separated by blanks, $ marks character */
data samples;
  input id $ site $ conc;
  datalines;
S001 Kampala 12.4
S002 Gulu 8.1
S003 Mbarara .
;
run;

/* character values longer than 8 or with spaces: give a length, use & or dlm */
data sites;
  length site $20;
  infile datalines dlm=',' dsd;
  input id $ site $ region $;
  datalines;
S001,Kampala Central,Central
S002,Gulu City,Northern
S003,"Mbarara, West",Western
;
run;
/* dsd: two commas in a row mean a missing value, and quoted
   values can contain the delimiter */

/* column input: values in fixed columns */
data fixed;
  input id $ 1-4 site $ 6-12 conc 14-17;
  datalines;
S001 Kampala 12.4
S002 Gulu     8.1
;
run;

/* formatted input: read with informats, e.g. dates */
data visits;
  input id $ 1-4 @6 visit yymmdd10. @17 conc 5.1;
  format visit yymmdd10.;
  datalines;
S001 2026-03-14 12.4
S002 2026-03-15  8.1
;
run;

/* modified list input with : for informats on list-style data */
data visits2;
  input id :$4. visit :date9. conc;
  format visit date9.;
  datalines;
S001 14MAR2026 12.4
S002 15MAR2026 8.1
;
run;

/* reading a real file: point INFILE at it */
/* data raw;
     infile "&root/data/samples.csv" dlm=',' dsd firstobs=2 truncover;
     length id $8 site $20;
     input id $ site $ conc visit :yymmdd10.;
     format visit yymmdd10.;
   run; */

/* PROC IMPORT guesses types from the first rows. Tell it to look at all
   of them, then check the result with PROC CONTENTS.
   An ID like 00123 becomes numeric 123 if you are not careful. */
proc export data=sashelp.class outfile="&root/output/class.csv" dbms=csv replace;
run;

proc import datafile="&root/output/class.csv" out=class_in dbms=csv replace;
  guessingrows=max;
  getnames=yes;
run;

proc contents data=class_in varnum; run;

/* Excel */
/* proc import datafile="&root/data/book.xlsx" out=xl dbms=xlsx replace;
     sheet='Sheet1';
   run; */

/* reading an existing SAS data set */
data teens;
  set sashelp.class;
  where age >= 13;
run;

/* writing out: PROC EXPORT for csv / xlsx */
proc export data=teens outfile="&root/output/teens.xlsx" dbms=xlsx replace;
  sheet='teens';
run;

/* or write a text file yourself with FILE + PUT */
data _null_;
  set teens;
  file "&root/output/teens.txt";
  put name $10. age 3. +2 height 5.1;
run;

/* Try it:
   Type five lab results into DATALINES with columns id, sex, test date
   (as 2026-01-31) and haemoglobin, read the date with yymmdd10., and
   export the data set to csv. */
