                      -- Amazon Analysis --           
-- Q1: What are the total sales made by each customer?
SELECT 
	customer_id,
	SUM(sale) AS total_sales
FROM
	orders 
GROUP BY
	customer_id;
        
-- Q2: How many orders were placed in each state?
SELECT 
	state,
	count(order_id) AS total_orders
FROM 
	orders 
GROUP BY
	state;

-- Q3. How many unique products were sold?
SELECT 
	COUNT(DISTINCT product_id) AS  total_unique_products
FROM
	orders;

-- Q4. How many returns were made for each product category?
SELECT 
	o.category,
	COUNT(r.return_id) AS total_returns
FROM 
	orders o
JOIN 
	returns r 
ON 
	o.order_id = r.order_id
GROUP BY
	o.category;
        
-- Q5. How many orders were placed each month(2022)?
SELECT 
	MONTH(order_date) AS order_month,
    COUNT(order_id) AS count_month_orders
FROM 
	orders
WHERE 
	YEAR(order_date)  = '2022'
GROUP BY 
	order_month
ORDER BY 
	order_month;

-- Q6.Determine the top 5 products whose revenue has decreased compared to the previous year.(current year =2023,previous year = 2022)
WITH cte_curr_year
AS
(
	SELECT
		product_id,
		SUM(sale) as curr_year_Sale
	FROM
		orders
	WHERE
		order_date BETWEEN '2023-01-01' AND '2023-12-31'
	GROUP BY 
		product_id
),
cte_prev_year
AS		
(
	SELECT 
		product_id,
		SUM(sale) as prev_year_Sale
	FROM
		orders
	WHERE 
		order_date BETWEEN '2022-01-01' AND '2022-12-31'
	GROUP BY 
		product_id
)

SELECT
	*,
	py.prev_year_Sale - cy.curr_year_Sale) AS revenue_decrease,
    ROUND(py.prev_year_Sale - cy.curr_year_Sale, 2)/ROUND(py.prev_year_Sale,2) * 100 AS revenue_decrease_percentage
FROM 
	cte_curr_year cy
JOIN 
	cte_prev_year py
ON 
	cy.product_id = py.product_id
WHERE 
	py.prev_year_Sale > cy.curr_year_Sale
ORDER BY
	revenue_decrease_percentage DESC;
        
-- Q7. List all orders where the quantity sold is greater than the average quantity sold across all orders.
SELECT 
	*
FROM
	orders
WHERE 
	quantity > (SELECT  AVG(quantity) FROM orders)
ORDER BY
	quantity;

-- Q8.  Find out the top 5 customers who made the highest profits.
SELECT 
    o.customer_id, 
    SUM((o.price_per_unit - p.cogs) * o.quantity) AS total_profit
FROM 
    orders AS o
LEFT JOIN 
    products AS p ON o.product_id = p.product_id
GROUP BY 
    o.customer_id
ORDER BY 
    total_profit DESC
LIMIT 5;

-- Q9. Find the details of the top 5 products with the highest total sales, where the total sale for each product is greater than the average sale across all products.
SELECT  
    state,
    COUNT(1)
FROM 
	orders
WHERE 
	state IS NOT NULL    
GROUP BY 
	state
HAVING 
	COUNT(1) > (SELECT COUNT(1)/(SELECT COUNT(DISTINCT state) from orders where state is not null)
                   FROM orders)
ORDER BY COUNT(1) DESC 
LIMIT 5;

-- Q10. Calculate the profit margin percentage for each sale
SELECT 
    order_id,
    ((SUM(o.price_per_unit - p.cogs) * o.quantity) / SUM(o.sale)) * 100 AS profit_margin_percentage
FROM 
    orders AS o
LEFT JOIN 
    products AS p ON o.product_id = p.product_id
GROUP BY 
    order_id;

-- Q 11: Find Top 5 states by total orders where each state orders is greater than average orders accross state orders.
SELECT
	state,
    COUNT(1) as total_state_orders
FROM 
	orders  o
WHERE
	state IS NOT NULL
GROUP BY 
	state
HAVING
	COUNT(1) > (SELECT COUNT(1)/(SELECT COUNT(DISTINCT state) FROM orders WHERE state IS NOT NULL))
ORDER BY 
	COUNT(1) DESC
LIMIT 5;

-- Q12: Identify returning customers: Label customers as "Returning" if they have placed more than one returns; otherwise, mark them as "New."
--  return cx_name, total orders, total returns and category they fall into    

SELECT
	o.customer_id,
	COUNT(o.order_id) AS total_orders,
    COUNT(r.return_id) AS total_returns,
	CASE 
		WHEN COUNT(r.return_id) > 1 THEN 'Returning' 
        ELSE 'NEW' 
	END AS customer_category
FROM 
	orders o
LEFT JOIN 
	returns r
ON
	o.order_id = r.order_id
GROUP BY
	o.customer_id;

