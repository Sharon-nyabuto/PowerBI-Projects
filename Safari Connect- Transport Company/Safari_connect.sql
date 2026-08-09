create schema if not exists safari_connect;
set search_path to safari_connect;
-------------------------------------IMPORTING DATA FROM CSV-------------------------------------------------
-------------------------------------------------------------------------------------------------------------

create table staging_safari_connect(
booking_id text,
passenger_name text,
passenger_phone text,
passenger_gender text,
passenger_city text,
route_code text,
route_from text,
route_to text,
vehicle_plate text,
vehicle_type text,
driver_name text,
driver_rating text,
departure_date text,
departure_time text,
seat_class text,
seats_booked text,
fare_per_seat text,
total_fare text,
payment_method text,
booking_status text,
trip_rating text);

select * from staging_safari_connect

--Duplicating the table
create table dirty_safari_data as select * from staging_safari_connect;

select * from dirty_safari_data;

-------------------------------------------DATA CLEANING-----------------------------------------------------
-------------------------------------------------------------------------------------------------------------

--1. Cleaning passenger_name column
-- Trimming and Proper Casing

select passenger_name from dirty_safari_data;
----
----
update dirty_safari_data
set passenger_name = initcap(trim(passenger_name))
where  passenger_name != initcap(trim(passenger_name));

--2. Cleaning Phone Numbers
select passenger_phone from dirty_safari_data;

select regexp_replace(regexp_replace(passenger_phone, '^(\+254|254)', '0'),'[^0-9]', '', 'g') as cleaned_data
from dirty_safari_data
where passenger_phone !~'^[0-9]+$';
----
----
update dirty_safari_data
set passenger_phone = regexp_replace(regexp_replace(passenger_phone, '^(\+254|254)', '0'),'[^0-9]', '', 'g')
where passenger_phone !~ '^[0-9]+$';

---removing blanks	
select coalesce(nullif(passenger_phone, ''),'null') 
from dirty_safari_data
where passenger_phone = '';
----
----
update dirty_safari_data
set passenger_phone = coalesce(nullif(passenger_phone, ''),'null')
where passenger_phone = '';
select * from dirty_safari_data dsd;

--3 Cleaning Passenger Gender
select passenger_gender from dirty_safari_data dsd;

--Leading $ trailing spaces and Capitalizing first Letter
select initcap(trim(passenger_gender)) 
from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd 
set passenger_gender = initcap(trim(passenger_gender)) 
where passenger_gender != initcap(trim(passenger_gender));

--Replacing M and F
select distinct passenger_gender,
case
	when passenger_gender = 'M' then 'Male'
	when passenger_gender = 'F' then 'Female'
	else passenger_gender
end
from dirty_safari_data dsd;
-----
-----
update dirty_safari_data dsd 
set passenger_gender =
case
	when passenger_gender = 'M' then 'Male'
	when passenger_gender = 'F' then 'Female'
	else passenger_gender
end;
select distinct(passenger_gender) from dirty_safari_data dsd;

--4. Passenger city
--Capitalizing each word, removing leading and trailing spaces
select distinct initcap(trim(passenger_city))  from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd
set passenger_city = initcap(trim(passenger_city))
where passenger_city != initcap(trim(passenger_city));

--blanks to unknown
select coalesce(nullif(passenger_city, ''), 'Unknown')
from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd 
set passenger_city = coalesce(nullif(passenger_city, ''), 'Unknown')
where dsd.passenger_city = '';

--5. Capitalizing each word for the Vehicle type
select distinct vehicle_type from dirty_safari_data dsd;
select distinct initcap(trim(vehicle_type))  from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd
set vehicle_type = initcap(trim(vehicle_type))
where vehicle_type != initcap(trim(vehicle_type));

--6. Driver_name

select distinct initcap(trim(driver_name))  from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd
set driver_name = initcap(trim(driver_name))
where driver_name != initcap(trim(driver_name));

