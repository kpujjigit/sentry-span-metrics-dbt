{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='date'
) }}

with daily_user_activity as (
    select
        event_date as date,
        count(distinct er.user_id) as active_users,
        count(distinct case when u.is_premium_user then er.user_id end) as premium_active_users,
        count(distinct case when not u.is_premium_user then er.user_id end) as basic_active_users,
        sum(daily_total_events) as total_events,
        sum(daily_page_views) as total_page_views,
        sum(daily_button_clicks) as total_button_clicks,
        sum(daily_form_submits) as total_form_submits,
        sum(daily_sessions) as total_sessions,
        avg(daily_avg_event_duration) as avg_session_duration,
        count(distinct country) as countries_represented
    from {{ ref('int_event_rollups') }} er
    join {{ ref('stg_users') }} u
        on er.user_id = u.user_id
    {% if is_incremental() %}
        where er.event_date > (select max(date) from {{ this }})
    {% endif %}
    group by event_date
),

daily_span_metrics as (
    select
        span_date as date,
        count(*) as total_spans,
        count(distinct trace_id) as total_traces,
        sum(duration_ms) as total_span_duration_ms,
        avg(duration_ms) as avg_span_duration_ms,
        sum(case when is_success = 1 then 1 else 0 end) as successful_spans,
        sum(case when is_web_request = 1 then 1 else 0 end) as web_requests,
        sum(case when is_database_call = 1 then 1 else 0 end) as database_calls,
        sum(case when is_cache_operation = 1 then 1 else 0 end) as cache_operations,
        count(distinct user_id) as users_with_spans
    from {{ ref('stg_spans') }}
    {% if is_incremental() %}
        where span_date > (select max(date) from {{ this }})
    {% endif %}
    group by span_date
)

select
    coalesce(dua.date, dsm.date) as date,
    dua.active_users,
    dua.premium_active_users,
    dua.basic_active_users,
    dua.total_events,
    dua.total_page_views,
    dua.total_button_clicks,
    dua.total_form_submits,
    dua.total_sessions,
    dua.avg_session_duration,
    dua.countries_represented,
    dsm.total_spans,
    dsm.total_traces,
    dsm.total_span_duration_ms,
    dsm.avg_span_duration_ms,
    dsm.successful_spans,
    dsm.web_requests,
    dsm.database_calls,
    dsm.cache_operations,
    dsm.users_with_spans,
    -- Calculated metrics
    case
        when dsm.total_spans > 0 then dsm.successful_spans::float / dsm.total_spans
        else null
    end as span_success_rate,
    case
        when dua.total_sessions > 0 then dua.total_events::float / dua.total_sessions
        else null
    end as avg_events_per_session
from daily_user_activity dua
full outer join daily_span_metrics dsm
    on dua.date = dsm.date
order by date
