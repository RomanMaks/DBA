-- 1 Написать запросы:

  -- 1. Запрос, который выберет категории и среднюю цену товаров в каждой категории,
  --    при условии, что эта средняя цена менее 1000 рублей (выбираем "бюджетные" 
  --    категории товаров)

    SELECT categories.name, AVG(products.price)
    FROM products
      INNER JOIN categories ON products.cat_id = categories.id
    GROUP BY categories.id
    HAVING AVG(products.price) < 1000;
  
  -- 2. Улучшите предыдущий запрос таким образом, чтобы в расчет средней цены 
  --    включались только товары, имеющиеся на складе.

    SELECT categories.name, AVG(products.price)
    FROM products
      INNER JOIN categories ON products.cat_id = categories.id
    WHERE products.goods_in_stock > 0
    GROUP BY categories.id
    HAVING AVG(products.price) < 1000;

  -- 3. Добавьте к таблице брендов класс бренда (A, B, C). Например, A - Apple, 
  --    B - Samsung, C - Xiaomi. Напишите запрос, который для каждой категории 
  --    и класса брендов, представленных в категории выберет среднюю цену товаров.

    ALTER TABLE brands ADD class VARCHAR(1) NULL;

    SELECT categories.name, brands.class, AVG(products.price)
    FROM products
      INNER JOIN categories ON products.cat_id = categories.id
      INNER JOIN brands on products.brand_id = brands.id
    GROUP BY categories.name, brands.class;

-- 2. Добавьте к своей базе данных таблицу заказов. Простейший вариант - номер заказа, 
--    дата и время, ID товара.

  CREATE TABLE orders (
    "number" SERIAL, -- `number` SERIAL для MySQL
    order_date DATE NOT NULL,
    product_id INTEGER NOT NULL,
    PRIMARY KEY ("number")
  );

  ALTER TABLE orders
  ADD FOREIGN KEY (product_id)
  REFERENCES products(id)
  ON UPDATE CASCADE
  ON DELETE RESTRICT;

-- 3. Напишите запрос, который выведет таблицу с полями "дата", "число заказов за дату",
--    "сумма заказов за дату". Для этого вам придется самостоятельно найти информацию о 
--    функциях работы с датой и временем
  
  SELECT
    orders.order_date,
    COUNT(orders.order_date),
    SUM(products.price)
  FROM products
    INNER JOIN orders ON products.id = orders.product_id
  GROUP BY (orders.order_date)

-- *  Улучшите этот запрос, введя группировку по признаку "дешевый товар", "средняя цена", 
--    "дорогой товар". Критерии отнесения товара к той или иной группе определите самостоятельно.
--    В итоге должно получиться "дата", "группа по цене", "число заказов", "сумма заказов"
  
  SELECT
    orders.order_date,
    CASE
      WHEN products.price BETWEEN 0 AND 500 THEN 'дешевый товар'
      WHEN products.price BETWEEN 600 AND 1900 THEN 'средняя цена'
      WHEN products.price >= 2000 THEN 'дорогой товар'
    END AS price_category,
    COUNT(orders.order_date),
    SUM(products.price)
  FROM products
    INNER JOIN orders ON products.id = orders.product_id
  GROUP BY (orders.order_date, price_category)