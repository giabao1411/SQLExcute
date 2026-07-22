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