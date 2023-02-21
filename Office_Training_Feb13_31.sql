CREATE DATABASE Office_Training
GO

USE Office_Training
GO



CREATE TABLE Jobs(
	Job_Id VARCHAR(50),
	Job_Title VARCHAR(50),
	Min_Salary DECIMAL(18,2),
	Max_Salary DECIMAL(18,2),
	CONSTRAINT PK_Jobs_Job_ID PRIMARY KEY(Job_Id)
);
GO

CREATE TABLE Locations(
	Location_Id INT,
	Street_Address VARCHAR(50),
	Postal_Code VARCHAR(50),
	City VARCHAR(50),
	State_Province VARCHAR(50),
	Country_Id VARCHAR(50),
	CONSTRAINT PK_Location_ID PRIMARY KEY(Location_Id)
);
GO


CREATE TABLE Department(
	Department_id INT,
	Department_Name VARCHAR(50),
	Manager_Id INT,
	Location_Id INT,
	CONSTRAINT PK_Department_id PRIMARY KEY(Department_id),
	CONSTRAINT FK_Department_Location_Id FOREIGN KEY(Location_Id) REFERENCES Locations(Location_Id)
);
GO 



CREATE TABLE Employees(
	Employee_Id INT,
	First_Name VARCHAR(50),
	Last_Name VARCHAR(50),
	Email VARCHAR(50),
	Phone_no VARCHAR(50),
	Hire_Date DATE,
	Job_Id VARCHAR(50),
	Salary DECIMAL(18,2),
	Commission DECIMAL(18,2),
	Manager_Id INT,
	Department_Id INT,
	CONSTRAINT PK_Employee_Id PRIMARY KEY(Employee_Id),
	CONSTRAINT FK_Employees_Job_Id FOREIGN KEY(Job_Id) REFERENCES dbo.Jobs(Job_Id),
	CONSTRAINT FK_Employees_Department_Id FOREIGN KEY(Department_Id) REFERENCES Department(Department_Id)
);
GO

CREATE TABLE Job_History(
	Employee_Id INT,
	Strt_Date DATE,
	End_Date DATE,
	Job_Id VARCHAR(50),
	Department_id INT,
	CONSTRAINT FK_JH_Employee_Id FOREIGN KEY(Employee_Id) REFERENCES Employees(Employee_Id),
	CONSTRAINT FK_JH_Job_Id FOREIGN KEY(Job_Id) REFERENCES Jobs(Job_Id),
	CONSTRAINT FK_JH_Department_Id FOREIGN KEY(Department_Id) REFERENCES Department(Department_Id)
);
GO

--BULK INSERT dbo.Job_History
--FROM 'D:\job_history.csv'
--WITH
--(
--	FORMAT = 'CSV',
--	FIRSTROW = 1
--);
--Go


SELECT * FROM dbo.Jobs
SELECT * FROM dbo.Locations
SELECT * FROM dbo.Department
SELECT * FROM dbo.Employees
SELECT * FROM dbo.Job_History



----------------------------Subqueries-------------------------------
--employees who receive a higher salary than the employee with ID 163

SELECT First_Name,
       Last_Name
FROM dbo.Employees
WHERE Salary >
(
    SELECT Salary FROM dbo.Employees WHERE Employee_Id = '163'
);
GO

SELECT e1.First_Name,e1.Last_Name FROM dbo.Employees e1 
INNER JOIN (SELECT Salary FROM dbo.Employees WHERE Employee_Id = '163') e2
ON e1.Salary > e2.Salary



--find those employees who report to that manager whose first name is ‘Payam’. Return first name, last name, employee ID and salary

SELECT First_Name,
       Last_Name,
       Employee_Id,
       Salary,
	   Manager_Id
FROM dbo.Employees
WHERE  Manager_Id = 
(
    SELECT Employee_Id FROM dbo.Employees WHERE First_Name = ' Payam'
);

SELECT e1.First_Name,
       e1.Last_Name,
       e1.Employee_Id,
       e1.Salary,
	   e1.Manager_Id
