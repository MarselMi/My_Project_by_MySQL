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

DROP TABLE IF EXISTS rubrics;
CREATE TABLE rubrics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO rubrics VALUES
  (NULL, 'Видеокарты'),
  (NULL, 'Память');

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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


-- Задание 1
INSERT INTO orders
 	(user_id)
VALUES
	(2), (1), (4);

-- Решение с помощью вложенного запроса
SELECT id
FROM users
WHERE id IN (SELECT user_id FROM orders);

-- Решение с помощью JOIN соединения
SELECT user_id, name
FROM orders o 
LEFT JOIN users u
ON o.user_id = u.id;


-- Задание 2
-- Вложенный запрос
SELECT id,
	name,
	(SELECT name FROM catalogs WHERE id=catalog_id) AS 'Раздел',
	(SELECT id FROM catalogs WHERE id=catalog_id) AS 'Шифр раздела'
FROM products;

-- JOIN соединение
SELECT 
	p.id, 
	p.name, 
	c.name AS 'Раздел',
	c.id AS 'Шифр раздела'	
FROM products p 
LEFT JOIN catalogs c 
ON p.catalog_id=c.id;


-- Задание 3
DROP TABLE IF EXISTS  flights;
CREATE TABLE flights (
	id SERIAL PRIMARY KEY,
	`from` VARCHAR(255),
	`to` VARCHAR(255)
);

INSERT INTO flights 
VALUES
	(DEFAULT, 'Moskow', 'Omsk'),
	(DEFAULT, 'Novgorod', 'Kazan'),
	(DEFAULT, 'Irkutsk', 'Moskow'),
	(DEFAULT, 'Omsk', 'Irkutsk'),
	(DEFAULT, 'Moskow', 'Kazan');

DROP TABLE IF EXISTS  `cities`;
CREATE TABLE `cities` (
	label  VARCHAR(255),
	name  VARCHAR(255)
);

INSERT INTO cities 
VALUES
	('Moskow', 'Москва'),
	('Irkutsk', 'Иркутск'),
	('Novgorod', 'Новгород'),
	('Kazan', 'Казань'),
	('Omsk', 'Омск');


-- Первый, не очень универсальный, способ
SELECT id, 
	CASE(`from`)
		WHEN 'Moskow' THEN 'Москва'
		WHEN 'Irkutsk' THEN 'Иркутск'
		WHEN 'Novgorod' THEN 'Новгород'
		WHEN 'Kazan' THEN 'Казань'
		ELSE 'Омск'
	END AS 'Вылет из', 
	CASE (`to`)
		WHEN 'Moskow' THEN 'Москва'
		WHEN 'Irkutsk' THEN 'Иркутск'
		WHEN 'Novgorod' THEN 'Новгород'
		WHEN 'Kazan' THEN 'Казань'
		ELSE 'Омск'
	END AS 'Прилет в' 
FROM flights f;

-- Второй способ вложенным запросом
SELECT id,
	(SELECT name FROM cities WHERE flights.`from`=label) AS 'Вылет из',
	(SELECT name FROM cities WHERE flights.`to`=label) AS 'Прилет в'
FROM flights;

-- UPDATE и JOIN соединение
-- Не смог выполнить одним запросом, выводилась ошибка " Truncated incorrect DOUBLE value: 'Москва' "

UPDATE flights f 
JOIN cities c
ON `from`=label
SET `from`=name;

UPDATE flights f 
JOIN cities c
ON `to`=label
SET `to`=name;

/*
UPDATE flights f 
JOIN cities c
ON `from`=label OR `to`=label
SET `from`=name AND `to`=name;
*/

 






