/* Lesson 10: PROC SQL
   select, where, group by, having, CALCULATED, joins, re-merging,
   set operators, subqueries, INTO macro variables, DATA step vs SQL

   PROC SQL runs each statement as you submit it; end with QUIT; */

proc sql;
  select name, age, height
  from sashelp.class
  where age > 14
  order by height desc;
quit;

/* new columns, formats and labels in the select */
proc sql outobs=10;
  select make, model,
         msrp format=dollar10. label='Price',
         msrp / horsepower as price_per_hp format=8.2
  from sashelp.cars
  order by calculated price_per_hp;     /* CALCULATED: refer to a new column */
quit;

/* summarise */
proc sql;
  create table by_origin as
  select origin,
         count(*)             as n,
         mean(msrp)           as mean_msrp format=dollar10.,
         std(msrp)            as sd_msrp   format=dollar10.,
         sum(type = 'SUV')    as n_suv            /* conditions count as 1/0 */
  from sashelp.cars
  group by origin
  having count(*) > 100
  order by mean_msrp desc;
quit;

/* re-merging: mixing a summary with row-level columns.
   SAS allows it and writes a NOTE about remerging. Check that you meant it. */
proc sql;
  select name, weight, mean(weight) as class_mean format=6.1,
         weight - mean(weight) as diff format=6.1
  from sashelp.class;
quit;

/* joins */
data demog; input id $ sex $ age; datalines;
P01 F 34
P02 M 41
P03 F 29
;
run;
data labs; input id $ hb; datalines;
P01 12.8
P01 13.1
P03 11.2
P09 10.0
;
run;

proc sql;
  title 'inner join';
  select d.id, d.sex, l.hb
  from demog as d inner join labs as l on d.id = l.id;

  title 'left join';
  select d.id, d.sex, l.hb
  from demog as d left join labs as l on d.id = l.id;

  title 'full join, key from whichever side has it';
  select coalesce(d.id, l.id) as id, d.sex, l.hb
  from demog as d full join labs as l on d.id = l.id;
quit;
title;

/* set operators: union, union all, except, intersect */
proc sql;
  select id from demog
  except
  select id from labs;          /* subjects with no labs */
quit;

/* subqueries */
proc sql;
  select name, weight
  from sashelp.class
  where weight > (select mean(weight) from sashelp.class);

  select * from demog
  where id in (select id from labs where hb < 12);
quit;

/* results into macro variables */
proc sql noprint;
  select count(*) into :n_class trimmed from sashelp.class;
  select mean(weight) format=6.1 into :mean_wt trimmed from sashelp.class;
  select distinct origin into :origins separated by ', ' from sashelp.cars;
  select name into :name1- from sashelp.class where age = 16;
quit;
%put &=n_class &=mean_wt &=origins;
%put &=sqlobs first=&name1;

/* when to use which
   SQL:        joins on keys that are not sorted, many-to-many, summaries
               with group by, quick look-ups into macro variables
   DATA step:  row logic, RETAIN and FIRST./LAST., arrays, several
               outputs in one pass, reading raw files */

/* Try it:
   With work.adsl and work.adae (00_setup.sas), list per arm the number
   of subjects and the number with at least one serious AE, in one query. */
