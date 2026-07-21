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