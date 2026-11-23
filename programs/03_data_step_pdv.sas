/* Lesson 3: how the DATA step really works
   compile and execute phases, the PDV, the implicit loop,
   automatic variables, OUTPUT, KEEP/DROP/RENAME, data set options

   The DATA step works one row at a time. You write the logic for a
   single observation and the implicit loop applies it to all of them.
   (In R you think in whole columns; in SAS you think in one row.)

   Each iteration:
     1. set new variables to missing (not ones read by SET, or RETAINed)
     2. read one observation into the PDV
     3. run your statements top to bottom
     4. implicit OUTPUT: write the PDV to the data set
     5. back to 1, until SET runs out of rows */

/* watch the loop with PUTLOG */
data demo;
  set sashelp.class(obs=3);
  putlog 'Before: ' _n_= name= bmi=;
  bmi = 703 * weight / height**2;
  putlog 'After:  ' _n_= name= bmi=;
run;

/* _N_ counts iterations, _ERROR_ flags data errors on this row */
data first3;
  set sashelp.class;
  if _n_ <= 3;
run;

/* attributes are fixed by the FIRST time SAS sees a variable.
   Here group gets length 5 from 'Child', so 'Teenager' is cut to 'Teena' */
data wrong;
  set sashelp.class;
  if age < 13 then group = 'Child';
  else group = 'Teenager';
run;

proc freq data=wrong; tables group; run;

/* fix: declare LENGTH before first use */
data right;
  length group $8;
  set sashelp.class;
  if age < 13 then group = 'Child';
  else group = 'Teenager';
run;

proc freq data=right; tables group; run;

/* explicit OUTPUT: write when you say. One OUTPUT anywhere turns off the
   automatic one, so every row you want written needs an OUTPUT */
data girls boys;
  set sashelp.class;
  if sex = 'F' then output girls;
  else output boys;
run;

/* one input row -> several output rows */
data long;
  set sashelp.class(keep=name height weight);
  length measure $6;
  measure = 'height'; value = height; output;
  measure = 'weight'; value = weight; output;
  keep name measure value;
run;

/* KEEP / DROP / RENAME as statements act on the output */
data slim;
  set sashelp.class;
  bmi = 703 * weight / height**2;
  drop height weight;
  rename name = student;
run;

/* as data set options they act where you put them.
   On the input side they save reading columns you never use. */
data slim2(rename=(name=student));
  set sashelp.class(keep=name age where=(age > 13));
run;

/* other useful data set options
   obs= firstobs=  limit rows (scoped to that one data set)
   in=             flag which input a row came from (lesson 7)
   label=          label the data set */
data cars_small(label='First 20 cars');
  set sashelp.cars(firstobs=1 obs=20);
run;

/* STOP and END= */
data last_row;
  set sashelp.class end=eof;
  if eof then output;
run;

/* DELETE drops the current row and returns to the top */
data no_twelve;
  set sashelp.class;
  if age = 12 then delete;
run;

/* Try it:
   From sashelp.cars make two data sets in one step: cheap (msrp < 20000)
   and expensive (msrp > 60000), keeping only make, model and msrp.
   Use PUTLOG to write the make of every expensive car to the log. */
