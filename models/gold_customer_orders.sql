{{ config(
  materialized = 'incremental',
  file_format  = 'delta',
  schema       = 'gold'
) }}


with 

customers as (

  select * from {{ ref('silver_customers') }}

),

paid_orders as (

  select * from {{ ref('silver_paid_orders') }}

),

customer_orders as (

  select
    paid_orders.order_id,
    paid_orders.customer_id,
    paid_orders.order_placed_at,
    paid_orders.order_status,
    paid_orders.total_amount_paid,
    paid_orders.payment_finalized_date,
    customers.customer_first_name,
    customers.customer_last_name,

    -- sales transaction sequence
    row_number() over (order by paid_orders.order_id) as transaction_seq,

    -- customer sales sequence
    row_number() over (partition by paid_orders.customer_id order by paid_orders.order_id) as customer_sales_seq,

    -- new vs returning customer
    case 
      when (
      rank() over (
        partition by paid_orders.customer_id
        order by paid_orders.order_placed_at, paid_orders.order_id
        ) = 1
      ) then 'new'
    else 'returning' end as customer_status,

    -- customer lifetime value
    sum(paid_orders.total_amount_paid) over (
      partition by paid_orders.customer_id
      order by paid_orders.order_placed_at
      ) as customer_lifetime_value,

    -- first day of sale
    first_value(order_placed_at) over (
      partition by paid_orders.customer_id
      order by paid_orders.order_placed_at
      ) as date_of_first_order
    from paid_orders
    left join customers on paid_orders.customer_id = customers.customer_id
)

select * from customer_orders