FROM dbo.Employees e1
INNER JOIN (SELECT Employee_Id FROM dbo.Employees WHERE First_Name = ' Payam')e2
ON e1.Manager_id = e2.Employee_Id




--employees whose salary falls within the range of the smallest salary and 2500. Return all the fields

SELECT * FROM dbo.Employees 
WHERE Salary
BETWEEN (SELECT MIN(Salary)FROM dbo.Employees) AND 2500
 
 


--employees who earn more than the average salary and work in the same department as an employee whose first name contains the letter 'J'


SELECT e1.Employee_Id, e1.First_Name, e1.Salary,e1.Department_Id FROM dbo.Employees e1
INNER JOIN (SELECT AVG(SALARY)sal , Department_Id FROM dbo.Employees GROUP BY Department_Id) e2 
ON E1.Department_Id=E2.Department_Id
WHERE e1.First_Name LIKE '%J%'  
AND e1.Salary > e2.sal 


--employees whose salaries are higher than the average for all departments

SELECT Employee_Id,First_Name,Last_Name FROM dbo.Employees
WHERE Salary>
(
SELECT Avg(Salary) FROM dbo.Employees
)

SELECT e1.Employee_Id, e1.First_Name, e1.Last_Name FROM dbo.Employees e1 
INNER JOIN (SELECT AVG(Salary)sal FROM dbo.Employees)e2
ON e1.Salary >= e2.sal




--the employee id, name ( first name and last name ), SalaryDrawn, AvgCompare (salary - the average salary of all employees) and the SalaryStatus column with a title HIGH and LOW respectively for those employees whose salary is more than and less than the average salary of all employees. 


SELECT Employee_Id,
       First_Name + Last_Name AS Emp_Name,
	   Salary AS SalaryDrawn,
	   Salary - (SELECT AVG(Salary) FROM dbo.Employees) AS AvgCompare,
	   (SELECT (CASE WHEN (Salary > (SELECT AVG(Salary) FROM dbo.Employees)) THEN 'HIGH'
			         WHEN (Salary < (SELECT AVG(Salary) FROM dbo.Employees)) THEN 'LOW'
	   END)) AS SalaryStatus 
FROM dbo.Employees
GO


;WITH AvgSalary AS (
  SELECT AVG(Salary) AS AvgSalary
  FROM dbo.Employees
)
SELECT 
  e.Employee_Id,
  CONCAT(e.First_Name, ' ', e.Last_Name) AS Emp_Name,
  e.Salary AS SalaryDrawn,
  e.Salary - a.AvgSalary AS AvgCompare,
  CASE
    WHEN e.Salary > a.AvgSalary THEN 'HIGH'
    WHEN e.Salary < a.AvgSalary THEN 'LOW'
	ELSE 'SAME'
  END AS SalaryStatus
FROM dbo.Employees e
CROSS JOIN AvgSalary a;
GO

--CREATE TABLE #t1(
--	avgsal DECIMAL(18,2)
--)

--WITH AvgSalary AS (
--  SELECT AVG(Salary) AS AvgSalary
--  FROM dbo.Employees
--)
--INSERT INTO #t1 SELECT * FROM  AvgSalary

--SELECT * FROM #t1


DECLARE @avgsalary DECIMAL(18,2)
SET @avgsalary = (SELECT AVG(Salary) FROM dbo.Employees)

SELECT Employee_Id, CONCAT(First_Name, ' ', Last_Name) AS Emp_Name,
 Salary AS SalaryDrawn,
  Salary - @avgsalary AS AvgCompare,
  CASE
    WHEN Salary > @avgsalary THEN 'HIGH'
    WHEN Salary < @avgsalary THEN 'LOW'
  END AS SalaryStatus
FROM dbo.Employees 
Go



--employees who report to a manager based in the United States

SELECT First_Name,
       Last_Name,Manager_Id
FROM dbo.Employees
WHERE Manager_Id In
(
    SELECT Employee_Id
    FROM dbo.Employees
    WHERE Manager_Id In
    (
        SELECT Manager_Id
        FROM dbo.Department
        WHERE Location_Id In
        (
            SELECT Location_Id FROM dbo.Locations WHERE Country_Id = ' US'
        )
    )
);

