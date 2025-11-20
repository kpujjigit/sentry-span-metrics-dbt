{{ config(materialized='view') }}

with event_metrics as (
    select
        event_date,
        user_id,
        event_type,
        count(*) as event_count,
        sum(duration_ms) as total_duration_ms,
        avg(duration_ms) as avg_duration_ms,
        min(duration_ms) as min_duration_ms,
        max(duration_ms) as max_duration_ms,
        count(distinct session_id) as unique_sessions
    from {{ ref('stg_events') }}
    group by event_date, user_id, event_type
),

daily_user_metrics as (
    select
        event_date,
        user_id,
        count(*) as total_events,
        sum(case when event_type = 'page_view' then 1 else 0 end) as page_views,
        sum(case when event_type = 'button_click' then 1 else 0 end) as button_clicks,
        sum(case when event_type = 'form_submit' then 1 else 0 end) as form_submits,
        count(distinct session_id) as sessions_count,
        sum(duration_ms) as total_session_duration_ms,
        avg(duration_ms) as avg_event_duration_ms
    from {{ ref('stg_events') }}
    group by event_date, user_id
)

select
    em.event_date,
    em.user_id,
    em.event_type,
    em.event_count,
    em.total_duration_ms,
    em.avg_duration_ms,
    em.min_duration_ms,
    em.max_duration_ms,
    em.unique_sessions,
    dum.total_events as daily_total_events,
    dum.page_views as daily_page_views,
    dum.button_clicks as daily_button_clicks,
    dum.form_submits as daily_form_submits,
    dum.sessions_count as daily_sessions,
    dum.total_session_duration_ms as daily_total_duration,
    dum.avg_event_duration_ms as daily_avg_event_duration
from event_metrics em
left join daily_user_metrics dum
    on em.event_date = dum.event_date
    and em.user_id = dum.user_id
