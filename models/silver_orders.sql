{{ config(
  materialized = 'table',
  file_format  = 'delta',
  schema       = 'silver'
) }}


with

order_source as (
    
    select * from {{ source('bronze', 'orders') }}
    
),

orders as (
        
      select 
      
        id as order_id,
        user_id as customer_id,
        status as order_status,
        order_date as order_placed_at,
        
        case 
            when status not in ('returned','return_pending') 
            then order_date 
        end as valid_order_date,
        
        row_number() over (
            partition by user_id 
            order by order_date, id
        ) as user_order_seq
        
      from order_source
    
)

select * from orders