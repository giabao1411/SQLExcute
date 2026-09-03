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
-- Câu 35 : Find Consistently Improving Employees
-- Viết một bài toán tìm kiếm những nhân viên có sự cải thiện hiệu suất làm việc liên tục trong ba lần đánh giá gần nhất. 
-- Một nhân viên phải có ít nhất 3 lần đánh giá để được xem xét.
-- 3 lần đánh giá gần nhất của nhân viên phải cho thấy xếp hạng tăng dần (mỗi lần đánh giá tốt hơn lần trước). 
-- Sử dụng 3 lần đánh giá gần nhất dựa trên ngày đánh giá cho mỗi nhân viên. 
-- Tính điểm cải thiện bằng hiệu số giữa xếp hạng mới nhất và xếp hạng cũ nhất trong 3 lần đánh giá gần nhất.
-- Trả về bảng kết quả được sắp xếp theo điểm cải thiện giảm dần, sau đó theo tên tăng dần.
with cte as (select r.employee_id , e.name 
from employees e join performance_reviews r
on e.employee_id = r.employee_id 
group by r.employee_id,e.name
having COUNT(e.employee_id) >= 3)

, cte2 as (select 
r.review_id , r.employee_id , r.review_date , r.rating,cte.name,
ROW_NUMBER() over(partition by r.employee_id order by review_date desc) as rnk
from performance_reviews r join cte on r.employee_id = cte.employee_id)

select employee_id , name ,
 MAX(CASE WHEN rnk = 1 THEN rating END) - MAX(CASE WHEN rnk = 3 THEN rating END) as improvement_score
 from cte2 
where rnk <=3
group by employee_id ,name 
HAVING 
    MAX(CASE WHEN rnk = 1 THEN rating END) > MAX(CASE WHEN rnk = 2 THEN rating END)
    AND MAX(CASE WHEN rnk = 2 THEN rating END) > MAX(CASE WHEN rnk = 3 THEN rating END)
order by improvement_score desc ,name asc
-- Câu 36: Find COVID Recovery Patients
-- Viết một bài toán tìm bệnh nhân đã hồi phục sau COVID-19 - những bệnh nhân có kết quả xét nghiệm dương tính nhưng sau đó xét nghiệm âm tính. 
-- Một bệnh nhân được coi là đã hồi phục nếu họ có ít nhất một kết quả xét nghiệm dương tính và sau đó là ít nhất một kết quả xét nghiệm âm tính vào một ngày sau đó. 
-- Tính thời gian hồi phục (tính bằng ngày) bằng hiệu số giữa kết quả xét nghiệm dương tính đầu tiên và kết quả xét nghiệm âm tính đầu tiên sau đó. 
-- Chỉ bao gồm những bệnh nhân có cả kết quả xét nghiệm dương tính và âm tính.
-- Trả về bảng kết quả được sắp xếp theo thời gian hồi phục tăng dần, sau đó theo tên bệnh nhân tăng dần.
with FirstPositive as (
select 
    patient_id, 
    MIN(test_date) as first_positive_date
 from covid_tests 
where result in ('Positive')
group by patient_id )
, 
FirstNegativeAfterPos as (
select t.patient_id ,
            fp.first_positive_date,
            MIN(t.test_date) as first_negative_date
from covid_tests as t join FirstPositive as fp 
on t.patient_id = fp.patient_id 
where t.result = 'Negative' and fp.first_positive_date < t.test_date
group by t.patient_id, fp.first_positive_date
)
select 
    f.patient_id , 
    p.patient_name , 
    p.age , 
    DATEDIFF(day,  first_positive_date,first_negative_date) as recovery_time 
