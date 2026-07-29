-- Lấy ID khách hàng có số lượng order nhiều nhất
select top 1  CustomerID from Orders 
group by CustomerID
order by Count(*) DESC
-- Câu 2 
select * from CITY where COUNTRYCODE = N'USA' and POPULATION > 100000
-- Câu 3 
select CITY, STATE from STATION
-- Câu 4
select distinct CITY from STATION where ID % 2 = 0
-- Câu 5 Tìm số thành phố 
select count(CITY) - count(DISTINCT CITY) from STATION
-- Câu 6: Tìm 2 thành phố có tên ngắn nhất và dài nhất , duy nhất
SELECT TOP 1 CITY, LEN(CITY) 
FROM STATION 
ORDER BY LEN(CITY) ASC, CITY ASC;

SELECT TOP 1 CITY, LEN(CITY) 
FROM STATION 
ORDER BY LEN(CITY) DESC, CITY ASC;
-- Câu 7: Weather Observation Station 6
select DISTINCT CITY from STATION where CITY LIKE '[aeiou]%'
-- Câu 8: Weather Observation Station 7
select DISTINCT CITY from STATION where CITY LIKE '%[aeiou]'
-- Câu 9: Weather Observation Station 8
select DISTINCT CITY from STATION where CITY LIKE '[aeiou]%' and CITY LIKE '%[aeiou]'
-- Câu 10: Weather Observation Station 9
select DISTINCT CITY from STATION where CITY NOT LIKE '[aeiou]%' 
-- Câu 11: Weather Observation Station 10
select distinct CITY from STATION where CITY not LIKE N'%[ueoai]'
-- Câu 12: Weather Observation Station 11
select distinct CITY from STATION where CITY NOT LIKE N'%[ueoai]' or CITY NOT LIKE N'[ueoai]%'
-- Câu 13: Weather Observation Station 12
select distinct CITY from STATION where CITY NOT LIKE '%[ueoai]' and  CITY NOT LIKE '[ueoai]%'
-- Câu 14: Lấy tên HS thi trên 75đ sắp xếp theo tên 3 ký tự cuối nếu trùng thì sắp xếp theo ID giảm dần
select Name from Students where Marks > 75
ORDER BY RIGHT(Name,3) , ID
-- Câu 15
SELECT name
FROM Employee
Order BY name asc
-- Câu 16
select name
from Employee
where salary > 2000 and months < 10
order by employee_id asc
-- Câu 17: Lọc theo điều kiện trả về loại tam giác theo 3 cạnh A B C
SELECT CASE 
    WHEN (A + B <= C) OR (B + C <= A) OR (A + C <= B) THEN 'Not A Triangle'
    WHEN A = B AND B = C THEN 'Equilateral'
    WHEN A = B OR B = C OR A = C THEN 'Isosceles'
    ELSE 'Scalene'
END
FROM TRIANGLES;
-- Câu 18: The PADs
select Name +'('+LEFT(Occupation,1) +')' from OCCUPATIONS 
order by Name
select 'There are a total of '+ CAST(COUNT(Occupation) as VARCHAR)+ ' ' +LOWER(Occupation)+'s.'
from Occupations
group by Occupation
ORDER BY COUNT(Occupation),Occupation
-- Câu 19: Pivot Occupations
WITH RankedOccupations AS (
    SELECT 
        Name, 
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM OCCUPATIONS
)
SELECT 
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM RankedOccupations
GROUP BY RowNum;
-- Câu 20: BST
select CASE 
WHEN P IS null THEN CAST(N as VARCHAR) +' Root' 
WHEN  N  NOT IN (SELECT P from BST where P is not null ) THEN CAST(N as VARCHAR) +' Leaf'
ELSE CAST(N as VARCHAR) + ' Inner' END
from  BST
order by N
-- Câu 21: New Companies
select cpy.company_code, cpy.founder, 
COUNT(DISTINCT(e.lead_manager_code)),
COUNT(DISTINCT(e.senior_manager_code)),
COUNT(DISTINCT(e.manager_code)),
COUNT(DISTINCT(e.employee_code))
from Company as cpy left join Employee as e on cpy.company_code = e.company_code
GROUP BY cpy.company_code, cpy.founder
ORDER BY cpy.company_code asc
-- Câu 22: Revising Aggregations - The Count Function
select COUNT(Name) from CITY where Population > 100000
-- Câu 23: Revising Aggregations - The SUM Function
select SUM(Population) from CITY where District = N'California'
-- Câu 24: The Blunder
select CEILING(AVG(CAST(Salary as DECIMAL ))-AVG(CAST(REPLACE(Salary,'0','')as DECIMAL))) from employees
-- Câu 25: Revising Aggregations - Averages
select avg(population) from city where district = N'California'
-- Câu 26: Average Population
select AVG(population) from city
-- Câu 27: Japan Population
select SUM(population) from city where countrycode = N'JPN'
-- Câu 28: Population Density Difference
select MAX(population) - MIN(population) from city
-- Câu 29: Top Earners
Select MAX(salary * months) ,COUNT(*)
from Employee
where salary * months = (select MAX(salary*months) from Employee)
-- Câu 30: Weather Observation Station 12
select CAST(ROUND(SUM(LAT_N), 2) as DECIMAL(12,2)), CAST(ROUND(SUM(LONG_W), 2) as DECIMAL(12,2)) from station
-- Câu 31: Weather Observation Station 13
SELECT CAST(SUM(LAT_N) as DECIMAL(12,4)) FROM STATION WHERE LAT_N > 38.7880 and LAT_N < 137.2345
-- Câu 32: Weather Observation Station 14
select CAST(MAX(LAT_N) as decimal(12,4)) from station where lat_n < 137.2345
-- Câu 33: Weather Observation Station 15
select CAST(LONG_W as decimal (12,4)) from STATION where LAT_N = (Select MAX(LAT_N) from station where LAT_N < 137.2345)
-- Câu 34 : Weather Observation Station 16
select top 1 CAST(LAT_N as decimal (12,4)) from station where lat_n > 38.7780
order by lat_n asc 
-- Câu 35: Weather Observation Station 17
select top 1 CAST(LONG_W as decimal (12,4))
from station 
where lat_n > 38.7780
ORDER BY lat_n asc
-- Câu 36: Weather Observation Station 18
SELECT CAST( 
ABS(MIN(LAT_N)-MAX(LAT_N)) + ABS(MIN(LONG_W)-MAX(LONG_W))
as DECIMAL(12,4))
from station
-- Câu 37: Weather Observation Station 19
select CAST( 
    SQRT(
        POWER(MAX(LAT_N)-MIN(LAT_N),2) +
        POWER(MAX(LONG_W)-MIN(LONG_W),2)
    )
    as DECIMAL (12,4))
    from Station
