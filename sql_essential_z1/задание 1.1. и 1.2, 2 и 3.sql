--1.1. Создайте новую базу данных с любым названием
psql -U postgres -c "create database hr"

--1.2. Восстановите бэкап учебной базы данных в новую базу данных с помощью psql
psql -U postgres -d hr < C:\Users\ansmironov\Documents\netology\ansmironov\hr.sql


-- 2.1. Создайте нового пользователя MyUser, которому разрешен вход, но не задан пароль и права доступа.
create role MyUser login;

-- 2.2. Задайте пользователю MyUser любой пароль сроком действия до последнего дня текущего месяца.
alter role MyUser with login password '123' valid until '31/05/2025';

grant connect on database hr to MyUser;

-- 2.3. Дайте пользователю MyUser права на чтение данных из двух любых таблиц восстановленной базы данных.
grant usage on schema hr to MyUser;
grant select on table hr.address to MyUser;
grant select on table hr.city to MyUser;


-- 2.4. Заберите право на чтение данных ранее выданных таблиц
revoke select on table hr.city from MyUser;
revoke select on table hr.address from MyUser;


-- 2.5. Удалите пользователя MyUser.
revoke usage on schema hr from MyUser;
revoke connect on database hr from MyUser;
drop role myuser;

-- 3.1. Начните транзакцию
begin;

-- 3.2. Добавьте в таблицу projects новую запись
insert into hr.projects (
  select 
    (select max(project_id) + 1 from hr.projects), 
    name, employees_id, amount, assigned_id, now() 
  from  hr.projects limit 1
) returning project_id;
-- вернуло project_id = 129

-- 3.3. Создайте точку сохранения
SAVEPOINT slav_point_3000;

-- 3.4. Удалите строку, добавленную в п.3.2
delete from hr.projects where project_id = 129;

-- 3.5. Откатитесь к точке сохранения
rollback to slav_point_3000;

-- 3.6. Завершите транзакцию.
commit;