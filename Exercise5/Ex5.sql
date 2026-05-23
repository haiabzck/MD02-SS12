USE employee_management;

DROP PROCEDURE IncreaseSalary;
DELIMITER //
CREATE PROCEDURE IncreaseSalary(IN emp_id INT, new_salary DECIMAL(10,2),reason TEXT)
BEGIN
	DECLARE v_old_salary DECIMAL(10,2);
    DECLARE v_emp_id INT;
    SELECT employee_id,base_salary INTO v_emp_id,v_old_salary  FROM salaries WHERE  employee_id = emp_id;
	START TRANSACTION;
	IF 	 v_emp_id IS NULL  THEN 
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=  'Nhân viên  không tồn tại.';
	ELSE 
        UPDATE salaries SET base_salary = new_salary  WHERE employee_id = emp_id;
        INSERT INTO salary_history(employee_id,old_salary,new_salary,reason) VALUE(emp_id,v_old_salary,new_salary,reason);
		COMMIT;
        SELECT 'Update Lương thành công' AS 'Thông báo';
	END IF;
END//
DELIMITER ;

CALL IncreaseSalary(4,12000,'Hết thử việc');
SELECT * FROM salary_history ;


DELIMITER //
CREATE PROCEDURE DeleteEmployee(IN emp_id INT)
BEGIN
    DECLARE v_emp_id INT;
    SELECT employee_id INTO v_emp_id  FROM salaries WHERE  employee_id = emp_id;
	START TRANSACTION;
	IF 	 v_emp_id IS NULL  THEN 
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=  'Nhân viên  không tồn tại.';
	ELSE 
        DELETE FROM employees WHERE employee_id = emp_id;
		COMMIT;
        SELECT 'Xóa nhân viên thành công' AS 'Thông báo';
	END IF;
END//
DELIMITER ;

CALL DeleteEmployee(4);