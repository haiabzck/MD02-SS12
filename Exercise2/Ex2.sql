USE ecommerce;

DELIMITER //
CREATE PROCEDURE sp_create_order(IN customer_id INT, product_id INT, quantity INT, price DECIMAL(10,2))
BEGIN
	DECLARE v_stock INT;
    DECLARE last_id INT;
    SELECT stock_quantity INTO v_stock  FROM inventory WHERE inventory.product_id = product_id;
	START TRANSACTION;
	IF 	v_stock < quantity THEN 
		SELECT ' Số Lượng trong kho không đủ' AS 'Thông báo';
		ROLLBACK;
	ELSE 
		INSERT INTO orders(customer_id) VALUE(customer_id);
        SET last_id = LAST_INSERT_ID();
        INSERT INTO order_items(order_id,product_id,quantity,price) VALUE(last_id,product_id,quantity,price);
        UPDATE inventory SET stock_quantity = stock_quantity - quantity WHERE inventory.product_id = product_id;
		SELECT 'Mua hàng thành công' AS 'Thông báo';
		COMMIT;
	END IF;
END//
DELIMITER ;
CALL sp_create_order(1,1,2,10000000);


DELIMITER //
CREATE PROCEDURE sp_pay_order(IN order_id  INT,payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer', 'Cash'))
BEGIN
	DECLARE v_status ENUM('Pending', 'Completed', 'Cancelled');
    DECLARE v_total_amount DECIMAL(10,2);
    SELECT status,total_amount INTO v_status,v_total_amount  FROM orders WHERE orders.order_id = order_id;
	START TRANSACTION;
	IF 	v_status <> 'Pending' THEN 
		SELECT ' Lỗi Không thanh toán được' AS 'Thông báo';
		ROLLBACK;
	ELSE 
		INSERT INTO payments(order_id,amount,payment_method) VALUE(order_id,v_total_amount,payment_method);
        UPDATE orders SET status = 'Completed' WHERE orders.order_id = order_id;
		SELECT 'Thanh toán thành công' AS 'Thông báo';
		COMMIT;
	END IF;
END//
DELIMITER ;
CALL sp_pay_order(13,'Credit Card');

DELIMITER //
CREATE PROCEDURE sp_cancel_order(IN in_order_id  INT)
BEGIN
	DECLARE v_status ENUM('Pending', 'Completed', 'Cancelled');
    DECLARE v_quantity INT;
    DECLARE v_product_id INT;
    SELECT quantity,product_id INTO v_quantity,v_product_id  FROM order_items WHERE order_id = in_order_id;
    SELECT status INTO v_status  FROM orders WHERE order_id = in_order_id;
	START TRANSACTION;
	IF 	v_status <> 'Pending' THEN 
		SELECT ' Lỗi Không hủy được do đơn hàng đã hủy hoặc đã thanh toán thành công !' AS 'Thông báo';
		ROLLBACK;
	ELSE 
		UPDATE inventory SET stock_quantity = stock_quantity + v_quantity WHERE inventory.product_id = v_product_id;
		DELETE FROM order_items WHERE order_id = in_order_id;
        UPDATE orders SET status = 'Cancelled' WHERE order_id = in_order_id;
		SELECT 'Hủy thành công đơn hàng' AS 'Thông báo';
		COMMIT;
	END IF;
END//
DELIMITER ;
CALL sp_cancel_order(14);


DROP PROCEDURE sp_create_order;
DROP PROCEDURE sp_pay_order;
DROP PROCEDURE sp_cancel_order;