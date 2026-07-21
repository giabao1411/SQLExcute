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