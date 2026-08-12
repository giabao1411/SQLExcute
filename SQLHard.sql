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
