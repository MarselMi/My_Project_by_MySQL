/*
База Данны магазина спортивной одежды. 
Задачи БД: 
 - данные продаваемого товара (тип товара, бренд, размер, цвет, остаток на складе);
 - данные пользователей, с возможностью иметь дисконтные карты;
 - размер скидки дисконтной_карты зависит от размера накопленного КЭШБЕКА;
 - корзина покупателя;
 - сохранение информации о выполненных заказов.
 
 Таблица brands содержит индексы продаваемых брендов
 
 Таблица type_sportswear содержит индексы продаваемых видов спортивной одежды
 
 Таблица size содержит информацию со всеми возможными размерами
 
 Таблица colors содержит индексы со всеми цветами
 
 Таблица products содержит информацию о продаваемом товаре.
 	name - имя модели
 	brand_id - индекс бренда
 	type_sportswear_id - индекс типа
 	gender_id - индекс половой принадлежности
 	size_id - индекс с таблицы размеров
 	color_id - индекс цвета
 	count - остаток конкретного товара на складе
 	price - цена на товар
 	
Таблица profile содержит основную информацию о пользователях, так же о наличии дисконтной карты

В таблице discount_card: 
 - индекс карточки,
 - profile_id принадлежность карточки к определенному человеку,
 - number_card уникальный,
 - cashback накопленные КЭШБЕК баллы, которые после можно потратить

Таблица orders:
 - номер ордера,
 - пользователь совершивший заказ
 - время заказа 
 - Сумма заказа
 
 Таблица order_products:
 - Составной первичный ключ, (номер продукта, номер заказа пользователя)
 - количество товара
 - сумма за определенное количество
 
 В сущности sales есть возможность установить скидку на товар: 
 - скидка на конкретный товар по products_id, по умолчанию значение NULL;
 - Возможность выбрать скиду по категориям ЦВЕТ/РАЗМЕР/ТИП_ОДЕЖДЫ/БРЕНД;
 - Время действия акции;
 - amaunt размер установленной скидки 
 
 
*/

DROP DATABASE IF EXISTS sportswear;
CREATE DATABASE sportswear;
USE sportswear;

-- Создаю таблицу с торговыми брендами магазина
DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
  id SERIAL PRIMARY KEY,
  brand_name varchar(50) DEFAULT NULL
) COMMENT='Таблица с брендами спортивной одежды';

-- Создаю таблицу с видами одежды (шорты, форма, футболки, кроссовки и пр.)
DROP TABLE IF EXISTS type_sportswear;
CREATE TABLE type_sportswear (
  id SERIAL PRIMARY KEY,
  type_of_sportswear varchar(80) DEFAULT NULL COMMENT 'Виды спортивной одежды'
) COMMENT='Вид спортивной одежды';

-- Таблица со всем возможными размерами
DROP TABLE IF EXISTS sizes;
CREATE TABLE sizes (
  id SERIAL PRIMARY KEY,
  `size` VARCHAR(10) DEFAULT NULL
);

-- Таблица со всеми цветами
DROP TABLE IF EXISTS colors;
CREATE TABLE colors (
	id SERIAL PRIMARY KEY,
	color VARCHAR(30) UNIQUE
);

