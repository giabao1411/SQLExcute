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