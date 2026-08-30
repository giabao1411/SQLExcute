-- Câu 1: Interviews
-- Tính tổng của từng bảng submission, view .group challenge_id
-- Join 2 bảng tạm đó với bảng challenges left join vì sẽ có trường hợp chỉ có người dùng xem mà không nộp bài và ngược lại 
-- nên lấy hết bên challenges mới đảm bảo đủ dữ liệu
-- group theo contest , hacker_id, name 

with Agg_Submission as (    
    select challenge_id,
    SUM(total_submissions) as sum_total_submission,
    SUM(total_accepted_submissions) as sum_total_accept_submission
    from Submission_Stats 
    GROUP BY challenge_id
),
Agg_Stats as (
    SELECT
    challenge_id,
    SUM(total_views) as sum_total_views,
    SUM(total_unique_views) as sum_total_unique_views
    from View_Stats
    group by challenge_id
    
)
select c.contest_id , c.hacker_id,c.name,
COALESCE(SUM(ags.sum_total_submission),0),
COALESCE(SUM(ags.sum_total_accept_submission),0),
COALESCE(SUM(agv.sum_total_views),0),
COALESCE(SUM(agv.sum_total_unique_views),0)
from 
Contests as c join Colleges as col on c.contest_id = col.contest_id
join Challenges as chal on col.college_id = chal.college_id
left join Agg_Submission as ags on chal.challenge_id = ags.challenge_id
left join Agg_Stats as agv on chal.challenge_id = agv.challenge_id
GROUP BY c.contest_id , c.hacker_id , c.name
HAVING COALESCE(SUM(ags.sum_total_submission),0)+
COALESCE(SUM(ags.sum_total_accept_submission),0)+
COALESCE(SUM(agv.sum_total_views),0)+
COALESCE(SUM(agv.sum_total_unique_views),0) > 0
order by c.contest_id asc
-- Câu 2 : 15 Days of Learning SQL
WITH 
-- -------------------------------------------------------------
-- NHÁNH 1: Đếm số hacker nộp bài liên tục từ ngày đầu tiên
-- -------------------------------------------------------------
-- Bước 1.1: Đếm số ngày NỘP BÀI DUY NHẤT của mỗi hacker tính TỪ ĐẦU cho đến ngày S1.submission_date
Hacker_Cumulative_Days AS (
    SELECT 
        s1.submission_date,
        s1.hacker_id,
        COUNT(DISTINCT s2.submission_date) AS days_submitted
    FROM (SELECT DISTINCT submission_date, hacker_id FROM Submissions) s1
    JOIN (SELECT DISTINCT submission_date, hacker_id FROM Submissions) s2 
      ON s2.hacker_id = s1.hacker_id 
     AND s2.submission_date <= s1.submission_date
    GROUP BY s1.submission_date, s1.hacker_id
),

-- Bước 1.2: Lọc các hacker có số ngày nộp bằng đúng số ngày đã trôi qua kể từ 2016-03-01
Consistent_Hackers_Count AS (
    SELECT 
        submission_date,
        COUNT(hacker_id) AS total_consistent_hackers
    FROM Hacker_Cumulative_Days
    -- DATEDIFF + 1 tính ra số ngày lý thuyết kể từ ngày bắt đầu 2016-03-01
    WHERE days_submitted = DATEDIFF(day, '2016-03-01', submission_date) + 1
    GROUP BY submission_date
),

-- -------------------------------------------------------------
-- NHÁNH 2: Tìm Top 1 Hacker có số bài nộp nhiều nhất mỗi ngày
-- -------------------------------------------------------------
-- Bước 2.1: Đếm tổng số bài nộp của mỗi hacker trong từng ngày
Daily_Submission_Counts AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(submission_id) AS sub_count
    FROM Submissions
    GROUP BY submission_date, hacker_id
),

-- Bước 2.2: Xếp hạng Hacker theo số bài nộp giảm dần, hacker_id tăng dần
Ranked_Daily_Hackers AS (
    SELECT 
        submission_date,
        hacker_id,
        ROW_NUMBER() OVER (
            PARTITION BY submission_date 
            ORDER BY sub_count DESC, hacker_id ASC
        ) AS rnk
    FROM Daily_Submission_Counts
)

