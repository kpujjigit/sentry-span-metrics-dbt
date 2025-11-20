{{ config(materialized='view') }}

with user_events as (
    select
        u.user_id,
        u.name,
        u.email,
        u.signup_date,
        u.country,
        u.subscription_tier,
        u.is_premium_user,
        u.signup_month,
        count(e.event_id) as total_events,
        count(distinct e.event_date) as active_days,
        count(distinct e.session_id) as total_sessions,
        min(e.event_date) as first_event_date,
        max(e.event_date) as last_event_date,
        sum(e.duration_ms) as total_duration_ms,
        avg(e.duration_ms) as avg_session_duration_ms,
        sum(case when e.event_type = 'page_view' then 1 else 0 end) as page_views,
        sum(case when e.event_type = 'button_click' then 1 else 0 end) as button_clicks,
        sum(case when e.event_type = 'form_submit' then 1 else 0 end) as form_submits
    from {{ ref('stg_users') }} u
    left join {{ ref('stg_events') }} e
        on u.user_id = e.user_id
    group by
        u.user_id, u.name, u.email, u.signup_date, u.country,
        u.subscription_tier, u.is_premium_user, u.signup_month
),

user_spans as (
    select
        user_id,
        count(span_id) as total_spans,
        count(distinct trace_id) as total_traces,
        sum(duration_ms) as total_span_duration_ms,
        avg(duration_ms) as avg_span_duration_ms,
        sum(case when is_success = 1 then 1 else 0 end) as successful_spans,
        sum(case when is_success = 0 then 1 else 0 end) as failed_spans,
        sum(case when is_web_request = 1 then 1 else 0 end) as web_requests,
        sum(case when is_database_call = 1 then 1 else 0 end) as database_calls,
        sum(case when is_cache_operation = 1 then 1 else 0 end) as cache_operations
    from {{ ref('stg_spans') }}
    where user_id is not null
    group by user_id
)

select
    ue.*,
    us.total_spans,
    us.total_traces,
    us.total_span_duration_ms,
    us.avg_span_duration_ms,
    us.successful_spans,
    us.failed_spans,
    us.web_requests,
    us.database_calls,
    us.cache_operations,
    -- Derived engagement metrics
    case
        when ue.active_days >= 7 then 'high'
        when ue.active_days >= 3 then 'medium'
        else 'low'
    end as engagement_level,
    datediff('day', ue.signup_date, ue.last_event_date) as days_since_signup,
    case
        when ue.total_events > 0 then ue.total_events / nullif(datediff('day', ue.signup_date, ue.last_event_date) + 1, 0)
        else 0
    end as avg_daily_events,
    case
        when us.total_spans > 0 then us.successful_spans::float / us.total_spans
        else null
    end as span_success_rate
from user_events ue
left join user_spans us
    on ue.user_id = us.user_id
