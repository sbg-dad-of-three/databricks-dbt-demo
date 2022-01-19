
select * from {{ source('bronze', 'payments') }}