/* Lesson 9: sorting and restructuring
   PROC SORT (NODUPKEY with DUPOUT, descending, out=),
   PROC TRANSPOSE long to wide and wide to long, PROC RANK */

/* always sort to a new data set while learning, so the original stays */
proc sort data=sashelp.cars out=cars;
  by origin descending msrp;
run;

/* remove duplicate keys, but keep a record of what you removed */
data dups;
  input id $ visit hb;
  datalines;
P01 1 12.8
P01 1 12.8
P01 2 13.1
P02 1 14.0
P02 1 13.9
;
run;

proc sort data=dups out=dedup nodupkey dupout=removed;
  by id visit;
run;
proc print data=removed; run;   /* look before you trust it */

/* NODUPRECS removes only rows identical in every variable */
proc sort data=dups out=dedup2 noduprecs;
  by id visit;
run;

/* long to wide: one row per subject, a column per visit */
data long;
  input id $ visit hb;
  datalines;
P01 1 12.8
P01 2 13.1
P01 3 13.9
P02 1 14.0
P02 3 13.2
;
run;

proc sort data=long; by id visit; run;

proc transpose data=long out=wide(drop=_name_) prefix=visit_;
  by id;
  id visit;
  var hb;
run;
proc print data=wide; run;   /* P02 has no visit_2 -> missing */

/* several variables at once: transpose each and merge, or go via a longer form */
data long2;
  input id $ visit hb wbc;
  datalines;
P01 1 12.8 6.1
P01 2 13.1 5.9
P02 1 14.0 7.2
;
run;

proc transpose data=long2 out=tall;
  by id visit;
  var hb wbc;
run;

data tall;
  set tall;
  length colname $20;
  colname = cats(_name_, '_v', visit);
run;

proc transpose data=tall out=wide2(drop=_name_);
  by id;
  id colname;
  var col1;
run;

/* wide to long */
proc transpose data=wide out=back_long(rename=(col1=hb)) name=visit_name;
  by id;
  var visit_:;
run;

data back_long;
  set back_long;
  visit = input(scan(visit_name, 2, '_'), 8.);
  drop visit_name;
run;

/* the array way from lesson 5 is often clearer for wide to long */

/* PROC RANK: ranks, groups, quartiles */
proc rank data=sashelp.class out=ranked descending ties=low;
  var weight;
  ranks weight_rank;
run;

proc rank data=sashelp.heart(keep=cholesterol) out=quart groups=4;
  var cholesterol;
  ranks chol_q;          /* 0,1,2,3 */
run;

/* Try it:
   From sashelp.stocks take Date, Stock and Close for 2005, and make a
   wide data set with one row per date and one column per stock. */
