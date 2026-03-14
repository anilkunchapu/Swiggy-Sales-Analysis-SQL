# Swiggy Sales Analysis (SQL Project)

## Project Overview
This project analyzes Swiggy food delivery data using SQL to identify sales trends, restaurant performance, and cuisine popularity.

## Tools Used
SQL (PostgreSQL)

## Dataset
The dataset contains:
- restaurant_name
- location
- category
- dish_name
- price
- rating
- order_date

## Project Steps

### Data Cleaning
- Checked NULL values
- Removed duplicate records
- Converted order_date to proper date format

### Data Modeling
Created a Star Schema:
- Fact Table: fact_swiggy_orders
- Dimension Tables:
  - dim_date
  - dim_location
  - dim_restaurant
  - dim_category

### KPI Analysis
Calculated metrics:
- Total Orders
- Total Revenue
- Average Rating
- Average Dish Price

### Business Insights
Performed analysis such as:
- Monthly order trends
- Top restaurants by orders
- Most popular dishes
- Cuisine performance
