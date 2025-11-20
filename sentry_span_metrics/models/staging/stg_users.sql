{{ config(materialized='view') }}

with source as (
    select * from {{ ref('users') }}
),

cleaned as (
    select
        user_id,
        name,
        lower(email) as email,
        cast(signup_date as date) as signup_date,
        upper(country) as country,
        subscription_tier,
        -- Add derived columns
        case
            when subscription_tier = 'premium' then true
            else false
        end as is_premium_user,
        date_trunc('month', cast(signup_date as date)) as signup_month
    from source
    where user_id is not null
)

select * from cleaned
