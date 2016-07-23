CREATE TABLE eemrt.contractors_tasksorders (
  contractor_toid NUMBER NOT NULL,
  contractor_id NUMBER,
  vendor_name VARCHAR2(200 BYTE),
  work_order_id NUMBER NOT NULL,
  subtask_id NUMBER,
  clin_id NUMBER,
  labor_category_id NUMBER,
  create_by VARCHAR2(20 BYTE),
  created_on TIMESTAMP,
  updated_by VARCHAR2(20 BYTE),
  updated_on TIMESTAMP,
  CONSTRAINT contractors_toid_pk PRIMARY KEY (contractor_toid)
);