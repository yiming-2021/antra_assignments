--Answer following questions
	--1. In SQL Server, assuming you can find the result by using both joins and subqueries, which one would you prefer to use and why?
		-- In general, join is preferred and runs faster than subqueries in most cases. Because for using join, the RDBMS would create an excution plan on what data to load a process, but for subqueries, all the data would be loaded and processed.
		
	--2. What is CTE and when to use it?
		-- CTE stands for Common Table Expression which is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. It is used when we want to reference a derived table multiple times in a single query or performing the same calculation multiple times over across multiple query components.

	--3. What are Table Variables? What is their scope and where are they created in SQL Server?
		-- Table varianbles are special local variables to help store data temporarily. Table variables would be out of scope at the end of the batch, and they are stored in the tempdb database.


	--4. What is the difference between DELETE and TRUNCATE? Which one will have better performance and why?
		-- DELETE is a DML which is used to remove the specified rows of a table; TRUNCATE is a DDL which will remove all the rows in the table. TRUNCATE is faster because it doesn't scan all the records before removing.


	--5. What is Identity column? How does DELETE and TRUNCATE affect it?
		-- Identity column is an integer column whose values are automatically generated from a system-defined sequence. DELETE statement does not reset the identity column but TRANCATE does.

	--6. What is difference between “delete from table_name” and “truncate table table_name”?
		-- DELETE statement removes records one at a time, but TRUNCATE statement removes all rows in a table by deallocating the pages that are used to store the table data.