from FirstNegativeAfterPos as f join
patients p on f.patient_id = p.patient_id
order by recovery_time asc,p.patient_name asc
--Câu 37 : Find Drivers with Improved Fuel Efficiency
-- Viết một bài toán tìm những tài xế có hiệu suất nhiên liệu được cải thiện bằng cách so sánh hiệu suất nhiên liệu trung bình của họ trong nửa đầu năm với nửa cuối năm. 
-- Tính hiệu suất nhiên liệu bằng công thức: quãng đường_km / nhiên liệu_tiêu thụ cho mỗi chuyến đi. 
-- Nửa đầu năm: Tháng 1 đến tháng 6, Nửa cuối năm: Tháng 7 đến tháng 12 
-- Chỉ bao gồm những tài xế có chuyến đi trong cả hai nửa năm. 
-- Tính mức độ cải thiện hiệu suất bằng công thức: (trung bình nửa cuối năm - trung bình nửa đầu năm). 
-- Làm tròn tất cả các kết quả đến 2 chữ số thập phân. 
-- Trả về bảng kết quả được sắp xếp theo mức độ cải thiện hiệu suất giảm dần, sau đó theo tên tài xế tăng dần.
with FirstHalf as (select driver_id , avg(distance_km*1.0/fuel_consumed) as first_half_avg
 
from trips 
WHERE MONTH(trip_date) BETWEEN 1 AND 6
group by driver_id 
)
, SecondHalf as (
 select driver_id , avg(distance_km*1.0/fuel_consumed) as second_half_avg
from trips 
WHERE MONTH(trip_date) BETWEEN 7 AND 12
group by driver_id
 
)
select fh.driver_id ,d.driver_name ,ROUND(fh.first_half_avg,2)as first_half_avg , ROUND(sh.second_half_avg,2) as second_half_avg, 
ROUND(sh.second_half_avg - fh.first_half_avg*1.0,2) as efficiency_improvement
 from 
FirstHalf fh join SecondHalf sh on fh.driver_id = sh.driver_id and fh.first_half_avg < sh.second_half_avg join drivers d on sh.driver_id = d.driver_id

order by efficiency_improvement desc , d.driver_name
--C2:
WITH DriverEfficiency AS (
    SELECT 
        t.driver_id,
        d.driver_name,
        -- Tính trung bình nửa đầu năm (Tháng 1 -> 6)
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 1 AND 6 THEN t.distance_km * 1.0 / t.fuel_consumed END) AS first_half_avg,
        -- Tính trung bình nửa cuối năm (Tháng 7 -> 12)
        AVG(CASE WHEN MONTH(t.trip_date) BETWEEN 7 AND 12 THEN t.distance_km * 1.0 / t.fuel_consumed END) AS second_half_avg
    FROM trips t
    JOIN drivers d ON t.driver_id = d.driver_id
    GROUP BY t.driver_id, d.driver_name
    HAVING 
        -- Đảm bảo tài xế có chuyến đi trong CẢ HAI nửa năm
        COUNT(CASE WHEN MONTH(t.trip_date) BETWEEN 1 AND 6 THEN 1 END) > 0
        AND COUNT(CASE WHEN MONTH(t.trip_date) BETWEEN 7 AND 12 THEN 1 END) > 0
)
SELECT 
    driver_id,
    driver_name,
    ROUND(first_half_avg, 2) AS first_half_avg,
    ROUND(second_half_avg, 2) AS second_half_avg,
    ROUND(second_half_avg - first_half_avg, 2) AS efficiency_improvement
FROM DriverEfficiency
WHERE second_half_avg > first_half_avg -- Chỉ lấy những tài xế CÓ CẢI THIỆN
ORDER BY 
    efficiency_improvement DESC, 
    driver_name ASC;