SELECT DISTINCT e1.First_Name,e1.Last_Name,e1.Manager_Id FROM dbo.Employees e1
INNER JOIN dbo.Employees e2
ON e1.Manager_Id= e2.Employee_Id
INNER JOIN dbo.Department d1
ON e2.Manager_Id =d1.Manager_Id
INNER JOIN dbo.Locations l1
ON d1.Location_Id=l1.Location_Id
WHERE l1.Country_Id = ' US'




--those departments that are located in the city of London

SELECT Department_id,
       Department_Name
FROM dbo.Department
WHERE Location_Id IN
      (
          SELECT Location_Id FROM dbo.Locations WHERE City = ' London'
      );


SELECT d.Department_id,d.Department_Name FROM dbo.Department d
INNER JOIN (SELECT Location_Id,City FROM dbo.Locations)l
ON l.Location_Id = d.Location_Id
WHERE l.City = ' London'


--whose salary matches that of the employee who works in department ID 40

SELECT First_Name,
       Last_Name,
       Salary,
       Department_Id
FROM dbo.Employees
WHERE Salary =
(
    SELECT Salary FROM dbo.Employees WHERE Department_Id = 40
);

SELECT e1.First_Name,
       e1.Last_Name,
       e1.Salary,
       e1.Department_Id
FROM dbo.Employees e1
INNER JOIN (SELECT Salary FROM dbo.Employees WHERE Department_Id = 40)e2
ON e1.Salary = e2.Salary


--employees who earn less than the average salary and work at the department where Laura (first name) is employed


SELECT First_Name,Last_Name,Salary,Department_Id FROM dbo.Employees
WHERE Salary < (SELECT AVG(Salary) FROM dbo.Employees) 
AND Department_Id In ( SELECT Department_Id FROM dbo.Employees WHERE First_Name =' Laura')


SELECT e1.First_Name, e1.Last_Name, e1.Salary, e1.Department_Id FROM dbo.Employees e1
INNER JOIN (SELECT AVG(Salary)Sal FROM dbo.Employees) e2
ON e1.Salary < e2.Sal
INNER JOIN (SELECT Department_Id FROM dbo.Employees WHERE First_Name =' Laura') d
ON e1.Department_Id = d.Department_Id

--managers who supervise four or more employees. Return manager name, department ID

SELECT First_Name + Last_Name AS Manager_Name,
       Department_Id
FROM dbo.Employees
WHERE Employee_Id IN
      (
          SELECT Manager_Id
          FROM dbo.Employees
          GROUP BY Manager_Id
          HAVING COUNT(Employee_Id) > 3
      );



SELECT CONCAT(e1.First_Name,' ',e1.Last_Name)Manager_Name, e1.Department_Id
FROM dbo.Employees e1
INNER JOIN (SELECT Manager_Id
          FROM dbo.Employees
          GROUP BY Manager_Id
          HAVING COUNT(Employee_Id) > 3)e2
		  ON e1.Employee_Id = e2.Manager_Id


--employees who have not had a job in the past


SELECT * FROM dbo.Employees
WHERE Employee_Id NOT IN (SELECT Employee_Id FROM dbo.Job_History)


SELECT DISTINCT e.* FROM dbo.Employees e
LEFT OUTER JOIN dbo.Job_History j
ON e.Employee_Id = j.Employee_Id
WHERE j.Employee_Id IS Null


SELECT * FROM dbo.Employees e
WHERE NOT EXISTS (SELECT 1 FROM dbo.Job_History WHERE Employee_Id = e.Employee_Id)

------------------------SUBQUERIES------------------------------

---Q2-01--------------------------------------------------------


SELECT e1.First_Name,e1.Last_Name,e1.Department_Id,e1.Salary FROM dbo.Employees e1
INNER JOIN (SELECT MIN(Salary)Sal FROM dbo.Employees) e2
ON e1.Salary = e2.Sal

--Q2-02---------------------------------------------------------

