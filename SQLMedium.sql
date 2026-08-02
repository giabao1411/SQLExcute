-- Câu 1: Print Prime Numbers
declare @N int =2 
  declare @output varchar(MAX)=''
  while @N <= 1000
  BEGIN
    declare @div int = 2;
    declare @isPrime int = 1;
    while @div <= sqrt(@N)
    BEGIN
    if @N % @div = 0
    BEGIN
        set @isPrime = 0;
        break;
    END
    set @div = @div + 1;
    END
    if @isPrime = 1
    BEGIN
    IF @output =''
        set @output= cast(@N as varchar)
    else 
        set @output = @output + '&'+ cast(@N as varchar)
    END
    
    set @N=@N+1;
  END
  print @output
  -- Câu 2: The Report
  --Cách 1: dùng union all 2 bảng 1 bảng trả giá trị từ 8 đến 10 và 1 bảng dưới 8
  select   std.Name  , grd.Grade,std.Marks from students as std join grades as grd ON
std.Marks >= grd.min_mark and std.Marks <= grd.max_mark and grd.Grade >=8 and grd.Grade<=10
UNION ALL
select NULL  , grd.Grade,std.Marks from students as std join grades as grd ON
std.Marks >= grd.min_mark and std.Marks <= grd.max_mark and grd.Grade <8 

ORDER BY Grade DESC, Name ASC, Marks ASC;
--Cách 2 
select case when grd.Grade < 8 then NULL else std.Name , grd.Grade, std.Marks from students as std join grades as grd ON
std.Marks between grd.min_mark and grd.max_mark 
order by grd.grade desc, std.name asc, std.marks asc
-- Câu 3: Top Competitors
select hks.hacker_id, hks.name
FROM Hackers as hks join Submissions as s 
on hks.hacker_id  = s.hacker_id join challenges as c on s.challenge_id = c.challenge_id join 
Difficulty as d on c.difficulty_level = d.difficulty_level  
where s.score = d.score
group by hks.hacker_id,hks.name
having count(hks.hacker_id)>1
order by count(hks.hacker_id) desc ,hks.hacker_id asc
-- Câu 4 : Ollivander's Inventory
with RankedWands as (
    Select w.id ,wp.age, w.coins_needed, w.power ,
    ROW_NUMBER() OVER(PARTITION BY wp.age, w.power order by w.coins_needed ASC) as rnk
    from wands as w join wands_property as wp on w.code = wp.code
    where wp.is_evil=0
) 
select id, age ,coins_needed, power 
from RankedWands
where rnk = 1 
order by power desc , age desc
-- Câu 5: Challenges
select  h.hacker_id , h.name , COUNT(c.challenge_id) 
from hackers as h join challenges as c on h.hacker_id = c.hacker_id 
group by h.hacker_id ,h.name
having 
COUNT(c.challenge_id) = (SELECT TOP 1 COUNT(c.challenge_id) from  challenges as c
group by c.hacker_id
order by COUNT(c.challenge_id) desc ) 
OR COUNT(c.challenge_id) IN (
    SELECT cnt 
    from (select count(challenge_id) as cnt from challenges group by hacker_id) as temp 
    group by cnt
    having count(cnt)=1
)
order by COUNT(c.challenge_id) desc ,h.hacker_id
-- Câu 6: Contest Leaderboard
WITH MaxScore as( 
    SELECT hacker_id,challenge_id ,MAX(score) as maxscore from submissions group by challenge_id,hacker_id
)

select h.hacker_id, h.name , SUM(s.maxscore)
from hackers as h join MaxScore as s on h.hacker_id = s.hacker_id
group by h.hacker_id ,h.name
having sum(s.maxscore)>0
order by sum(s.maxscore) desc , h.hacker_id asc 
-- Câu 7: SQL Project Planning (Gấp dải thời gian (Gaps and Islands Problem))
--StarDate không nằm trong End_Date nào thì là ngày bắt đầu dự án
WITH Starters AS (
    
    SELECT Start_Date, ROW_NUMBER() OVER (ORDER BY Start_Date) AS rn
    FROM Projects
    WHERE Start_Date NOT IN (SELECT DISTINCT End_Date FROM Projects)
),
--EndDate không nằm trong StarDate nào thì là ngày kết thúc dự án 
Enders AS (
    
    SELECT End_Date, ROW_NUMBER() OVER (ORDER BY End_Date) AS rn
    FROM Projects
    WHERE End_Date NOT IN (SELECT DISTINCT Start_Date FROM Projects)
)
--Sau khi sắp xếp đánh thứ tự thì nối theo row thì ta có 1 bộ dữ liệu liền kề
SELECT 
    s.Start_Date, 
    e.End_Date
FROM Starters s
JOIN Enders e ON s.rn = e.rn
ORDER BY 
    DATEDIFF(day, s.Start_Date, e.End_Date) ASC, 
    s.Start_Date ASC;
-- Câu 8: Placements
select s.name 
from students as s join friends as f on s.id= f.id
-- Lấy lương của sv đó
 join packages as p_stu on s.id = p_stu.id 
 -- lấy lương của bạn thân sv đó
 join packages as p_fri on f.friend_id=p_fri.id
 where p_stu.salary < p_fri.salary
 order by p_fri.salary 
 -- Câu 9: 
 SELECT f1.X, f1.Y