--Câu 38: Find Overbooked Employees 
-- Viết một bài toán tìm nhân viên dành nhiều thời gian họp - những nhân viên dành hơn 50% thời gian làm việc cho các cuộc họp trong bất kỳ tuần nào. Giả sử một tuần làm việc tiêu chuẩn là 40 giờ. 
-- Tính tổng số giờ họp của mỗi nhân viên mỗi tuần (Thứ Hai đến Chủ Nhật).
-- Một nhân viên được coi là dành nhiều thời gian họp nếu số giờ họp hàng tuần của họ > 20 giờ (50% của 40 giờ). 
-- Đếm số tuần mỗi nhân viên dành nhiều thời gian họp. Chỉ bao gồm những nhân viên dành nhiều thời gian họp trong ít nhất 2 tuần. 
-- Trả về bảng kết quả được sắp xếp theo số tuần dành nhiều thời gian họp theo thứ tự giảm dần, sau đó theo tên nhân viên theo thứ tự tăng dần.
WITH WeeklyMeetings AS (
    -- Bước 1 & 2: Gom nhóm theo nhân viên + tuần ISO, lọc tuần > 20 giờ họp
    SELECT 
        employee_id,
        DATEPART(yyyy, meeting_date) AS meeting_year,
        DATEPART(iso_week, meeting_date) AS meeting_week,
        SUM(duration_hours) AS total_hours
    FROM meetings
    GROUP BY 
        employee_id,
        DATEPART(yyyy, meeting_date),
        DATEPART(iso_week, meeting_date)
    HAVING SUM(duration_hours) > 20
),
HeavyUsers AS (
    -- Bước 3: Đếm số tuần meeting-heavy của mỗi nhân viên, lọc >= 2 tuần
    SELECT 
        employee_id,
        COUNT(*) AS meeting_heavy_weeks
    FROM WeeklyMeetings
    GROUP BY employee_id
    HAVING COUNT(*) >= 2
)
-- Bước 4: JOIN lấy thông tin nhân viên và sắp xếp kết quả
SELECT 
    e.employee_id,
    e.employee_name,
    e.department,
    h.meeting_heavy_weeks
FROM HeavyUsers h
JOIN employees e ON h.employee_id = e.employee_id
ORDER BY h.meeting_heavy_weeks DESC, e.employee_name ASC;
-- Câu 39 : Find Stores with Inventory Imbalance
-- Viết lời giải để tìm các cửa hàng có sự mất cân bằng hàng tồn kho - các cửa hàng mà sản phẩm đắt nhất có số lượng tồn kho thấp hơn sản phẩm rẻ nhất. 
-- Đối với mỗi cửa hàng, hãy xác định sản phẩm đắt nhất (giá cao nhất) và số lượng của nó. 
-- Đối với mỗi cửa hàng, hãy xác định sản phẩm rẻ nhất (giá thấp nhất) và số lượng của nó. 
-- Một cửa hàng có sự mất cân bằng hàng tồn kho nếu số lượng của sản phẩm đắt nhất ít hơn số lượng của sản phẩm rẻ nhất. 
-- Tính tỷ lệ mất cân bằng bằng công thức (số lượng sản phẩm rẻ nhất / số lượng sản phẩm đắt nhất). 
-- Làm tròn tỷ lệ mất cân bằng đến 2 chữ số thập phân. 
-- Chỉ bao gồm các cửa hàng có ít nhất 3 sản phẩm khác nhau. 
-- Trả về bảng kết quả được sắp xếp theo tỷ lệ mất cân bằng giảm dần, sau đó theo tên cửa hàng tăng dần.

with cte as (select store_id, product_name,quantity,price,
ROW_NUMBER() over (partition by store_id order by price desc) as rnk_price
from inventory )
, 
cte2 as (
select store_id, product_name,quantity,price,
 ROW_NUMBER() over (partition by store_id order by price asc) as rnk_price_min
from inventory
),
cte_count AS (
    SELECT 
        store_id
        
    FROM inventory
    GROUP BY store_id
    HAVING COUNT(DISTINCT product_name) >= 3 -- Lọc trực tiếp các cửa hàng >= 3 sản phẩm
)
select 
    cte.store_id,
    s.store_name,
    s.location,
    cte.product_name as most_exp_product,
    cte2.product_name as cheapest_product,
     ROUND(cte2.quantity*1.0/cte.quantity,2) as imbalance_ratio
 from cte join cte2
 on cte.store_id = cte2.store_id 
 and cte.rnk_price = 1 
 and cte2.rnk_price_min =1 
 join cte_count as c 
 on cte.store_id = c.store_id 
 join stores s on cte.store_id = s.store_id
where cte.quantity < cte2.quantity 
-- Câu 40 : Find Books with Polarized Opinions

