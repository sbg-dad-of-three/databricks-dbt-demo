{{ config(
  materialized = 'table',
  file_format  = 'delta',
  schema       = 'silver'
) }}


with 

orders as (

  select * from {{ ref('silver_orders') }}

),

payments as (

  select * from {{ ref('silver_payments') }}

),

completed_payments as (

  select 
    order_id,
    max(payment_created_at) as payment_finalized_date,
    sum(payment_amount) as total_amount_paid
  from payments
  where payment_status <> 'fail'
  group by 1

),

paid_orders as (

  select 
    orders.order_id,
    orders.customer_id,
    orders.order_placed_at,
    orders.order_status,
    completed_payments.total_amount_paid,
    completed_payments.payment_finalized_date
  from orders
 left join completed_payments on orders.order_id = completed_payments.order_id
)

select * from paid_orders