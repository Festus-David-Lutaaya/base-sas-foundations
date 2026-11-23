/* Lesson 4: variables, missing values and conditional logic
   assignment, LENGTH, operators, the missing-value trap,
   sum statement and RETAIN, IF-THEN-ELSE, DO blocks, SELECT,
   subsetting IF vs WHERE */

/* operators
   arithmetic  + - * / **
   comparison  = ^= > < >= <=   or  eq ne gt lt ge le
   logical     and or not
   membership  in ('A', 'B')
   concatenate ||  (or better, the CAT functions in lesson 6) */

/* missing values: . for numbers, ' ' for characters.
   A missing number is SMALLER than any real number. */
data trap;
  input id $ conc;
  if conc < 5 then flag = 'low';        /* missing gets flagged low too! */
  if not missing(conc) and conc < 5 then flag2 = 'low';
  datalines;
A 3
B .
C 9
;
run;

proc print data=trap; run;

/* arithmetic with missing gives missing; functions skip it */
data sums;
  a = 1; b = .; c = 3;
  plus = a + b + c;        /* .   with a note in the log */
  total = sum(a, b, c);    /* 4 */
  avg = mean(a, b, c);     /* 2 */
run;

/* the sum statement: x + expr  retains x and treats missing as 0 */
data running;
  set sashelp.class;
  total_weight + weight;
  count + 1;
run;

/* RETAIN keeps a value from one iteration to the next */
data carry;
  set sashelp.class;
  retain first_name;
  if _n_ = 1 then first_name = name;
run;

/* IF-THEN-ELSE */
data grouped;
  length bmi_cat $11;
  set sashelp.class;
  bmi = 703 * weight / height**2;
  if missing(bmi) then bmi_cat = 'Missing';
  else if bmi < 18.5 then bmi_cat = 'Underweight';
  else if bmi < 25 then bmi_cat = 'Normal';
  else bmi_cat = 'Overweight';
run;

/* DO blocks run several statements on one condition */
data flagged;
  set sashelp.class;
  if age >= 15 then do;
    senior = 1;
    note = 'check consent';
  end;
  else senior = 0;
run;

/* SELECT reads well when testing one variable for many values */
data regions;
  length region $10;
  set sashelp.cars(keep=make origin);
  select (origin);
    when ('USA') region = 'Americas';
    when ('Europe') region = 'EMEA';
    when ('Asia') region = 'APAC';
    otherwise region = 'Other';
  end;
run;

/* subsetting IF vs WHERE
   WHERE filters before the row enters the PDV: faster, works in PROCs,
   but only sees variables already in the input data.
   Subsetting IF filters after: can use new variables. */
data heavy_where;
  set sashelp.class;
  where weight > 100;
run;

data heavy_bmi;
  set sashelp.class;
  bmi = 703 * weight / height**2;
  if bmi > 20;                  /* bmi does not exist yet for WHERE */
run;

proc print data=sashelp.class;
  where sex = 'F' and age between 12 and 14;
run;

/* WHERE operators SAS adds: between, contains, like, is missing */
proc print data=sashelp.cars noobs;
  where model contains 'Sport' and msrp is not missing;
  var make model msrp;
run;

/* Try it:
   Using sashelp.heart, create bp_cat ('Normal', 'High', 'Missing') from
   systolic (high = 140 or more), making sure missing systolic does not
   land in 'Normal'. Count the categories with PROC FREQ. */
