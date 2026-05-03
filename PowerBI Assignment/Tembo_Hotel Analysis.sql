create schema Tembo_hotel;
set search_path to tembo_hotel;

create table Staging_bookings(
booking_id text,
guest_name text,
guest_phone text,
guest_city text,
guest_nationality text,
room_no text,
room_type text,
room_rate_per_night text,
check_in_date text,
check_out_date text,
nights_stayed text,
staff_name text,
staff_department text,
staff_salary text,
payment_method text,
booking_status text,
total_amount text,
service_used text,
service_price text,
guest_rating text
);

select * from staging_bookings;
create table cleaning_bookings as
select * from staging_bookings;

--=======================================DATA CLEANING FOR  COLUMNS WITH STRNG DATA================================= 
--Guest Name
-- 1a. Correcting inconsistencies capitalising the first letters of each name
update cleaning_bookings
set guest_name = initcap(guest_name)
where guest_name != initcap(guest_name);
 
--	 Removning leading and trailing spaces in the names
update cleaning_bookings
set guest_name = trim(guest_name)
where guest_name != trim(guest_name);

--Guest City
--	 Removing leading and trailing spaces in the city names
update cleaning_bookings
set guest_city = trim(guest_city)
where guest_city != trim(guest_city);

--  Correcting inconsistencies capitalising the first letters of each city
update cleaning_bookings
set guest_city = initcap(guest_city)
where guest_city != initcap(guest_city);
 
--  Correcting spellings the city names/labels
UPDATE cleaning_bookings
SET guest_city = 'Thika'
WHERE guest_city = 'Thikax';
 
-- Filling blank cities with unknown
UPDATE cleaning_bookings
SET guest_city = 'Unknown'
WHERE guest_city = '';

--Guest Nationality 
--  Standardising the format of Nationality and proper case
update cleaning_bookings
set guest_nationality = 'Kenyan'
where guest_nationality = 'KENYAN';
 
--Room Type
--  Standardizing the different Room_types
update cleaning_bookings
set room_type = initcap(room_type)
where room_type!= initcap(room_type);
 
-- Correcting the spelling from Dlx to Deluxe
update cleaning_bookings
set room_type = 'Deluxe'
where room_type = 'Dlx';
 
-- Correcting the spelling from Std to Standard
update cleaning_bookings
set room_type = 'Standard'
where room_type = 'Std';

--Staff Name
--	Trimming from staff_name
update cleaning_bookings
set staff_name = trim(staff_name)
where staff_name like ' %' or staff_name like '% ';

--Staff Department
--	Department Name - Trimming department name
update cleaning_bookings
set staff_department = trim(staff_department)
where staff_department like ' %' or staff_department like '% ';

--Payment_method
--	Trimming payment_method
update cleaning_bookings
set payment_method = trim(payment_method)
where payment_method like ' %' or payment_method like '% ';

--	Changing payment method from mpesa to M-pesa
update cleaning_bookings
set payment_method = 'M-pesa'
where payment_method = 'mpesa';

--Booking Status
--Transforming to proper case 
update cleaning_bookings
set booking_status = initcap(booking_status)
where booking_status!= initcap(booking_status);

--removing leading and trailing spaces
update cleaning_bookings
set booking_status = trim(booking_status)
where booking_status!= trim(booking_status);

--Service_Used
--	Service used removing leading and trailing spaces & Replacing blank values with unknown
update cleaning_bookings
set service_used = trim(service_used)
where service_used!= trim(service_used);

UPDATE cleaning_bookings
SET service_used = 'Unknown'
WHERE service_used = '';

--=======================================DATA CLEANING FOR  COLUMNS WITH NUMERIC DATA=============================== 
--Phone Number
--	Removing leading spaces and +
UPDATE cleaning_bookings 
SET guest_phone = REPLACE(guest_phone, '+', '') 
WHERE guest_phone LIKE '+%';

--	Replacing the 254 with a 0
update cleaning_bookings
set guest_phone = '0' || right(guest_phone, 9)
where guest_phone like '254%';

