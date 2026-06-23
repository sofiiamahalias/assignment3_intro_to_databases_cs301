create table customers (
                           customer_id serial primary key,
                           full_name varchar(100) not null,
                           email varchar(100) unique not null,
                           balance numeric(10,2) default 0
);

create table products (
                          product_id serial primary key,
                          product_name varchar(100) not null,
                          price numeric(10,2) not null,
                          stock_quantity int not null
);

create table orders (
                        order_id serial primary key,
                        customer_id int references customers(customer_id),
                        order_date timestamp default current_timestamp,
                        total_amount numeric(10,2) default 0
);

create table order_items (
                             order_item_id serial primary key,
                             order_id int references orders(order_id),
                             product_id int references products(product_id),
                             quantity int not null,
                             price numeric(10,2) not null
);

create table order_log (
                           log_id serial primary key,
                           order_id int,
                           customer_id int,
                           action varchar(50),
                           log_date timestamp default current_timestamp
);


--TASK 1
create or replace function calculate_order_total(p_order_id int)
returns numeric(10,2) --обрала цей тип даних, оскільки він використовується для цін та сум в таблиці 
as $$
declare
total numeric(10,2); --створюю змінну для збереження результату
begin
select coalesce(sum(quantity*price),0) --використовую cоalesce, щоб при відсутності замовлень повертало 0
into total
from order_items
where order_id=p_order_id;
return total;
end;
$$language plpgsql;
select calculate_order_total(2); --перевірка чи працює функція
