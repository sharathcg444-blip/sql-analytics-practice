create table sales(
transaction_id varchar(100),	
customer_id	varchar(100),
customer_name varchar(200),	
customer_age integer,
gender varchar(50),
product_id varchar(100),
product_name varchar(150),
product_category varchar(150),
quantity integer,
price numeric(10,2),
payment_mode varchar(150),
purchase_date date,
time_of_purchase time,
status varchar(150)
)
select * from sales
drop table sales;


/* 1. Display all records from the sales table. */
select * from sales;


/* 2. Find the total number of orders placed. */
select count(distinct transaction_id) as number_of_order_placed from sales;

/* 3. Show the distinct product categories available. */
select distinct product_category from sales;

/* 4. Calculate the total revenue generated from all sales. */
select sum(price * quantity) as total_revenue from sales;


/* 5. Find the total sales amount for each category. */
select product_category,sum(price*quantity) from sales
group by  product_category;

/* 6. Display the top 5 products with the highest sales value. */
  select product_name, sum(price*quantity) from sales
  group by product_name  order by sum(price*quantity) desc limit 5;  

/* 7. Count how many orders each customer has placed. */
     select customer_name,count(distinct transaction_id) from sales
	 group by customer_name order by sum(quantity) desc;

/* 8. Find the average order value across all orders. */
   select round(sum(price*quantity)/count(distinct transaction_id),2) from sales

/* 9. Show the maximum and minimum sales amount in the table. */
  select max(price*quantity)as max_sales,min(price*quantity) as min_sales from sales;
  
/* 10. Retrieve all orders placed in the year 2024. */

select * from sales where purchase_date >= '2024-01-01'
  and purchase_date < '2025-01-01';



/* 11. Find monthly total sales grouped by year and month. */
 select product_category,extract(month from purchase_date) 
 as month_wise,extract(year from purchase_date),sum(price * quantity) from sales
 group by product_category,extract(month from purchase_date),extract(year from purchase_date) 
 order by product_category,extract(month from purchase_date),extract(year from purchase_date);

/* 12. Rank products by total sales amount within each category. */
   
with total_sales as(select product_category,product_name,sum(price*quantity) as product_sales
from sales group by product_category,product_name order by product_category,product_name,product_sales
),

ranked_products as(select product_category,product_name,product_sales,rank() 
over(partition by product_category order by product_sales desc ) as rnk
from total_sales)
select
 product_category,
    product_name,
    product_sales,
    rnk
	from ranked_products
where rnk <3
ORDER BY product_category, rnk;


/* 13. Identify customers who have spent more than the average spending. */
 with total_sales as(select customer_id,customer_name,sum(price*quantity) as amt_spent from sales
 group by customer_id,customer_name  )
 select customer_id,customer_name,amt_spent from total_sales
 where amt_spent >(select avg(amt_spent) from total_sales) order by amt_spent desc;

 select * from sales

/* 14. Find the cumulative (running) total of sales ordered by date. */
select customer_name,purchase_date,sum(price*quantity) as tot_sal, sum(sum(price*quantity))
over(order by purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) from sales
group by customer_name,purchase_date order by purchase_date;





/* 15. Calculate the percentage contribution of each category to total sales. */
SELECT
    product_category,
    SUM(price * quantity) AS category_sales,
    ROUND(
        SUM(price * quantity) * 100.0 / (SELECT SUM(price * quantity) FROM sales),
        2
    ) AS percentage_of_total
FROM sales
GROUP BY product_category;





/* 16. Find the second highest sales amount from the table. */
 with total_sales as(select product_category,product_name,sum(price*quantity) as product_sales from sales
 group by product_category,product_name),
 ranking as(select product_category,product_name,product_sales,rank() 
 over(order by product_category,product_name,product_sales) as rnk from total_sales)
 select product_category, product_name, product_sales, rnk
 from ranking
 where rnk=2;
 
 

/* 17. Show orders where the quantity sold is greater than the average quantity. */
    with total_orders as (select product_category,customer_name,sum(quantity) as quant_sold from sales
	group by product_category,customer_name)
	select product_category,customer_name,quant_sold from total_orders
	where quant_sold > (select avg(quant_sold) from total_orders) order by quant_sold desc;

/* 18. Find the first and last order date for each customer. */
select customer_id,customer_name,
min(purchase_date) as first_purchase_date,
max(purchase_date) as second_purchase_date
from sales group by customer_id,customer_name order by customer_name;

/* 19. Detect duplicate records based on order_id and product_id. */
 select transaction_id,customer_id,customer_name,count(*) from sales
 group by transaction_id,customer_id,customer_name
 having count(*)>1;
select * from sales;
 /* 20. Find customers who purchased products from more than 3 different categories. */
 select customer_name,count(distinct product_category) as cat_count from sales
 group by customer_name 
 having count(distinct product_category)>3;
  

/* 21. Find the first purchase date for each customer. */
 SELECT
    customer_name,
    MIN(purchase_date) AS first_purchase_date
FROM sales
GROUP BY customer_name
ORDER BY customer_name;


/*22. Find orders where the total quantity of items is greater than the average order quantity. */
with avg_tot as(select customer_id,customer_name,
  sum(quantity) as total_quantity,
  avg(sum(quantity)) over() as avg_quantity from sales  group by customer_id,customer_name )
  select customer_id,customer_name,total_quantity from avg_tot
  where total_quantity > avg_quantity;

/*23. Calculate the percentage contribution of each product to total sales. */


select product_name,sum(price*quantity) as pro_sales, 
round(
sum(price*quantity)*100.00/ (select sum(price*quantity)
as contribution from sales),2) as per_by_prod
from sales
group by product_name
order by per_by_prod;



/*24. Identify the most frequently purchased product for each customer. */ 
	with prod_purchase as(select customer_name,product_name,count(*) as total_quant from sales 
	group by customer_name,product_name),ranking as(select customer_name,product_name,total_quant,
	rank() over(partition by customer_name order by total_quant desc)as rnk from prod_purchase)
	select customer_name,product_name,total_quant from ranking
	where rnk =1;


/*25. Find categories where total revenue is above the category average revenue. */
  with tot_revenue as(select product_category,sum(price*quantity) as total_sales from sales 
  group by product_category)
  select product_category,total_sales from tot_revenue
  where total_sales > (select avg(total_sales) from tot_revenue);



/*26. Find the top 1 product per category based on revenue using window functions. */ 
with product_sales as(select product_category,product_name,sum(price*quantity) as total_sales from sales
group by product_category,product_name),
ranking_wise as(select product_category,product_name,total_sales,rank() over(partition by product_category
order by total_sales desc) as rnk from product_sales)
select 
product_category,product_name,total_sales,rnk from ranking_wise
where rnk = 1;

27./*Find the most recent purchase date for each customer*/

select  customer_name,max(purchase_date) from sales group by customer_name ;

28./* Find total sales amount for each product */

select product_category,sum(price*quantity) as tot_sales from sales 
group by product_category order by tot_sales


29./*Find customers who have placed more than one order*/
select customer_name, count(customer_id) from sales  group by customer_name
having count(customer_id)>1 order by count(customer_id) desc;





