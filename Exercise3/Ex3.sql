USE ecommerce;

CREATE TABLE order_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    old_status ENUM('Pending', 'Completed', 'Cancelled'),
    new_status ENUM('Pending', 'Completed', 'Cancelled'),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER before_insert_check_payment
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
	DECLARE v_total_amount DECIMAL(10,2);
SELECT total_amount INTO v_total_amount 
FROM orders
WHERE
    NEW.order_id = orders.order_id;
    IF v_total_amount <> NEW.amount  THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Số tiền thanh toán không khướp';
    END IF;
END//
DELIMITER ;


DELIMITER //
CREATE TRIGGER after_update_order_status
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status  THEN
		INSERT INTO order_logs(order_id,old_status,new_status,log_date) VALUE(OLD.order_id,OLD.status,NEW.status,NOW());
    END IF;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_update_order_status_with_payment(IN 
		order_id INT, 
		new_status ENUM('Pending', 'Completed', 'Cancelled'), 
		payment_amount DECIMAL(10,2), 
		payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer', 'Cash')
)
BEGIN
	DECLARE v_status ENUM('Pending', 'Completed', 'Cancelled');
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Nếu có bất kỳ lỗi nào (sai khóa ngoại, thiếu cột...), thực hiện quay lui
		SELECT 'Đã xảy ra lỗi hệ thống!' AS Message;
        ROLLBACK;
    END;
    SELECT status INTO v_status  FROM orders WHERE orders.order_id = order_id;
	START TRANSACTION;
	IF new_status = 'Completed' THEN
        INSERT INTO payments(order_id,amount,payment_method,status) VALUE(order_id,payment_amount,payment_method,new_status);
        UPDATE orders SET status = new_status WHERE orders.order_id = order_id;
		SELECT 'Update Thanh toán thành công' AS 'Thông báo';
		COMMIT;
	ELSE 
		SELECT ' Xảy ra lỗi' AS 'Thông báo';
		ROLLBACK;
	END IF;
END//
DELIMITER ;
CALL sp_update_order_status_with_payment(2,'Completed',0,'Credit Card');
SELECT * FROM order_logs;
DROP TRIGGER before_insert_check_payment;
DROP TRIGGER after_update_order_status;
DROP PROCEDURE sp_update_order_status_with_payment;