-- -------------------------------------------------------------
-- BƯỚC CUỐI: Ghép 2 nhánh lại với bảng Hackers để lấy tên
-- -------------------------------------------------------------
SELECT 
    c.submission_date,
    c.total_consistent_hackers,
    r.hacker_id,
    h.name
FROM Consistent_Hackers_Count c
JOIN Ranked_Daily_Hackers r 
  ON c.submission_date = r.submission_date AND r.rnk = 1
JOIN Hackers h 
  ON r.hacker_id = h.hacker_id
ORDER BY c.submission_date ASC;
-- Câu 3 : Department Top Three Salaries 
WITH RankedSalaries AS (
    SELECT 
        d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (
            PARTITION BY e.departmentId 
            ORDER BY e.salary DESC
        ) AS rnk
    FROM Employee e
    JOIN Department d ON e.departmentId = d.id
)
SELECT Department, Employee, Salary
FROM RankedSalaries
WHERE rnk <= 3;
-- Câu 4 : Trips and Users
WITH TbUsersNotBanned AS (
    SELECT status, request_at
    FROM Trips
    WHERE client_id IN (SELECT users_id FROM Users WHERE banned = 'No')
      AND driver_id IN (SELECT users_id FROM Users WHERE banned = 'No')
      AND request_at BETWEEN '2013-10-01' AND '2013-10-03' 
)
SELECT 
        request_at AS Day,
        
        CAST(
            SUM(CASE WHEN status LIKE 'cancelled%' THEN 1.0 ELSE 0 END) 
            / COUNT(*) as
            DECIMAL(12,2)
        ) AS 'Cancellation Rate'
    FROM TbUsersNotBanned
    GROUP BY request_at
--Câu 5: Human Traffic of Stadium
-- Viết chương trình để hiển thị các bản ghi có từ ba hàng trở lên với ID liên tiếp, và số người trong mỗi hàng lớn hơn hoặc bằng 100. Trả về bảng kết quả được sắp xếp theo ngày truy cập theo thứ tự tăng dần. Định dạng kết quả được thể hiện trong ví dụ sau.
with cte as (select 
    id, 
    LEAD(id,1) over(order by id asc) as next,
    Lead(id,2) over(order by id asc) as next2
    from Stadium 
    where people >=100)
 , cte2 as (  select id ,
    next,next2
    from cte where id=next-1 and id = next2-2 )

select distinct s.id,s.visit_date,s.people from stadium s join cte2 on s.id = cte2.id or s.id = cte2.next or s.id =cte2.next2
    order by s.id asc
    --C2 : id-row_number(): tách từng nhóm nếu liên tiếp thì nằm trong 1 nhóm nếu không liên tiếp bị tách ra 1 nhóm khác 
    WITH Filtered AS (
    SELECT 
        id, 
        visit_date, 
        people,
        id - ROW_NUMBER() OVER (ORDER BY id ASC) AS grp --gộp nhóm liên tiếp
    FROM Stadium
    WHERE people >= 100
),
Grouped AS (
    SELECT *, COUNT(*) OVER (PARTITION BY grp) AS cnt --đếm số lượng trong nhóm đó 
    FROM Filtered
)
SELECT id, visit_date, people
FROM Grouped
where cnt >=3 --nhóm nào có hơn 3 dòng thì lấy giá trị
order by id
--Câu 6: Find Category Recommendation Pairs
-- Amazon muốn hiểu rõ hành vi mua sắm trên các danh mục sản phẩm. 
-- Hãy viết một giải pháp cho bài toán: Tìm tất cả các cặp danh mục (trong đó danh mục 1 < danh mục 2) 
-- Đối với mỗi cặp danh mục, xác định số lượng khách hàng duy nhất đã mua sản phẩm từ cả hai danh mục. 
-- Một cặp danh mục được coi là có thể báo cáo nếu có ít nhất 3 khách hàng khác nhau đã mua sản phẩm từ cả hai danh mục. 
-- Trả về bảng kết quả gồm các cặp danh mục có thể báo cáo được sắp xếp theo số lượng khách hàng giảm dần, và trong trường hợp có số lượng bằng nhau, sắp xếp theo danh mục 1 tăng dần theo thứ tự từ điển, sau đó theo danh mục 2 tăng dần.
with cte as (
    select distinct
        pp.user_id,
        pi.category
        from ProductPurchases pp join ProductInfo pi 
        on pp.product_id = pi.product_id 

)
SELECT 
    c1.category AS category1,
    c2.category AS category2,
    COUNT(c1.user_id) AS customer_count