--Removing the dashes, and filling in blanks with unknown
select * from cleaning_bookings;
select check_in_date
from cleaning_bookings
group by check_in_date;

update cleaning_bookings
set guest_phone = replace(guest_phone, '-', '');

update cleaning_bookings
set guest_phone = 'unknown'
where guest_phone  = '';

--Check_in_Date 
-- 	Query output date in yyyy-mm-dd
select check_in_date, to_date(check_in_date, 'YYY-MM-DD')
from cleaning_bookings
where check_in_date like '%-%';
limit 20;

--Query to remove / and replace with -
update cleaning_bookings
set check_in_date = to_date(check_in_date, 'DD-MM-YYYY')::text
where check_in_date like '%/%';

--Query to replace short dates with full dates

update cleaning_bookings
set check_in_date = to_date(check_in_date, 'DD-MM-YY')::text
where check_in_date like '%-%' and length (check_in_date) = 8;

update cleaning_bookings
set check_in_date = to_date(check_in_date, 'MM-DD-YYYY')::text
where check_in_date like '%-%' and length (check_in_date) = 10 and split_part (check_in_date,'-',1)::integer <=12;

update cleaning_bookings
set check_in_date = to_char(to_date(check_in_date, 'dd-mm-yyyy'), 'yyyy-mm-dd')
where check_in_date like '__-__-____';
select * from cleaning_bookings;

--Check_out date

update cleaning_bookings
set check_out_date = to_date(check_out_date, 'DD-MM-YYYY')::text
where check_out_date like '%/%';

update cleaning_bookings
set check_out_date = to_char(to_date(check_out_date, 'dd-mm-yyyy'), 'yyyy-mm-dd')
where check_out_date like '__-__-____';

update cleaning_bookings
set check_out_date = to_date(check_out_date, 'DD-MM-YY')::text
where check_out_date like '%-%' and length (check_out_date) = 8;

update cleaning_bookings
set check_out_date = to_date(check_out_date, 'MM-DD-YYYY')::text
where check_out_date like '%-%' and length (check_out_date) = 10 and split_part (check_out_date,'-',1)::integer <=12;

--Staff Salary
update cleaning_bookings
set staff_salary = 'Unknown'
where staff_salary = 'KES ,';

update cleaning_bookings
set staff_salary = null
where staff_salary = 'Unknown' or staff_salary = 'Null';
 
update cleaning_bookings
set staff_salary = trim(staff_salary)
where staff_salary != trim(staff_salary);

--Total_Amount
update cleaning_bookings
set total_amount = replace(total_amount, 'KES ', '')
where total_amount like 'KES %';
 
update cleaning_bookings
set total_amount = 'Unknown'
where total_amount = ',' or total_amount = '';

update cleaning_bookings
set total_amount = null
where total_amount = 'Unknown';

update cleaning_bookings
set total_amount = trim(total_amount)
where total_amount != trim(total_amount);
 
update cleaning_bookings
set total_amount = replace(total_amount, ',', '')
where total_amount like '%,%' ;
select * from cleaning_bookings;

--Service Price
update cleaning_bookings
set service_price = trim(service_price)
where service_price != trim(service_price);
 
update cleaning_bookings
set service_price = 'Unknown'
where service_price = '';
 
update cleaning_bookings
set service_price = null
where service_price = 'Unknown';

-- Guest Rating
update cleaning_bookings
set guest_rating = trim(guest_rating)
where guest_rating != trim(guest_rating);

update cleaning_bookings
set guest_rating= null
where guest_rating = '';

--==========================================REMOVING DUPLICATED ENTRIES============================================ 

