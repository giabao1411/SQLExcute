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
-- Câu 5
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
