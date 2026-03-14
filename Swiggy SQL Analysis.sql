\create table swiggy_data (
state varchar(100),
city varchar(100),
order_date varchar(50),
restaurant_name varchar(100),
location varchar(100),
category varchar(100),
dish_name varchar(200),
price float,
rating decimal(10,2),
rating_count int
)

select * from swiggy_data

alter table swiggy_data
add column order_date_clean DATE;

update swiggy_data
set order_date_clean = TO_DATE(order_date,'DD-MM-YYYY')

ALTER TABLE swiggy_data
drop column order_date

alter table swiggy_data
rename column order_date_clean to order_date

--Data_cleaning/Data_validation
--check for null values

select
sum(case when state is null then 1 else 0 end) as state_null,
sum(case when city is null then 1 else 0 end)as city_null,
sum(case when restaurant_name is null then 1 else 0 end) as restaurant_name_null,
sum(case when location is null then 1 else 0 end) as location_null, 
sum(case when category is null then 1 else 0 end) as category_null,
sum(case when dish_name is null then 1 else 0 end) as dishname_null,
sum(case when price is null then 1 else 0 end) as price_null,
sum(case when rating is null then 1 else 0 end) as rating_null,
sum(case when rating_count is null then 1 else 0 end) as ratingcount_null,
sum(case when order_date is null then 1 else 0 end) as order_date_null
from swiggy_data

--check for empty_string
select *
from swiggy_data
where  state=''or 
city=''or
restaurant_name=''or 
location='' or 
category='' or
dish_name='' 
--check duplicates
select state,
city,
restaurant_name,
location,
category,
dish_name,
price,
rating,
rating_count,
order_date
,count(*) from swiggy_data
group by  state,city,restaurant_name,location,category,dish_name,price,rating,rating_count,order_date
having count(*)>1

---delete duplication
with cte as (
select ctid,
row_number() over(partition by state,
city,
restaurant_name,
location,
category,
dish_name,
price,
rating,
rating_count,
order_date order by order_date
) as rn
from swiggy_data
)
delete from swiggy_data
where ctid in (
select ctid from cte
where rn > 1
)





---creation of star_schema
select * from swiggy_data
create table dim_location (
location_id serial primary key,
state varchar(50),
city varchar(50),
location varchar(50)
)

insert into dim_location(state,city,location)
select distinct
state,city,location
from swiggy_data

select count(*) from dim_restaurant

--restaurant
create table dim_restaurant(
restaurant_id serial,
restaurant_name varchar(50)
)

insert into dim_restaurant(restaurant_name)
select distinct
restaurant_name
from swiggy_data

--date
create table dim_date(
date_id serial  primary key,
order_date date,
year_num int,
month_num int,
quarter_num int,
day_name varchar(50)
)

insert into dim_date (order_date,year_num,month_num,quarter_num,day_name)
select distinct
order_date,
extract(year from order_date),
extract(month from order_date),
extract(quarter from order_date),
TO_CHAR(order_date,'Day')  as day_name
from swiggy_data

select * from swiggy_data

create table dim_category(
category_id serial,
category varchar(100),
dish_name varchar(200)
)

insert into dim_category(category,dish_name)
select distinct
category,
dish_name
from swiggy_data

select * from dim_orders
--creation of fact table
select * from swiggy_data

alter table dim_category
add primary key(category_id)

alter table dim_restaurant
add primary key(restaurant_id)

