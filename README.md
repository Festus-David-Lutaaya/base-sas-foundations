# Base SAS foundations

Lesson programs covering the core of Base SAS: how the DATA step works,
reading and combining data, functions, SQL, macros and debugging.

Next step after this: [sas-tables](https://github.com/Festus-David-Lutaaya/sas-tables),
which builds publication and clinical tables with PROC REPORT and ODS.

## Lessons

| # | Program | What you learn |
|---|---------|----------------|
| 00 | `00_setup.sas` | paths, options, small simulated trial data |
| 01 | `01_program_structure_libraries.sas` | steps, syntax rules, LIBNAME, WORK, CONTENTS, dictionary tables |
| 02 | `02_reading_data.sas` | DATALINES, INFILE/INPUT styles, PROC IMPORT/EXPORT |
| 03 | `03_data_step_pdv.sas` | the PDV and implicit loop, _N_, OUTPUT, KEEP/DROP/RENAME |
| 04 | `04_variables_logic.sas` | LENGTH, the missing-value trap, RETAIN, IF/SELECT, WHERE vs IF |
| 05 | `05_loops_arrays.sas` | DO loops, arrays, LAG and DIF |
| 06 | `06_functions.sas` | numeric, character and date functions, PUT/INPUT |
| 07 | `07_combining_data.sas` | SET, MERGE with IN=, many-to-many, UPDATE |
| 08 | `08_by_group_processing.sas` | FIRST./LAST., change from baseline, NOTSORTED |
| 09 | `09_restructuring_sorting.sas` | NODUPKEY + DUPOUT, PROC TRANSPOSE, PROC RANK |
| 10 | `10_proc_sql.sas` | joins, re-merging, set operators, subqueries, INTO |
| 11 | `11_macros.sas` | macro variables, quoting, %MACRO, %DO, scope, MPRINT |
| 12 | `12_debugging_qc.sas` | reading the log, PUTLOG, PROC COMPARE, common pitfalls |

The order goes from how SAS reads a program, to how the DATA step
processes one row at a time, to the tools built on top of that.
Lesson 12 collects the mistakes that cause most silent errors.

## Coming from R

| R | SAS |
|---|---|
| data frame / tibble | SAS data set |
| `filter()` | WHERE or subsetting IF |
| `select()` | KEEP= / DROP= |
| `mutate()` | assignment in a DATA step |
| `group_by() |> summarise()` | PROC MEANS with CLASS, or PROC SQL |
| `left_join()` | MERGE with IN=, or PROC SQL |
| `pivot_wider()` / `pivot_longer()` | PROC TRANSPOSE |
| `arrange()` | PROC SORT |
| `NA` | `.` for numbers, blank for text |
| factor | a variable plus a user format |

R works on whole columns at once. The DATA step works on one row at a
time: you write the logic for a single observation and SAS loops it over
the data.

## How to use

1. Put this folder where SAS can see it (on SAS OnDemand for Academics,
   upload it to your home folder).
2. Open `programs/00_setup.sas`, change `%let root =` to that folder and run it.
3. Work through the lessons in order, reading the log after each step.
   Re-run `00_setup.sas` in every new session.

Each program ends with a short "Try it" exercise.
