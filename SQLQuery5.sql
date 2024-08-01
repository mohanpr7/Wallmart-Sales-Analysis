use  [wallmart sales]
select * from wallmart

select distinct CUSTOMERID from wallmart


-- identifying top 10 customers by thier total number of orders
select 
customername,
total_orders
from (
      select 
      customername, count(order_id) as total_orders,
      dense_rank() over(order by count(order_id) desc) as dnr
      from wallmart
      group by customername
      ) as subquery
where dnr <= 10;


-- identifying top 2 cities for each state by their total sales price 
-- total sales price = sales_price * quantity
WITH cte AS
(
SELECT 
STATE, 
city,
SUM(sales_price * quantity) as total_sales_price,
DENSE_RANK() OVER(PARTITION BY state ORDER BY SUM(sales_price * quantity)DESC) AS dnr
FROM wallmart
GROUP BY city, state
)
SELECT * FROM cte
WHERE dnr<=2;



-- Total orders, Total sales and total profit by each category
SELECT
    Category,
	count(*) AS total_orders,
    SUM(Sales_price) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM
    wallmart
GROUP BY
    category;



--  Total orders and Average Discount Given for Each Ship Mode.
SELECT
    Ship_Mode,
	count(*) as total_orders,
    round(AVG(Discount) * 100, 2) AS Average_Discount
FROM
    wallmart
WHERE
	discount is not null
GROUP BY
    Ship_Mode;



-- identifying top subcategory for each state by their total no. of orders
SELECT 
	state,
	subcategory
FROM
(
SELECT
	state, 
	subcategory,
	count(*) AS total_orders,
	RANK() OVER( PARTITION BY state ORDER BY count(*)desc) AS r
FROM
	wallmart
GROUP BY
	state, subcategory) AS subquery
WHERE r=1
	


-- Comparing current month sales with previous month sales and identifying decreasing or increasing	

WITH MonthlySales AS (
    SELECT 
        DATEPART(year, order_date) AS year,
        DATEPART(month, order_date) AS month,
        ROUND(SUM(sales_price * quantity), 2) AS total_sales_amount
    FROM 
		wallmart
    GROUP BY 
		DATEPART(year, order_date), DATEPART(month, order_date)
),
CTE1 AS (
	SELECT
		c.year,
		c.month,
		c.total_sales_amount AS current_month_sales,
		previous.total_sales_amount AS previous_month_sales,
    CASE
        WHEN previous.total_sales_amount IS NULL THEN 'No Previous Data'
        WHEN c.total_sales_amount > previous.total_sales_amount THEN 'Increased'
        WHEN c.total_sales_amount < previous.total_sales_amount THEN 'Decreased'
        ELSE 'No Change'
    END AS sales_trend
FROM 
	MonthlySales AS c
LEFT JOIN MonthlySales AS previous
    ON c.month = previous.month + 1 AND c.year = previous.year
	OR c.month = 1 AND previous.month = 12 AND c.year = previous.year + 1
)
SELECT 
	year,
	month,
	sales_trend
FROM 
	CTE1 
ORDER BY 
	year, month;


-- Identifying processing days (order date - ship date) , total shippments and percentage of shippments by total shippments.
SELECT 
	processing_days, 
	count(*) AS total_shippments,
	cast(count(*) * 100.0 / (SELECT count(*) FROM wallmart) AS decimal(10,2)) AS percentage_of_shippments
FROM ( 
	 SELECT DATEDIFF(day, order_date , ship_date) AS processing_days
     FROM wallmart
	 ) AS c
GROUP BY processing_days
ORDER BY processing_days



-- Caluclating total sales for each year
SELECT
	datepart(year, order_date),
	sum(sales_price*quantity) AS total_sales
FROM 
	wallmart
GROUP BY
	datepart(year, order_date)



-- Caluclating total profit or total loss by each state.
WITH cte1 AS 
( 
	SELECT 
		State,
		SUM(Profit) AS Total_Profit
	FROM 
		wallmart
	WHERE
		profit > 0
	GROUP BY 
		state
),
cte2 AS
(
	SELECT 
		State,
		SUM(Profit) AS Total_loss
	FROM 
		wallmart
	WHERE
		profit < 0
	GROUP BY 
		state
)
SELECT 
	cte1.state,  
	(total_profit + total_loss) AS profit_or_loss
FROM 
	cte1
JOIN cte2 ON
	cte1.state = cte2.state




select state, count(*)
from wallmart
group by state


































