DELIMITER //
CREATE PROCEDURE `BMS-DDE-DEV`.`mod_test_table_insert`(
	IN in_function_name VARCHAR(255),
    IN in_call_by INT,
    IN in_args TEXT
)
BEGIN

INSERT INTO `test_table` (`name`, `description`) VALUES (JSON_EXTRACT(in_args, '$.name'), JSON_EXTRACT(in_args, '$.description'));

END
//
DELIMITER ;


