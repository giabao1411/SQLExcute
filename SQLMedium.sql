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
-- Câu 19: Market Analysis I
select s.user_id as buyer_id , s.join_date , COUNT(o.buyer_id) orders_in_2019
from Users s left join Orders o 
on s.user_id = o.buyer_id and year(o.order_date) = 2019
group by s.user_id,s.join_date
-- Câu 20: Product Price at a Given Date
/*Nhóm 1: Có ít nhất một lần thay đổi giá vào hoặc trước ngày 2019-08-16. Giá của sản phẩm sẽ là giá ở ngày thay đổi gần nhất
 (ngày lớn nhất <= 2019-08-16).
Nhóm 2: Lần thay đổi giá đầu tiên diễn ra sau ngày 2019-08-16 (tức là tính đến ngày 2019-08-16 
thì chưa bao giờ đổi giá). Giá của nhóm này sẽ lấy giá mặc định là 10*/
WITH LatestPrice AS (
    SELECT 
        product_id,
        new_price AS price,
        RANK() OVER(PARTITION BY product_id ORDER BY change_date DESC) AS rnk
    FROM Products
    WHERE change_date <= '2019-08-16'
),
AllProducts AS (
    SELECT DISTINCT product_id 
    FROM Products
)
SELECT 
    p.product_id,
    COALESCE(lp.price, 10) AS price
FROM AllProducts p
LEFT JOIN LatestPrice lp 
    ON p.product_id = lp.product_id AND lp.rnk = 1;
