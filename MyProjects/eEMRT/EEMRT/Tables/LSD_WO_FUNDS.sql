CREATE TABLE eemrt.lsd_wo_funds (
  lsd_wo_id NUMBER NOT NULL,
  contract_number VARCHAR2(100 BYTE),
  lsd VARCHAR2(200 BYTE),
  work_orders_id NUMBER,
  amount NUMBER(18,2),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  sub_tasks_id NUMBER,
  CONSTRAINT pk_lsd_wo_id PRIMARY KEY (lsd_wo_id),
  CONSTRAINT fk_contract_number FOREIGN KEY (contract_number) REFERENCES eemrt.contract (contract_number)
);