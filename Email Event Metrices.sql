/* Weekly User Engagement */
select week(occurred_at) as week_number,count(users_eng) as no_of_users
from 
(select distinct user_id as users_eng,occurred_at
from events
where event_type="engagement") a
group by week(occurred_at)
order by 1;


/* Distinct Users added per week */
select week(occurred_at) as week,
count(distinct user_id) as distinct_users_added
from email_events
group by week(occurred_at)
order by week(occurred_at)

/* Users Engagement with Emails */
select week, round((clickthrough_events/emails_sent)*100,2) as click_through_rate_in_perc,
round((email_open_events/emails_sent)*100,2) as email_open_rate_in_perc
from
(SELECT
  week(occurred_at) AS week,
  SUM(CASE WHEN action = 'email_open' THEN 1 ELSE 0 END) AS email_open_events,
  SUM(CASE WHEN action = 'email_clickthrough' THEN 1 ELSE 0 END) AS clickthrough_events,
  SUM(CASE WHEN action = 'sent_reengagement_email' OR action = 'sent_weekly_digest' THEN 1 ELSE 0 END) AS emails_sent
FROM
  email_events
GROUP BY
  week(occurred_at)
ORDER BY
	week(occurred_at)) a
    
/* No. of Users interacting with email over the weeks */
select week(occurred_at) as wk,count(user_id) as "No. of Users"
from (
select * from email_events
where action = "email_clickthrough"
having user_id in (
select distinct user_id from email_events
where action="email_open"
having user_id in (
select distinct user_id
from email_events
where action="sent_weekly_digest" or action="sent_reengagement_email")
)
) a
group by wk
order by week(occurred_at)

/* Percentage user email engagement */
select round(avg((email_open_events/emails_sent)*100),2) as step_1,
round(avg((clickthrough_events/email_open_events)*100),2) as step_2,
round(avg((clickthrough_events/emails_sent)*100),2) as direct
from
(
SELECT user_id,
  SUM(CASE WHEN action = 'sent_reengagement_email' OR action = 'sent_weekly_digest' THEN 1 ELSE 0 END) AS emails_sent,
  SUM(CASE WHEN action = 'email_open' THEN 1 ELSE 0 END) AS email_open_events,
  SUM(CASE WHEN action = 'email_clickthrough' THEN 1 ELSE 0 END) AS clickthrough_events
  
FROM
  email_events
group by user_id) a

/* weekly user engagement per device */
select device,wk,activity,rk
from
(
select device,week(occurred_at) as wk,count(event_name) as activity,
rank() over(partition by week(occurred_at) order by week(occurred_at), count(event_name) desc) as rk
from events
group by device,week(occurred_at)
) a
where rk<=3