FROM cte c1
JOIN cte c2 
    ON c1.user_id = c2.user_id 
   AND c1.category < c2.category
GROUP BY c1.category, c2.category
HAVING COUNT(c1.user_id) >= 3
ORDER BY 
    customer_count DESC, 
    category1 ASC, 
    category2 ASC;
--Câu 7 : Find Zombie Sessions
-- Viết một giải pháp để xác định các phiên "ma", tức là các phiên mà người dùng có vẻ hoạt động nhưng lại thể hiện các hành vi bất thường. 
-- Một phiên được coi là phiên "ma" nếu đáp ứng TẤT CẢ các tiêu chí sau: 
-- Thời lượng phiên hơn 30 phút. 
-- Có ít nhất 5 sự kiện cuộn trang. 
-- Tỷ lệ nhấp chuột trên cuộn trang nhỏ hơn 0,20. 
-- Không có giao dịch mua nào được thực hiện trong phiên đó. 
-- Trả về bảng kết quả được sắp xếp theo số lần cuộn trang giảm dần, sau đó theo ID phiên tăng dần.
with cte as (select user_id,
        session_id,
        DATEDIFF(minute,MIN(event_timestamp),MAX(event_timestamp)) as minute,
        SUM(CASE WHEN event_type= 'scroll'then 1 else 0 end) as count_scroll,
        SUM(CASE WHEN event_type='click' then 1  else 0 end) as count_click,
        SUM(Case when event_type='purchase' then 1 else 0 end) as count_purchase

from app_events 
group by user_id , session_id)
select session_id ,
        user_id ,
        minute as session_duration_minutes,
        count_scroll as scroll_count
from cte 
where minute > 30
and count_scroll >= 5
and count_click*1.0/count_scroll,2 < 0.20
and count_purchase = 0
order by scroll_count desc , session_id asc
--Câu 8: Find Invalid IP Addresses
-- Viết chương trình để tìm các địa chỉ IP không hợp lệ. 
-- Một địa chỉ IPv4 không hợp lệ nếu đáp ứng bất kỳ điều kiện nào sau đây: 
-- Chứa các số lớn hơn 255 trong bất kỳ octet nào
--  Có số 0 đứng đầu trong bất kỳ octet nào (ví dụ: 01.02.03.04) 
--  Có ít hơn hoặc nhiều hơn 4 octet 
--  Trả về bảng kết quả được sắp xếp theo invalid_count và ip theo thứ tự giảm dần.
SELECT 
    ip,
    COUNT(*) AS invalid_count
FROM logs
WHERE 
    -- 1. Lỗi không đúng 4 octets (không đúng 3 dấu chấm)
    LEN(ip) - LEN(REPLACE(ip, '.', '')) <> 3
    
    -- 2. Lỗi ký tự không hợp lệ hoặc chứa leading zeros (ví dụ '01', '00')
    OR PARSENAME(ip, 4) LIKE '%[^0-9]%' OR (LEN(PARSENAME(ip, 4)) > 1 AND PARSENAME(ip, 4) LIKE '0%')
    OR PARSENAME(ip, 3) LIKE '%[^0-9]%' OR (LEN(PARSENAME(ip, 3)) > 1 AND PARSENAME(ip, 3) LIKE '0%')
    OR PARSENAME(ip, 2) LIKE '%[^0-9]%' OR (LEN(PARSENAME(ip, 2)) > 1 AND PARSENAME(ip, 2) LIKE '0%')
    OR PARSENAME(ip, 1) LIKE '%[^0-9]%' OR (LEN(PARSENAME(ip, 1)) > 1 AND PARSENAME(ip, 1) LIKE '0%')
    
    -- 3. Lỗi octet vượt quá 255
    OR CAST(PARSENAME(ip, 4) AS INT) > 255
    OR CAST(PARSENAME(ip, 3) AS INT) > 255
    OR CAST(PARSENAME(ip, 2) AS INT) > 255
    OR CAST(PARSENAME(ip, 1) AS INT) > 255
