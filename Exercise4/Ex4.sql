CREATE DATABASE employee_management;
USE employee_management;
-- 1. Bảng departments (Phòng ban)
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL
);

-- 2. Bảng employees (Nhân viên)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

-- 3. Bảng attendance (Chấm công)
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
    total_hours DECIMAL(5,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- 4. Bảng salaries (Bảng lương)
CREATE TABLE salaries (
    employee_id INT PRIMARY KEY,
    base_salary DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- 5. Bảng salary_history (Lịch sử lương)
CREATE TABLE salary_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (employee_id) REFERENCES salaries(employee_id) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER before_insert_employees
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	IF  NEW.email NOT LIKE '%@%' THEN
		SET NEW.email= CONCAT(NEW.email , '@company.com');
	ELSEIF NEW.email NOT LIKE '%@company.com' THEN
		SET NEW.email= CONCAT(SUBSTRING_INDEX(NEW.email,'@',1),'@company.com') ;
    END IF;
END//
DELIMITER ;
DROP TRIGGER before_insert_employees;
INSERT INTO employees VALUE(null,'NGUYỄN VĂN B','nguyenvanb@gmail','0987654321',NOW(),1);
SELECT * FROM employees;

DELIMITER //
CREATE TRIGGER after_insert_employees
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
	INSERT INTO salaries VALUE(NEW.employee_id,10000,0,DEFAULT);
END//
DELIMITER ;

SELECT * FROM salaries;

DROP TRIGGER before_update_employees;

DELIMITER //
CREATE TRIGGER before_update_employees
BEFORE UPDATE ON attendance
FOR EACH ROW
BEGIN
	DECLARE v_total_time DECIMAL(4,2);
	SET v_total_time = (TIMESTAMPDIFF(MINUTE, NEW.check_in_time, NEW.check_out_time) / 60.0) - 1;
    IF 8.5 > v_total_time AND v_total_time > 8 THEN
		SET NEW.total_hours = 8;
    ELSE 
		SET NEW.total_hours = v_total_time;
    END IF;
END//
DELIMITER ;

UPDATE attendance 
SET check_out_time = '2023-10-27 17:20:00' ,check_in_time = '2023-10-27 8:00:00'
WHERE employee_id = 1;
SELECT * FROM attendance;


