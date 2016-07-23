CREATE TABLE eemrt.wo_labor_category (
  wo_labor_category_id NUMBER NOT NULL,
  labor_category_id NUMBER NOT NULL,
  clin_id NUMBER NOT NULL,
  work_orders_id NUMBER NOT NULL,
  std_labor_category_id NUMBER,
  labor_category_rate NUMBER(18) NOT NULL,
  labor_category_hours NUMBER,
  contractor VARCHAR2(100 BYTE),
  vendor VARCHAR2(100 BYTE),
  comments VARCHAR2(2000 BYTE),
  created_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT SYSDATE,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  clin_type VARCHAR2(20 BYTE),
  lc_amount NUMBER,
  CONSTRAINT wo_labor_category_fk1 FOREIGN KEY (labor_category_id) REFERENCES eemrt.clin_labor_category (labor_category_id)
);