-- Viết một bài toán tìm sách có ý kiến ​​trái chiều - những cuốn sách nhận được cả điểm đánh giá rất cao và rất thấp từ các độc giả khác nhau. 
-- Một cuốn sách được coi là có ý kiến ​​trái chiều nếu nó có ít nhất một điểm đánh giá ≥ 4 và ít nhất một điểm đánh giá ≤ 2. 
-- Chỉ xem xét những cuốn sách có ít nhất 5 lần đọc. 
-- Tính độ chênh lệch điểm đánh giá bằng công thức (điểm_đánh_cao_nhất - điểm_đánh_thấp_nhất). 
-- Tính điểm phân cực bằng số điểm đánh giá cực đoan (điểm ≤ 2 hoặc ≥ 4) chia cho tổng số lần đọc.
-- Chỉ bao gồm những cuốn sách có điểm phân cực ≥ 0,6 (ít nhất 60% điểm đánh giá cực đoan). 
-- Trả về bảng kết quả được sắp xếp theo điểm phân cực giảm dần, sau đó theo tiêu đề giảm dần. Điểm phân cực nên được làm tròn đến 2 chữ số thập phân.
--C1: tách ra 2 cte :  kiểm tra 5 lần đọc ,và có ít nhất điểm đánh giá >= 4 và <=2 , tính độ chênh lệch và cte 2 tính điểm phân cực
with BookReading5 as (select book_id ,MAX(session_rating) - MIN(session_rating) as rating_spread
from reading_sessions 
group by book_id 
having COUNT(book_id) >=5 and MAX(session_rating) >=4 and MIN(session_rating)<=2)
, 
cte as (select 
    r.book_id,
    ROUND(AVG(CASE WHEN r.session_rating <=2 or r.session_rating>=4 then 1.0 else 0.0 end ),2) as polarization_score,
    b5.rating_spread
from reading_sessions r join BookReading5 b5
on r.book_id = b5.book_id
group by r.book_id , b5.rating_spread
having AVG(CASE WHEN r.session_rating <=2 or r.session_rating>=4 then 1.0 else 0.0 end ) >= 0.6)

select 
    c.book_id,
    b.title,
    b.author,
    b.genre,
    b.pages,
    c.rating_spread,
    c.polarization_score
from cte as c 
join books b 
on c.book_id = b.book_id
order by c.polarization_score desc, b.title desc
--C2: chỉ join 1 lần bảng reading_sessions
WITH PolarizationSummary AS (
    SELECT 
        book_id,
        -- Độ chênh lệch = Max - Min
        MAX(session_rating) - MIN(session_rating) AS rating_spread,
        -- Điểm phân cực = Số điểm cực đoan / Tổng số lượt đọc
        ROUND(
            CAST(SUM(CASE WHEN session_rating <= 2 OR session_rating >= 4 THEN 1 ELSE 0 END) AS FLOAT) 
            / COUNT(*), 
            2
        ) AS polarization_score
    FROM reading_sessions
    GROUP BY book_id
    HAVING 
        COUNT(*) >= 5                                              -- Ít nhất 5 lần đọc
        AND MAX(session_rating) >= 4                               -- Có ít nhất 1 đánh giá >= 4
        AND MIN(session_rating) <= 2                               -- Có ít nhất 1 đánh giá <= 2
        AND CAST(SUM(CASE WHEN session_rating <= 2 OR session_rating >= 4 THEN 1 ELSE 0 END) AS FLOAT) 
            / COUNT(*) >= 0.6                                     -- Điểm phân cực >= 0.6
)
SELECT 
    p.book_id,
    b.title,
    b.author,
    b.genre,
    b.pages,
    p.rating_spread,
    p.polarization_score
FROM PolarizationSummary p
JOIN books b 
    ON p.book_id = b.book_id
ORDER BY 
    p.polarization_score DESC,                                    -- Điểm phân cực giảm dần
    b.title DESC;                                                 -- Tiêu đề giảm dần
-- Câu 41: Find Loyal Customers
-- Viết một giải pháp để tìm khách hàng trung thành. 
-- Một khách hàng được coi là trung thành nếu họ đáp ứng TẤT CẢ các tiêu chí sau: 
-- Đã thực hiện ít nhất 3 giao dịch mua hàng. 
-- Đã hoạt động ít nhất 30 ngày. Tỷ lệ hoàn tiền của họ dưới 20%. 
-- Tỷ lệ hoàn tiền là tỷ lệ các giao dịch được hoàn tiền, 
-- được tính bằng số giao dịch hoàn tiền chia cho tổng số giao dịch (mua hàng cộng với hoàn tiền). 
-- Trả về bảng kết quả được sắp xếp theo customer_id theo thứ tự tăng dần.

