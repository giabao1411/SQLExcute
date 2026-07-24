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