-- Câu 38: Weather Observation Station 20
SELECT CONVERT(DECIMAL(18,4),LAT_N)
FROM STATION
ORDER BY LAT_N
OFFSET (SELECT COUNT(*) FROM STATION) / 2 ROWS
FETCH NEXT 1 ROWS ONLY
-- Câu 39: Population Census
select SUM(cty.population) from CITY as cty join country as cnt on cty.CountryCode = cnt.Code where cnt.continent = N'Asia'
-- Câu 40: African Cities
SELECT ct.Name FROM City as ct join Country as cnt on ct.CountryCode = cnt.Code
WHERE cnt.Continent = N'Africa'
-- Câu 41: Average Population of Each Continent
select cnt.Continent , FLOOR(AVG(ct.Population)) FROM
COUNTRY as cnt join City as ct on cnt.code = ct.CountryCode
group by cnt.Continent
-- Câu 42: Draw The Triangle 1 
declare @var int = 20;
while @var > 0
begin 
print(replicate('* ',@var))
set @var = @var - 1
end
-- Câu 43: Draw The Triangle 2
declare @var int = 1
while @var<=20
begin 
print(replicate('* ',@var))
set @var=@var+1
end
-- Câu 43 : Combine Two Tables
SELECT p.firstName, p.lastName,
a.city, a.state
FROM Person p LEFT JOIN Address a 
ON p.personId = a.personId
-- Câu 44 : Find the employee has salary more than manager
select e1.name as Employee
from Employee as e1 join Employee as e2 on e1.managerId = e2.id and e1.salary > e2.salary
-- Câu 45 : Find duplicate email
select email 
from Person
group by email
having count(email)>1 
-- Câu 46: Customers Who Never Order
select cus.name  as Customers from Customers as cus where id not in (select customerId from orders)
-- Câu 47: Delete Duplicate Email keeping only one unique email with the smallest id 
delete p1
from Person as p1 join Person as p2 on p1.email=p2.email and p1.id > p2.id
-- Câu 48 : Rising Temperature
select w2.id 
from Weather as w1 join Weather as w2 on DATEADD(day,1,w1.recordDate)=w2.recordDate 
and w2.temperature > w1.temperature
-- Câu 49: Game Play Analysis I
select player_id , MIN(event_date) as first_login
from Activity 
group by player_id
-- Câu 50: Employee Bonus
select e.name , b.bonus
from employee as e left join bonus as b on e.empId = b.empId  
where b.bonus < 1000 or b.bonus is null
-- Câu 51: Find Customer Referee
select name
from Customer 
where referee_id is null or referee_id !=2 
-- Câu 52: Customer Placing the Largest Number of Orders
select TOP 1 customer_number 
from orders 
group by customer_number
order by COUNT(*) desc
-- Câu 53: Big Countries
select name , population, area 
from World 
where area >= 3000000 or population >= 25000000
-- Câu 54: Classes With at Least 5 Students
select class 
from Courses 
group by class
having count(*) >=5
-- Câu 55: Sales Person
select name 
from SalesPerson
where sales_id NOT IN(select s.sales_id
from salesperson as s join orders as o on s.sales_id = o.sales_id join company as c on o.com_id = c.com_id 
where c.name = N'RED')
-- Câu 56: Triangle Judgement
select x, y ,z ,
CASE WHEN x + y > z and y+z>x and z+x > y then N'Yes' ELSE N'No' end as triangle 
from Triangle
-- Câu 57: Biggest Single Number
with temp as (select  num
from MyNumbers 
group by num 
having COUNT(*)=1
)
select MAX(num) as num from temp
-- Câu 58: Not Boring Movies
select * 
from Cinema 
where id % 2 = 1 and description != N'boring'
order by rating desc
-- Câu 59 : Swap Sex of Employees
update salary set sex = case when sex=N'm' then  N'f' else  N'm' end 
-- Câu 60 : Actors and Directors Who Cooperated At Least Three Times
select actor_id, director_id 
from ActorDIrector
group by actor_id,director_id 
having COUNT(*) >=3
-- Câu 61: Product Sales Analysis I
select d.product_name, s.year,s.price
from Sales s join Product d on s.product_id = d.product_id
-- Câu 62: Project Employees I
select p.project_id ,CAST(AVG(e.experience_years*1.0)as decimal (12,2)) as average_years
from Project p join Employee e on p.employee_id = e.employee_id
group by p.project_id
-- Câu 63: Sales Analysis III
--C1: subquery
select distinct product_id ,product_name 
from (select p.product_id ,p.product_name  from Product p join sales s on p.product_id = s.product_id
where s.sale_date between '2019-01-01' and '2019-03-31'
) as temp where product_id not in (select product_id 
from sales where sale_date > '2019-03-31' or sale_date <'2019-01-01')
--C2: group by and date [min(date);max(date)] bài toán chỉ nằm duy nhất trong khoảng nên sử dụng min,max 
SELECT p.product_id, p.product_name
FROM Product p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
HAVING MIN(s.sale_date) >= '2019-01-01' 
   AND MAX(s.sale_date) <= '2019-03-31';
