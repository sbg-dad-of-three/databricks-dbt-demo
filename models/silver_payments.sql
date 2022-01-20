{{ config(
  materialized = 'table',
  file_format  = 'delta',
  schema       = 'silver'
) }}


with 

payment_source as (

    select * from {{ source('bronze', 'payments') }}
),

payments as (

    select
      
      id as payment_id,
      orderid as order_id,
      created as payment_created_at,
      status as payment_status,
      round(amount/100.00, 2) as payment_amount
    
    from payment_source
) 

select * from payments 