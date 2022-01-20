{{ config(
  materialized = 'table',
  file_format  = 'delta',
  schema       = 'silver'
) }}


with

customer_source as (

    select * from {{ source('bronze', 'customers') }}

),

customers as (

    select 

        id as customer_id,
        last_name as customer_last_name,
        first_name as customer_first_name,
        first_name || ' ' || last_name as customer_full_name

    from customer_source

)

select * from customers