create table fact_swiggy_orders(
order_id serial primary key,
date_id int,
location_id int,
category_id int,
restaurant_id int,
price decimal(10,2),
rating decimal(10,2),
rating_count int,
foreign key (date_id)references dim_date(date_id),
foreign key (location_id) references dim_location(location_id),
foreign key (category_id) references dim_category(category_id),
foreign key (restaurant_id)  references dim_restaurant(restaurant_id)
)
select * from fact_swiggy_orders
insert into fact_swiggy_orders(
date_id,
location_id,
category_id,
restaurant_id,
price,
rating,
rating_count
)
select
d.date_id,
l.location_id,
c.category_id,
r.restaurant_id,
s.price,
s.rating,
s.rating_count  
from swiggy_data s
join dim_date d
on d.order_date = s.order_date
join dim_location l
on l.state = s.state 
and l.city = s.city
and l.location = s.location
join dim_restaurant r
on r.restaurant_name = s.restaurant_name
join dim_category c
on c.category=s.category
and c.dish_name = s.dish_name

select * from dim_date
select* from fact_swiggy_orders s
join dim_date d
on d.date_id = s.date_id
join dim_location l
on l.location_id = s.location_id
join dim_restaurant r
on r.restaurant_id = s.restaurant_id
join dim_category c
on c.category_id = s.category_id



--kpis
--total_orders
select count(*) as total_orders
from fact_swiggy_orders
--total_revenue
select sum(price) as total_revenue
from fact_swiggy_orders

select * from dim_category
--average_dish_price
select c.dish_name,round(avg(s.price),2)
from fact_swiggy_orders s
join dim_category c
on s.category_id = c.category_id
group by c.dish_name

--averge_price
select avg(price)
from fact_swiggy_orders
--average rating
select avg(rating) as avg_rating
from fact_swiggy_orders


select * from dim_date
--Business Analysis
--monthly orders
select year_num,month_num,count(order_id) as total_orders
from dim_date d
join fact_swiggy_orders s
on d.date_id = s.date_id
group by year_num,month_num

--Quarter trends
select quarter_num,count(*) as total_orders
from fact_swiggy_orders s
join dim_date d
on d.date_id = s.date_id
group by quarter_num

--year wise trends
select year_num,count(*) as total_orders
from fact_swiggy_orders s
join dim_date d
on d.date_id = s.date_id
group by year_num

--day wise trends
select d.day_name,count(*) as total_orders
from fact_swiggy_orders s
join dim_date d
on d.date_id = s.date_id
group by d.day_name

--location based Analysis
select l.location,count(*) as total_orders
from dim_location l 
join fact_swiggy_orders s
on l.location_id = s.location_id
group by l.location
--revenue by states
select l.state,count(*) as total_orders
from dim_location l
join fact_swiggy_orders s
on l.location_id = s.location_id
group by l.state

--food performance
--Top 10 restauarnts by Orders
select r.restaurant_name,count(*) as total_orders
from dim_restaurant r
join fact_swiggy_orders s
on r.restaurant_id = s.restaurant_id
group by r.restaurant_name 
order by count(*) desc
limit 10

---Top 10 categorys
select c.category,count(*) as total_orders
from dim_category c
join fact_swiggy_orders s
on c.category_id = s.category_id
group by c.category
order by count(*) desc
limit 10

--TOP dishes
select c.dish_name,count(*) as total_orders
from dim_category c
join fact_swiggy_orders s
on c.category_id = s.category_id
group by c.dish_name
order by count(*) desc
limit 10

--	Cuisine performance → Orders + Avg Rating
select c.category ,round(avg(s.rating),2),count(*) as total_orders
from dim_category c
join fact_swiggy_orders s
on c.category_id = s.category_id
group by c.category 

--orders divide
select
case
when price <100 then 'under 100'
when price between 100 and 199 then '100-199'
when price between 200 and 299 then '200-299'
when price between 300 and 399 then '300 and 400'
else'400+'
end as price_range,
count(*) total_orders 
from fact_swiggy_orders 
group by
case when price <100 then 'under 100'
when price between 100 and 199 then '100-199'
when price between 200 and 299 then '200-299'
when price between 300 and 399 then '300 and 400'
else'400+'
end 
order by total_orders desc

---rating analysis

select rating,count(*) as total_orders
from fact_swiggy_orders
group by rating
order by total_orders desc

