/* Run this first in every session.
   Change root to wherever you put this folder.
   SAS OnDemand for Academics: something like /home/u12345678/base-sas-foundations */

%let root = D:/SCRIPTS/SAS/base-sas-foundations;
%let out  = &root/output;

/* create output/ and data/ if they are not there; proj = permanent library */
options dlcreatedir;
libname outdir "&out";
libname outdir clear;
libname proj "&root/data";

/* msglevel=i adds notes when a MERGE overwrites a variable, among others */
options nodate nonumber validvarname=v7 nofmterr msglevel=i;

/* small simulated trial (work.adsl, work.adae) used in the exercises of
   lessons 7, 8, 10 and 12 */
%include "&root/macros/clinical_data.sas";

proc contents data=work.adsl varnum; run;
proc print data=work.adsl(obs=5); run;
proc print data=work.adae(obs=5); run;