--7. Driver_rating

select  driver_rating,
case 
	when driver_rating = '0' then null 
	when driver_rating = '6' then null
	else driver_rating
end
from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd
set driver_rating =
case 
	when driver_rating = '0' then null 
	when driver_rating = '6' then null
	else driver_rating
end;

--8 Date Standardization
select departure_date from dirty_safari_data dsd;
select
    to_char(
        case
            -- dd-mm-yy
            when departure_date like '__-__-__'
                then to_date(departure_date, 'dd-mm-yy')
            -- yyyy-mm-dd
            when departure_date like '____-__-__'
                then to_date(departure_date, 'yyyy-mm-dd')
            -- dd/mm/yyyy
            when departure_date like '__/__/____'
                then to_date(departure_date, 'dd/mm/yyyy')
            -- dd-mm-yyyy (e.g. 18-01-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 2)::int <= 12
                then to_date(departure_date, 'dd-mm-yyyy')
            -- mm-dd-yyyy (e.g. 01-18-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 1)::int <= 12
                then to_date(departure_date, 'mm-dd-yyyy')
            else null
        end,
        'dd-mm-yyyy'
    ) as formatted_date
from dirty_safari_data dsd;
----
---- 
update dirty_safari_data dsd
set departure_date =
to_char(
        case
            -- dd-mm-yy
            when departure_date like '__-__-__'
                then to_date(departure_date, 'dd-mm-yy')
            -- yyyy-mm-dd
            when departure_date like '____-__-__'
                then to_date(departure_date, 'yyyy-mm-dd')
            -- dd/mm/yyyy
            when departure_date like '__/__/____'
                then to_date(departure_date, 'dd/mm/yyyy')
            -- dd-mm-yyyy (e.g. 18-01-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 2)::int <= 12
                then to_date(departure_date, 'dd-mm-yyyy')
            -- mm-dd-yyyy (e.g. 01-18-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 1)::int <= 12
                then to_date(departure_date, 'mm-dd-yyyy')
            else null
        end,
        'dd-mm-yyyy'
    );

--9 Seat class
--Initcap, trim and standardize
select distinct seat_class from dirty_safari_connect dsc;
select distinct seat_class,
case
	when initcap(trim(seat_class)) = 'Bus' then 'Business Class'
	when initcap(trim(seat_class)) = 'Business' then 'Business Class'
	when initcap(trim(seat_class)) = 'Economy' then 'Economy Class'
	when initcap(trim(seat_class)) = 'Eco' then 'Economy Class'	
	else initcap(trim(seat_class))
end
from dirty_safari_data;
----
----
update dirty_safari_connect
set seat_class = 
case 
	when initcap(trim(seat_class)) = 'Bus' then 'Business Class'
	when initcap(trim(seat_class)) = 'Business' then 'Business Class'
	when initcap(trim(seat_class)) = 'Economy' then 'Economy Class'
	when initcap(trim(seat_class)) = 'Eco' then 'Economy Class'	
	else initcap(trim(seat_class))
end;

select distinct vehicle_plate from dirty_safari_data dsd
--10. Seats Booked
select * from dirty_safari_data dsd;
select seats_booked from dirty_safari_data dsd
where seats_booked = '-1';

update dirty_safari_data  
set seats_booked = null
where seats_booked = '-1';

--11. Fare per seat
--regexp_replace to remove the kshs, dashes etc
select fare_per_seat, regexp_replace(fare_per_seat,'[^0-9]', '','g')
from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd 
set fare_per_seat = regexp_replace(fare_per_seat,'[^0-9]', '','g')
where  fare_per_seat !~ '^[0-9]+$';

--12. Total Fare
--regexp_replace to remove the kshs, dashes etc
select total_fare, regexp_replace(total_fare,'[^0-9]', '','g')
from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd 
set total_fare = regexp_replace(total_fare,'[^0-9]', '','g')
where  total_fare !~ '^[0-9]+$';


