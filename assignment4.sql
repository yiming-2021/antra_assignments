--Answer following questions
	--1. What is View? What are the benefits of using views?
		-- A view is a virtual table whose content is defined by a query. Using a view, we can obtain a subset of a existing table, or join multiple tables. Also, views can save space, because it only define the table instead of store the content of the table.
	
	--2. Can data be modified through views?
		-- Yes. Data in the base table will be modified.
	
	--3. What is stored procedure and what are the benefits of using it?
		-- A stored procedure is a query which can be saved to reuse over and over again. It provides not only the higher productivity but also increased scalabity.
	
	--4. What is the difference between view and stored procedure?
		-- A view is used to simply get the snapshot of a virtual table generated from existing tables, while a stored procedure can also provide encapsulation and more complex logics on the data. 

	--5. What is the difference between stored procedure and functions?
		-- A function must return a single value, but for a stored procedure, it is optional.
		-- A function can have only input parameters, a stored procedure can have input or output parameters.
		-- A function can be called from a stored procedure, but a stored procedure cannot be called from a function.
		-- A function can only have SELECT statement in it, but a stored procedure can also have other DML statements as well.

	--6. Can stored procedure return multiple result sets?
		-- Yes.

	--7. Can stored procedure be executed as part of SELECT Statement? Why?
		-- No. Because unlike functions, a stored procedure doesn't have to return a value.

	--8. What is Trigger? What types of Triggers are there?
		-- A trigger is a special stored precedure which would automatically run when an event occurs. There are DDL trigger, DML trigger and LOGON trigger.


	--9. What are the scenarios to use Triggers?
		-- Triggers are often used when we want to enforce some complex integrity of data. 


	--10. What is the difference between Trigger and Stored Procedure? 
		-- Stored procedures are run when they are explicitly called; while triggers are run automatically when some events occur. 

