/* Lesson 7: combining data sets
   concatenating, interleaving, PROC APPEND, match-merging with IN=,
   one-to-many, the many-to-many trap, UPDATE */

data demog;
  input id $ sex $ age;
  datalines;
P01 F 34
P02 M 41
P03 F 29
P04 M 52
;
run;

data labs;
  input id $ visit hb;
  datalines;
P01 1 12.8
P01 2 13.1
P02 1 14.0
P03 1 11.2
P03 2 11.9
P05 1 13.5
;
run;

/* concatenate: rows of the second under the first */
data site_a; input id $ hb; datalines;
A1 12
A2 13
;
run;
data site_b; input id $ hb; datalines;
B1 14
;
run;

data both;
  set site_a site_b;
run;

/* with lengths that differ, set LENGTH first or values get cut */
data both2;
  length id $10;
  set site_a(in=a) site_b;
  site = ifc(a, 'A', 'B');
run;

/* interleave: SET with BY keeps the result sorted */
proc sort data=site_a; by id; run;
proc sort data=site_b; by id; run;
data inter;
  set site_a site_b;
  by id;
run;

/* PROC APPEND adds to the end without reading the base data set again */
proc append base=both data=site_b;
run;

/* match-merge: both sorted by the key */
proc sort data=demog; by id; run;
proc sort data=labs;  by id; run;

data merged;
  merge demog(in=d) labs(in=l);
  by id;
run;
proc print data=merged; run;   /* P04 has no labs, P05 has no demog */

/* IN= flags give you the type of join */
data inner;      merge demog(in=d) labs(in=l); by id; if d and l; run;
data left;       merge demog(in=d) labs(in=l); by id; if d;       run;
data no_labs;    merge demog(in=d) labs(in=l); by id; if d and not l; run;
data orphan_lab; merge demog(in=d) labs(in=l); by id; if l and not d; run;

/* same variable name in both: the one on the right wins. RENAME to keep both */
data a; input id $ value; datalines;
X 1
;
run;
data b; input id $ value; datalines;
X 2
;
run;
data ab;
  merge a b(rename=(value=value_b));
  by id;
run;
/* options msglevel=i (set in 00_setup) puts a note in the log when
   a merge overwrites a variable */

/* many-to-many: MERGE does NOT give all combinations.
   The log says "MERGE statement has more than one data set with repeats
   of BY values". Use PROC SQL instead. */
data m1; input id $ x; datalines;
K 1
K 2
;
run;
data m2; input id $ y; datalines;
K 10
K 20
;
run;

data mm_merge;  merge m1 m2; by id; run;       /* 2 rows: wrong */

proc sql;
  create table mm_sql as                         /* 4 rows: every pair */
  select m1.id, x, y from m1, m2 where m1.id = m2.id;
quit;

/* UPDATE: apply corrections from a transaction data set.
   Missing values in the transaction do not overwrite. */
data master; input id $ age weight; datalines;
P01 34 60
P02 41 72
;
run;
data fixes; input id $ age weight; datalines;
P02 . 75
;
run;
data master2;
  update master fixes;
  by id;
run;

/* Try it:
   Merge work.adsl and a count of AEs per subject from work.adae
   (from 00_setup.sas) so every subject has n_ae, with 0 when they had none. */
