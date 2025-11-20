{{ config(materialized='view') }}

with source as (
    select * from {{ ref('events') }}
),

cleaned as (
    select
        event_id,
        user_id,
        event_type,
        event_name,
        cast(timestamp as timestamp) as event_timestamp,
        page_url,
        session_id,
        duration_ms,
        -- Add derived columns
        cast(event_timestamp as date) as event_date,
        extract(hour from cast(event_timestamp as timestamp)) as event_hour,
        case
            when event_type = 'page_view' then 1
            else 0
        end as is_page_view,
        case
            when event_type = 'button_click' then 1
            else 0
        end as is_button_click,
        case
            when event_type = 'form_submit' then 1
            else 0
        end as is_form_submit
    from source
    where event_id is not null
      and user_id is not null
)

select * from cleaned
