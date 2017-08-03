ods clear output;

/*Read in data*/

/* 6376 observations */
proc import datafile="C:\Users\ao6bc\Downloads\reservations_(5).csv" 
out=reserves dbms=csv; 
getnames=yes; 
run;

/* 1000 observations */
proc import datafile="C:\Users\ao6bc\Downloads\vehicles_(6).csv" 
out=vehicles dbms=csv; 
getnames=yes; 
run;

proc contents data = vehicles;
run;

proc print data = vehicles;
run;

/* Creates a new variable for a single reserveation (res) and gets sum*/
data resnew;
set reserves;
res = 1;
run;

/* Sort by Vehicle ID */
proc sort data = resnew out = resnew_1;
by vehicle_id;
run;

/* Gets Sum of Reservations per Vehicle ID */
proc sql;
create table res_tot as
select vehicle_id, sum(res) as restot
from resnew_1
group by vehicle_id
order by vehicle_id;
quit;

/* Creates Sequence from 1 to 1000 */
data test1;
do seq=1 to 1000;
output;
end;
run;

/* Merge two data sets together */
proc sql;
create table res_final as
select

vehicle_id,
seq,
restot

from res_tot
right join test1 on seq = vehicle_id;
quit;

/* Deals with missing Vehicle ID and Total Reservations */
data res_merge;
set res_final;
drop vehicle_id;
if restot = . then restot = 0;
run;

proc print data = res_merge; 
run;

proc contents data = res_merge; 
run;

/* Merge two data sets together for modeling */
proc sql;
create table res_model as
select

technology,
recommended_price, 
actual_price, 
num_images, 
street_parked, 
description, 
restot

from vehicles
left join res_merge on seq = vehicle_id;
quit;

proc print data = res_model;
run;

proc contents data = res_model;
run;

/* Export data */
proc export data = res_model
   outfile = "C:\Users\ao6bc\Desktop\res_model.csv"
   dbms=csv;
run;
