/* Lesson 5: loops and arrays
   iterative DO, DO WHILE / DO UNTIL, ARRAY, DO OVER, LAG and DIF */

/* a DO loop inside one iteration of the DATA step */
data compound;
  amount = 1000;
  do year = 1 to 5;
    amount = amount * 1.10;
    output;
  end;
run;

/* generating data with no input at all */
data grid;
  do dose = 0 to 40 by 10;
    do rep = 1 to 3;
      output;
    end;
  end;
run;

/* DO WHILE checks at the top, DO UNTIL at the bottom (always runs once) */
data doubling;
  cells = 100; hours = 0;
  do while (cells < 10000);
    cells = cells * 2;
    hours + 4;
  end;
run;

data until;
  x = 50;
  do until (x > 10);
    x = x + 1;      /* runs once even though x > 10 already */
  end;
run;

/* arrays group variables so one loop can treat them all the same */
data scores;
  input id $ q1-q5;
  datalines;
A 3 4 . 5 2
B 1 . . 4 4
C 5 5 5 5 5
;
run;

data scores_clean;
  set scores;
  array q{5} q1-q5;
  do i = 1 to dim(q);
    if missing(q{i}) then q{i} = 0;
  end;
  total = sum(of q1-q5);
  drop i;
run;

/* recode many lab values at once: 999 means "not done" */
data labs;
  input id $ hb wbc plt;
  datalines;
P1 13.1 6.2 250
P2 999 7.0 999
P3 11.8 999 310
;
run;

data labs_clean;
  set labs;
  array lab{*} hb wbc plt;          /* {*}: SAS counts them for you */
  do i = 1 to dim(lab);
    if lab{i} = 999 then lab{i} = .;
  end;
  drop i;
run;

/* two arrays in step: values and their flags */
data labs_flag;
  set labs_clean;
  array v{3} hb wbc plt;
  array lo{3} _temporary_ (11 4 150);   /* temporary: not written out */
  array hi{3} _temporary_ (17 11 400);
  array f{3} $1 hb_f wbc_f plt_f;
  do i = 1 to 3;
    if missing(v{i}) then f{i} = ' ';
    else if v{i} < lo{i} then f{i} = 'L';
    else if v{i} > hi{i} then f{i} = 'H';
    else f{i} = 'N';
  end;
  drop i;
run;

/* wide to long with an array */
data scores_long;
  set scores;
  array q{5} q1-q5;
  do item = 1 to 5;
    score = q{item};
    output;
  end;
  keep id item score;
run;

/* LAG returns the value from the previous time LAG ran.
   Call it on every row, never inside an IF, or the queue skips. */
data sp;
  set sashelp.stocks(where=(stock='IBM'));
  prev_close = lag(close);
  change = dif(close);           /* close - lag(close) */
run;

/* the wrong way, for comparison */
data lag_wrong;
  set sashelp.class;
  if sex = 'F' then prev = lag(name);   /* prev comes from the last girl, not the last row */
run;

/* Try it:
   sashelp.heart has systolic and diastolic. Use an array to set any
   value over 250 to missing for both, and count with a DO loop how many
   values you changed per row. */