FROM Functions AS f1
JOIN Functions AS f2 
    ON f1.X = f2.Y 
   AND f1.Y = f2.X
GROUP BY f1.X, f1.Y
HAVING 
    -- Trường hợp 1: X < Y (Luôn đúng nếu tìm thấy cặp khớp)
    f1.X < f1.Y 
    
    -- Trường hợp 2: X = Y (Bắt buộc phải xuất hiện từ 2 dòng trở lên)
    OR (f1.X = f1.Y AND COUNT(*) > 1)

ORDER BY f1.X ASC;
-- Câu 10: Consecutive Numbers
WITH RankedLogs AS (
    SELECT num,
           LEAD(num, 1) OVER (ORDER BY id) AS next_1,
           LEAD(num, 2) OVER (ORDER BY id) AS next_2
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM RankedLogs
WHERE num = next_1 AND next_1 = next_2;
-- Câu 11: Game Play Analysis IV
--C1: cross join
WITH first_logins AS (
    SELECT 
        player_id, 
        MIN(event_date) AS first_date
    FROM Activity
    GROUP BY player_id
),
 temp as (
    select COUNT(DISTINCT a.player_id) as total_player_vaild 
from first_logins a join Activity cte on DATEADD(day,1,a.first_date) = cte.event_date and a.player_id = cte.player_id ), 
temp_total as(
    select COUNT(distinct player_id) as total from activity)

select ROUND(temp.total_player_vaild*1.0/temp_total.total,2) as fraction from temp cross join temp_total
--C2: 
WITH first_logins AS (
    SELECT 
        player_id, 
        MIN(event_date) AS first_date
    FROM Activity
    GROUP BY player_id
)
 select 
    ROUND(
        COUNT(*)*1.0/ (SELECT COUNT(*) from first_logins),
        2
    ) as fraction
    from first_logins f 
    join Activity a
    on f.player_id = a.player_id
    where a.event_date = DATEADD(day, 1 ,f.first_date)
--C3: dùng window function
WITH RankedActivity AS (
    SELECT 
        player_id,
        event_date,
        MIN(event_date) OVER(PARTITION BY player_id) AS first_date,
        ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY event_date) AS rn
    FROM Activity
)
SELECT 
    ROUND(
        COUNT(CASE WHEN DATEADD(day, 1, first_date) = event_date AND rn = 2 THEN 1 END) * 1.0 
        / COUNT(DISTINCT player_id), 
        2
    ) AS fraction
FROM RankedActivity;
-- Câu 12: Managers with at Least 5 Direct Reports
select m.name 
from employee e 
join employee m 
on e.managerId = m.id
group by m.id,m.name
having COUNT(m.id) >= 5
-- Câu 13: Investments in 2016
--C1: subquery
WITH UniqueLocation AS (
    SELECT lat, lon
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1
),
DuplicateTiv2015 AS (
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
)
SELECT 
    ROUND(SUM(i.tiv_2016 * 1.0), 2) AS tiv_2016
FROM Insurance i
JOIN UniqueLocation ul 
    ON i.lat = ul.lat AND i.lon = ul.lon   
JOIN DuplicateTiv2015 dt 
    ON i.tiv_2015 = dt.tiv_2015;
--C2 : Window Function
WITH Stats AS (
    SELECT 
        tiv_2016,
        COUNT(*) OVER(PARTITION BY tiv_2015) AS count_tiv_2015,
        COUNT(*) OVER(PARTITION BY lat, lon) AS count_lat_lon
    FROM Insurance
)
SELECT 
    ROUND(SUM(tiv_2016 * 1.0), 2) AS tiv_2016
FROM Stats
WHERE count_tiv_2015 > 1      
  AND count_lat_lon = 1;     
-- Câu 14: Friend Requests II: Who Has the Most Friends
WITH AllFriends AS (
    -- Lấy danh sách ID từ cả 2 vai trò: người gửi và người nhận
    SELECT requester_id AS id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id AS id FROM RequestAccepted
)
SELECT TOP 1 
    id, 
    COUNT(*) AS num
FROM AllFriends
-- Câu 15: Tree Node
select id,
CASE WHEN 
p_id is null then N'Root' 
when p_id in (select id from Tree) and id in (select p_id from tree) then N'Inner'
else N'Leaf' end as type 
from Tree
-- Câu 16: Exchange Seats
select 
case when id % 2 != 0 and id = (select MAX(id) from seat ) then id
when id % 2 !=0 then id + 1
else id - 1 end as id ,student
from seat 
order by id
-- Câu 17: Customers Who Bought All Products
select customer_id 
from Customer
group by customer_id
having COUNT(distinct product_key) = (select COUNT(*) from product)
-- Câu 18: Product Sales Analysis III
with cte as (
    select product_id , MIN(year) as first_year_sale_product
    from sales 
    group by product_id 
)
select s.product_id , s.year as first_year ,s.quantity,s.price
from sales s 
join cte on
s.product_id = cte.product_id and s.year=cte.first_year_sale_product