select customer_id 
from customer_transactions 
group by customer_id 
having COUNT(*) >= 3 and DATEDIFF(day, MIN(transaction_date),MAX(transaction_date)) >= 30
and AVG(CASE WHEN transaction_type = 'refund' then 1.0 else 0.0 end)*100.0 <20 
order by customer_id asc

--Câu 41: Find Golden Hour Customers
-- Viết một giải pháp để tìm khách hàng giờ vàng - những khách hàng thường xuyên đặt hàng trong giờ cao điểm và mang lại sự hài lòng cao. 
-- Một khách hàng được coi là khách hàng giờ vàng nếu họ đáp ứng TẤT CẢ các tiêu chí sau: 
-- Đã đặt ít nhất 3 đơn hàng. 
-- Ít nhất 60% đơn hàng của họ được đặt trong giờ cao điểm (11:00-14:00 hoặc 18:00-21:00).
-- Xếp hạng trung bình của họ cho các đơn hàng đã đánh giá ít nhất là 4.0, làm tròn đến 2 chữ số thập phân. 
-- Đã đánh giá ít nhất 50% đơn hàng của họ. 
-- Trả về bảng kết quả được sắp xếp theo xếp hạng trung bình giảm dần, sau đó theo mã khách hàng giảm dần.

select 
    customer_id ,
    COUNT(*) as total_orders ,
    ROUND(AVG(
     CASE when  CAST(order_timestamp AS TIME) BETWEEN '11:00:00' AND '14:00:00' 
        or  CAST(order_timestamp AS TIME) BETWEEN '18:00:00' AND '21:00:00' then 1.0 else 0.0 end )  *100.0,0)
        as peak_hour_percentage,
     ROUND(AVG(CAST(order_rating AS FLOAT)), 2)  as average_rating
from restaurant_orders 
group by customer_id 
having COUNT(*)>2 
and AVG(
     CASE when  CAST(order_timestamp AS TIME) BETWEEN '11:00:00' AND '14:00:00' 
        or  CAST(order_timestamp AS TIME) BETWEEN '18:00:00' AND '21:00:00' then 1.0 else 0.0 end ) >= 0.6
and AVG ( CASE WHEN order_rating is not null then 1.0 else 0.0 end) >=0.5
and ROUND(AVG(CAST(order_rating AS FLOAT)), 2) >= 4.0
order by average_rating desc , customer_id desc
--Câu 42: Find Churn Risk Customers
--C1:
-- Viết giải pháp để tìm Khách hàng có nguy cơ hủy đăng ký - những người dùng có dấu hiệu cảnh báo trước khi hủy. 
-- Một người dùng được coi là khách hàng có nguy cơ hủy đăng ký nếu họ đáp ứng TẤT CẢ các tiêu chí sau: 
-- Hiện đang có đăng ký hoạt động (sự kiện cuối cùng của họ không phải là hủy). 
-- Đã thực hiện ít nhất một lần hạ cấp gói đăng ký trong lịch sử đăng ký của họ. 
-- Doanh thu của gói hiện tại thấp hơn 50% so với doanh thu tối đa của gói trước đây. 
-- Đã là người đăng ký ít nhất 60 ngày. 
-- Trả về bảng kết quả được sắp xếp theo số ngày đăng ký giảm dần, sau đó theo ID người dùng tăng dần.

with cte as (select user_id, event_date,event_type , monthly_amount,plan_name,
ROW_NUMBER() over (partition by user_id order by event_date desc) rnk_date_desc
from subscription_events)
, cte2 as (
select  user_id,monthly_amount,plan_name from cte
where rnk_date_desc = 1 and event_type != 'cancel')
select 
    s.user_id,
    cte2.plan_name as current_plan,
    MIN(cte2.monthly_amount) as current_monthly_amount,
    MAX(s.monthly_amount) as max_historical_amount,
    DATEDIFF(day,MIN(event_date),MAX(event_date)) as days_as_subscriber
    