GROUP BY ip
ORDER BY 
    invalid_count DESC,
    ip DESC;
--Câu 9: Most Common Course Pairs
-- Viết một giải pháp để xác định lộ trình thành thạo kỹ năng bằng cách phân tích trình tự hoàn thành khóa học của những sinh viên xuất sắc: 
-- Chỉ xem xét những sinh viên xuất sắc (những sinh viên đã hoàn thành ít nhất 5 khóa học với điểm trung bình từ 4 trở lên). 
-- Đối với mỗi sinh viên xuất sắc, hãy xác định trình tự các khóa học mà họ đã hoàn thành theo thứ tự thời gian. 
-- Tìm tất cả các cặp khóa học liên tiếp (Khóa A → Khóa B) mà những sinh viên này đã học. 
-- Trả về tần suất của các cặp khóa học, xác định những chuyển đổi khóa học nào phổ biến nhất trong số những sinh viên đạt thành tích cao. 
-- Trả về bảng kết quả được sắp xếp theo tần suất của các cặp khóa học theo thứ tự giảm dần và sau đó theo tên khóa học đầu tiên và tên khóa học thứ hai theo thứ tự tăng dần.
WITH HighAchievers AS (
    SELECT user_id
    FROM course_completions
    GROUP BY user_id
    HAVING COUNT(DISTINCT course_id) >= 5 
       AND AVG(CAST(course_rating AS DECIMAL(3,2))) >= 4.0
),
CourseSequences AS (
    SELECT 
        c.course_name AS first_course,
        LEAD(c.course_name) OVER (
            PARTITION BY c.user_id 
            ORDER BY c.completion_date ASC, c.course_id ASC
        ) AS second_course
    FROM course_completions c
    INNER JOIN HighAchievers h ON c.user_id = h.user_id
)
SELECT 
    first_course,
    second_course,
    COUNT(*) AS transition_count
FROM CourseSequences
WHERE second_course IS NOT NULL
GROUP BY first_course, second_course
ORDER BY 
    transition_count DESC,
    first_course ASC,
    second_course ASC;
--Câu 10:
WITH RankedSessions AS (
    SELECT 
        student_id,
        subject,
        session_date,
        hours_studied,
        LAG(session_date) OVER (PARTITION BY student_id ORDER BY session_date) AS prev_date
    FROM study_sessions
),
IslandChain AS (
    SELECT 
        student_id,
        subject,
        session_date,
        hours_studied,
        SUM(CASE WHEN DATEDIFF(day, prev_date, session_date) > 2 THEN 1 ELSE 0 END) 
            OVER (PARTITION BY student_id ORDER BY session_date) AS chain_id
    FROM RankedSessions
),
SequenceData AS (
    SELECT 
        student_id,
        chain_id,
        subject,
        session_date,
        hours_studied,
        ROW_NUMBER() OVER (PARTITION BY student_id, chain_id ORDER BY session_date) AS pos
    FROM IslandChain
),
-- Tách riêng đếm số môn duy nhất (unique_in_cycle) bằng GROUP BY để tránh lỗi DISTINCT OVER
UniqueSubjectCount AS (
    SELECT 
        student_id, 
        chain_id, 
        COUNT(DISTINCT subject) AS total_unique_subjects,
        COUNT(*) AS total_sessions,
        SUM(hours_studied) AS total_hours
    FROM SequenceData
    GROUP BY student_id, chain_id
),
PossibleCycles AS (
    SELECT 
        s1.student_id,
        s1.chain_id,
        k_table.k AS cycle_length,
        u.total_unique_subjects,
        u.total_sessions,
        u.total_hours
    FROM SequenceData s1
    JOIN UniqueSubjectCount u 
      ON s1.student_id = u.student_id AND s1.chain_id = u.chain_id
    CROSS JOIN (VALUES (3), (4), (5), (6), (7), (8), (9), (10)) AS k_table(k)
    LEFT JOIN SequenceData s2 
        ON s1.student_id = s2.student_id 
       AND s1.chain_id = s2.chain_id 
       AND s1.pos = s2.pos + k_table.k
    WHERE k_table.k >= 3
      AND (s1.pos <= k_table.k OR s1.subject = s2.subject)
)
SELECT 
    p.student_id,
    st.student_name,
    p.cycle_length,
    p.total_study_hours