--13. Payment Method
select distinct payment_method from dirty_safari_data dsd;
select  distinct  payment_method,
case 
	when initcap(trim(payment_method)) = 'Mpesa' then 'M-Pesa'
	else initcap(trim(payment_method)) 
end
from dirty_safari_data dsd;
------
------
update dirty_safari_data dsd
set payment_method = 
case 
	when initcap(trim(payment_method)) = 'Mpesa' then 'M-Pesa'
	else initcap(trim(payment_method)) 
end;

--14. Booking Status - Standardizing
select distinct booking_status from dirty_safari_data dsd;
select distinct initcap(trim(booking_status))  from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd
set booking_status = initcap(trim(booking_status))
where booking_status != initcap(trim(booking_status));

--15. Trip rating

select * from dirty_safari_data dsd;
select distinct trip_rating ,
case 
	when trip_rating = '' then null 
	when trip_rating = '6' then null 
	when trip_rating = '7' then null 
	when trip_rating = '0' then null 
	else trip_rating
end
from dirty_safari_data dsd;
----
----
update dirty_safari_data dsd 
set trip_rating =
case 
	when trip_rating = '' then null 
	when trip_rating = '6' then null 
	when trip_rating = '7' then null 
	when trip_rating = '0' then null 
	else trip_rating
end;

---16. Removing duplicates
select * from dirty_safari_data
where ctid not in (
 select min(ctid)
 from dirty_safari_data
 group by booking_id);
-----
-----
delete from dirty_safari_data
where ctid not in (
select min(ctid)
from dirty_safari_data
group by booking_id);

--17. Standardizing Data types.
alter table dirty_safari_data add primary key (booking_id);
alter table dirty_safari_data
alter column passenger_name type varchar(50),
alter column passenger_phone type varchar(10),
alter column passenger_gender type varchar(20),
alter column passenger_city type varchar(50),
alter column route_code type varchar(10),
alter column route_from type varchar(50),
alter column route_to type varchar(50),
alter column vehicle_plate type varchar(10),
alter column vehicle_type type varchar(50),
alter column driver_name type varchar(50),
alter column driver_rating type decimal using driver_rating::decimal,
alter column departure_date type date using to_date(departure_date, 'DD-MM-YYYY'),
alter column departure_time type time using departure_time::time,
alter column seat_class type varchar(20),
alter column seats_booked type numeric using seats_booked::numeric,
alter column fare_per_seat type numeric using fare_per_seat::numeric,
alter column total_fare type numeric using total_fare::numeric,
alter column payment_method type varchar(20),
alter column booking_status type varchar(20),
alter column trip_rating type numeric using trip_rating::numeric;
select * from dirty_safari_data dsd 

create table v_clean_trips as select * from dirty_safari_data;
select * from  v_clean_trips;

-----------------------------------------------DATA ANALYSIS-------------------------------------------------
-------------------------------------------------------------------------------------------------------------

--Question 1 - Route Analysis
--Business need: The Director wants to know which routes are the backbone of the business and which underperform

-- 1A - Revenue and bookings by route
-- Show: route_code, route_from, route_to, total_bookings, total_seats, total_revenue, avg_fare, avg_trip_rating. Order by total_revenue descending.

-- Revenue by route_code
select route_code, route_from, route_to, count(booking_id) as total_bookings,sum(seats_booked) as total_seats, sum(total_fare) as Revenue_by_route_code, round(avg(total_fare),2) as avg_fare, round(avg(trip_rating),2) as avg_trip_rating
from v_clean_trips vct 
group by route_code, route_from, route_to
order by revenue_by_route_code desc;

select distinct departure_date from v_clean_trips vct;

-- 1B - Revenue per seat by route (efficiency metric)
-- Which route earns the most per seat sold? Show route, total_revenue, total_seats, and revenue_per_seat = total_revenue / total_seats.

