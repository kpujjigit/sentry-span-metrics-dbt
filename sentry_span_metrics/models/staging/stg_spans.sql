{{ config(materialized='view') }}

with source as (
    select * from {{ ref('spans') }}
),

cleaned as (
    select
        span_id,
        trace_id,
        parent_span_id,
        operation_name,
        cast(start_timestamp as timestamp) as start_timestamp,
        cast(end_timestamp as timestamp) as end_timestamp,
        duration_ms,
        status,
        service_name,
        user_id,
        tags,
        -- Add derived columns
        cast(start_timestamp as date) as span_date,
        extract(hour from cast(start_timestamp as timestamp)) as span_hour,
        case
            when status = 'ok' then 1
            else 0
        end as is_success,
        case
            when parent_span_id is null then 1
            else 0
        end as is_root_span,
        case
            when service_name = 'web_server' then 1
            else 0
        end as is_web_request,
        case
            when service_name = 'database' then 1
            else 0
        end as is_database_call,
        case
            when service_name = 'cache' then 1
            else 0
        end as is_cache_operation
    from source
    where span_id is not null
      and trace_id is not null
)

select * from cleaned
