DROP DATABASE IF EXISTS shop;
CREATE DATABASE shop;
USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	set_time DATETIME DEFAULT NOW(),
	table_name VARCHAR (255),
	table_id BIGINT,
	column_names VARCHAR (255)
)ENGINE=Archive;

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина' ENGINE=InnoDB;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

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

/* Задание 1.
Возникла проблема при создании триггера через DBeaver - При выполнении команды " 'Alt'+X ", 
во вкладке "Триггеры" пропадают ранее созданные и сохраненные триггеры. 
 */

DROP TRIGGER IF EXISTS user_logs;
DROP TRIGGER IF EXISTS catalog_logs;
DROP TRIGGER IF EXISTS prod_logs;

DELIMITER //
CREATE TRIGGER user_logs
AFTER INSERT
ON users FOR EACH ROW
BEGIN 
	INSERT INTO logs
	SET 
		set_time = NOW(),
	 	table_name = 'users',
	 	table_id = NEW.id,
	 	column_names = NEW.name;
END//

CREATE TRIGGER catalog_logs
AFTER INSERT
ON catalogs FOR EACH ROW
BEGIN 
	INSERT INTO logs
	SET 
		set_time = NOW(),
	 	table_name = 'catalogs',
	 	table_id = NEW.id,
	 	column_names = NEW.name;
END//

CREATE TRIGGER prod_logs
AFTER INSERT
ON products FOR EACH ROW
BEGIN 
	INSERT INTO logs
	SET 
		set_time = NOW(),
	 	table_name = 'products',
	 	table_id = NEW.id,
	 	column_names = NEW.name;
END//
DELIMITER ;

/* Второе задание
 Не знаю в чем проблема, но в специальных разделах: Процедуры, функции, триггеры мои записи стираются
 после выполнения скрипта. 
 
 Данную процедуру закомитил, дабы не вводить Ваш компьютер в длительную работу)

DROP PROCEDURE IF EXISTS shop.insert_users;
DELIMITER $$
CREATE PROCEDURE shop.insert_users()
BEGIN
	SET @i=1000000;
	WHILE @i>=0 DO
		INSERT INTO users VALUES
		(DEFAULT, 'name', '1985-05-20', NOW(), NOW());
		SET @i=@i-1;
	END WHILE;
END$$
DELIMITER ;

*/

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память')
 ;

 INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29')
 ; 	

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2)
;
 
 -- Показываю что в таблицу logs вошли записи согласно заданию.
SELECT * FROM logs;

-- Вызываю созданную процедуру

CALL insert_users();

-- Проверяю выполнение работы процедурой
SELECT MAX(`id`) FROM `users`;



