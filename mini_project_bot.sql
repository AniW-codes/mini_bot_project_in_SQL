-- SQL Mini Project 10/10
-- SQL Mentor User Performance

-- DROP TABLE user_submissions; 

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;


-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

select username,
		Count(*) as total_submissions,
		SUM(points) as points_earned
from user_submissions
group by 1
order by 3 desc;


-- Q.2 Calculate the daily average points for each user.

select 
		TO_CHAR(submitted_at, 'DD-MM') as date,
		username,
		avg(points) as daily_avg_points
from user_submissions
group by 1,2
order by 2;


-- Q.3 Find the top 3 users with the most correct submissions for each day.

With CTE_daily  --CTE 1
as
		(select 
			TO_CHAR(submitted_at, 'DD-MM') as date,
			username,
			SUM(CASE
				When points > 0 then 1
				else 0
			END) as correct_responses_per_day
		from user_submissions
		group by 1,2)
,
CTE_Rank --CTE 2
as
		(select date,
				username,
				correct_responses_per_day,
				DENSE_RANK() OVER(Partition by date order by correct_responses_per_day desc) as RNK
		from CTE_daily)

Select * from CTE_Rank
where RNK <=3;



-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
--Return should also include points lost due to incorrect submissions, points gained for correct submissions and total correct submissions.


select 
			username,
			SUM(CASE
				When points < 0 then 1
				else 0
			END) as incorrect_responses_per_day,
			SUM(CASE
				When points < 0 then points
				else 0
			END) as points_lost_to_incorrect_responses,
			SUM(CASE
				When points > 0 then 1
				else 0
			END) as correct_responses_per_day,
			SUM(CASE
				When points > 0 then points
				else 0
			END) as points_won_to_correct_responses_per_day,
			sum(points) as total_points
from user_submissions
group by 1
order by 2 desc
LIMIT 5;




-- Q.5 Find the top 10 performers for each week.

With CTE_Weekly
as
		(select
				EXTRACT(WEEK from submitted_at) as week_no,
				username,
				SUM(points) as total_points
		from user_submissions
		group by 1,2)
,
CTE_Rank
as
		(select 
				username,
				week_no,
				total_points,
				DENSE_RANK() OVER(Partition by week_no order by total_points desc) as RNK
		from CTE_Weekly
		group by 1,2,3)

Select * 
from CTE_Rank
where RNK <=10