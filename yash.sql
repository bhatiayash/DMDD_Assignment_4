SET SERVEROUTPUT ON;

CREATE TABLE department (
  dept_id NUMBER(5) NOT NULL PRIMARY KEY,
  dept_name VARCHAR2(20) UNIQUE NOT NULL,
  dept_location VARCHAR2(2) NOT NULL
);

CREATE SEQUENCE dept_id_seq START WITH 1;

INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Marketing', 'MA');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Sales', 'TX');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Finance', 'IL');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Engineering', 'CA');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'Human Resources', 'NY');
INSERT INTO department (dept_id, dept_name, dept_location) VALUES (dept_id_seq.NEXTVAL, 'IT', 'NJ');

CREATE OR REPLACE PROCEDURE UPDATE_DEPT(
    p_dept_name IN VARCHAR2,
    p_dept_location IN VARCHAR2
)
IS
    v_dept_name VARCHAR2(40);
    v_count NUMBER;
BEGIN
    -- Validate department name
    IF p_dept_name IS NULL OR LENGTH(p_dept_name) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Department name cannot be null or empty.');
    ELSIF REGEXP_LIKE(p_dept_name, '^[0-9]+$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Department name cannot be a number.');
    END IF;

    -- Convert department name to camel case
    v_dept_name := INITCAP(p_dept_name);

    -- Validate department location
    IF NOT p_dept_location IN ('MA', 'TX', 'IL', 'CA', 'NY', 'NJ', 'NH', 'RH') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Department location is not valid.');
    END IF;
    
    -- Check if department name length is more than 20 chars
    IF LENGTH(p_dept_name) > 20 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Department name cannot be more than 20 characters.');
    END IF;
    
    -- Check if department name already exists
    SELECT COUNT(*) INTO v_count FROM DEPARTMENT WHERE dept_name = v_dept_name;
    IF v_count = 0 THEN
        -- Insert new department
        INSERT INTO DEPARTMENT(dept_id, dept_name, dept_location)
        VALUES(dept_id_seq.NEXTVAL, v_dept_name, p_dept_location);
        DBMS_OUTPUT.PUT_LINE('Department inserted successfully.');
    ELSE
        -- Update department location
        UPDATE DEPARTMENT SET dept_location = p_dept_location WHERE dept_name = v_dept_name;
        DBMS_OUTPUT.PUT_LINE('Department updated successfully.');
    END IF;
    COMMIT;
END;
/
--TEST CASE TO INSERT A DEPARTMENT WITH A NULL NAME
BEGIN
    UPDATE_DEPT(NULL, 'NY');
END;
/
--TEST CASE TO INSERT A DEPARTMENT WITH EMPTY NAME (ZERO LENGTH)
BEGIN
    UPDATE_DEPT('', 'NY');
END;
/
--TEST CASE TO INERT A DEPARTMENT NAME WITH A NUMBER
BEGIN
    UPDATE_DEPT(123, 'NY');
END;
/
-- TEST CASE TO INSERT A DEPARTMENT WITH INVALID LOCATION
BEGIN
    UPDATE_DEPT('Marketing', 'FL');
END;
/
--TEST CASE TO INSERT A DEPARTMENT NAME WITH MORE THAN 20 CHARACTERS
BEGIN
    UPDATE_DEPT('abcdefghijklmnopqrstuvwxyz', 'NY');
END;
/
-- TEST CASE TO INSERT A DEPARTMENT IF NAME DOESN'T EXIST
BEGIN
    UPDATE_DEPT('Yash', 'CA');
END;
/
--TEST CASE TO UPDATE A DEPARTMENT LOCATION IF NAME EXISTS
BEGIN
    UPDATE_DEPT('Yash', 'NY');
END;
/
--TEST CASE TO CONVERT DEPARTMENT NAME TO CAMELCASE
BEGIN
    UPDATE_DEPT('test case', 'CA');
END;
/
BEGIN
    UPDATE_DEPT('CAPITAL', 'CA');
END;
/
BEGIN
    UPDATE_DEPT('SPECI@L', 'CA');
END;
/
