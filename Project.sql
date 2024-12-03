-- the total number of orders placed

select * from orders;
select * from pizzas;
select * from pizza_types;
select * from orders_details;
select count(order_id) as Total_orders from orders;

--  the total revenue generated from pizza sales
select round(sum(OD.quantity*P.price),0) as Total_Revenue from pizzas as P
join  orders_details as OD on OD.pizza_id=P.pizza_id ;

-- Identify the highest-priced pizza.

Select  PT.name as Pizza_type,P.price from pizzas as p
join Pizza_types as PT on PT.Pizza_type_id =P.pizza_type_id order by Price desc
limit 1;

-- Identify the most common pizza size ordered

select P.size as Pizza_Size,count(OD.Order_details_id) as Orders from pizzas as P
 join orders_details as OD on OD.pizza_id=P.pizza_id
 group by P.size order by Orders desc;
 
 -- List the top 5 most ordered pizza types along with their quantities.
 
 
 select PT.name, count(OD.quantity) as Quantity from pizza_types as PT
 join Pizzas as P on P.Pizza_type_id=PT.pizza_type_id
 join orders_details as OD on OD.pizza_id=P.pizza_id
 group by PT.name
 order by Quantity desc limit 5;
 
 -- Join the necessary tables to find the total quantity of each pizza category ordered.
 
  select PT.category as Category, sum(OD.quantity) as Quantity_Count from pizza_types as PT
  join Pizzas as P on P.Pizza_type_id=PT.pizza_type_id
 join orders_details as OD on OD.pizza_id=P.pizza_id
 group by Category order by Quantity_Count desc  ;
 
 -- Determine the distribution of orders by hour of the day.
 
 select hour(order_time) as Hours,count(order_id)as Total_orders 
 from orders group by hours order by hours;
 
 --  to find the category-wise distribution of pizzas.
 
 select category,count(name) as Pizza_Type from pizza_types
 group by category order by Pizza_Type desc;
 

 -- Group the orders by date and calculate the average number of pizzas ordered per day
 select round( avg(Quantity),0) as Average_orders_Per_Day from
 
 (select O.order_date,sum(OD.quantity) as Quantity from orders as O
 join orders_details as OD on OD.order_id=O.order_id
 group by O.order_date) as Orders_;
 
 -- Determine the top 3 most ordered pizza types based on revenue
 
 select PT.name as Pizza_Type, round(sum(OD.quantity * P.Price),2) as Total_Revenue from pizza_types as PT
 join pizzas as P on P.pizza_type_id=PT.pizza_type_id
 join orders_details as OD on OD.pizza_id=P.pizza_id
 group by Pizza_Type order by Total_Revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue. name_PizzaType

select PT.Category,round(sum(OD.quantity*P.price)
 /(select round(sum(OD.quantity*P.price),2) as Total_Revenue from pizzas as P
join  orders_details as OD on OD.pizza_id=P.pizza_id)*100,2) as total 
from pizza_types as PT 
join pizzas as P on P.pizza_type_id=PT.pizza_type_id
join orders_details as OD on OD.pizza_id=P.pizza_id
group by PT.Category order by total desc;


-- Analyze the cumulative revenue generated over time.

select order_date,Total_revenue,sum(Total_revenue) over (order by order_Date) as Cumm_rev from

(select O.order_date,Round(sum(OD.quantity*P.price),2) as Total_revenue from orders as O
join orders_details as OD on OD.order_id=O.order_id
join pizzas as P on P.pizza_id=OD.pizza_id group by O.order_date ) as total ;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with Pizza_Revenue as (select PT.category as Pizza_Category,PT.name as Pizza_name,SUM(OD.quantity * P.price) AS revenue
    FROM pizza_types AS PT
    join pizzas as P on P.pizza_type_id=PT.pizza_type_id
    JOIN orders_details as OD on OD.pizza_id=P.pizza_id
    GROUP BY PT.category, Pizza_name),
    RankedPizzas AS (
    SELECT 
        pizza_category,
       Pizza_name,
        revenue,
       Rank() OVER (PARTITION BY pizza_category ORDER BY revenue DESC) AS rank_
    FROM Pizza_Revenue)
    
    SELECT 
    pizza_category,
    Pizza_name,
    revenue
FROM RankedPizzas
WHERE rank_ <= 3
ORDER BY pizza_category, rank_;

    