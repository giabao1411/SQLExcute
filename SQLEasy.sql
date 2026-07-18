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
