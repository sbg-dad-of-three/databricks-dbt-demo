{{ config(
  materialized = 'incremental',
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
        last_name as surname,
        first_name as givenname,
        first_name || ' ' || last_name as full_name

    from customer_source

)

select * from customers