select route_code,route_from, route_to, sum(seats_booked) as total_seats, sum(total_fare) as total_revenue, round(sum(total_fare)/sum(seats_booked),2) as revenue_per_seat
from v_clean_trips vct 
group by route_code,route_from, route_to
order by revenue_per_seat desc;
-- RTOO1: KES 1,248


--1C - Route ranking with window function
-- Rank all routes by total revenue using RANK(). Also show each route's percentage of total company revenue.

select sum(total_fare)
from v_clean_trips vct; 

select route_code, route_from, route_to, sum(total_fare), rank() over (order by sum(total_fare) desc) as revenue_rank 
from v_clean_trips vct
group by route_code, route_from, route_to; 


select route_code, route_from, route_to, sum(total_fare), rank() over (order by sum(total_fare) desc) as revenue_rank, 
round((sum(total_fare) * 100.0) / sum(sum(total_fare)) over (),2) as percentage_revenue
from v_clean_trips vct
group by route_code, route_from, route_to; 


-- using a CTE
with route_revenue as (
select route_code, route_from, route_to, sum(total_fare) as revenue_by_route,
rank() over (order by sum(total_fare) desc) as revenue_rank
from v_clean_trips vct
group by route_code, route_from, route_to)
select *,round((revenue_by_route * 100.0) / sum(revenue_by_route) over(),2) as revenue_percentage
from route_revenue;


--1D - Vehicle type performance
--Compare Bus vs Matatu vs Minibus - total bookings, revenue, avg rating. Which vehicle type is most profitable?

select vehicle_type, count(booking_id) as total_bookings, sum(total_fare) as revenue_by_vehicle_type, round(avg(trip_rating),2) as avg_trip_rating
from v_clean_trips vct 
group by vehicle_type
order by revenue_by_vehicle_type desc;
-- The Bus generated the highest revenue and had the highest number of bookings
-- The Minibus rated the highest


-- Question 2 - Driver Performance
-- Business need: HR wants to know who to promote, who needs training, and whether driver rating affects passenger satisfaction.

-- 2A - Driver summary
-- Show: driver_name, total_trips, total_seats_carried, total_revenue, avg_trip_rating, driver_rating. Order by total_revenue descending.

select driver_name, count(distinct concat(departure_date, '_', departure_time, '_', route_code)) as total_trips, sum(seats_booked) as total_seats_carried, sum(total_fare) as total_revenue, round(avg(trip_rating),2) as avg_trip_rating, avg(driver_rating) as avg_driver_rating
from v_clean_trips  
group by driver_name 
order by total_revenue desc;   --->

SELECT 
    driver_name,
    count(distinct trip_id) as total_trips
from v_clean_trips vct 
group by driver_name;

select driver_name, count(concat(vehicle_type, '_', route_code)) as total_trips, sum(seats_booked), sum(total_fare) as total_revenue, round(avg(trip_rating),2) as avg_trip_rating, avg(driver_rating) as avg_driver_rating
from v_clean_trips  
group by driver_name 
order by total_revenue desc;

-- 2B - Driver ranking - overall + by vehicle type
-- Using a CTE for driver totals, rank drivers overall by revenue AND within their vehicle type using PARTITION BY vehicle_type.

with driver_totals as
(select driver_name, vehicle_type, sum(total_fare) as total_revenue
from v_clean_trips vct 
group by driver_name, vehicle_type)
select *, rank() over (partition by vehicle_type order by total_revenue desc)
from driver_totals;

-- 2C - Does driver rating predict passenger satisfaction?
-- Group drivers into high-rated (≥ 4.5) and standard (< 4.5). Compare average passenger trip_rating for each group. Does a higher driver rating lead to happier passengers?

select * from v_clean_trips;
---what answers the questions
with passenger_satisfaction as(
    select driver_name, avg(driver_rating) as avg_driver_rating, avg(trip_rating) as avg_trip_rating,
        case
            when avg(driver_rating) >= 4.5 then 'high_rated'
            else 'standard'
        end as rating_groupings
    from v_clean_trips
    group by driver_name)