from cte2 join subscription_events s on cte2.user_id = s.user_id
group by s.user_id,cte2.plan_name
having COUNT(CASE WHEN event_type='downgrade' then 1 end) >0 
and DATEDIFF(day,MIN(event_date),MAX(event_date)) >= 60
and MIN(cte2.monthly_amount)/MAX(s.monthly_amount)*100 < 50
order by days_as_subscriber desc , s.user_id 
--C2:
WITH RankedEvents AS (
    SELECT 
        user_id,
        event_date,
        event_type,
        plan_name,
        monthly_amount,
        -- Xếp hạng từ mới nhất đến cũ nhất
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date DESC) AS rnk_desc,
        -- Lấy ngày đăng ký đầu tiên
        MIN(event_date) OVER (PARTITION BY user_id) AS first_event_date
    FROM subscription_events
),
UserStats AS (
    SELECT 
        user_id,
        -- Thông tin sự kiện hiện tại (rnk_desc = 1)
        MAX(CASE WHEN rnk_desc = 1 THEN plan_name END) AS current_plan,
        MAX(CASE WHEN rnk_desc = 1 THEN monthly_amount END) AS current_monthly_amount,
        MAX(CASE WHEN rnk_desc = 1 THEN event_type END) AS latest_event_type,
        
        -- Doanh thu tối đa của các gói TRƯỚC ĐÂY (rnk_desc > 1)
        MAX(CASE WHEN rnk_desc > 1 THEN monthly_amount END) AS max_historical_amount,
        
        -- Số lần hạ cấp trong lịch sử
        SUM(CASE WHEN event_type = 'downgrade' THEN 1 ELSE 0 END) AS downgrade_count,
        
        -- Số ngày đăng ký (từ sự kiện đầu tiên đến sự kiện mới nhất)
        DATEDIFF(day, MIN(first_event_date), MAX(event_date)) AS days_as_subscriber
    FROM RankedEvents
    GROUP BY user_id
)
SELECT 
    user_id,
    current_plan,
    cgit -add .t_monthly_amount,
    max_historical_amount,
    days_as_subscriber
FROM UserStats
WHERE 
    latest_event_type != 'cancel'                                     -- 1. Đang hoạt động
    AND downgrade_count > 0                                           -- 2. Đã từng hạ cấp
    AND current_monthly_amount < (max_historical_amount * 0.5)        -- 3. Thấp hơn 50% max trước đây
    AND days_as_subscriber >= 60                                      -- 4. Đăng ký >= 60 ngày
ORDER BY 
    days_as_subscriber DESC, 
    user_id ASC;
--Câu 43 :  Find Emotionally Consistent Users
-- Viết một giải pháp để xác định người dùng có tính nhất quán về mặt cảm xúc dựa trên các yêu cầu sau:
--  Đối với mỗi người dùng, hãy đếm tổng số phản ứng mà họ đã đưa ra. 
--  Chỉ bao gồm những người dùng đã phản ứng với ít nhất 5 nội dung khác nhau. 
--  Một người dùng được coi là nhất quán về mặt cảm xúc nếu ít nhất 60% phản ứng của họ thuộc cùng một loại.
-- Trả về bảng kết quả được sắp xếp theo tỷ lệ phản ứng (reaction_ratio) giảm dần và sau đó theo ID người dùng (user_id) tăng dần. Lưu ý: Tỷ lệ phản ứng (reaction_ratio) cần được làm tròn đến 2 chữ số thập phân.
with cte as (
    select 
    user_id ,
    COUNT(reaction) as total_reaction
from reactions 
group by user_id 
having count(distinct content_id ) >4)
,cte2 as (
select reaction,user_id ,COUNT(reaction) as total_reaction_type
from reactions 
group by reaction ,user_id)