-- Câu 64: User Activity for the Past 30 Days I
select activity_date as day , COUNT(distinct user_id) as active_users 
from Activity 
where activity_date between dateadd(day,-29,'2019-07-27') and '2019-07-27' and activity_type in  ('open_session', 'end_session', 'scroll_down', 'send_message')
group by activity_date
-- Câu 65: Article Views I
select distinct author_id as id 
from Views 
where author_id = viewer_id
order by id
-- Câu 66:Reformat Department Table
SELECT 
    id,
    Jan AS Jan_Revenue, Feb AS Feb_Revenue, Mar AS Mar_Revenue,
    Apr AS Apr_Revenue, May AS May_Revenue, Jun AS Jun_Revenue,
    Jul AS Jul_Revenue, Aug AS Aug_Revenue, Sep AS Sep_Revenue,
    Oct AS Oct_Revenue, Nov AS Nov_Revenue, Dec AS Dec_Revenue
FROM 
    Department
PIVOT (
    MAX(revenue)
    FOR month IN (
        [Jan], [Feb], [Mar], [Apr], [May], [Jun], 
        [Jul], [Aug], [Sep], [Oct], [Nov], [Dec]
    )
) AS PivotTable;
-- Câu 67: Queries Quality and Percentage
select query_name,
 CAST(AVG(rating*1.0/position*1.0) as decimal(12,2)) as quality,
 CAST(AVG(CASE when rating < 3 then 1.0 else 0.0 end )*100 as decimal (12,2)) as poor_query_percentage
from Queries 
group by query_name
-- Câu 68: Average Selling Price
select p.product_id ,
CAST(COALESCE(SUM(u.units * p.price) * 1.0 / NULLIF(SUM(u.units), 0), 0) 
        as decimal (12,2)) as average_price
from Prices p left join UnitsSold u on p.product_id = u.product_id and u.purchase_date between p.start_date and p.end_date
group by p.product_id
-- Câu 69: Students and Examinations
SELECT 
    s.student_id,
    s.student_name,
    sub.subject_name,
    COUNT(e.student_id) AS attended_exams
FROM 
    Students s
CROSS JOIN 
    Subjects sub
LEFT JOIN 
    Examinations e 
    ON s.student_id = e.student_id 
   AND sub.subject_name = e.subject_name
GROUP BY 
    s.student_id, 
    s.student_name, 
    sub.subject_name
ORDER BY 
    s.student_id, 
    sub.subject_name;
-- Câu 70: List the Products Ordered in a Period
select p.product_name , sum(o.unit) as unit
from Products p join orders o on p.product_id = o.product_id 
where o.order_date >='2020-02-01' and o.order_date <='2020-02-29'
group by o.product_id,p.product_name
having sum(o.unit)>=100