select rating_groupings, round(avg(avg_trip_rating), 2) as final_passenger_satisfaction
from passenger_satisfaction
group by rating_groupings;

----breaks it down to the driver (This does not necessarily answer the question)
select
    driver_name, round(avg(driver_rating), 2) as avg_driver_rating, round(avg(trip_rating), 2) as avg_passenger_satisfaction,
    case
        when avg(driver_rating) >= 4.5 then 'high_rated'
        else 'standard'
    end as rating_groupings, round(avg(trip_rating) - avg(driver_rating), 2) as rating_gap, count(*) as total_trips
from v_clean_trips
group by driver_name
order by avg_driver_rating desc;

---3A - Monthly revenue with month-over-month change (CTE + LAG)

select * from v_clean_trips;
with current_monthly_revenue as(
select to_char(date_trunc('month', departure_date),'Month') as month, 
date_trunc('month', departure_date) as month_date, sum(total_fare) as total_revenue
from v_clean_trips
group by month_date) 
select month, total_revenue, lag(total_revenue) over(order by month_date) as previous_month_revenue from current_monthly_revenue;

---3B - Running total of revenue
select
    to_char(departure_date, 'Month') as month, sum(total_fare) as monthly_revenue,
    sum(sum(total_fare)) over (order by date_trunc('month', departure_date)) as running_total
from v_clean_trips
group by
    date_trunc('month', departure_date),
    month
order by
    date_trunc('month', departure_date);

---3C - Best and worst 3 months
--Using a CTE for monthly revenue, show the top 3 months and the bottom 3 months by revenue. Use RANK().

with cumulative_revenue as(
select to_char(date_trunc('Month', departure_date), 'Month')as month, to_char(date_trunc('Year', departure_date), 'YYYY')as year, sum(total_fare) as total_revenue, 
rank() over (order by sum(total_fare) desc) as rank
from v_clean_trips
group by year, month)
select month, year, total_revenue, rank
from cumulative_revenue
where rank <= 3 or rank >=11;

--3D - Revenue by route per month (pivot)
--Show one row per month with separate columns for the top 3 routes (RT001, RT002, RT003) using CASE WHEN + SUM.
--Getting the top 3 routes
with ranked_revenue as
(select route_code, sum(total_fare) as revenue_by_route,
rank() over (order by sum(total_fare) desc) as revenue_rank
from v_clean_trips vct
group by route_code)
select * from ranked_revenue 
where revenue_rank <= 3;

--Pivot table
select 
    to_char(date_trunc('month', departure_date), 'Month') as month,
	sum(case when route_code = 'RT001' then total_fare else 0 end) as rt001_revenue,
    sum(case when route_code = 'RT004' then total_fare else 0 end) as rt004_revenue,
    sum(case when route_code = 'RT002' then total_fare else 0 end) as rt002_revenue
from v_clean_trips
group by date_trunc('month', departure_date)
order by date_trunc('month', departure_date);

--4A - Top passenger cities
--Show: passenger_city, total_bookings, total_seats, total_revenue, avg_fare. 
--Order by total_bookings descending. Only include cities with 3+ bookings.
select * from
(select passenger_city, count(booking_id) as total_bookings, sum(seats_booked) as total_seats, sum(total_fare) as total_revenue, round(avg(total_fare),2) as avg_fare
from v_clean_trips
group by passenger_city
order by total_bookings desc) booking_summary
where total_bookings >= 3;

--4B - Gender split and seat class preference
--Show bookings and revenue broken down by passenger_gender and seat_class. Use a CASE WHEN pivot to show Economy and Business as separate columns.
select passenger_gender,seat_class, count(booking_id) as total_bookings, 
	sum(case when seat_class = 'Economy Class' then total_fare else 0 end) as "Economy_Revenue",
	sum(case when seat_class = 'Business Class' then total_fare else 0 end) as "Business_Revenue"