select cte.user_id , cte2.reaction as dominant_reaction, ROUND(cte2.total_reaction_type*1.0/cte.total_reaction,2) as reaction_ratio from 
cte join cte2 on 
cte.user_id = cte2.user_id 
where cte2.total_reaction_type*1.0/cte.total_reaction >=0.6
order by reaction_ratio desc , cte.user_id 
-- Câu 43: Training Count
select t.user_id, u.username  , t.training_date , COUNT(training_id) as training_count
from users as u right join training_details as t 
on u.user_id = t.user_id
group by t.user_id , t.training_date
having COUNT(training_id) > 1
order by training_date asc, training_count desc,t.user_id 
--Câu 44: User's Third Transaction
with cte as (SELECT user_id , spend , transaction_date,
ROW_NUMBER() OVER(partition by user_id order by transaction_date asc) as rnk
FROM transactions)
select user_id , spend, transaction_date 
from cte 
where rnk = 3
--Câu 45: Second Highest Salary
SELECT salary as second_highest_salary
FROM (select salary ,
ROW_NUMBER() OVER(order by salary desc) as rnk_salary
from employee
) as trans_emp
where trans_emp.rnk_salary = 2
--Câu 46: Sending vs. Opening Snaps
SELECT age_bucket ,
ROUND(SUM(case when activity_type = 'send' then time_spent else 0 end) *100.0/SUM(time_spent),2) as send_perc,
ROUND(SUM(case when activity_type = 'open' then time_spent else 0 end) *100.0/SUM(time_spent),2) as open_perc

FROM activities as act join age_breakdown as age 
on act.user_id = age.user_id 
where act.activity_type in('open','send')
group by age.age_bucket 
--Câu 47: Tweets' Rolling Averages
SELECT
    user_id,
    tweet_date,
    ROUND(AVG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg_3d
FROM
    tweets;
--Câu 48: Highest-Grossing Items
SELECT 
  category, 
  product, 
  total_spend 
  from(
select category,product , SUM(spend) as total_spend,
ROW_NUMBER() OVER(partition by category ORDER by sum(spend) desc) rnk
from product_spend where YEAR(transaction_date) =2022
group by category,product ) as ranked_spending

where ranked_spending.rnk <=2
--Câu 49: Top Three Salaries
with cte as (SELECT d.department_name , 
e.name, e.salary,
DENSE_RANK() over(partition by e.department_id order by e.salary desc) as rnk 
FROM employee e join department d 
ON e.department_id = d.department_id)
SELECT department_name , 
name, salary
from cte 
where rnk < 4
order by department_name asc, salary desc, name asc
--Câu 50: Signup Activation Rate
SELECT  ROUND(COUNT(t.email_id)*1.0/COUNT(DISTINCT e.email_id),2
) as activation_rate
from emails e left join texts t 
on e.email_id = t.email_id and t.signup_action = 'Confirmed'
--Câu 51: Spotify Streaming History
with cte as 
(SELECT 
  user_id ,
  song_id ,
  COUNT(*) as total_weekly
FROM songs_weekly  
where listen_time <='2022-08-04 23:59:59'
group by user_id ,song_id

UNION ALL

SELECT 
    user_id, 
    song_id, 
    song_plays
  FROM songs_history)
select user_id , song_id,SUM(total_weekly) as song_plays
from cte 
group by user_id , song_id
order by song_plays desc
--Câu 52: Supercloud Customer
WITH cte as (
select COUNT(DISTINCT product_category) as total_category FROM products
)

SELECT c.customer_id FROM customer_contracts c
join products p on c.product_id = p.product_id
group by c.customer_id 
having COUNT(DISTINCT p.product_category) = (select total_category from cte)
--Câu 53 : Odd and Even Measurements
with cte as (SELECT measurement_id , measurement_value, measurement_time ,
ROW_NUMBER() over(partition by CAST(measurement_time as date ) order by measurement_time asc) as rnk
FROM measurements)
select DATE_TRUNC('day', measurement_time) as measurement_day,
SUM(Case when rnk % 2 !=0 then measurement_value else 0.0 end ) as odd_sum,
SUM(Case when rnk % 2 =0 then measurement_value else 0.0 end) as even_sum
from cte 
group by DATE_TRUNC('day',measurement_time)
order by measurement_day
--Câu 54: Swapped Food Delivery
SELECT 
CASE WHEN 
 (order_id = (select MAX(order_id) from orders)) and order_id % 2!=0 then order_id
 WHEN order_id % 2 =0 then order_id -1
 ELSE  order_id + 1 end as corrected_order_id ,item
FROM orders 
order by corrected_order_id 
--Câu 55: FAANG Stock Min-Max (Part 1)
with cte as (SELECT ticker,TO_CHAR(date, 'Mon-YYYY') AS month ,
open,
DENSE_RANK() over(partition by ticker order by open desc) as rnk_hightopen
FROM stock_prices)
,cte2 as (SELECT ticker,TO_CHAR(date, 'Mon-YYYY') AS month ,
open,
DENSE_RANK() over (partition by ticker order by open asc) as rnk_lowestopen
FROM stock_prices)
select c1.ticker,c1.month as highest_mth, c1.open as highest_open,
c2.month as lowest_mth,
c2.open as lowest_open

from cte c1 join cte2 c2 on c1.ticker = c2.ticker  and  
 c1.rnk_hightopen =1 and c2.rnk_lowestopen =1
 order by c1.ticker
 --Câu 56: Best-Selling Product
 with cte as (SELECT p.category_name , p.product_name , s.sales_quantity , s.rating,
DENSE_RANK() OVER(partition by p.category_name order by s.sales_quantity desc , s.rating desc) rnk
FROM products p join product_sales s 
ON p.product_id = s.product_id )
select category_name , product_name 
from cte 
where rnk =1 
order by category_name
-- Câu 57: User Shopping Sprees
WITH deduplicated AS (
   
    SELECT DISTINCT 
        user_id, 
        transaction_date::date AS transaction_date
    FROM transactions
),
ranked_transactions AS (
  
    SELECT 
        user_id,
        transaction_date,
       
        transaction_date - (ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY transaction_date
        ))::int AS spree_group
    FROM deduplicated
),
spree_summary AS (
   
    SELECT 
        user_id,
       
        COUNT(*) AS consecutive_days
    FROM ranked_transactions
    GROUP BY user_id, spree_group
)