FROM (
    SELECT 
        student_id,
        cycle_length,
        MAX(total_hours) AS total_study_hours,
        ROW_NUMBER() OVER (
            PARTITION BY student_id 
            ORDER BY cycle_length DESC, MAX(total_hours) DESC
        ) AS rn
    FROM PossibleCycles
    GROUP BY student_id, chain_id, cycle_length, total_unique_subjects, total_sessions
    HAVING total_unique_subjects >= cycle_length
       AND total_sessions >= 2 * cycle_length
       AND total_sessions % cycle_length = 0
       AND COUNT(*) = total_sessions
) p
JOIN students st ON p.student_id = st.student_id
WHERE p.rn = 1
ORDER BY p.cycle_length DESC, p.total_study_hours DESC;
--Câu 11: Active User Retention
SELECT 
  EXTRACT(MONTH FROM curr_month.event_date) AS month,
  COUNT(DISTINCT curr_month.user_id) AS monthly_active_users
FROM user_actions AS curr_month
JOIN user_actions AS last_month
  ON curr_month.user_id = last_month.user_id
  AND EXTRACT(MONTH FROM last_month.event_date) = EXTRACT(MONTH FROM curr_month.event_date) - 1
  AND EXTRACT(YEAR FROM last_month.event_date) = EXTRACT(YEAR FROM curr_month.event_date)
WHERE EXTRACT(MONTH FROM curr_month.event_date) = 7
  AND EXTRACT(YEAR FROM curr_month.event_date) = 2022 
GROUP BY EXTRACT(MONTH FROM curr_month.event_date)
--Câu 12 :Y-on-Y Growth Rate
--C1: dùng self join
WITH yearly_summary AS (
  
  SELECT 
    product_id,
    EXTRACT(YEAR FROM transaction_date) AS txn_year,
    SUM(spend) AS total_spend
  FROM user_transactions
  GROUP BY product_id, EXTRACT(YEAR FROM transaction_date)
),

 cte as (SELECT curr_year.product_id,curr_year.txn_year AS current_year,
    curr_year.total_spend AS curr_spend,
    prev_year.total_spend AS prev_spend
  FROM yearly_summary curr_year
  LEFT JOIN yearly_summary prev_year 
    ON curr_year.product_id = prev_year.product_id
   AND curr_year.txn_year - 1 = prev_year.txn_year
   )
SELECT 
  current_year,
  product_id,
  curr_spend,
  prev_spend AS prev_year_spend,
  ROUND((curr_spend - prev_spend) * 100.0 / prev_spend, 2) AS yoy_rate
FROM cte
ORDER BY product_id, current_year
--C2: dùng LAG window function
WITH yearly_spend AS (
  SELECT 
    EXTRACT(YEAR FROM transaction_date) AS year,
    product_id,
    SUM(spend) AS curr_year_spend
  FROM user_transactions
  GROUP BY 
    EXTRACT(YEAR FROM transaction_date),
    product_id
)

SELECT 
  year,
  product_id,
  curr_year_spend,
  LAG(curr_year_spend) OVER (
    PARTITION BY product_id 
    ORDER BY year
  ) AS prev_year_spend,
  ROUND(
    (curr_year_spend - LAG(curr_year_spend) OVER (PARTITION BY product_id ORDER BY year)) 
    * 100.0 
    / LAG(curr_year_spend) OVER (PARTITION BY product_id ORDER BY year)
  , 2) AS yoy_rate