--Write queries for following scenarios
	--Use Northwind database. All questions are based on assumptions described by the Database Diagram sent to you yesterday. When inserting, make up info if necessary. Write query for each step. Do not use IDE. BE CAREFUL WHEN DELETING DATA OR DROPPING TABLE.
	use Northwind
	go


	--1. Lock tables Region, Territories, EmployeeTerritories and Employees. Insert following information into the database. In case of an error, no changes should be made to DB.
		--a. A new region called “Middle Earth”;
		BEGIN TRAN
		insert Region values(5, 'Middle Earth');

		--b. A new territory called “Gondor”, belongs to region “Middle Earth”;
		--select * from EmployeeTerritories
		--select * from Territories
		insert Territories values ('99999', 'Gondor',5);

		--c. A new employee “Aragorn King” who's territory is “Gondor”.
		select * from EmployeeTerritories
		insert Employees(LastName, FirstName,Region) values ('Aragorn','King','Middle Earth')
		insert EmployeeTerritories values(10,99999)
		

		--select * from Region
		--select * from Territories
		--select * from EmployeeTerritories

	--2. Change territory “Gondor” to “Arnor”.

		update Territories 
		set TerritoryDescription = 'Arnor'
		where TerritoryDescription = 'Gondor'


	--3. Delete Region “Middle Earth”. (tip: remove referenced data first) (Caution: do not forget WHERE or you will delete everything.) In case of an error, no changes should be made to DB. Unlock the tables mentioned in question 1.
		delete from Region 
		where RegionDescription = 'Middle Earth';
		
		ROLLBACK
	
	--4. Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
		create view view_product_order_gu 
		AS
		select p.ProductID, sum(od.Quantity) totalOrdered
		from Products p
		left join [Order Details] od
		on p.ProductID = od.ProductID
		group by p.ProductID;
		
	--5. Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
		CREATE PROC sp_product_order_quantity_gu
		@Productid int
		as
		select totalOrdered
		from view_product_order_gu 
		where ProductID = @Productid;
		GO

		EXEC sp_product_order_quantity_gu @Productid = 1;


	--6. Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
		CREATE PROC sp_product_order_city_gu
		@ProductName nvarchar(40)
		as
		select top 5 o.ShipCity, sum(od.Quantity) totalQuantity
		from Products p 
		join [Order Details] od
		on p.ProductID = od.ProductID
		join Orders o
		on od.OrderID = o.OrderID
		where p.ProductName = @ProductName
		group by o.ShipCity
		order by totalQuantity desc
		go

		EXEC sp_product_order_city_gu @ProductName = 'Chang';

		
	--7. Lock tables Region, Territories, EmployeeTerritories and Employees. Create a stored procedure “sp_move_employees_[your_last_name]” that automatically find all employees in territory “Tory”; if more than 0 found, insert a new territory “Stevens Point” of region “North” to the database, and then move those employees to “Stevens Point”.
		BEGIN TRAN
		CREATE PROCEDURE sp_move_employees_gu
		as
		BEGIN
			--declare @toryNum int

			--select @toryNum = count(distinct et.EmployeeID), @toryid = et.EmployeeID
			--from EmployeeTerritories et, Territories t
			--where t.TerritoryDescription = 'Tory' and et.TerritoryID = t.TerritoryID

			--if (@toryNum > 0)
			--Begin
				insert Territories values ('99998', 'Stevens Point',3);
				UPDATE EmployeeTerritories
				SET TerritoryID = 99998
				WHERE EmployeeID in (select  et.EmployeeID
			from EmployeeTerritories et, Territories t
			where t.TerritoryDescription = 'Troy' and et.TerritoryID = t.TerritoryID)
			--end
			--else begin
			--	return @torynum
			--end
		end


		ROLLBACK
	
	--8. Create a trigger that when there are more than 100 employees in territory “Stevens Point”, move them back to Troy. (After test your code,) remove the trigger. Move those employees back to “Troy”, if any. Unlock the tables.
		BEGIN TRAN
		CREATE TRIGGER triggerMove ON EmployeeTerritories
		FOR INSERT AS
		BEGIN
		   UPDATE EmployeeTerritories
			SET TerritoryID = 99998
		END

		ROLLBACK

	--9. Create 2 new tables “people_your_last_name” “city_your_last_name”. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”. Create a view “Packers_your_name” lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
		create table people_gu (id int, Name nvarchar(20), City int)
		insert people_gu values (1, 'Aaron Rodgers',2)
		insert people_gu values (2, 'Russell Wilson',1)
		insert people_gu values (3, 'Jody Nelson',2)

		create table city_gu (id int, City nvarchar(20))
		insert city_gu values (1, 'Seattle')
		insert city_gu values (2, 'Green Bay')
		
		DELETE FROM city_gu WHERE City = 'Seattle'
		insert city_gu values (3, 'Madison')
		UPDATE people_gu
		set city = 3
		where city = 1

		select * from city_gu
		select * from people_gu


		create view Packers_Yiming
		as 
		select name 
		from people_gu p,  city_gu c
		where p.City = c.id and c.City = 'Green Bay'

		drop table people_gu, city_gu
		drop view Packers_Yiming
		
	--10.  Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
		create procedure sp_birthday_employees_gu
		as 
			Select * into birthday_employees_gu  from  Employees  where MONTH(BirthDate) = 2
		go

		EXEC sp_birthday_employees_gu
		Drop table birthday_employees_gu




	--11. Create a stored procedure named “sp_your_last_name_1” that returns all cites that have at least 2 customers who have bought no or only one kind of product. Create a stored procedure named “sp_your_last_name_2” that returns the same but using a different approach. (sub-query and no-sub-query).
		create proc sp_your_gu_1
		as
		select City
		from Customers
		where CustomerID in (
			select o.CustomerID
			from Orders o, [Order Details] od
			where o.OrderID = od.OrderID
			group by o.CustomerID
			having count(distinct od.ProductID) <= 1)
		group by city
		having count(CustomerID) >= 2


	--12. How do you make sure two tables have the same data?
		-- We can use UNION statement to combine 2 tables. If there are different data, the row number of the output would be larger than the original 2 tables. Otherwise, it should be exactly same as the 2 tables.

	--14.
		--First Name  --Last Name  --Middle Name
		--John				--Green
		--Mike				--White			 --M
	--Output should be
		--Full Name
		--John Green
		--Mike White M.
		--Note: There is a dot after M when you output.

		create table ##nameTable (FirstName nvarchar(20), LastName nvarchar(20), MiddleName nvarchar(5))
		insert ##nameTable values ('John','Green','')
		insert ##nameTable values ('Mike','White','M')

		select case 
			when MiddleName = '' then CONCAT(FirstName, ' ', LastName)
			else CONCAT(FirstName, ' ', LastName, ' ', MiddleName, '.')
			end as 'Full Name'
		from ##nameTable


	--15.
	--Student		--Marks		--Sex
	--Ci				--70			--F
	--Bob				--80			--M
	--Li				--90			--F
	--Mi				--95			--M

	--Find the top marks of Female students.
	--If there are to students have the max score, only output one.
	
		create table ##studentMarks (Student nvarchar(20), Marks int, Sex nvarchar(1))
		insert ##studentMarks values ('Ci',70,'F')
		insert ##studentMarks values ('Bob',80,'M')
		insert ##studentMarks values ('Li',90,'F')
		insert ##studentMarks values ('Mi',95,'M')
		
		select top 1 Student, Marks from ##studentMarks where sex = 'F' order by Marks desc

	--16.
	--Student		--Marks			--Sex
	--Li				--90				--F
	--Ci				--70				--F
	--Mi				--95				--M
	--Bob				--80				--M

	--How do you out put this?
		select *
		from ##studentMarks
		order by sex, marks desc
