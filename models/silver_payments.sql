with 

-- import CTE
payment_source as (

    select * from {{ source('bronze', 'payments') }}
),

-- transformation CTE
payments as (

    select
      
      id as payment_id,
      orderid as order_id,
      status as payment_status,
      round(amount/100.00, 2) as payment_amount
    
    from payment_source
) 

-- final
select * from payments 