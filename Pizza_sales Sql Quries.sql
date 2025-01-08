Create Database Pizzahut
use pizzahut
Select * from pizzas

BULK INSERT pizzas
FROM 'C:\ABHI\SQL\pizza_sales\pizzas.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1
);

Create table pizza_types(
pizza_type_id varchar(20),
Pizza_name varchar(100) ,
category varchar (20),
ingredients varchar(200))

Select * from pizza_types

BULK INSERT pizza_types
FROM 'C:\ABHI\SQL\pizza_sales\pizza_types.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1
);

Select * from pizza_types

delete from pizza_types
where Pizza_name = 'Pizza_name'

CREATE TABLE "order" (
    order_id INT,
    date DATE,
    time TIME,
    PRIMARY KEY (order_id)
);

Select * from "order"

BULK INSERT "order"
FROM 'C:\ABHI\SQL\pizza_sales\orders.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1
);

Create Table Order_Details(
order_details_id int,
order_id int,
pizza_id Varchar(20),
quantity int)

Select * from Order_Details

BULK INSERT Order_Details
FROM 'C:\ABHI\SQL\pizza_sales\Order_Details.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1
);

--Retrieve the total Number Of Oders Placed.
Use Pizzahut

Select Count(order_id) as Total_Number_order from "order"

--Calculated Total Revenue from Pizza sales

Select * from Order_Details
select * from pizzas

Select Round (sum(pizzas.price*Order_Details.quantity),2) as Total_Reveneu from Order_Details
join pizzas
on pizzas.pizza_id = Order_Details.pizza_id

--Identifide the Highest Price Of pizza-

Select * from pizzas
select * from pizza_types

SELECT pizza_types.Pizza_name, pizzas.price
FROM pizza_types
JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


--Identifide the most common pizza size order--

Select * from Order_Details

select  pizzas.size, Count(Order_Details.order_details_id) as Orders from pizzas
join Order_Details
on 
pizzas.pizza_id = Order_Details.pizza_id
group by pizzas.size order by Orders desc Limit 1


--List top 5 Most ordered pizza type along with thier Quantities--

Select * from pizza_types
select * from Order_Details
Select * from pizzas

Select pizza_types.Pizza_name, sum(Order_Details.quantity) As Order_Quantity from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join Order_details on
pizzas.pizza_id = Order_Details.pizza_id
Group by Pizza_name order by Order_Quantity desc Limit 5

--Join the necessary table   to find the total quantity of each pizza category ordered--


Select pizza_types.category , sum(Order_details.quantity) as Total_Order
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join Order_details on
pizzas.pizza_id = Order_Details.pizza_id
group by category order by Total_Order desc


--Determine the distribution of orders  by hour of the day--
Use Pizzahut
Select * from "order"

ALTER TABLE "order"
ADD Total_hours int;

UPDATE "order"
SET Total_hours = DATEPART(HOUR, time)
WHERE Total_hours IS NULL;

SELECT Total_hours, COUNT(order_id) AS OrderCount
FROM "order"
GROUP BY Total_hours
ORDER BY COUNT(order_id) DESC; 

--join the relevent tables to find category wise distrubution pizza--

Select category, count(Pizza_name) as Pizza_count from pizza_types group by category order by Pizza_count desc

--Group the order by date and calculate the average number of pizza ordered per day .

Select * from "order"
Select * from Order_Details

	Select avg(quantity) as avg_Pizza_order_perDay from 
	(Select "order".date, sum(Order_Details.quantity) as quantity from "order"
	join Order_Details
	on "order".order_id = Order_Details.order_id
	group by "order".date) as order_quantity


--Determine the top 3 most ordered pizza type based on revenue

Select * from Order_Details

alter table Order_Details
add Total_Amount int

UPDATE Order_Details
SET Total_Amount = Order_Details.quantity * pizzas.price
FROM Order_Details
JOIN pizzas ON Order_Details.pizza_id = pizzas.pizza_id
WHERE Total_Amount IS NULL;

Select pizza_types.Pizza_name, sum(Order_Details.Total_Amount) as Revenue from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join Order_Details
on Order_Details.pizza_id = pizzas.pizza_id
group by pizza_types.Pizza_name order by Revenue desc Limit 3

--Calculate the percentage  contribution of each pizza type to total revenue--


select * from pizza_types

SELECT pizza_types.category, 
       ROUND(SUM(Order_Details.quantity * pizzas.price) / 
       (SELECT SUM(Order_Details.quantity * pizzas.price) 
        FROM Order_Details
        JOIN pizzas ON pizzas.pizza_id = Order_Details.pizza_id) * 100, 2) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN Order_Details ON Order_Details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

--Analyze the cumulative revenue generated over time--

Select * from "order"
Select * from Order_Details

SELECT date,
    SUM(Revenue) OVER (ORDER BY date) AS Cum_revenue
FROM (SELECT "order".date, 
        SUM(Order_Details.Total_Amount) AS Revenue
    FROM  "order"
    JOIN Order_Details 
    ON  "order".order_id = Order_Details.order_id
    GROUP BY "order".date) AS Sales ORDER BY date
	Limit 10;

--Determine the top 3 most ordered  pizza type based on revenue for each pizza Category--
Select * from pizza_types
Select * from Order_Details
Select * from pizzas


SELECT Pizza_name, 
    Revenue 
FROM (
    SELECT 
        category, 
        Pizza_name, 
        Revenue, 
        RANK() OVER (PARTITION BY category ORDER BY Revenue DESC) AS Rank
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.Pizza_name, 
            SUM(Order_Details.Total_Amount) AS Revenue
        FROM 
            pizza_types
        JOIN 
            pizzas 
        ON 
            pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN 
            Order_Details 
        ON 
            pizzas.pizza_id = Order_Details.pizza_id
        GROUP BY 
            pizza_types.category, 
            pizza_types.Pizza_name
    ) AS Subquery_A
) AS B
WHERE Rank <= 3;





