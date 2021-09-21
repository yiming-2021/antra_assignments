--Answer following questions
	--1. What is an object in SQL?
		-- An object is any SQL Server resource, including schemas, journals, catalogs, tables, aliases, views, indexes, constraints, triggers, sequences, stored procedures, user-defined functions, user-defined types, global variables, and SQL packages.

	--2. What is Index? What are the advantages and disadvantages of using Indexes?
		-- Indexes are database objects based on table column for faster retrieval of data. 
		-- The major advantage of the using index is speeding up the data retrieving. 
		-- A disadvantage of index is requiring additional disk space for non-clustered index. For clustered index, if we update a record and change the value of an indexed column in a clustered index, the database might need to move the entire row into a new position to keep the rows in sorted order. This behavior essentially turns an update query into a DELETE followed by an INSERT, with an obvious decrease in performance. 

	--3. What are the types of Indexes?
		-- Clustered and non-clustered index.

	--4. Does SQL Server automatically create indexes when a table is created? If yes, under which constraints?
		-- Yes, clustered index will be created 

	--5. Can a table have multiple clustered index? Why?
		-- No. Because by the definition of clusered index, the order of the clustered index is the physical order, so we can only sort the data by one column. 

	--6. Can an index be created on multiple columns? If yes, is the order of columns matter?
		-- Yes. The order of the column matter.
		
	--7. Can indexes be created on views?
		-- No.

	--8. What is normalization? What are the steps (normal forms) to achieve normalization?
		-- In brief, normalization is a way of organizing the data in the database. Normalization entails organizing the columns and tables of a database to ensure that their dependencies are properly enforced by database integrity constraints.
		-- 1NF: tackle the problem of atomicity (a single cell cannot hold multiple values)
		-- 2NF: should not contain partial dependency (one of the composite primary keys determines a non-prime attribute.)
		-- 3NF: should be no transitive dependency for non-prime attributes (non-prime attributes dependent on other non-prime attributes)

	--9. What is denormalization and under which scenarios can it be preferable?
		-- Denormalization is a strategy used on a previously-normalized database to increase performance. When the queries to retrieve can be simpler (fewer joins) after denormalization, it is preferable.

	--10. How do you achieve Data Integrity in SQL Server?
		-- We can add constraints.
			
	--11. What are the different kinds of constraint do SQL Server have?
		-- Not Null Constraint, 
		-- Check Constraint
		-- Default Constraint
		-- Unique Constraint
		-- Primary Constraint
		-- Foreign Constraint

	--12. What is the difference between Primary Key and Unique Key?'
		--UNIQUE allows one NULL value, but PRIMARY KEY doesn't allow any
		--one table can have multiple UNIQUE constraints, but only one PRIMARY KEY constraint
		--PRIMARY KEY will sort the data in ascending order by default but UNIQUE will not sort
		--PRIMARY KEY will by default create clustered index but UNIQUE key creates non clustered index
		--PRIMARY KEY can be referred by another column but unique key can not be referred

	--13. What is foreign key?
		-- A foreign key is a column in one table, that refers to the PRIMARY KEY in another table. 
	--14. Can a table have multiple foreign keys?
		-- Yes.
	--15. Does a foreign key have to be unique? Can it be null?
		-- No. Yes.

	--16. Can we create indexes on Table Variables or Temporary Tables?
		-- Yes.

	--17. What is Transaction? What types of transaction levels are there in SQL Server?
		-- A transaction is a logical unit of work that contains one or more SQL statements, begining with the first executable SQL statement and ending when it is committed or rolled back.

--Write queries for following scenarios
	-- 1. Write an sql statement that will display the name of each customer and the sum of order totals placed by that customer during the year 2002
		Create table customer(cust_id int,  iname varchar (50)) 
		create table orders(order_id int,cust_id int,amount money,order_date smalldatetime)

		select c.iname, count(o.order_id) as totalOrder
		from customer c, orders o
		where c.cust_id = o.cust_id and year(o.order_date) = 2002


	-- 2.  The following table is used to store information about company’s personnel:
		Create table person (id int, firstname varchar(100), lastname varchar(100)) 
		-- write a query that returns all employees whose last names  start with “A”.

		select id, firstname, lastname from person p 
		where lastname like 'A%'

	--3.  The information about company’s personnel is stored in the following table:
		Create table person2(person_id int primary key, manager_id int null, name varchar(100)not null) 
		--The filed managed_id contains the person_id of the employee’s manager.
		--Please write a query that would return the names of all top managers(an employee who does not have  a manger, and the number of people that report directly to this manager.
		select m.person_id, count(p.person_id)
		from person2 p,
		(select person_id
		from person2 
		where manager_id is null) m
		where p.manager_id = m.person_id
		group by m.person_id


	--4.  List all events that can cause a trigger to be executed.
		--An INSERT , UPDATE , or DELETE statement on a specific table (or view, in some cases)
		--A CREATE , ALTER , or DROP statement on any schema object.
		--A database startup or instance shutdown.
		--A specific error message or any error message.
		--A user logon or logoff.

	--5. Generate a destination schema in 3rd Normal Form.  Include all necessary fact, join, and dictionary tables, and all Primary and Foreign Key relationships.  The following assumptions can be made:
		--a. Each Company can have one or more Divisions.
		--b. Each record in the Company table represents a unique combination 
		--c. Physical locations are associated with Divisions.
		--d. Some Company Divisions are collocated at the same physical of Company Name and Division Name.
		--e. Contacts can be associated with one or more divisions and the address, but are differentiated by suite/mail drop records.status of each association should be separately maintained and audited.

		--			Company								Division								
		--	PK	company_id	 int					PK	division_id		int					
		--		company_name char(30)				FK  company_id		int					
		--												division_name   char(30)
		--												address			nvarchar(40)
		--
		--			Contacts							Division_Contact
		--	PK  contact_id		int					PK  division_contact_id  int
		--		contact_name	char(30)			FK  division_id		int	
		--											FK  contact_id		int	
		--												mail_drop		nvarchar(40)
		