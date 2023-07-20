CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

Select * from order_items

-- Case Study Questions

--1) Which product has the highest price? Only return a single row.

Select top 1 product_name,Price from products Order By price Desc

--2) Which customer has made the most orders?

With CTE1 AS
(
Select customer_id,Count(order_id) AS count From orders
Group by customer_id Having COUNT(order_id) >1 
)
SELECT c.first_name, c.last_name, CTE1.customer_id From customers c JOIN  CTE1  ON c.customer_id =CTE1.customer_id Order By CTE1.count DESC



--3) What’s the total revenue per product?
SELECT p.product_id, product_name, sum(p.price* oi.quantity) AS Revenue
From products p Join order_items oi 
ON p.product_id = oi.product_id 
Group by p.product_id, product_name
Order By Sum(p.price* oi.quantity) DESC

--4) Find the day with the highest revenue.

With CTE1 AS
(
SELECT oi.order_id, p.price* oi.quantity AS Revenue
From products p Join order_items oi 
ON p.product_id = oi.product_id 
) 
Select TOP 1 order_date, SUM(CTE1.Revenue) From orders join CTE1 
on orders.order_id = CTE1.order_id  
group by order_date 
Order BY SUM(CTE1.Revenue) DESC

--5) Find the first order (by date) for each customer.

With CTE1 AS 
(
Select customer_id, min(order_date) As first_purchase From orders Group by customer_id
)
Select order_id AS first_order, orders.customer_id, order_date From orders JOIN CTE1 
ON CTE1.customer_id = orders.customer_id AND CTE1.first_purchase = orders.order_date

--6) Find the top 3 customers who have ordered the most distinct products

Select TOP 3 c.customer_id,c.first_name, c.last_name, count(distinct oi.product_id) AS distinct_product 
From customers c
Join orders o ON c.customer_id = o.customer_id
join order_items oi ON o.order_id = oi.order_id
Group by c.customer_id,c.first_name,c.last_name
Order By count(distinct oi.product_id) Desc

--7) Which product has been bought the least in terms of quantity?

Select Top 1 p.product_name,oi.product_id, SUM(quantity) AS Qty
From order_items oi Join products p
On p.product_id = oi.product_id
Group BY oi.product_id, p.product_name
Order By SUM(quantity)

--8) What is the median order total?

WITH order_totals AS (
    SELECT SUM(p.price * oi.quantity) AS total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY oi.order_id
)
SELECT distinct median = PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) OVER() 
FROM order_totals;

--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.



SELECT oi.order_id, Sum(p.price* oi.quantity) AS Tolamt, 
CASE
When Sum(p.price* oi.quantity) > 300 Then 'expensive'
When Sum(p.price* oi.quantity) < 300 AND Sum(p.price* oi.quantity)  >  100 Then 'Affordable' 
Else 'Cheap'
End AS category
From products p Join order_items oi 
ON p.product_id = oi.product_id 
Group by oi.order_id
Order By Sum(p.price* oi.quantity) DESC



--10) Find customers who have ordered the product with the highest price.

Select c.first_name,c.last_name,c.customer_id, order_id from customers c
Join orders o ON c.customer_id = o.customer_id 
Where order_id in(
Select  Order_id From order_items where product_id in (
Select Top 1 product_id from products order by price DESC ))