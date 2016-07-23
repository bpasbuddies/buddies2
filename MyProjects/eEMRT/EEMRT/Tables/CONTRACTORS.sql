CREATE TABLE eemrt.contractors (
  contractor_id NUMBER NOT NULL,
  first_name VARCHAR2(100 BYTE) NOT NULL,
  middle_name VARCHAR2(20 BYTE),
  last_name VARCHAR2(100 BYTE) NOT NULL,
  email VARCHAR2(100 BYTE),
  vendor VARCHAR2(200 BYTE),
  work_order_id NUMBER,
  subtask_id NUMBER,
  clin_id NUMBER,
  labor_category_id NUMBER,
  create_by VARCHAR2(20 BYTE),
  created_on TIMESTAMP,
  updated_by VARCHAR2(20 BYTE),
  updated_on TIMESTAMP,
  contract_number VARCHAR2(100 BYTE),
  CONSTRAINT contractors_pk PRIMARY KEY (contractor_id)
);