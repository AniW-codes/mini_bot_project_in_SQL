# SQL Mentor User Performance Analysis

## Project Overview

This project is designed to help beginners understand SQL querying and performance analysis using real-time data from SQL Mentor datasets. In this project, we will analyze user performance by creating and querying a table of user submissions. The goal is to solve a series of SQL problems to extract meaningful insights from user data.

## Objectives

- Learn how to use SQL for data analysis tasks such as aggregation, filtering, and ranking.
- Understand how to calculate and manipulate data in a real-world dataset.
- Gain hands-on experience with SQL functions like `COUNT`, `SUM`, `AVG`, `EXTRACT()`, and `DENSE_RANK()`.
- Develop skills for performance analysis using SQL by solving different types of data problems related to user performance.

## Project Level: Beginner

We'll be working with a small dataset and writing SQL queries to solve different tasks that are commonly encountered in data analysis.

## SQL Mentor User Performance Dataset

The dataset consists of information about user submissions for an online learning platform. Each submission includes:
- **User ID**
- **Question ID**
- **Points Earned**
- **Submission Timestamp**
- **Username**

This data allows us to analyze user performance in terms of correct and incorrect submissions, total points earned, and daily/weekly activity.

## SQL Problems and Questions

Here are the SQL problems that we will solve as part of this project:

### Q1. List All Distinct Users and Their Stats
- **Description**: Return the user name, total submissions, and total points earned by each user.
- **Expected Output**: A list of users with their submission count and total points.

### Q2. Calculate the Daily Average Points for Each User
- **Description**: For each day, calculate the average points earned by each user.
- **Expected Output**: A report showing the average points per user for each day.

### Q3. Find the Top 3 Users with the Most Correct Submissions for Each Day
- **Description**: Identify the top 3 users with the most correct submissions for each day.
- **Expected Output**: A list of users and their correct submissions, ranked daily.

### Q4. Find the Top 5 Users with the Highest Number of Incorrect Submissions
- **Description**: Identify the top 5 users with the highest number of incorrect submissions.
- **Expected Output**: A list of users with the count of incorrect submissions, points lost due to incorrect submissions, points gained for correct submissions and total correct submissions.

### Q5. Find the Top 10 Performers for Each Week
- **Description**: Identify the top 10 users with the highest total points earned each week.
- **Expected Output**: A report showing the top 10 users ranked by total points per week.

## Key SQL Concepts Covered

- **Aggregation**: Using `COUNT`, `SUM`, `AVG` to aggregate data.
- **Date Functions**: Using `EXTRACT()` and `TO_CHAR()` for manipulating dates.
- **Conditional Aggregation**: Using `CASE WHEN` to handle positive and negative submissions.
- **Ranking**: Using `DENSE_RANK()` to rank users based on their performance.
- **Group By**: Aggregating results by groups (e.g., by user, by day, by week).


## Schema

```sql

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;


```

## SQL Queries Solutions

Below are the solutions for each question in this project:

### Q1: List All Distinct Users and Their Stats
```sql

select username,
		Count(*) as total_submissions,
		SUM(points) as points_earned
from user_submissions
group by 1
order by 3 desc;

```

### Q2: Calculate the Daily Average Points for Each User
```sql

select 
		TO_CHAR(submitted_at, 'DD-MM') as date,
		username,
		avg(points) as daily_avg_points
from user_submissions
group by 1,2
order by 2;


```

### Q3: Find the Top 3 Users with the Most Correct Submissions for Each Day
```sql

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
CTE_Rank         --CTE 2
as
		(select date,
				username,
				correct_responses_per_day,
				DENSE_RANK() OVER(Partition by date order by correct_responses_per_day desc) as RNK
		from CTE_daily)

Select * from CTE_Rank
where RNK <=3;

```

### Q4: Find the Top 5 Users with the Highest Number of Incorrect Submissions. Return should also include points lost due to incorrect submissions, points gained for correct submissions and total correct submissions.

```sql
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


```

### Q5: Find the Top 10 Performers for Each Week

```sql

With CTE_Weekly		 --CTE 1
as
		(select
				EXTRACT(WEEK from submitted_at) as week_no,
				username,
				SUM(points) as total_points
		from user_submissions
		group by 1,2)
,
CTE_Rank 			--CTE 2
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

```

## Conclusion

By working through these SQL queries, we gain hands-on experience with data aggregation, ranking, date manipulation, and conditional logic.

**AUTHOR**: Aniruddha Warang
