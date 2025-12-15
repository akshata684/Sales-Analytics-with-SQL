SELECT * FROM collage.`product-sales-region(sheet1)`;
create database collage;
rename table `product-sales-region(sheet1)` to data;
use collage;
select * from data;
select count(*) from data;

select sum(sales) from data;
-- 1 Display unique Products
select distinct(Product) from data;

-- 2 Retrieve all orders made in the "North" region.
select * from data where Region='North';

-- 3 count total orders where Quantity > 10.
select count(*) from data where Quantity>10;

-- 4 Find all orders where PaymentMethod = "Credit Card".
select * from data where PaymentMethod="Credit Card";

-- 5 Count how many orders were Returned.
select count(Returned) from data where Returned=1;

-- 4 Count total number of orders.
select count(OrderID) from data;

-- 5 Count total customers.
select count(distinct(CustomerName)) from data;

-- 6 Find average UnitPrice.
select avg(UnitPrice) from data;

-- 7 Find maximum TotalPrice.
select max(TotalPrice) from data;

-- 8 Total Quantity sold overall.
select sum(Quantity) from data;

-- 9 Total  Quantity sold by Region.
select Region,sum(Quantity) from data group by Region;

-- Add the sales column
alter table data add column sales decimal(10,2);
update data set sales=TotalPrice*(1-Discount)+ShippingCost;

-- 10 Total sales by Region.
select Region, sum(sales) from data group by Region;

-- 11 Total sales by StoreLocation.
select StoreLocation, sum(sales) from data group by StoreLocation;

-- 12 Count of orders by PaymentMethod.
select PaymentMethod, count(OrderID) from data group by PaymentMethod;

-- 13 Average Discount given by CustomerType.
select CustomerType, avg(Discount) from data group by CustomerType;

-- 14 Show StoreLocations where total sales > 10,000.
select StoreLocation,sales from data having sales>10000;

-- 15 Show Regions where average Quantity > 5.
select region,Quantity from data having Quantity>5;

-- 16 Show products where total quantity sold is more than 500.
select Product,sum(Quantity) as total_quantity from data group by Product having total_quantity>500;

-- 17 Show salespeople whose total revenue is more than 10,000.
select Salesperson,sum(sales) as total_sales from data group by Salesperson having total_sales>10000;

-- 18 Show customer types with an average discount greater than 10%.
select CustomerType,avg(Discount) as avg_dis from data group by CustomerType having avg_dis>0.10;

-- 19 List products where the average unit price is higher than 100.
select Product, avg(UnitPrice) from data group by Product having avg(UnitPrice)>100;

-- 20 Show regions where the total number of returned orders is more than 10.
select region,sum(returned) from data group by region having sum(returned)>50;

-- 21 Show Salesperson whose total sales is greater than the overall average Salesperson sales.
select Salesperson,sum(sales) total_sales from data group by Salesperson having total_sales>(select avg(sales) from data);

-- 22 Show products where total discount given is more than the average discount for all products.
select Product,sum(Discount) as total_discount 
from data group by Product having 
sum(Discount)>(select avg(product_dis) 
from (select sum(Discount) as product_dis 
from data group by Product) as t);

-- 23 Identify the top 5 products contributing the highest revenue.
select Product, sum(sales) as total_sales from data group by Product order by total_sales desc limit 5;

-- 24 Find the products whose return rate is higher than the overall return rate.
select Product,sum(Returned)*100/count(*) as product_return_rate
from data group by product
having (product_return_rate)>(select sum(Returned)*100/count(*) from data);

-- 25 Who are the customers with the highest return ratio?
select CustomerName,sum(Returned)*100/count(*) as return_ratio from data group by CustomerName order by return_ratio desc;

-- 26 List customers whose average order value is higher than the company’s overall AOV.
select CustomerName,sum(sales)/count(distinct(OrderID)) as cus_AOV from data group by CustomerName 
having sum(sales)/count(distinct(OrderID))>(select sum(sales)/count(distinct(OrderID)) as comp_AOV from data);

-- 27 Identify the most profitable customer type (Retail / Wholesale).
select CustomerType,sum(sales) as total_sales from data group by CustomerType order by total_sales desc limit 1;

-- 28 Find regions where the total revenue > average revenue of all regions.
select Region,sum(sales) as total_sales 
from data group by Region 
having sum(sales)>(select avg(region_total) 
from (select sum(sales) as region_total 
from data group by Region) as t);

-- 29 Show month-over-month revenue change.
select month(OrderDate) as Month_no,
monthname(OrderDate) as sales_month,sum(sales) as total_sales 
from data group by Month_no,sales_month order by Month_no;

-- 30 Identify loyal customers (most repeat orders).
select CustomerName,count(distinct OrderID) as total_orders from data group by CustomerName order by total_orders desc;

-- 31 Find products with highest return rate.
select Product,sum(Returned)*100/count(*) as return_rate from data group by Product order by return_rate desc;

-- 32 Identify underperforming regions (sales < 30%).
select Region,sum(sales) as region_sales,round(sum(sales)*100/(select sum(sales) from data),2)as sales_per
from data group by Region having sales_per<20;

-- 33 Create a Region-wise sales summary (total, avg, min, max).
select Region,sum(sales) as total_sales,avg(sales) as avg_sales,min(sales) as min_sales,max(sales) as max_sales
 from data group by Region;
 
-- 34 Create a Product performance report (sales, quantity, return rate).
select Product,sum(sales) as total_sales,
sum(Quantity) as total_quantity,sum(Returned)*100/count(*) as return_rate from data
group by Product;