SELECT e1.Department_Id,e1.First_Name,e1.Job_Id, d1.Department_Name FROM dbo.Employees e1
INNER JOIN (SELECT Department_id,Department_Name FROM dbo.Department)d1
ON e1.Department_Id = d1.Department_id
WHERE d1.Department_Name = ' Finance'

--Q2-03---------------------------------------------------------

SELECT * FROM dbo.Employees
WHERE Salary 
BETWEEN 1000 AND 3000

--Q2-04---------------------------------------------------------

SELECT e1.*
FROM dbo.Employees e1
    INNER JOIN
    (
        SELECT Employee_Id,
               DENSE_RANK() OVER (ORDER BY Salary DESC) sal
        FROM dbo.Employees
    ) e2
        ON e1.Employee_Id = e2.Employee_Id
WHERE e2.sal = 2;


---Q2-11--------------------------------------------------------

SELECT d.* FROM dbo.Department d
INNER JOIN (SELECT salary,employee_Id, department_Id FROM dbo.Employees e)e1
ON d.Department_id = e1.department_Id
INNER JOIN (SELECT Employee_Id,COUNT(Employee_Id)cnt FROM dbo.Job_History
GROUP BY Employee_Id 
HAVING COUNT(Employee_Id)>1)a
ON a.Employee_Id = e1.employee_Id
WHERE e1.Salary>=7000

--Q2-12---------------------------------------------------------

--query to find those employees who earn the second-lowest salary of all the employees. Return all the fields of employees


SELECT e1.*
FROM dbo.Employees e1
    INNER JOIN
    (
        SELECT Employee_Id,
               DENSE_RANK() OVER (ORDER BY Salary) sal
        FROM dbo.Employees
    ) rnk
        ON e1.Employee_Id = rnk.Employee_Id
WHERE rnk.sal = 2;


------------------------JOINS-----------------------------------

--find the first name, last name, department id, and department name for each employee.

SELECT e.First_Name, e.Last_Name,e.Department_Id, d.Department_Name FROM dbo.Employees e
INNER JOIN dbo.Department d
ON e.Department_Id = d.Department_id


-- employees whose first name contains the letter ‘z’. Return first name, last name, department, city, and state province

SELECT e.First_Name, e.Last_Name,e.Department_Id, d.Department_Name, l.City,l.State_province FROM dbo.Employees e
INNER JOIN dbo.Department d
ON e.Department_Id = d.Department_id
INNER JOIN dbo.Locations l
ON d.Location_Id=l.Location_Id
WHERE e.First_Name LIKE '%z%'


--employees have or do not have a department


SELECT e.First_Name, e.Last_Name, e.Department_Id , d.Department_Name FROM dbo.Employees e
LEFT JOIN dbo.Department d
ON e.Department_Id = d.Department_id
WHERE NOT EXISTS (SELECT 1 FROM dbo.Department WHERE Department_id=e.Department_Id)


--query to calculate the average salary, the number of employees receiving commissions in that department


SELECT AVG(e1.Salary) AS Avg_Salary,
       COUNT(e2.Employee_Id) AS Employee_Count
FROM dbo.Employees e1
INNER JOIN dbo.Employees e2 ON 
e1.Employee_Id = e2.Employee_Id
WHERE e2.Commission > 0.00
GROUP BY e1.Department_Id


--SQL query to find the employees who earn $12000 or more

SELECT e.Employee_Id, jh.Strt_Date, jh.End_Date,e.Job_Id,e.Department_Id FROM dbo.Employees e
INNER JOIN dbo.Job_History jh 
ON jh.Employee_Id = e.Employee_Id
WHERE e.Salary >= 12000


--query to find full name (first and last name), job title, start and end date of last jobs of employees who did not receive commissions

SELECT e.First_Name + e.Last_Name AS Full_Name, j.Job_Title, jh.Strt_Date, jh.End_Date FROM dbo.Employees e
INNER JOIN dbo.jobs j
ON j.Job_Id = e.Job_Id
INNER JOIN dbo.Job_History jh
ON jh.Employee_Id = e.Employee_Id
WHERE e.Commission <= 0.00