CREATE DATABASE Zomato_Case_Study;
USE Zomato_Case_Study;

/*CREATING TABLE FOR goldusers_signup*/
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date DATE);

/*INSERT VALUE INTO goldusers_signup*/
INSERT INTO goldusers_signup(userid,gold_signup_date) VALUES (1,'2017-09-22'),
(3,'2017-04-21');


/*CREATING TABLE FOR users*/
drop table if exists users;
CREATE TABLE users(userid integer,signup_date DATE); 

/*INSERT VALUE INTO users*/

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

/*INSERT VALUE INTO sales*/

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date DATE,product_id integer); 

/*INSERT VALUE INTO sales*/

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

/*CREATING TABLE FOR products*/


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

/*INSERT VALUE INTO product*/

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

/*QUESTION BASED ON ABOVE DATA SETS*/

-- 1. what is the totoal amaount each customer spen on the zomato
SELECT s.userid,SUM(p.price) AS 'Total_Spent'
FROM sales AS s INNER JOIN product AS p
ON s.product_id = p.product_id
GROUP BY s.userid ORDER BY s.userid;

-- 2. How many days each customer visited zomato
SELECT u.userid,COUNT(s.created_date) AS 'Days_Visited'
FROM users AS u INNER JOIN sales AS s
ON u.userid = s.userid
GROUP BY s.userid ORDER BY s.userid;

-- 3.What was the first purchased by each customers?

WITH RECURSIVE my_cte AS(
	SELECT *,ROW_NUMBER() OVER(PARTITION BY userid ORDER BY product_id) AS 'first_cust'
    FROM sales
)
SELECT m.userid,p.product_name
FROM my_cte AS m INNER JOIN
product AS p ON m.product_id = p.product_id
WHERE m.first_cust = 1; 

-- 4.what is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT userid,COUNT(product_id)
FROM sales
WHERE product_id = (
					SELECT product_id
					FROM sales
					GROUP BY product_id ORDER BY COUNT(created_date)  DESC limit 1)
GROUP BY userid ORDER BY userid;         

-- 5.which item was the most popular for each of the customer?   
SELECT *,RANK() OVER(PARTITION BY userid ORDER BY cnt DESC) FROM
(SELECT userid,product_id,COUNT(product_id) AS 'cnt' FROM sales GROUP BY userid,product_id ORDER BY userid) a;

SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

-- 6.which item was purchased first by the customer after they become member
SELECT b.* FROM
(SELECT a.*,rank() OVER(PARTITION BY userid ORDER BY created_date) rnk FROM
(SELECT s.userid,s.created_date,s.product_id,g.gold_signup_date
FROM sales AS s INNER JOIN goldusers_signup AS g ON g.userid = s.userid
WHERE s.created_date >= g.gold_signup_date) AS a) b WHERE rnk = 1;

-- 7.whats is the total order and price spent for each customer before they become a member?
SELECT userid,COUNT(created_date),SUM(price) FROM
(SELECT a.*,p.price FROM
(SELECT s.userid,s.product_id,g.gold_signup_date,s.created_date
FROM goldusers_signup AS g INNER JOIN sales AS s
ON g.userid = s.userid
WHERE s.created_date<=g.gold_signup_date) a INNER JOIN product AS p
ON p.product_id = a.product_id) AS b
GROUP BY userid ORDER BY userid;

-- if each product genetares points for Eg. 5rs = 2 zemotopi=oints and each product have
-- diffrent purchasing points for eg p1 5rs = 1 zomato point, p2 10rs = 1 zomato point,
-- p3 5rs = 1 zomato point, calc point collected by each customers and for which product
-- most points have been given till now.
SELECT userid,SUM(total_score) AS zomato_point FROM
(SELECT b.*,(amt/point) AS total_score FROM
(SELECT a.*,
CASE
	WHEN product_id=1 THEN 5
    WHEN product_id=2 THEN 2
    WHEN product_id=3 THEN 5
END AS point FROM    
(SELECT s.userid,p.product_id,SUM(p.price) AS amt
FROM product AS p INNER JOIN sales AS s
ON s.product_id = p.product_id
GROUP BY s.userid,p.product_id ORDER BY s.userid) AS a) AS b) AS c GROUP BY userid;


























