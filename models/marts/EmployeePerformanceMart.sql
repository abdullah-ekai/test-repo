{{ config(
    materialized='table',
    unique_key='employeeid',
    description='Data mart for tracking employee performance metrics including average ratings, total compensation, turnover rates, and job changes.'
) }}

with employees as (
    select *
    from {{ ref('employees') }}
),
compensations as (
    select *
    from {{ ref('compensations') }}
),
performance_reviews as (
    select *
    from {{ ref('performance_reviews') }}
),
job_histories as (
    select *
    from {{ ref('job_histories') }}
),
time_off_requests as (
    select *
    from {{ ref('time_off_requests') }}
)

select
    e.employeeid,
    e.firstname,
    e.lastname,
    e.departmentid,
    e.jobid,
    AVG(pr.overallrating) AS average_performance_rating,
    SUM(c.basesalary) AS total_compensation,
    COUNT(CASE WHEN e.employmentstatus = 'terminated' THEN 1 END) / COUNT(e.employeeid) AS employee_turnover_rate,
    COUNT(jh.jobhistoryid) / COUNT(e.employeeid) AS job_changes_per_employee
from
    employees e
left join compensations c on e.employeeid = c.employeeid
left join performance_reviews pr on e.employeeid = pr.employeeid
left join job_histories jh on e.employeeid = jh.employeeid
left join time_off_requests tor on e.employeeid = tor.employeeid
group by
    e.employeeid,
    e.firstname,
    e.lastname,
    e.departmentid,
    e.jobid