from v_clean_trips vct 
group by passenger_gender,seat_class
order by passenger_gender;

--4C - Satisfaction breakdown (CTE)
--Using a CTE, count how many trips fall into each satisfaction category (Satisfied / Neutral / Unsatisfied / No Rating). Show count and percentage of total completed trips.

with satisfaction_ratings as
(select count(booking_id) as total_bookings,
case
	when trip_rating >= 4 then 'Satisfied'
	when trip_rating = 3 then 'Neutral'
	when trip_rating < 3 then 'Unsatisfied'
	else 'No Rating'
end as satisfaction_category
from v_clean_trips
where  booking_status = 'Completed'
group by satisfaction_category)
select satisfaction_category,total_bookings, round(total_bookings * 100.0 / sum(total_bookings) over(),2) as percentage_of_total from satisfaction_ratings; 

-- 4D - Passenger quartiles by spend (NTILE)
-- Using a CTE for total spend per passenger, divide passengers into 4 quartiles using NTILE(4). Show: passenger_name, total_spent, quartile. Label quartile 4 as 'Top Spender'.
with quartile_spend as
(select passenger_name, sum(total_fare) as total_spend, ntile(4) over (order by sum(total_fare) asc) as quartiles_by_spend
from v_clean_trips
group by passenger_name)
select * ,
case 
	when quartiles_by_spend = 4 then 'Top Spender'
	else quartiles_by_spend::text 
end as quartile_category
from quartile_spend;

--5A - Overall status breakdown
select booking_status,count(booking_id) as total_bookings, sum(total_fare) as revenue_by_bookings
from v_clean_trips
group by booking_status;

select * from v_clean_trips vct;
--5B - Cancellation rate by route
--Show: route_code, route, total_bookings, completed, cancelled, no_show, cancellation_rate_pct.

with bookings_distribution as
(select route_code,route_to, route_from, count(booking_id) as total_bookings 
from v_clean_trips
where booking_status = 'Cancelled'
group by booking_status,route_code,route_to, route_from 
order by route_code)
select *, round(total_bookings *100/ sum(total_bookings) over(),2)as cancellation_rate  from bookings_distribution;

--5C - Revenue lost from cancellations and no-shows
select booking_status, sum(total_fare) as revenue_lost
from v_clean_trips vct 
where booking_status in ('Cancelled','No Show')
group by booking_status;

--6A - Revenue by day of week
--- isodow: the global standard for numbering days of week the first day is monday,
--  dow: starts from sunday--USA standard

select to_char(departure_date,'Day') AS day_of_week, sum(total_fare)as total_revenue
from v_clean_trips vct
group by day_of_week, extract(isodow from departure_date)
order by extract(isodow from departure_date);

--Alternative; 
---- 'FMDay'--Fill-mode- tells postgres do not pad with extra spaces
select to_char(departure_date, 'fmDay') as day_of_week, sum(total_fare) as total_revenue
from v_clean_trips
group by to_char(departure_date, 'fmDay'), extract(isodow from departure_date)
order by extract(isodow from departure_date);

--6B - Busiest departure times
--Group by departure_time. Show which time slots carry the most passengers and generate the most revenue.
select * from v_clean_trips

select departure_time,sum(seats_booked) as total_seats, sum(total_fare) as total_revenue
from v_clean_trips
group by departure_time
order by departure_time;

-- breakdown by seat class
select seat_class,departure_time,sum(seats_booked) as total_seats, sum(total_fare) as total_revenue
from v_clean_trips
group by departure_time,seat_class
order by departure_time;

--6C - Seat utilisation by vehicle type
--Compare how full each vehicle type typically runs. Show: vehicle_type, avg_seats_booked, and a label - 'High Load' if avg > 3, 'Medium Load' if 2-3, 'Low Load' if below 2.
select * from v_clean_trips