-- Câu 21: Immediate Food Delivery II
WITH FirstOrders AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS min_order_date
    FROM Delivery
    GROUP BY customer_id
)
SELECT 
    ROUND(
        COUNT(CASE WHEN d.order_date = d.customer_pref_delivery_date THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS immediate_percentage
FROM Delivery d
JOIN FirstOrders f 
    ON d.customer_id = f.customer_id 
   AND d.order_date = f.min_order_date;
-- Câu 22: Monthly Transactions I
select LEFT(trans_date,7) as month , country , COUNT(id) trans_count
, COUNT(CASE WHEN state = N'approved' then 1 end ) as approved_count
 , SUM(amount)  as trans_total_amount 
 ,SUM(CASE WHEN state = N'approved' then amount else 0 end ) as approved_total_amount
from Transactions 
group by LEFT(trans_date,7),country
order by LEFT(trans_date,7) asc ,country desc
-- Câu 23: Last Person to Fit in the Bus
with cte as (select turn, person_id, person_name, weight, SUM(weight) OVER (order by turn) AS total_weight
from Queue
)
select top 1 person_name  from cte
where total_weight <= 1000
order by total_weight desc 
-- Câu 24: Restaurant Growth
WITH DailySales AS (
    -- Bước 1: Tổng doanh thu từng ngày
    SELECT 
        visited_on,
        SUM(amount) AS day_amount
    FROM Customer
    GROUP BY visited_on
),
MovingStats AS (
    -- Bước 2: Tính tổng 7 ngày & trung bình 7 ngày bằng Cửa sổ (Window Frame)
    SELECT 
        visited_on,
        SUM(day_amount) OVER (
            ORDER BY visited_on 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS amount,
        ROUND(
            AVG(day_amount * 1.0) OVER (
                ORDER BY visited_on 
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ), 2
        ) AS average_amount,
        -- Lấy ngày nhỏ nhất toàn bảng để kiểm tra điều kiện đủ 7 ngày
        MIN(visited_on) OVER () AS first_date
    FROM DailySales
)
-- Bước 3 & 4: Lọc đủ 7 ngày và xuất kết quả
SELECT 
    visited_on,
    amount,
    average_amount
FROM MovingStats
WHERE visited_on >= DATEADD(day, 6, first_date) -- Dùng DATE_ADD(first_date, INTERVAL 6 DAY) nếu là MySQL
ORDER BY visited_on ASC;
-- Câu 25: Movie Rating
with cte as (select top 1 u.name as results
from Users u join MovieRating r 
on u.user_id = r.user_id
group by u.user_id ,u.name
order by COUNT(r.movie_id) desc, u.name asc)
, 
cte2 as (
select top 1 m.title as results
from Movies m join MovieRating r 
on m.movie_id = r.movie_id
where r.created_at >='2020-02-01' and r.created_at <= '2020-02-29'
group by m.movie_id,m.title
order by ROUND(AVG(r.rating*1.0),2) desc, m.title )

select * from cte 
union all 
select * from cte2
-- Câu 26: Capital Gain/Loss
SELECT 
    stock_name,
    SUM(CASE WHEN operation = 'Sell' THEN price ELSE -price END) AS capital_gain_loss
FROM Stocks
GROUP BY stock_name;
-- Câu 27: Count Salary Categories
select 'Average Salary' as category, COUNT(*) as accounts_count from
Accounts where 
income >= 20000 and income <=50000
union all
select 'Low Salary' as category, COUNT(*) as accounts_count from
Accounts where 
income < 20000 
union all
select 'High Salary' as category, COUNT(*) as accounts_count from
Accounts where 
 income > 50000
 -- Câu 28: Confirmation Rate 
 select s.user_id, 
ROUND(COALESCE(SUM(case when c.action='confirmed' then 1.0 else 0 end)/NULLIF(COUNT(c.user_id),0),0),2)  as confirmation_rate
from 
Signups s left join Confirmations c 
on s.user_id = c.user_id 
group by s.user_id
--c2 
select s.user_id, 
ROUND(COALESCE(AVG(CASE WHEN c.action = 'confirmed' THEN 1.0 ELSE 0 END),0),2)  as confirmation_rate
from 
Signups s left join Confirmations c 
on s.user_id = c.user_id 
group by s.user_id
--Câu 29: Odd and Even Transactions
SELECT 
    transaction_date,
    COALESCE(SUM(CASE WHEN amount % 2 != 0 THEN amount ELSE 0 END), 0) AS odd_sum,
    COALESCE(SUM(CASE WHEN amount % 2 = 0 THEN amount ELSE 0 END), 0) AS even_sum
FROM transactions 
GROUP BY transaction_date
ORDER BY transaction_date;
--Câu 30 : Find Students Who Improved
WITH RankedScores AS (
    SELECT 
        student_id,
        subject,
        score,
        -- Đánh số 1 cho bài thi ĐẦU TIÊN
        ROW_NUMBER() OVER (
            PARTITION BY student_id, subject 
            ORDER BY exam_date ASC
        ) AS rn_asc,
        -- Đánh số 1 cho bài thi GẦN NHẤT
        ROW_NUMBER() OVER (
            PARTITION BY student_id, subject 
            ORDER BY exam_date DESC
        ) AS rn_desc
    FROM Scores
)
SELECT 
    student_id,
    subject,
    MAX(CASE WHEN rn_asc = 1 THEN score END) AS first_score,
    MAX(CASE WHEN rn_desc = 1 THEN score END) AS latest_score
FROM RankedScores
WHERE rn_asc = 1 OR rn_desc = 1
GROUP BY student_id, subject
-- Bắt buộc phải có ít nhất 2 bài thi (lần đầu khác lần cuối) và điểm sau > điểm đầu
HAVING MAX(CASE WHEN rn_desc = 1 THEN score END) > MAX(CASE WHEN rn_asc = 1 THEN score END)
   AND COUNT(score) >= 2
ORDER BY student_id, subject;
--Câu 31 : DNA Pattern Recognition
select sample_id, dna_sequence, species , 
CASE WHEN dna_sequence LIKE 'ATG%' then 1 else 0 end as has_start,
CASE WHEN dna_sequence LIKE '%TAA' 
           OR dna_sequence LIKE '%TAG' 
           OR dna_sequence LIKE '%TGA' THEN 1 ELSE 0 END AS has_stop,
    CASE WHEN dna_sequence LIKE '%ATAT%' THEN 1 ELSE 0 END AS has_atat,
    CASE WHEN dna_sequence LIKE '%GGG%' THEN 1 ELSE 0 END AS has_ggg
from Samples
order by sample_id
-- Câu 32 : Analyze Subscription Conversion 
select user_id ,
 ROUND(AVG(CASE When activity_type ='free_trial' then activity_duration *1.0 end),2) as trial_avg_duration
 ,ROUND(AVG(Case when activity_type ='paid' then activity_duration *1.0 end),2) as paid_avg_duration
from UserActivity
where activity_type != 'cancelled'
group by user_id 
having COUNT( distinct activity_type) > 1
order by user_id
-- Câu 33: Find Product Recommendation Pairs
-- Amazon muốn triển khai tính năng "Khách hàng mua sản phẩm này cũng mua..." dựa trên mô hình mua đồng thời. 
-- Hãy viết giải pháp cho các bài toán sau: 
-- Xác định các cặp sản phẩm khác nhau thường được cùng một khách hàng mua cùng nhau (trong đó product1_id < product2_id)
-- Đối với mỗi cặp sản phẩm, xác định có bao nhiêu khách hàng đã mua cả hai sản phẩm 
-- Một cặp sản phẩm được xem xét để đề xuất nếu có ít nhất 3 khách hàng khác nhau đã mua cả hai sản phẩm. Trả về bảng kết quả được sắp xếp theo số lượng khách hàng giảm dần, 
-- và trong trường hợp có số lượng bằng nhau, 
-- sắp xếp theo product1_id tăng dần, sau đó theo product2_id tăng dần.
with UserPurchases as (
    select pp.user_id,pp.product_id , p.category 
    from ProductInfo p join ProductPurchases pp
    on p.product_id = pp.product_id
)
select 
    p1.product_id as product1_id ,
    p2.product_id as product2_id , 
    p1.category as product1_category,
    p2.category as product2_category ,
    COUNT(p1.user_id) customer_count 
from UserPurchases p1 
join UserPurchases p2 
on p1.user_id = p2.user_id and p1.product_id < p2.product_id
group by p1.product_id , p1.category , p2.product_id,p2.category
having COUNT(p1.user_id)>=3
order by COUNT(p1.user_id) desc , product1_id , product2_id
-- Câu 34 : Seasonal Sales Analysis
--C1 : 
-- Viết lời giải để tìm danh mục sản phẩm phổ biến nhất cho mỗi mùa. Các mùa được định nghĩa như sau: 
-- Mùa đông: Tháng 12, tháng 1, tháng 2 
-- Mùa xuân: Tháng 3, tháng 4, tháng 5 
-- Mùa hè: Tháng 6, tháng 7, tháng 8 
-- Mùa thu: Tháng 9, tháng 10, tháng 11 
-- Mức độ phổ biến của một danh mục được xác định bởi tổng số lượng bán ra trong mùa đó. 
-- Nếu có sự trùng lặp, hãy chọn danh mục có tổng doanh thu cao nhất (số lượng × giá).
-- Nếu vẫn có sự trùng lặp, hãy trả về danh mục có thứ tự xếp hạng thấp hơn. 
-- Trả về bảng kết quả được sắp xếp theo mùa theo thứ tự tăng dần.
with cte as (select s.product_id ,s.quantity,s.price , p.category
, CASE WHEN MONTH(s.sale_date) in (12,1,2) then 'Winter'  
 when MONTH(s.sale_date) in(3,4,5) then 'Spring' 
 when MONTH(s.sale_date) in (6,7,8) then 'Summer' else 
'Fall' end as season
from sales s join products p 
on s.product_id = p.product_id
)
,
cte2 as (select season,category ,  sum(quantity)  as total_quantity, 
SUM(quantity * price)  total_revenue
from cte
group by season,category)
, cte3 as (select season , category , 
total_quantity, total_revenue,
ROW_NUMBER() OVER (
            PARTITION BY season 
            ORDER BY 
                total_quantity DESC, 
                total_revenue DESC, 
                category ASC
        ) AS rnk
from cte2 )

select season , category ,total_quantity,total_revenue
from cte3
where rnk=1
order by season
--C2: khác cách 1 ở điểm gộp cte cte2 thành 1 bảng tạm 
WITH SeasonalAgg AS (
    SELECT 
        CASE 
            WHEN MONTH(s.sale_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(s.sale_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(s.sale_date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Fall'
        END AS season,
        p.category,
        SUM(s.quantity) AS total_quantity,
        SUM(s.quantity * s.price) AS total_revenue
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY 
        CASE 
            WHEN MONTH(s.sale_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(s.sale_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(s.sale_date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Fall'
        END,
        p.category
),
RankedCategories AS (
    SELECT 
        season,
        category,
        total_quantity,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY season 
            ORDER BY 
                total_quantity DESC, 
                total_revenue DESC, 
                category ASC
        ) AS rnk
    FROM SeasonalAgg
)
SELECT 
    season,
    category,
    total_quantity,
    total_revenue
FROM RankedCategories
WHERE rnk = 1
ORDER BY season;