delete from cleaning_bookings
where ctid in (select ctid (from (
    select ctid,row_number() over (partition by booking_id order by booking_id) as rn
    from cleaning_bookings)
  where rn > 1);

--============================================CHANGING DATA TYPES================================================== 

alter table cleaning_bookings add primary key (booking_id);
alter table cleaning_bookings
alter column guest_name type varchar(100) using guest_name :: varchar(100);
alter table cleaning_bookings
alter column guest_phone type varchar (10) using guest_phone::varchar (10); 
alter table cleaning_bookings
alter column guest_city type varchar (20) using guest_city::varchar (20);
alter table cleaning_bookings
alter column guest_nationality type varchar (20) using guest_nationality::varchar (20);
alter table cleaning_bookings
alter column room_no type varchar (5) using room_no::varchar (5);
alter table cleaning_bookings
alter column room_type type varchar (20) using room_type::varchar (20);
alter table cleaning_bookings
alter column room_rate_per_night type decimal using room_rate_per_night::decimal;
alter table cleaning_bookings
alter column check_in_date type date using check_in_date::date;
alter table cleaning_bookings
alter column check_out_date type date using check_out_date::date;
alter table cleaning_bookings
alter column nights_stayed type int using nights_stayed::int;
alter table cleaning_bookings
alter column staff_name type varchar (100) using staff_name::varchar (100); 
alter table cleaning_bookings
alter column staff_department type varchar (50) using staff_department::varchar (50);
alter table cleaning_bookings
alter column staff_salary type decimal using staff_salary::decimal;
alter table cleaning_bookings
alter column payment_method type varchar (50) using payment_method::varchar (50);
alter table cleaning_bookings
alter column booking_status type varchar (50) using booking_status::varchar (50); 
alter table cleaning_bookings
alter column total_amount type decimal using total_amount::decimal;
alter table cleaning_bookings
alter column service_used type varchar (50) using service_used::varchar (50);
alter table cleaning_bookings
alter column service_price type decimal using service_price::decimal; 
alter table cleaning_bookings
alter column guest_rating type int using guest_rating::int;

--Final Cleaned Booking
create table version1_clean_bookings as
select *
from cleaning_bookings;
select* from cleaning_bookings;

--==========================================DATA ANALYSIS QUERIES================================================== 
select * from  version1_clean_bookings;

--Revenue analysis:
 
--	Total revenue by month
select date_part('month',check_out_date)::text as month,
date_part('year',check_out_date)::text as year,
sum(total_amount) as Total_revenue
from version1_clean_bookings
group by month,year
order by year,month;

--	Total revenue by room type
select room_type, sum(total_amount) as total_revenue
from  version1_clean_bookings
group by room_type
order by total_revenue desc;

--	Total revenue by payment method
select  payment_method, sum(total_amount) as Revenue_by_Method
from version1_clean_bookings
group by payment_method
order by Revenue_by_Method desc;

--Occupancy 

---	Room_types Booked the most 
select room_type,count(Booking_id) as bookingcount
from version1_clean_bookings
group by room_type;

---Alternative (showing in desc)
with Bookings as 
(select room_type,count(Booking_id) as bookingcount
from version1_clean_bookings
group by room_type)
select room_type,bookingcount from bookings order by bookingcount desc;

--	Average nights stayed per room type
select room_type,round(AVG(nights_stayed),0) as avg_nightsstayed_per_roomtype
from version1_clean_bookings
group by room_type;

--Guest insights:
  
--	Top 10 cities where guests come from 
select guest_city,count(booking_id) as count_by_city
from version1_clean_bookings
group by guest_city 
order by count_by_city desc
limit 10;

--	Average rating per room type
select room_type, round(avg(guest_rating),2) as avg_rating
from version1_clean_bookings
group by room_type;

--Staff performance:
 
--	Which staff handled the most bookings? 
select * from (
select staff_name,count(booking_id) as number_of_bookings, 
dense_rank() over(order by count(booking_id)desc) as Rank
from version1_clean_bookings
group by staff_name)
where Rank = 1;

--Which department generates most revenue?

--- Using a Subquery
select staff_department, total_revenue from (
select staff_department,sum(total_amount) as total_revenue,
dense_rank()over(order by sum(total_amount)desc) as revenue_per_department
from version1_clean_bookings
group by staff_department)
where revenue_per_department= 1;

--USing a CTE
select staff_department,sum(total_amount) as dept_revenue
from version1_clean_bookings
group by staff_department;

--Trends: 
--	Revenue growth month over month (window function)
select 
date_trunc ('month', check_in_date) as month,
  sum(total_amount) as monthly_revenue,
  lag(sum(total_amount)) over (order by date_trunc('month',check_in_date )
  ) as prev_month_revenue,
round(
    (sum(total_amount) - lag(sum(total_amount)) over (
        order by date_trunc('month', check_in_date))) 
    / lag(sum(total_amount)) over (order by date_trunc('month', check_in_date)
     ) * 100,2
  ) as month_over_month_growth_percentage
from version1_clean_bookings
group by date_trunc('month', check_in_date)
order by month;

----without the percentage comparison
select date_trunc ('month', check_in_date) as month,sum(total_amount) as monthly_revenue,
lag(sum(total_amount)) over (order by date_trunc('month',check_in_date )) 
as prev_month_revenue,
(sum(total_amount) - lag(sum(total_amount)) 
over (order by date_trunc('month', check_in_date))) as month_over_month_growth
from version1_clean_bookings
group by date_trunc('month', check_in_date)
order by month;

---- USING CTE
with monthly_revenue as(
select
date_part('month', check_in_date) as month,
date_part('year', check_in_date)::text as year,
sum(total_amount) as curent_month_revenue
from version1_clean_bookings
group by 1, 2)
select *, lag(curent_month_revenue) over(order by mv.year,mv.month) as previous_month
from monthly_revenue mv;

---	Busiest vs quietest months

with sum_bookings as (
select date_trunc('month', check_in_date) as month,
date_trunc('year', check_in_date)::text as year,
sum(total_amount) as bookings_per_month_total from version1_clean_bookings
group by month, year)
select * from sum_bookings
where bookings_per_month_total = (select max(bookings_per_month_total) from sum_bookings)or bookings_per_month_total = (select min(bookings_per_month_total) from sum_bookings);

--Cancellations  
 --		Cancellation rate per room type.
select booking_status,room_type, count(distinct booking_id)
from version1_clean_bookings
where booking_status= 'Cancelled'
group by booking_status,room_type;

---	Revenue Lost from cancellations and No shows
select booking_status, sum(total_amount) as lost_revenue
from version1_clean_bookings
where booking_status= 'Cancelled' or booking_status= 'No Show'
group by booking_status;
 
select max(nights_stayed)

--	Cancellation rate per room type
select 
    room_type, round(count(case when booking_status = 'Cancelled' then 1 end) * 100.0 / count(*), 2) as cancellation_rate_pct
from version1_clean_bookings
group by room_type;

--==============================================INDEXING=========================================================== 

-- index on checkin_date
create index idx_bookings_checkin
on version1_clean_bookings(check_in_date);
 
-- index on roomtype
create index idx_bookings_room_type
on version1_clean_bookings(room_type);
 
-- index on booking_status
create index idx_bookings_status
on version1_clean_bookings(booking_status);
 
-- index on staff_name
create index idx_bookings_staff
on version1_clean_bookings(staff_name);
 
-- index on guestcity
create index idx_bookings_guest_city
on version1_clean_bookings(guest_city);
select * from version1_clean_bookings;

--=============================================CREATING VIEWS====================================================== 

--At least 4 views created - one per major business area

--Revenue
create view Revenue_by_month as
select date_part('month',check_out_date)::text as month,
date_part('year',check_out_date)::text as year,
sum(total_amount) as Total_revenue
from version1_clean_bookings
group by month,year
order by year,month;

--Occupancy
create view Occupancy_view as
with Bookings as 
(select room_type,count(Booking_id) as bookingcount
from version1_clean_bookings
group by room_type)
select room_type,bookingcount from bookings order by bookingcount desc;

--Staff
create view Revenue_by_Staff_Department_View as
select staff_department,sum(total_amount) as dept_revenue
from version1_clean_bookings
group by staff_department;

--Guest_Cities
create view Top_guest_cities as
select guest_city,count(booking_id) as count_by_city
from version1_clean_bookings
group by guest_city 
order by count_by_city desc
limit 10;