--Write queries for following scenarios
--All scenarios are based on Database NORTHWND.
use Northwind
go

	--1. List all cities that have both Employees and Customers.
	select distinct e.City
	from Employees e
	inner join
	Customers c
	on e.City = c.City



	--2. List all cities that have Customers but no Employee.
		--a. Use sub-query
		select distinct c.City
		from customers c
		where c.City not in 
			(select e.city from Employees e)

		--b. Do not use sub-query
		select distinct c.City
		from Customers c
		left join 
		Employees e
		on c.City = e.City
		where e.city is null


	--3. List all products and their total order quantities throughout all orders.
	select p.ProductID, sum(od.Quantity) totalOrder
	from Products p
	left join 
	[Order Details] od
	on p.ProductID = od.ProductID
	group by p.ProductID

	--4. List all Customer Cities and total products ordered by that city.
	select c.City, sum(od.Quantity) total
	from Customers c
	left join Orders o
	on c.CustomerID = o.CustomerID
	left join [Order Details] od
	on od.OrderID = o.OrderID
	group by c.City


	--5. List all Customer Cities that have at least two customers.
		--a. Use union
		--b. Use sub-query and no union
		select c.City from Customers c
		group by c.City
		having count(c.customerid) >= 2
		-- There is no need to use union or subquery.

	--6. List all Customer Cities that have ordered at least two different kinds of products.
		-- if the question means cities from which at least 2 kinds of products are ordered:
		select c.City
		from Customers c
		left join Orders o
		on c.CustomerID = o.CustomerID
		left join [Order Details] od
		on od.OrderID = o.OrderID
		group by c.City
		having count(od.ProductID) >=2 
		-- if the question means cities of the customers who ordered at least 2 kinds of products:
		select c.City
		from Customers c
		where c.CustomerID in 
		(select o.customerid from Orders o, [Order Details] od where o.OrderID = od.OrderID group by o.CustomerID having count(distinct od.ProductID) >=2)


	--7. List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.
		select distinct c.ContactName
		from Orders o
		left join Customers c
		on o.CustomerID = c.CustomerID 
		where c.City != o.ShipCity

	--8. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
		with fiveMostPopularProducts
		as 
		(
		select top 5 od.ProductID 
		from [Order Details] od
		group by od.productID
		order by sum(od.quantity) desc
		),
		customerCityOrderedQuantity
		as
		(select f.ProductID, c.City, sum(od.Quantity) as total
		from Customers c, fiveMostPopularProducts f, [Order Details] od, Orders o
		where c.CustomerID = o.CustomerID and o.OrderID = od.OrderID and f.ProductID = od.ProductID
		group by  f.ProductID, c.City)
			   
		select p.ProductName, p.UnitPrice, t2.City cityOrderedMost
		from Products p
		join fiveMostPopularProducts
		on p.ProductID = fiveMostPopularProducts.ProductID
		join 
		(select ccoq.ProductID, ccoq.City from customerCityOrderedQuantity ccoq, 
			(select ProductID, max(total) maxQ from customerCityOrderedQuantity group by ProductID) t
		where ccoq.total = t.maxQ) t2
		on p.ProductID = t2.ProductID

	--9. List all cities that have never ordered something but we have employees there.
		--a. Use sub-query
		select distinct e.City
		from Employees e
		where e.City not in 
		(select ShipCity from Orders)


		--b. Do not use sub-query
		select distinct e.City
		from Employees e
		left join orders o
		on e.City = o.ShipCity
		where o.ShipCity is null

	--10. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
		select  t1.ShipCity from 
		(select top 1 o.ShipCity, count(o.OrderID) orderNum from Orders o group by o.ShipCity order by count(o.OrderID) desc) t1
		join
		(select top 1 o.ShipCity, sum(od.Quantity) totalProducts from [Order Details] od, Orders o where od.OrderID = o.OrderID group by o.ShipCity order by sum(od.Quantity) desc) t2
		on t1.ShipCity = t2.ShipCity

	--11. How do you remove the duplicates record of a table?
		-- We can use cte to achieve that as such:
			--with CTE 
			--as
			--(
			--select *,ROW_NUMBER() OVER (PARTITION BY col1,col2,col3 ORDER BY col1,col2,col3) as RN
			--from tableName
			--)
			--delete from CTE where RN<>1


	--12. Sample table to be used for solutions below- Employee ( empid integer, mgrid integer, deptid integer, salary integer) Dept (deptid integer, deptname text)

		-- Find employees who do not manage anybody.
		
		create database temp
		use temp 
		go

		create table Employee
		(
		  empid int NOT NULL PRIMARY KEY,
		  mgrid int NULL,
		  deptid int,
		  salary int
		)
		create table Dept
		(
		  deptid int NOT NULL PRIMARY KEY,
		  deptname CHAR(20)
		)
		INSERT INTO Employee VALUES (1, NULL, 1, 120000)
		INSERT INTO Employee VALUES (2,  1, 1, 80000)
		INSERT INTO Employee VALUES (3,  1, 2, 80000)
		INSERT INTO Employee VALUES (4,  2, 1, 60000)
		INSERT INTO Employee VALUES (5,  2, 1, 65000)
		INSERT INTO Employee VALUES (6,  3, 2, 70000)
		INSERT INTO Employee VALUES (7,  3, 2, 60000)
		INSERT INTO Employee VALUES (8,  5, 1, 45000)
		INSERT INTO Employee VALUES (9,  6, 2, 46000)
		INSERT INTO Employee VALUES (10, 6, 3, 45000) 
		
		INSERT INTO Dept VALUES (1, 'Technology')
		INSERT INTO Dept VALUES (2, 'Marketing')
		INSERT INTO Dept VALUES (3, 'HR')

		select m.empid from Employee m 
		left join Employee e
		on m.empid = e.mgrid
		where e.mgrid is null



	--13. Find departments that have maximum number of employees. (solution should consider scenario having more than 1 departments that have maximum number of employees). Result should only have - deptname, count of employees sorted by deptname.
		select deptid, count(e.empid) empNum
		from Employee e
		group by deptid
		order by count(e.empid) desc

	--14. Find top 3 employees (salary based) in every department. Result should have deptname, empid, salary sorted by deptname and then employee with high to low salary.
		select d.deptid Department, e1.empid Employee, e1.Salary Salary
		from Employee  e1
		join Dept d
		on e1.deptid = d.deptid
		where 3 > (
           select COUNT(DISTINCT Salary)
           from Employee e2
           where e2.Salary > e1.Salary
           and e1.deptid = e2.deptid
          )
		order by Department, Salary desc;