FROM yearly_spend;
--Câu 13: Maximize Prime Item Inventory
WITH summary AS (
    -- Bước 1: Tính kích thước và số lượng mặt hàng của 1 combo batch theo từng loại
    SELECT 
        item_type,
        SUM(square_footage) AS total_sqft,
        COUNT(*) AS item_count
    FROM inventory
    GROUP BY item_type
),
prime_calc AS (
    -- Bước 2: Tính số lô Prime tối đa và diện tích Prime chiếm dụng
    SELECT 
        item_type,
        total_sqft,
        item_count,
        FLOOR(500000 / total_sqft) AS prime_batches,
        FLOOR(500000 / total_sqft) * item_count AS prime_item_count,
        FLOOR(500000 / total_sqft) * total_sqft AS prime_occupied_sqft
    FROM summary
    WHERE item_type = 'prime_eligible'
)
-- Bước 3: Ghép kết quả đầu ra cho cả 2 nhóm prime_eligible và not_prime
SELECT 
    'prime_eligible' AS item_type,
    prime_item_count AS item_count
FROM prime_calc

UNION ALL

SELECT 
    'not_prime' AS item_type,
    FLOOR((500000 - (SELECT prime_occupied_sqft FROM prime_calc)) / total_sqft) * item_count AS item_count
FROM summary
WHERE item_type = 'not_prime';
--Câu 14: Median Google Search Frequency
WITH summary AS (
  SELECT 
    searches,
    num_users,
    -- Tổng dồn từ thấp đến cao
    SUM(num_users) OVER (ORDER BY searches ASC) AS cum_asc,
    -- Tổng dồn từ cao đến thấp
    SUM(num_users) OVER (ORDER BY searches DESC) AS cum_desc,
    -- Tổng tất cả người dùng
    SUM(num_users) OVER () AS total_users
  FROM search_frequency
)
SELECT 
  ROUND(AVG(searches)::numeric, 1) AS median
FROM summary
WHERE cum_asc >= total_users / 2.0
  AND cum_desc >= total_users / 2.0
--Câu 14: Advertiser Status
SELECT COALESCE(a.user_id,d.user_id) as user_id
,
CASE WHEN d.paid is null then 'CHURN' 
WHEN d.paid IS NOT NULL AND a.status IN ('NEW','EXISTING','RESURRECT') THEN 'EXISTING'
    WHEN d.paid IS NOT NULL AND a.status = 'CHURN' THEN 'RESURRECT'
    WHEN d.paid IS NOT NULL AND a.status IS NULL THEN 'NEW' end as new_status FROM advertiser as a full outer join daily_pay d 
on a.user_id = d.user_id
order by user_id
--Câu 15: 3-Topping Pizzas
SELECT 
  CONCAT(p1.topping_name, ',', p2.topping_name, ',', p3.topping_name) AS pizza,
  p1.ingredient_cost + p2.ingredient_cost + p3.ingredient_cost AS total_cost
FROM pizza_toppings AS p1
INNER JOIN pizza_toppings AS p2
  ON p1.topping_name < p2.topping_name 
INNER JOIN pizza_toppings AS p3
  ON p2.topping_name < p3.topping_name 
ORDER BY total_cost DESC, pizza;
--Câu 16: Consecutive Filing Years
-- dùng island and gap
with island_taxes as (SELECT * ,
EXTRACT(YEAR from filing_date) - (ROW_NUMBER() over(partition by user_id order by  EXTRACT(YEAR FROM filing_date)))::int as group_year
FROM filed_taxes
WHERE product LIKE N'%TurboTax%' )
,gap_taxes as (
SELECT user_id ,
COUNT(*) as consecutive_year
from island_taxes 
group by user_id, group_year
)
select distinct user_id 
from gap_taxes
where consecutive_year >=3
order by user_id
--Câu 17: Marketing Touch Streak
WITH week_events AS (
  SELECT 
    event_id,
    contact_id,
    event_type,
    DATE_TRUNC('week', event_date) AS current_week,
    LAG(DATE_TRUNC('week', event_date)) OVER (
      PARTITION BY contact_id 
      ORDER BY DATE_TRUNC('week', event_date)
    ) AS lag_week,
    LEAD(DATE_TRUNC('week', event_date)) OVER (
      PARTITION BY contact_id 
      ORDER BY DATE_TRUNC('week', event_date)
    ) AS lead_week
  FROM marketing_touches
),
valid_contacts AS (
  SELECT DISTINCT contact_id
  FROM week_events
  WHERE 
    
    (lag_week = current_week - INTERVAL '1 week' 
     AND lead_week = current_week + INTERVAL '1 week')
)
SELECT DISTINCT c.email
FROM valid_contacts v
JOIN marketing_touches m ON v.contact_id = m.contact_id
JOIN crm_contacts c ON v.contact_id = c.contact_id
WHERE m.event_type = 'trial_request'
--Câu 18: Patient Support Analysis (Part 3)
WITH NextCallInfo AS (
  SELECT 
    policy_holder_id,
    call_date,
    LEAD(call_date) OVER (
      PARTITION BY policy_holder_id 
      ORDER BY call_date
    ) AS next_call_date
  FROM callers
)

