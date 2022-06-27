DROP DATABASE IF EXISTS magazine;
CREATE DATABASE magazine;
USE magazine;

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(500),
  updated_at VARCHAR(500)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id INT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = 'Скидки';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

-- Задание 1. Устанавливаю дату время согласно заданию
UPDATE users
SET created_at=NOW(), updated_at=NOW();

-- Задание 2. Преобразование данных типа VARCHAR к типу данных DATETIME

-- Создаю ошибочную запись в неверном формате 20.10.2017 8:10
UPDATE users SET created_at='20.10.2017 8:10', updated_at='20.10.2017 8:10';

-- Создаю новые столбцы
ALTER TABLE users ADD COLUMN 
	`created_new` DATETIME DEFAULT NULL;
ALTER TABLE users ADD COLUMN
    `updated_new` DATETIME DEFAULT NULL;
   
-- Перезаписываю старые данные в новый формат и помещаю в созданные столбцы
UPDATE users 
	SET `created_new`=STR_TO_DATE(created_at, '%d.%m.%Y %h:%i'),
	`updated_new`=STR_TO_DATE(updated_at, '%d.%m.%Y %h:%i');

-- Удаляю столбцы с неверной датой, и переименовываю новые
ALTER TABLE users 
DROP created_at, 
DROP updated_at,
RENAME COLUMN 
	created_new TO created_at,
RENAME COLUMN 
	updated_new TO updated_at;

-- Задание 3. 
-- Заполняю столбец value значениями c задания
INSERT INTO storehouses_products
(value)
VALUES (0),
	(0),
	(2500),
	(1),
	(30),
	(500);

-- Не понял, было ли обязательным условие того чтоб выводить ноль в конце списка, поэтому сделал без него
SELECT value FROM storehouses_products
	ORDER BY FIELD (value, '0'), value ASC;

-- Задание 5. Сортировка в нужном порядке вывода (5, 1, 2)
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD (id, '2'), id DESC;
-- С помощью функции FIELD помещаю id=2 в конец списка

-- Практическое задание теме «АГРЕГАЦИЯ ДАННЫХ»
-- Задание 1.
-- Вычисляю возраст каждого пользователя, суммирую и делю на их количество пользователей
SELECT SUM(TIMESTAMPDIFF(year, birthday_at, NOW()))/COUNT(id)  FROM users AS age;

-- Задание 2.
-- Создаю COUNT(id) для подсчета количества пользователей, и группирую список по дням недели
SELECT COUNT(id), DAYNAME(MAKEDATE(YEAR(NOW()), DAYOFYEAR(birthday_at))) AS day_of_week FROM users GROUP BY day_of_week;

-- Задание 3.
SELECT EXP(SUM(ln(id))) FROM users;