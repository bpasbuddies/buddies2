CREATE TABLE eemrt.task_clin_old (
  task_clin_id NUMBER NOT NULL,
  task_orders_id NUMBER,
  task_clin_number VARCHAR2(6 BYTE),
  task_clin_type VARCHAR2(100 BYTE),
  task_clin_sub_clin VARCHAR2(6 BYTE),
  task_clin_title VARCHAR2(200 BYTE),
  task_clin_hours NUMBER,
  task_clin_rate NUMBER(18,2),
  task_clin_amount NUMBER(18,2),
  hours_commited NUMBER,
  created_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT SYSDATE,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  PRIMARY KEY (task_clin_id),
  CONSTRAINT fk_task_clin FOREIGN KEY (task_orders_id) REFERENCES eemrt.task_orders_old (task_orders_id)
);