/* Lesson 6: functions
   numeric, character, dates, PUT and INPUT conversion, CALL routines */

/* numeric */
data num;
  x = 3.14159;
  r1 = round(x, 0.01);      /* 3.14 */
  r2 = round(1234, 100);    /* 1200 */
  c = ceil(x); f = floor(x); i = int(-3.7);   /* 4, 3, -3 */
  a = abs(-5); s = sqrt(16); l = log(10); e = exp(1);
  m = mod(17, 5);           /* 2 */
  lo = min(4, ., 2);        /* 2  missing ignored */
  n_ok = n(1, ., 3);        /* 2  how many non-missing */
  n_na = nmiss(1, ., 3);    /* 1 */
run;

/* row-wise statistics across variables: the OF list */
data row_stats;
  input id $ v1-v4;
  avg = mean(of v1-v4);
  sd = std(of v1-v4);
  big = max(of v1-v4);
  datalines;
A 1 2 3 4
B 5 . 7 8
;
run;

/* character */
data chr;
  length full $30 first $15 last $15;
  full = '  Grace Akello  Nambi ';
  clean = strip(full);                    /* no leading/trailing blanks */
  single = compbl(full);                  /* repeated blanks -> one */
  up = upcase(full); low = lowcase(full); prop = propcase(strip(full));
  first = scan(full, 1, ' ');             /* Grace */
  last = scan(full, -1, ' ');             /* Nambi: negative counts from the end */
  len = length(strip(full));
  part = substr('STUDY-001', 7, 3);       /* 001 */
  pos = find('STUDY-001', '-');           /* 6 */
  has = index(upcase(full), 'DAVID') > 0;
  swap = tranwrd('Drug A vs Placebo', 'vs', 'versus');
  nodig = compress('S-00-12', '-');       /* S0012 */
  digits = compress('ab12c3', , 'kd');    /* keep digits: 123 */
run;

/* joining text: the CAT family handles blanks for you */
data joined;
  a = 'STUDY'; b = '  001 '; c = 'Kampala';
  j1 = a || '-' || b;           /* keeps the blanks */
  j2 = cats(a, '-', b);         /* STUDY-001 */
  j3 = catx('-', a, b, c);      /* STUDY-001-Kampala */
  j4 = catx(' ', 'n =', 25);    /* numbers are converted for you */
run;

/* dates: a SAS date is the number of days since 1 January 1960 */
data dates;
  d = '16NOV2026'd;                    /* date literal */
  t = today();
  y = year(d); m = month(d); dd = day(d); wd = weekday(d);   /* 1 = Sunday */
  made = mdy(3, 14, 2026);
  age = intck('year', '15JUN1996'd, d, 'c');   /* completed years */
  next_visit = intnx('month', d, 3, 'same');   /* same day, 3 months later */
  days_between = d - made;
  dt = dhms(d, 14, 30, 0);             /* datetime: seconds since 1960 */
  dpart = datepart(dt);
  format d made next_visit dpart t yymmdd10. dt datetime19.;
run;

proc print data=dates noobs; run;

/* conversion: PUT turns a number into text, INPUT turns text into a number.
   Do it on purpose; letting SAS convert gives a NOTE and surprises. */
data convert;
  num_text = put(42, z5.);              /* '00042' */
  money = put(1234.5, dollar10.2);      /* '$1,234.50' */
  date_text = put('16NOV2026'd, yymmdd10.);
  text_num = input('12.7', 8.);         /* 12.7 */
  text_date = input('2026-11-16', yymmdd10.);
  bad = input('n/a', ?? 8.);            /* ?? hides the invalid-data note */
  format text_date date9.;
run;

/* a column read as text that should be a number, keeping its name:
   rename on the way in, convert, drop the old one */
data raw_txt;
  input id $ conc_c $;
  datalines;
A 12.4
B 8.1
C <LOD
;
run;

data typed;
  set raw_txt(rename=(conc_c=conc_txt));
  conc = input(conc_txt, ?? 8.);    /* '<LOD' becomes missing, quietly */
  drop conc_txt;
run;

/* CALL routines */
data calls;
  length a b $10;
  a = 'first'; b = 'second';
  call missing(a);                 /* set to missing */
  x = 5;
  call symputx('five', x);         /* data step value -> macro variable */
  call streaminit(1); r = rand('normal', 0, 1);
run;
%put five = &five;

/* Try it:
   From sashelp.class make subject IDs like CLS-01, CLS-02 ... using _n_,
   PUT and CATS, and a visit date 30 days after 01JAN2026 for everyone. */