SELECT 
  COUNT(DISTINCT policy_holder_id) AS policy_holder_count
FROM NextCallInfo
WHERE next_call_date IS NOT NULL
  AND next_call_date - call_date <= INTERVAL '7 days'
-- Câu 19: Patient Support Analysis (Part 4)
with cte as (SELECT COUNT(case_id) as curr_mth_calls,
EXTRACT(YEAR from call_date) as yr,
EXTRACT(MONTH from call_date) as mth,
LAG(COUNT(case_id)) over(order by EXTRACT(YEAR from call_date),  EXTRACT(MONTH from call_date)) as prev_mth_calls
FROM callers
where call_duration_secs > 300
GROUP BY
EXTRACT(YEAR from call_date),
EXTRACT(MONTH from call_date))
select yr,
mth,
ROUND((curr_mth_calls-prev_mth_calls)*100.0/prev_mth_calls,1) as long_calls_growth_pct
from cte
order by yr, mth
--Câu 20: Repeated Payments
with cte as (
SELECT
     transaction_id , merchant_id, credit_card_id, amount, transaction_timestamp,
LAG(transaction_timestamp) over(partition by  merchant_id, credit_card_id, amount 
ORDER BY transaction_timestamp ) as prev_transaction_time
FROM transactions)
select COUNT(*) as payment_count 
from cte 
where prev_transaction_time is not null 
and  EXTRACT(EPOCH FROM (transaction_timestamp - prev_transaction_time)) / 60 <=10
-- Câu 21: Reactivated Users
--C1:
SELECT 
    EXTRACT(MONTH FROM curr_month.login_date) AS mth,
    COUNT(DISTINCT curr_month.user_id) AS reactivated_users
FROM user_logins AS curr_month
WHERE NOT EXISTS (
    SELECT 1 
    FROM user_logins AS last_month
    WHERE last_month.user_id = curr_month.user_id
      AND EXTRACT(MONTH FROM last_month.login_date) = EXTRACT(MONTH FROM curr_month.login_date - INTERVAL '1 month')
      AND EXTRACT(YEAR FROM last_month.login_date) = EXTRACT(YEAR FROM curr_month.login_date - INTERVAL '1 month')
)
GROUP BY EXTRACT(MONTH FROM curr_month.login_date)
ORDER BY mth;
--C2: dùng LAG()
WITH user_active_months AS (
    -- Bước 1: Lấy các tháng duy nhất mà user có hoạt động
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('month', login_date) AS active_month
    FROM user_logins
),
user_gaps AS (
    -- Bước 2: Lấy tháng hoạt động liền trước của user đó
    SELECT 
        user_id,
        active_month,
        LAG(active_month) OVER (
            PARTITION BY user_id 
            ORDER BY active_month
        ) AS prev_active_month
    FROM user_active_months
)
-- Bước 3: Lọc những trường hợp khoảng cách > 1 tháng (hoặc không có tháng trước đó)
SELECT 
    EXTRACT(MONTH FROM active_month) AS mth,
    COUNT(DISTINCT user_id) AS reactivated_users
FROM user_gaps
WHERE prev_active_month IS NULL 
   OR active_month > prev_active_month + INTERVAL '1 month'
GROUP BY active_month
ORDER BY mth;
--Câu 22 : Senior Managers
SELECT 
  managers.manager_name,
  COUNT(DISTINCT managers.emp_id) AS direct_reportees
FROM employees
JOIN employees AS managers
  ON employees.manager_id = managers.emp_id
JOIN employees AS senior_managers
  ON managers.manager_id = senior_managers.emp_id
GROUP BY managers.manager_name
ORDER BY direct_reportees DESC;