-- Таблица продаваемого со всеми параматрами товара
DROP TABLE IF EXISTS products;
CREATE TABLE products(
	id SERIAL PRIMARY KEY,
	nomenclature VARCHAR(60) COMMENT 'Номенклатура товара',
	brand_id BIGINT unsigned NOT NULL COMMENT 'Индекс бренда товара',
	type_sportswear_id BIGINT unsigned NOT NULL,
	gender CHAR(1),
	size_id BIGINT unsigned NOT NULL,
	color_id BIGINT unsigned NOT NULL,
	`count` INT COMMENT 'Общий остаток  товара на складе',
	price DECIMAL(10, 2) unsigned NOT NULL,
	INDEX products_price_idx(price),
	FOREIGN KEY (brand_id) REFERENCES brands(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (color_id) REFERENCES colors(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (size_id) REFERENCES sizes(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (type_sportswear_id) REFERENCES type_sportswear(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Таблица с данными профиля
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles(
	id SERIAL PRIMARY KEY,
	name VARCHAR(60),
	surname VARCHAR(60),
	user_genders CHAR(1),	
	date_of_birth DATE,
	created_at DATETIME DEFAULT NOW(),
	email VARCHAR(100) UNIQUE,
    phone BIGINT UNIQUE,
    hometown VARCHAR(100),
    password_hash varchar(100) UNIQUE
);

-- триггер на дату рождения
DELIMITER //
DROP TRIGGER IF EXISTS tg_birthday_corr//
CREATE TRIGGER tg_birthday_corr BEFORE INSERT ON profiles FOR EACH ROW
BEGIN 
	IF (NEW.user_genders != 'f') AND (NEW.user_genders != 'm') THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Ошибка в вводе пола пользователя, Используйте: "f"-женский или "m"-мужской';
	END IF;
END//

-- триггер на указание правильного пола пользователя
DROP TRIGGER IF EXISTS tg_gender_corr//
CREATE TRIGGER tg_gender_corr BEFORE INSERT ON profiles FOR EACH ROW
BEGIN 
	IF NEW.date_of_birth > current_date() THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Ошибка в вводе даты рождения, Введите корректную дату рождения';
	END IF;
END//
DELIMITER ;

DROP TABLE IF EXISTS discount_cards;
CREATE TABLE discount_cards(
	id SERIAL PRIMARY KEY,
	profile_id BIGINT unsigned NOT NULL,
	number_card VARCHAR(60) UNIQUE,
	date_of_registration DATETIME DEFAULT NOW(),
	cashback DECIMAL(11, 2) DEFAULT NULL,
	FOREIGN KEY (profile_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE
);
	
DROP TABLE IF EXISTS order_products;
CREATE TABLE order_products(
	orders_id BIGINT unsigned NOT NULL,
	product_id BIGINT unsigned NOT NULL,
	`count` BIGINT NOT NULL,
	price_products DECIMAL(11, 2) DEFAULT NULL,
	PRIMARY KEY (product_id, orders_id),
	FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Триггер на подсчет суммы товара в зависимости от количества
DELIMITER //
DROP TRIGGER IF EXISTS tg_ord_insert//
CREATE TRIGGER tg_ord_insert BEFORE INSERT ON order_products FOR EACH ROW
BEGIN 
	SET NEW.price_products=(SELECT price FROM products WHERE NEW.product_id=id)*NEW.`count`;
END//
DELIMITER ;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
	id SERIAL PRIMARY KEY,
	profile_id BIGINT unsigned NOT NULL,
	order_price DECIMAL(11, 2) DEFAULT NULL,
	order_time DATETIME DEFAULT NOW(),
	FOREIGN KEY (profile_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Триггер на подсчет суммы заказа у определенного ордера.
DELIMITER //
DROP TRIGGER IF EXISTS tg_ord_price//
CREATE TRIGGER tg_ord_price AFTER INSERT ON order_products FOR EACH ROW
BEGIN 
	UPDATE orders
	SET order_price=(SELECT SUM(price_products) FROM order_products WHERE orders_id=orders.id);
END//
DELIMITER ;

DROP TABLE IF EXISTS sales;
CREATE TABLE sales(
	id SERIAL,
	product_id BIGINT UNSIGNED DEFAULT NULL,
	brand_id BIGINT UNSIGNED DEFAULT NULL,
	color_id BIGINT UNSIGNED DEFAULT NULL,
	size_id BIGINT UNSIGNED DEFAULT NULL,
	type_id BIGINT UNSIGNED DEFAULT NULL,
	amaunt FLOAT UNSIGNED DEFAULT NULL,
	start_time DATE DEFAULT NULL,
	end_time DATE DEFAULT NULL,
	FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES brands(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (color_id) REFERENCES colors(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (size_id) REFERENCES sizes(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (type_id) REFERENCES type_sportswear(id) ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE order_products ADD CONSTRAINT fk_orders_id
    FOREIGN KEY (orders_id) REFERENCES orders(id)
    ON UPDATE CASCADE ON DELETE CASCADE;
      
-- Заполняю таблицы согласно очереди
INSERT INTO colors
	(color)
VALUES
	('Red'), ('Black'), ('Yellow'), ('Pink'), ('White'), 
	('Green'), ('Blue'), ('Orange'), ('Purplue'), ('Grey');

INSERT INTO sizes
	(`size`)
VALUES
	('XXXS'),('XXS'),('XS'),('S'),('M'),('L'),('XL'),('XXL'),('XXXL'),('XXXXL');

INSERT INTO brands
	(brand_name)
VALUES 
	('BBS'),('ADSport'),('RUNning'),('WeatherLight'),('PUPuma'),
	('NikeDANCE'),('ADIDos'),('REEBack'),('Milka'),('NegaMike');

INSERT INTO type_sportswear
	(type_of_sportswear)
VALUES 
	('Головные уборы'),('Футболки'),('Шорты'),('Майки'),
	('Брюки'),('Носки'),('Костюмы'),('Кофты'), ('Шарфы'), ('Перчатки');
	
INSERT INTO profiles 
	VALUES 
	(DEFAULT,'Nicholas','Greenholt','f','2000-05-10','2012-05-09 13:07:18','cschowalter@example.org',79988562425,'Moskow','2b0cbfd07fdfb04f7ff3fc1234d793f24509873a'),
	(DEFAULT,'Mohammad','Kuvalis','m','1979-02-09','1992-12-09 15:37:02','ihermiston@example.com',79084562425,'Kazan','dd52797de62d7757056203602bf90cd1b32a720b'),
	(DEFAULT,'Kallie','Powlowski','f','1970-03-14','2011-12-16 07:07:17','gkautzer@example.net',79099562425,'Ufa','d0684605f4ce45d2480ecd644749aac29cb227ba'),
	(DEFAULT,'Clotilde','Streich','m','1996-07-18','2014-04-22 08:12:22','thaddeus56@example.org',79953321425,'Krasnodar','6295d60a30e0e31dbcc08c7b9265d162598b036d'),
	(DEFAULT,'Jayson','Schowalter','m','1987-05-03','1976-03-09 16:34:33','evan16@example.net',79064501548,'Moskow','ef340d5463b54acea39ac72babe3c6de536dc4e7'),
	(DEFAULT,'Caleb','Price','m','1994-11-22','2008-10-05 09:40:38','baylee.kshlerin@example.com',79000212425,'Samara','0195cdec8d6eba84e8fa8483d34b42a627137bec'),
	(DEFAULT,'Nella','Boyer','m','1987-09-24','2007-12-22 10:09:49','vwyman@example.org',79054234285,'Rostov','a200f34efa2416261c4a11fd8de74940aebaa696'),
	(DEFAULT,'Domingo','Davis','m','1988-06-14','1973-12-30 18:03:44','pearl.parisian@example.com',79048888285,'Rostov','b9902517e515a1ced07c067172ed159cdda61caf'),
	(DEFAULT,'Annetta','Hickle','m','1973-10-21','1992-01-11 08:55:55','epollich@example.net',79114191912,'Kazan','6ab0d5dfdefdc5956f46be93ee3074394ce8025c'),
	(DEFAULT,'Delphia','Batz','m','1976-06-11','2005-02-10 10:11:21','gbruen@example.com',79111142825,'Novgorod','22624d054b1f21e4e6e148f7d67c6a7183cd5ff1'),
	(DEFAULT,'Catharine','Purdy','f','1988-09-06','1982-11-11 18:28:44','armando52@example.com',79670756425,'Omsk','8d30d114b17bb009ba02feaa697201cf3ad97685'),
	(DEFAULT,'Deion','Anderson','m','1998-02-27','2021-04-25 22:33:48','renee73@example.net',79777786425,'Moskow','8013997df071a2357aa7df82e5118d8a8c2ef8bc'),
    (DEFAULT,'Mordor','Kuvalis','m','1978-02-09','1992-12-19 15:37:02','iherwqon@example.com',79084751445,'Kazan','dd52797de62d77ewsd203602bf90cd1b32a720b'),
	(DEFAULT,'Kasad','Powli','f','1967-04-14','2011-12-26 07:07:17','gka2er@example.net',79099532025,'Ufa','d0684605f4ce45d2480ecd644sadddaaac29cb227ba'),
	(DEFAULT,'Clode','Sreich','m','1997-09-18','2014-04-12 08:12:22','tha1eus56@example.org',79951215425,'Krasnodar','6295d60a30e0e31dbcccdwec265d162598b036d'),
	(DEFAULT,'Bason','Scliter','m','1988-07-03','1976-03-29 16:34:33','ev22an16@example.net',79064552548,'Moskow','ef340d5463b54acea39ac72babevee2v536dc4e7'),
	(DEFAULT,'Moneb','Pice','f','1991-12-22','2008-10-15 09:40:38','baylee12.kshlerin@example.com',79062182425,'Samara','0195cdec8d6eba84e8fvvvee4b42a627137bec'),
	(DEFAULT,'Nulla','Boyder','m','1989-07-24','2007-12-21 10:09:49','vwym88n@example.org',79054134825,'Volgograd','a200f34efa2416261c4a11fd8de7494vfdfhaa696'),
	(DEFAULT,'Flamingo','Bravis','m','1977-04-14','1973-12-20 18:03:44','pehfdrl.parisian@example.com',79044885825,'Rostov','b9902517e515a1ced07c067154htt59cdda61caf'),
	(DEFAULT,'Vanetta','Kickle','m','1990-05-21','1992-01-17 08:55:55','epoddlich@example.net',79114101182,'Kazan','6ab0d5dfdefdc5956f46be93ee3074rthh458025c')
;

INSERT INTO discount_cards
	(profile_id, number_card)
VALUES
	(13, '8888-8888-4774'),
	(6, '8888-8338-4434'),
    (8, '8118-1288-4884'),
    (19, '6688-8888-4564'),
    (4, '8865-4488-4993'),
   	(12, '8888-1888-4884'),
    (20, '8848-4458-4654'),
    (7, '8808-8778-4074'),
    (9, '8830-8888-4974'),
    (15, '8228-2388-4554');

-- Обновляю данные таблицы discount_cards с простым логическим условием 
UPDATE discount_cards SET cashback=800.00 WHERE profile_id > 10;

INSERT INTO products VALUES
	(1,'5319622744894488',1,1,'m',1,1,10,1103.14),(2,'4929701883826',2,2,'m',2,2,11,887.77),(3,'5234014982862608',3,3,'f',3,3,12,5414.13),(4,'4929213234277285',4,4,'f',4,4,14,8731.50),(5,'5115725635972610',5,5,'m',5,5,12,4652.39),(6,'4201903250671',6,6,'f',6,6,10,15068.48),(7,'5416449127007206',7,7,'f',7,7,11,999.99),(8,'5292457410480976',8,8,'f',8,8,13,709.99),(9,'4916463727724',9,9,'m',9,9,10,7066.12),(10,'5270129660861111',10,10,'m',10,10,15,2005.80),(11,'6011251263977490',1,1,'m',1,1,13,415.55),(12,'4532764447557942',2,2,'m',2,2,10,344.29),(13,'5296455041496696',3,3,'f',3,3,15,7548.37),(14,'5523403829364166',4,4,'m',4,4,12,1254.98),(15,'4539450490135',5,5,'m',5,5,11,1430.91),(16,'4546494997735',6,6,'m',6,6,11,9218.78),(17,'5549376417551691',7,7,'m',7,7,10,2150.11),(18,'341586690949364',8,8,'f',8,8,11,699.99),(19,'5594805068464883',9,9,'f',9,9,12,14744.18),(20,'4539586877147',10,10,'m',10,10,13,4887.97),(21,'5503535089114753',1,1,'m',1,1,15,2428.67),(22,'4539981977034',2,2,'f',2,2,11,2770.85),(23,'5386583362924178',3,3,'m',3,3,12,4864.83),(24,'5165730271081681',4,4,'m',4,4,12,6078.45),(25,'5572893696700607',5,5,'f',5,5,11,6191.60),(26,'5530540115992770',6,6,'m',6,6,12,13292.99),(27,'4024007189675708',7,7,'f',7,7,11,8459.92),(28,'4929789870239163',8,8,'f',8,8,15,12407.75),(29,'5432890872070109',9,9,'f',9,9,12,7078.41),(30,'4929740536352704',10,10,'f',10,10,12,4876.63),(31,'5235446074190484',1,1,'m',1,1,13,3515.28),(32,'4485795281803403',2,2,'f',2,2,11,11616.69),(33,'6011469603359884',3,3,'f',3,3,11,14244.12),(34,'5227709085582592',4,4,'m',4,4,11,6613.30),(35,'5274208627289867',5,5,'m',5,5,11,1999.99),(36,'5372356878652816',6,6,'m',6,6,14,5321.44),(37,'6011909441291940',7,7,'f',7,7,15,14856.93),(38,'4539124365419',8,8,'f',8,8,11,10747.06),(39,'4257828934092',9,9,'m',9,9,14,9966.98),(40,'6011119160604327',10,10,'m',10,10,15,1382.0),(41,'4716818766399753',1,1,'f',1,1,15,6027.36),(42,'5101477094307861',2,2,'f',2,2,10,8452.60),(43,'4532777488091907',3,3,'m',3,3,12,9333.65),(44,'5552071142456688',4,4,'m',4,4,13,9947.49),(45,'4532243954151',5,5,'m',5,5,14,5622.55),(46,'5453116927189406',6,6,'f',6,6,13,7734.11),(47,'377998757541909',7,7,'f',7,7,14,4214.47),(48,'5484959251240987',8,8,'m',8,8,15,1560.22),(49,'5497134587958701',9,9,'f',9,9,11,8905.12),(50,'4485278902589',10,10,'m',10,10,12,10150.53),(51,'4532237567980',1,1,'m',1,1,13,14683.83),(52,'4716732118434017',2,2,'m',2,2,11,3919.74),(53,'5549186962716407',3,3,'m',3,3,15,7680.68),(54,'370795918247351',4,4,'f',4,4,13,4171.02),(55,'5276065706794889',5,5,'m',5,5,11,7508.37),(56,'4024007195564791',6,6,'m',6,6,10,2028.82),(57,'5157205169563612',7,7,'f',7,7,10,967.05),(58,'374534618721745',8,8,'f',8,8,13,1372.81),(59,'4209370019030913',9,9,'m',9,9,10,5036.23),(60,'6011993031079230',10,10,'f',10,10,13,3029.91),(61,'373653338792097',1,1,'f',1,1,11,2752.30),(62,'5596392598068100',2,2,'m',2,2,14,6985.56),(63,'4916583408268',3,3,'m',3,3,14,7916.00),(64,'5541572538454290',4,4,'f',4,4,12,2816.61),(65,'5195161195025263',5,5,'f',5,5,15,928.32),(66,'5535854541774038',6,6,'m',6,6,10,5855.32),(67,'4556413671560789',7,7,'f',7,7,15,1989.8),(68,'4716666159462565',8,8,'f',8,8,14,4384.23),(69,'5314101578362474',9,9,'m',9,9,13,2099.99),(70,'5542778670614882',10,10,'m',10,10,14,2658.04),(71,'4532520518519',1,1,'m',1,1,12,5350.91),(72,'4024007156326',2,2,'m',2,2,14,3330.85),(73,'5261519606505315',3,3,'f',3,3,15,4491.16),(74,'5293732707772517',4,4,'m',4,4,14,5952.99),(75,'4539149863281560',5,5,'f',5,5,15,5126.93),(76,'4916438474193016',6,6,'f',6,6,13,1367.14),(77,'374535473521922',7,7,'f',7,7,13,7691.15),(78,'5158944532346658',8,8,'f',8,8,11,634.74),(79,'4024007116506',9,9,'m',9,9,15,1780.75),(80,'5331511804571982',10,10,'m',10,10,14,959.32),(81,'349122177954006',1,1,'m',1,1,13,866.36),(82,'5362954788708558',2,2,'f',2,2,11,3075.18),(83,'5577528163845974',3,3,'m',3,3,12,6042.62),(84,'5236445420334787',4,4,'m',4,4,10,8582.59),(85,'5521881035708321',5,5,'m',5,5,11,2081.26),(86,'5317273360196159',6,6,'f',6,6,14,1552.76),(87,'4539829262178590',7,7,'m',7,7,10,3319.91),(88,'5524035551243074',8,8,'f',8,8,14,2770.42),(89,'4707765170788',9,9,'f',9,9,15,3739.25),(90,'5221220189632212',10,10,'f',10,10,10,9412.81),(91,'5284802013306881',1,1,'m',1,1,15,924.52),(92,'5437885526403416',2,2,'m',2,2,13,11107.28),(93,'5220840487729150',3,3,'m',3,3,15,999.99),(94,'4419107297756005',4,4,'f',4,4,12,544.09),(95,'4539013902263337',5,5,'m',5,5,14,829.07),(96,'4020521844924368',6,6,'f',6,6,14,3881.04),(97,'4532054914577',7,7,'m',7,7,13,1182.26),(98,'4485661592808',8,8,'m',8,8,15,524.10),(99,'4024007168126200',9,9,'m',9,9,14,1614.18),(100,'4916346288261659',10,10,'m',10,10,10,9175.14)
;

INSERT INTO orders (profile_id) VALUES
	(1),
	(4),
	(7),
	(8),
	(20),
	(18),
	(13),
	(15),
	(11),
	(6);

INSERT INTO order_products (orders_id, product_id, `count`) VALUES
	(1, 1, 2),
	(1, 4, 1),
	(1, 5, 3),
	(2, 15, 4),
	(2, 10, 2),
	(3, 1, 2),
	(3, 4, 1),
	(3, 5, 3),
	(4, 9, 4),
	(5, 11, 1),
	(6, 1, 2),
	(7, 4, 1),
	(8, 5, 3),
	(9, 9, 4),
	(10, 11, 1);

INSERT INTO sales (product_id, brand_id, color_id, size_id, type_id, amaunt, start_time, end_time) VALUES
	(14, DEFAULT, 10, DEFAULT, DEFAULT, 0.95, '2020-06-20', '2020-07-01'),
	(4, 4, DEFAULT, DEFAULT, DEFAULT, 0.5, '2022-02-20', '2022-08-01');

-- INNER JOIN соединение. Вывести пользователей, которые имеют дисконтные карты
SELECT p.id, p.name 
FROM profiles p
JOIN discount_cards ds 
ON p.id=ds.profile_id 
ORDER BY p.id;

-- Вложенный запрос. Показать пользователей, чей заказ больше 4000 рублей
SELECT 
	profiles.id, 
	profiles.name
FROM profiles
WHERE profiles.id IN (SELECT profile_id FROM orders WHERE order_price>4000);

-- Представление Таблицы, содержащая товары участвующие в скидках в настоящее время
CREATE OR REPLACE VIEW v_products_sale AS
SELECT 
	p.id, p.price, s.amaunt, 
	s.start_time, s.end_time  
FROM products p 
JOIN sales s 
ON (p.id=s.product_id OR p.brand_id=s.brand_id OR p.type_sportswear_id=s.type_id OR p.size_id=s.size_id OR p.color_id=s.color_id) AND 
		((curdate()<s.end_time) AND (curdate()>s.start_time));


-- Процедура для обновления цен если скидка распространяется на товар 
DROP PROCEDURE IF EXISTS pr_price_sale;
DELIMITER //
CREATE PROCEDURE pr_price_sale()
BEGIN
	UPDATE products p INNER JOIN sales s ON (p.id = s.product_id)
	SET
	p.price = p.price*s.amaunt
	WHERE (p.id=s.product_id OR p.brand_id=s.brand_id OR p.type_sportswear_id=s.type_id OR p.size_id=s.size_id OR p.color_id=s.color_id) AND 
		((curdate()<s.end_time) AND (curdate()>s.start_time));
END//
DELIMITER ;

CALL pr_price_sale();

SELECT id, price, amaunt, start_time, end_time FROM v_products_sale;

-- Показать пользователей которые совершили заказ, имеют дисконтные карты, и есть баланс на кэшбэке
SELECT 
	p.id, 
	CONCAT(p.name,' ', p.surname) AS `user`
FROM profiles p
JOIN discount_cards dc ON p.id=dc.profile_id AND (dc.cashback <> 0) 
JOIN orders o ON o.profile_id=dc.profile_id
GROUP BY `user`;

-- допустим 15 пользователь решил использовать свой кэшбэк на покупку. Произведем транзакцию
START TRANSACTION;

SET @cashback = (SELECT cashback FROM discount_cards WHERE profile_id=15);

UPDATE orders o 
SET o.order_price = o.order_price - @cashback
WHERE o.profile_id=15;

UPDATE discount_cards 
SET cashback=0 
WHERE profile_id=15;

-- Транзакция прошла успешно, заканчиаваем.
COMMIT;


