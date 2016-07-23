CREATE TABLE eemrt.invoice_detail (
  invoice_detail_id NUMBER NOT NULL,
  invoice_id NUMBER,
  work_orders_id NUMBER,
  sub_tasks_id NUMBER,
  clin_id NUMBER,
  sub_clin_id NUMBER,
  clin_type VARCHAR2(20 BYTE),
  labor_category VARCHAR2(200 BYTE),
  contract_clin_cost_type VARCHAR2(20 BYTE),
  contractor_employee_name VARCHAR2(200 BYTE),
  invoice_hours_qty NUMBER,
  invoice_rate NUMBER,
  invoice_amount NUMBER,
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  contractor_id NUMBER,
  description VARCHAR2(2000 BYTE),
  travel_auth VARCHAR2(1000 BYTE),
  odc_auth VARCHAR2(1000 BYTE),
  CONSTRAINT invoice_detail_pk PRIMARY KEY (invoice_detail_id),
  CONSTRAINT invoice_detail_fk1 FOREIGN KEY (invoice_id) REFERENCES eemrt.invoice (invoice_id) ON DELETE CASCADE
);