create database	if not exists DannyD;
use DannyD;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);
INSERT INTO sales
  (customer_id, order_date,product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from sales;
select * from menu;
select * from members;


-- 1. What is the total amount each customer spent at the restaurant?
select 
	s.customer_id,
	sum(m.price) as total_price
from sales s 
inner join menu m
	on s.product_id = m.product_id
group by s.customer_id
order by total_price desc;

-- 2. How many days has each customer visited the restaurant?
select 
	customer_id,
    count(distinct order_date) as Days_visited
from sales
group by customer_id
order by Days_visited desc;

-- 3. What was the first item from the menu purchased by each customer?
select 
	customer_id,
    product_name
from
(
select 
	s.customer_id,
	m.product_name,
	row_number() over(partition by s.customer_id order by s.order_date) as Ranks
from sales s 
join menu m 
	on s.product_id = m.product_id ) ranking
where Ranks = 1
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	m.product_name,
	COUNT(*) AS order_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY order_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer? not done hai

select 
	s.customer_id,
	m.product_name,
	count(s.order_date) as total
from sales s
join menu m 
	on s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
order by total desc;

-- 6. Which item was purchased first by the customer after they became a member?
select 
	customer_id,
	product_name
from (
select 
	s.customer_id,
	m.product_name,
	row_number() over(partition by s.customer_id order by s.order_date) as ranking
from sales s 
join menu m
	on s.product_id = m.product_id
join members mem
	on s.customer_id = mem.customer_id
where s.order_date >=mem.join_date ) as firstra
where ranking =1
;
-- 7. Which item was purchased just before the customer became a member?

select 
	customer_id,
	product_name
from (
select 
	s.customer_id,
	m.product_name,
	s.order_date,
	row_number() over(partition by s.customer_id order by s.order_date desc) as ranking
from sales s 
join menu m
	on s.product_id = m.product_id
join members mem
	on s.customer_id = mem.customer_id
where s.order_date < mem.join_date ) as firstra
where ranking =1;

-- 8. What is the total items and amount spent for each member before they became a member?
select
	s.customer_id,
	count(m.product_name) as total_item,
	sum(m.price) as total_price
from sales s
join menu m
	on s.product_id = m.product_id
join members mem
	on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select 
	s.customer_id,
	sum(m.price) total,
	sum(
		case m.product_name
			when 'sushi' then m.price * 10*2
			else m.price * 10
			end
		) as total_point
from sales s 
join menu m 
on s.product_id = m.product_id
group by s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select 
	s.customer_id,
	sum(
		case 
			when s.order_date BETWEEN mem.join_date AND date_add(mem.join_date, INTERVAL 7 DAY) then m.price * 2
			else m.price 
			end
		) as total_point
from sales s 
join menu m 
	on s.product_id = m.product_id
join members mem
	on s.customer_id = mem.customer_id
where s.order_date < date('2024-01-31') and s.customer_id in ('A','B')
group by s.customer_id;