-- 35 Calculate each Salesperson’s contribution % to total company revenue.
select Salesperson,sum(sales) as total_sales,round(sum(sales)*100/(select sum(sales) from data),2) as sales_per
from data group by Salesperson;

-- 36 Find top 5 customers based on total spending.
select CustomerName,sum(TotalPrice) as total_spending from data group by CustomerName order by total_spending desc limit 5;

-- 37 Analyze fastest delivery store locations (avg delivery days).
select StoreLocation,round(avg(datediff(DeliveryDate, OrderDate)),2) as delivery_days from data group by StoreLocation;

-- 38 Identify seasonal trends using OrderDate year.
select year(OrderDate) as year_name,sum(sales) as total_sales from data group by year_name;

-- 39 Do high discounts increase quantity? (Group by discount ranges)
select Discount,sum(Quantity) as total_quantity from data group by Discount order by total_quantity desc;

-- 40 Count rows with NULL values.
select count(*) as total_rows from data where 
Region is null or Product is null or Quantity is null or StoreLocation is null or 
Salesperson is null or TotalPrice is null or PaymentMethod is null or OrderID is null;

-- 41 Create a function to calculate total revenue for a given product name.
DELIMITER $$
create procedure product(IN prod_name varchar(20))
begin
select Product,sum(sales) as total_sales from data where Product=prod_name group by Product;
end $$
DELIMITER ;
call product('Desk');

-- 42 Create a stored procedure that returns delivery duration (in days) when OrderID is passed.
DELIMITER $$
CREATE PROCEDURE duration5(IN Order_id VARCHAR(20))
BEGIN
    SELECT OrderID,
           SUM(DATEDIFF(DeliveryDate, OrderDate)) AS delivery_duration
    FROM data
    WHERE OrderID = Order_id
    GROUP BY OrderID;
END $$
DELIMITER ;
call duration5('REG100022');

-- 43 Classify each order as High / Medium / Low Value based on TotalPrice.
select sales, case
				when sales>4000 then 'high'
				when sales between 2000 and 4000 then 'medium'
				else 'low' end as sales_category from data;


-- 44 Categorize customers based on total spending:
-- Premium
-- Regular
-- Low Value
select CustomerName,case
						when TotalPrice>5000 then 'Premium'
                        when TotalPrice between 2000 and 5000 then 'Regular'
                        else 'Low Value' end as customer_category from data;


-- 45 Create discount slabs:No Discount Low Discount (1–10%) Medium Discount (11–30%) Heavy Discount (>30%)
select Discount,case when
						Discount=0 then 'No Discount'
                        when Discount between 0.1 and 0.10 then 'Medium Discount'
                        else 'Heavy Discount' end as 'discount_slabs' from data;

-- 46 Classify regions as High Performing / Low Performing based on average sales.
select Region,case when avg(sales)>(select avg(sales) from data)
then ' High Performing'
else 'Low Performing' end as region_performance from data group by Region;

-- 47 Categorize products based on return rate:
-- High Return
-- Medium Return
-- Low Return
select Product,round(sum(Returned)*100/count(*),2), case when
							sum(Returned)*100/count(*)>20 then 'High Return'
							when sum(Returned)*100/count(*) between 10 and 20 then 'Medium Return'
							else 'Low Return' end as rate from data group by Product;
                            
  -- 48 Find total sales for the year 2024 only.
  select year(OrderDate) as year_name,sum(sales) as total_sales from data group by year_name having year_name=2024;

-- 49 Find orders where delivery took more than 7 days.
select OrderID, datediff(DeliveryDate,OrderDate) as delivery_days from data having delivery_days>7;

-- 50 Find the average delivery time per region.
select Region,avg(datediff(DeliveryDate,OrderDate)) as delivery_days from data group by Region;

-- 51 Count number of orders placed each year.
select year(OrderDate) as year_name,count(OrderID) as Total_Orders from data group by year_name;

-- 52 Find sales generated in the last 30 days.
select sum(sales) as sales_last_30_days from data where OrderDate>=(select max(OrderDate) from data
)- interval 30 day;

-- 53 Find orders where TotalPrice is greater than the average TotalPrice.
select * from data where TotalPrice>(select avg(TotalPrice) from data);

-- 54 Find products whose total sales are greater than the average product sales.
select Product,sum(sales) as total_sales from data
group by Product having sum(sales)>(select avg(Product_sales) from(select sum(sales) as product_sales from data
group by Product)as t);

-- 55 Find customers who spent more than the average customer spending.
select CustomerName,sum(TotalPrice) as total_spent
from data group by CustomerName having sum(TotalPrice)>(select avg(customer_spending)
from (select sum(TotalPrice) as customer_spending from data group by CustomerName)as t);

-- 56 Find salespeople whose total sales are greater than the average salesperson sales.
select Salesperson,sum(sales) as total_sales from data group by Salesperson having sum(sales)>(select avg(Salesperson_sales)
from (select sum(sales) as Salesperson_sales from data group by Salesperson)as t);

-- 57 Find store locations whose average shipping cost is greater than the company average shipping cost.
select StoreLocation,avg(ShippingCost) as avg_ShippingCost from data StoreLocation group by StoreLocation
having avg(ShippingCost)>(select avg(ShippingCost) from data);


-- 58 Find products whose unit price is higher than the average unit price.
select product, UnitPrice from data where UnitPrice>(select avg(UnitPrice) from data);
