select vehicle_type, round(avg(seats_booked),2) as avg_seats,
case 
	when avg(seats_booked) > 3 then 'High Load'
	when avg(seats_booked) between 2 and 3 then 'Medium Load'
	else 'Low Load'
end
from v_clean_trips
group by vehicle_type;

-----------------------------------------------CREATING VIEWS------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- View 1: Route performance
--CREATE OR REPLACE VIEW v_route_performance AS
-- paste your 1A query here

CREATE OR REPLACE VIEW v_route_performance AS
select route_code, route_from, route_to, count(booking_id) as total_bookings,sum(seats_booked) as total_seats, sum(total_fare) as Revenue_by_route_code, round(avg(total_fare),2) as avg_fare, round(avg(trip_rating),2) as avg_trip_rating
from v_clean_trips vct 
group by route_code, route_from, route_to
order by revenue_by_route_code desc;

-- View 2: Driver performance
--CREATE OR REPLACE VIEW v_driver_performance AS
-- paste your 2A query here

CREATE OR REPLACE VIEW v_driver_performance AS
select driver_name, count(distinct concat(departure_date, '_', departure_time, '_', route_code)) as total_trips, sum(seats_booked) as total_seats_carried, sum(total_fare) as total_revenue, round(avg(trip_rating),2) as avg_trip_rating, avg(driver_rating) as avg_driver_rating
from v_clean_trips  
group by driver_name 
order by total_revenue desc;

-- View 3: Monthly revenue trend
--CREATE OR REPLACE VIEW v_monthly_revenue AS
-- paste your 3A query (the CTE) here

CREATE OR REPLACE VIEW v_monthly_revenue AS
with month_over_month as 
(select  date_trunc('month', departure_date) as month, sum(total_fare) as current_revenue, lag(sum(total_fare)) over (order by date_trunc('month', departure_date)) as previous_month_revenue
from v_clean_trips
group by month)
select *, (current_revenue - previous_month_revenue) as month_over_month_change, round((current_revenue - previous_month_revenue) * 100/previous_month_revenue,2) as percentage_change
from month_over_month;

-- View 4: Cancellation analysis
-- CREATE OR REPLACE VIEW v_cancellation_analysis AS
-- paste your 5B query here

CREATE OR REPLACE VIEW v_cancellation_analysis AS
with bookings_distribution as
(select route_code, route_to, route_from, booking_status,count(booking_id) as total_bookings 
from v_clean_trips
where booking_status = 'Cancelled'
group by booking_status,route_code,route_to, route_from
order by route_code)
select *,round(total_bookings *100/ sum(total_bookings) over(),2) as cancellation_rate  from bookings_distribution;

-- View 5: Passenger city insights
--CREATE OR REPLACE VIEW v_passenger_insights AS
-- paste your 4A query here

CREATE OR REPLACE VIEW v_passenger_insights AS
select * from
(select passenger_city, count(booking_id) as total_bookings, sum(seats_booked) as total_seats, sum(total_fare) as total_revenue, round(avg(total_fare),2) as avg_fare
from v_clean_trips
group by passenger_city
order by total_bookings desc) booking_summary
where total_bookings >= 3;

-----------------------------------------------CREATING INDEX------------------------------------------------
-------------------------------------------------------------------------------------------------------------

-- booking_id, passenger_phone, route_code, driver_name,departure_time,vehicle_type,seat_class

create index idx_passenger_phone on v_clean_trips(passenger_phone);

create index idx_route_code on v_clean_trips(route_code) ;

create index idx_driver_name on v_clean_trips(driver_name);

create index idx_departure_time on v_clean_trips(departure_time);

create index idx_vehicle_type on v_clean_trips(vehicle_type);

create index idx_seat_class on v_clean_trips(seat_class);

create index idx_passenger_gender on v_clean_trips(passenger_gender);

select * from pg_indexes where  tablename = 'v_clean_trips'; 

