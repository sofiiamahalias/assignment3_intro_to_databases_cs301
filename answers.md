1. What is the difference between a function and a procedure in PostgreSQL?
    
Функція завжди має повертати результат та викликається всередині запиту, не може містити commit/rollback/savepoint. Процедура викликається через call, може мати commit/rollback/savepoint, не обов'язково має повертати результат.
2. Can a trigger be executed manually? Why or why not? 
    
Ні, вручну викликати не можна. Тому, що тригер спрацьовує тільки автоматично як відповідь на insert, update aбо delete. 
3. What are the advantages and disadvantages of storing business logic inside the database? 

Переваги: цілісність даних завдяки тригерам та транзакціям (якщо виникає проблема в процесі, всі зміни відкочуються, роблячи пошкодження даних неможливим), швидке виконання операцій при введенні коректного та оптимізованого запиту. Недоліки: складні запити є об'ємними та складними для читання.