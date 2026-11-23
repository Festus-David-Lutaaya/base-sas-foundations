/* Lesson 8: BY-group processing
   FIRST. and LAST., counting and totals per group, first/last record,
   change from baseline, NOTSORTED, GROUPFORMAT

   With a BY statement SAS creates two temporary flags per BY variable:
   first.var = 1 on the first row of a group, last.var = 1 on the last. */

data visits;
  input id $ visit hb;
  datalines;
P01 0 12.8
P01 1 13.1
P01 2 13.9
P02 0 14.0
P02 1 13.2
P03 0 11.2
P03 1 11.9
P03 2 12.5
P03 3 12.7
;
run;

proc sort data=visits; by id visit; run;

/* see the flags */
data show;
  set visits;
  by id;
  f = first.id;
  l = last.id;
run;
proc print data=show; run;

/* count rows per subject */
data counts;
  set visits;
  by id;
  if first.id then n = 0;
  n + 1;
  if last.id then output;
  keep id n;
run;

/* total and mean per subject */
data per_subj;
  set visits;
  by id;
  if first.id then do; total = 0; k = 0; end;
  total + hb;
  k + 1;
  if last.id then do;
    mean_hb = total / k;
    output;
  end;
  keep id k mean_hb;
run;

/* first and last record per subject */
data baseline;  set visits; by id; if first.id; run;
data last_obs;  set visits; by id; if last.id;  run;

/* change from baseline: retain the baseline value across the group */
data chg;
  set visits;
  by id;
  retain base;
  if first.id then base = hb;
  chg = hb - base;
  pchg = 100 * chg / base;
run;

/* number each row within its group */
data numbered;
  set visits;
  by id;
  if first.id then seq = 0;
  seq + 1;
run;

/* two BY variables: first.visit resets inside each id too */
proc sort data=sashelp.cars out=cars; by origin type; run;
data type_counts;
  set cars;
  by origin type;
  if first.type then n = 0;
  n + 1;
  if last.type then output;
  keep origin type n;
run;

/* NOTSORTED: groups are consecutive runs of the same value, in data order */
data runs;
  input day weather $;
  datalines;
1 dry
2 dry
3 wet
4 wet
5 dry
;
run;

data spells;
  set runs;
  by weather notsorted;
  if first.weather then start = day;
  retain start;
  if last.weather then do;
    length_days = day - start + 1;
    output;
  end;
run;

/* GROUPFORMAT: group by the formatted value */
proc format;
  value agegrp low-12 = 'Under 13' 13-high = '13+';
run;
proc sort data=sashelp.class out=class; by age; run;
data age_groups;
  set class;
  by age groupformat;
  format age agegrp.;
  if first.age then n = 0;
  n + 1;
  if last.age then output;
  keep age n;
run;

/* Try it:
   From work.adae (00_setup.sas), keep one row per subject with their
   worst severity (aesevn). Sort by usubjid and aesevn, then use last.usubjid. */
