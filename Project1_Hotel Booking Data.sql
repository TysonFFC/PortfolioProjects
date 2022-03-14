
-- Identify Hotel 2018 Revenue Data
select *  FROM [Project_Hotel Booking Data].[dbo].['2018$']


-- Identify Hotel 2018 Revenue Data
select *  FROM [Project_Hotel Booking Data].[dbo].['2019$']


-- Identify Hotel 2018 Revenue Data
select *  FROM [Project_Hotel Booking Data].[dbo].['2020$']


-- Join 3 years hotel data into one table
with hotels as (
select *  FROM [Project_Hotel Booking Data].[dbo].['2018$']
union
select * FROM [Project_Hotel Booking Data].[dbo].['2019$']
union
select * FROM [Project_Hotel Booking Data].[dbo].['2020$'])

select 
arrival_date_year,
hotel,
round (sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2) as revenue 
from hotels
group by arrival_date_year, hotel