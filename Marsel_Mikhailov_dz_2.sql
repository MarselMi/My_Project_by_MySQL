
-- Задание 1
 
/*
Создание файла my.cnf и заполнение, выполняю чз командную строку 
 
cd c:\Program Files\MySQL\MySQL Server 8.0
c:\Program Files\MySQL\MySQL Server 8.0>copy con my.cnf
[client]
user=root
password=***my_password***

ctrl+Z, соглашаемся и сохраняем файл

*/

-- Задание 2

DROP DATABASE IF EXISTS example;
CREATE DATABASE example;

USE example;

DROP TABLE IF EXISTS users;
CREATE TABLE users(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(255) COMMENT 'Имя пользователя',
	surname VARCHAR(255) COMMENT 'Фамилия пользователя'
) COMMENT 'Информация о пользователях';

INSERT INTO users (name, surname) VALUES ("Marsel", "Mikhailov"), 
    ("Vasya", "Pupkin");

-- Задание 3

/*
c:\Program Files\MySQL\MySQL Server 8.0>mysqldump example > sample.sql

c:\Program Files\MySQL\MySQL Server 8.0>mysql sample < sample.sql
ERROR 1049 (42000): Unknown database 'sample'

В директории появился файл sample.sql, но обратный dump происходит с ошибкой,
пробовал открыть файл sample.sql и запустить код, но программа выводит ошибку
Еще обратил внимание на то что в файл не записался закомментированный текст.

*/


/*
Хотел попробовать посмотреть директорию по команде

mysql> SHOW VARIABLES LIKE 'datadir';
+---------------+---------------------------------------------+
| Variable_name | Value                                       |
+---------------+---------------------------------------------+
| datadir       | C:\ProgramData\MySQL\MySQL Server 8.0\Data\ |
+---------------+---------------------------------------------+
Но почему то у меня такой директории не оказалось, проверял...
*/

