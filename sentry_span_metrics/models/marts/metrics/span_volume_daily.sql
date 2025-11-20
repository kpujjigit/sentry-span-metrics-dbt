{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='date'
) }}

with span_performance as (
    select
        span_date as date,
        service_name,
        operation_name,
        count(*) as span_count,
        sum(duration_ms) as total_duration_ms,
        avg(duration_ms) as avg_duration_ms,
        min(duration_ms) as min_duration_ms,
        max(duration_ms) as max_duration_ms,
        percentile_cont(0.95) within group (order by duration_ms) as p95_duration_ms,
        percentile_cont(0.99) within group (order by duration_ms) as p99_duration_ms,
        sum(case when status = 'ok' then 1 else 0 end) as successful_spans,
        sum(case when status = 'error' then 1 else 0 end) as failed_spans,
        count(distinct trace_id) as unique_traces,
        count(distinct user_id) as unique_users_affected
    from {{ ref('stg_spans') }}
    {% if is_incremental() %}
        where span_date > (select max(date) from {{ this }})
    {% endif %}
    group by span_date, service_name, operation_name
),

service_daily_summary as (
    select
        date,
        service_name,
        sum(span_count) as total_spans,
        sum(total_duration_ms) as total_duration_ms,
        avg(avg_duration_ms) as avg_span_duration,
        min(min_duration_ms) as min_span_duration,
        max(max_duration_ms) as max_span_duration,
        avg(p95_duration_ms) as avg_p95_duration,
        avg(p99_duration_ms) as avg_p99_duration,
        sum(successful_spans) as total_successful_spans,
        sum(failed_spans) as total_failed_spans,
        sum(unique_traces) as total_unique_traces,
        sum(unique_users_affected) as total_unique_users,
        count(distinct operation_name) as unique_operations,
        case
            when sum(span_count) > 0 then sum(failed_spans)::float / sum(span_count)
            else 0
        end as error_rate
    from span_performance
    group by date, service_name
)

select
    date,
    service_name,
    total_spans,
    total_duration_ms,
    avg_span_duration,
    min_span_duration,
    max_span_duration,
    avg_p95_duration,
    avg_p99_duration,
    total_successful_spans,
    total_failed_spans,
    total_unique_traces,
    total_unique_users,
    unique_operations,
    error_rate,
    -- Performance classification
    case
        when avg_span_duration < 100 then 'fast'
        when avg_span_duration < 1000 then 'normal'
        when avg_span_duration < 5000 then 'slow'
        else 'very_slow'
    end as performance_category,
    case
        when error_rate < 0.01 then 'excellent'
        when error_rate < 0.05 then 'good'
        when error_rate < 0.10 then 'concerning'
        else 'critical'
    end as reliability_category
from service_daily_summary
order by date, service_name
