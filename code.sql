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

--TASK 2
create or replace procedure create_order(p_customer_id int)
as $$
begin
	if exists ( --перевірка чи існує користувач
		select customer_id 
		from customers 
		where customer_id=p_customer_id
	) then --якщо користувач є, відбувається вставка значень
		insert into orders (
		customer_id,
		total_amount,
		order_date
		)
		values ( 
			p_customer_id, 
			0, --за умовою завдання встановлюємо нуль
			current_timestamp --теперішню дату
		);
    else
		raise exception 'Customer does not exist'; --у випадку, якщо користувача не інсує
    end if;
end;
$$ language plpgsql;
call create_order(1); --перевірка чи працює процедура

--TASK 3
create or replace procedure add_product_to_order(p_order_id int, p_product_id int, p_quantity int)
as $$
declare
product_price numeric(10,2); --створила змінні для збереження ціни та кількості
	product_stock int;
begin
	if p_quantity<=0 then --перевірка введеної кількості (має бути строго більше нуля)
		raise exception 'Quantity must be more than zero';
end if;
select price, stock_quantity --отримала з таблиці значенння 
into product_price, product_stock
from products
where product_id=p_product_id;
if product_stock<p_quantity then --перевірка чи достатньо на складі одиниць
		raise exception 'Not enough items left';
end if;
insert into order_items(order_id,product_id,quantity,price) --якщо достатня кількість, вставляю значення в рядок
values (p_order_id,p_product_id,p_quantity,product_price);
update products
set stock_quantity=stock_quantity-p_quantity --оновлюю (зменшую) після замовлення кількість на складі
where product_id=p_product_id;
end;
$$language plpgsql;

--TASK 4
create or replace function update_order_total()
returns trigger --функція буде викликатись тригером
as $$
begin
update orders
set total_amount=calculate_order_total(coalesce(new.order_id,old.order_id)) --використовую функцію з першої вправи та беру нове order_id (при операціях insert або update воно існує, у випадку delete є лише old, тому використовую coalesce щоб обрати перше, яке існує)  
where order_id=coalesce(new.order_id, old.order_id); --оновлюємо лише для потрібного замовлення
return null; --ніяке значення не повертаю
end;
$$language plpgsql;
create trigger trigger_update_order_total
after insert or delete or update --спрацьовую після цих дій
on order_items
for each row --для кожного рядка, де відбулися зміни
execute function update_order_total(); --виклик функції оновлення замовлення