SELECT 
    user_id
FROM spree_summary
WHERE consecutive_days >= 3
ORDER BY user_id;
--Câu 58: Histogram of Users and Purchases
with cte as (SELECT user_id ,
transaction_date,
DENSE_RANK() over(partition by user_id order by transaction_date desc) rnk_trandate
FROM user_transactions)
select MAX(transaction_date) as transaction_date , user_id , COUNT(user_id) as purchase_count
from cte 
where rnk_trandate=1
group by user_id
order by transaction_date
--Câu 59: Compressed Mode
SELECT item_count as mode 
FROM items_per_order
where order_occurrences = (Select MAX(order_occurrences) from items_per_order)
order by item_count
--Câu 60: Card Launch Success
select card_name,issued_amount 
from (
    SELECT issue_month,issue_year,card_name,issued_amount,
     ROW_NUMBER() over(partition by card_name order by issue_year, issue_month) as rnk 
     FROM monthly_cards_issued )
as tran
where tran.rnk =1
order by issued_amount desc
--Câu 61: International Call Percentage
SELECT  
  ROUND(100.0*SUM(CASE 
    WHEN caller.country_id <> receiver.country_id THEN 1 ELSE NULL END)/ COUNT(*),1) AS international_call_pct
  
FROM phone_calls AS calls
LEFT JOIN phone_info AS caller
  ON calls.caller_id = caller.caller_id
LEFT JOIN phone_info AS receiver
  ON calls.receiver_id = receiver.caller_id;
--Câu 62: Patient Support Analysis (Part 2)
SELECT ROUND(
    100.0*SUM(
        CASE WHEN call_category ='n/a' or call_category is NULL then 1 else NULL end)
        /COUNT(*),1) as uncategorised_call_pct  
FROM callers
--Câu 63:
SELECT distinct year(birth_date) as birth_year from patients order by birth_year
--Câu 64:
SELECT first_name from patients group by first_name having COUNT(*) =1
order by first_name
--Câu 65: Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
SELECT patient_id,first_name FROM patients
where len(first_name) >5 and lower(first_name) like '%s' and lower(first_name) like 's%'
--Câu 66:
SELECT p.patient_id,p.first_name,p.last_name FROM patients p join admissions a on p.patient_id = a.patient_id
where a.diagnosis = 'Dementia'