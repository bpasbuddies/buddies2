CREATE TABLE eemrt.sub_tasks_clins (
  stc_id NUMBER,
  work_orders_id NUMBER NOT NULL,
  fk_sub_tasks_id NUMBER,
  fk_period_of_performance_id NUMBER,
  clin_id NUMBER,
  sub_clin_id NUMBER,
  clin_hours NUMBER(18,2),
  clin_amount NUMBER(18,2),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  st_clin_type VARCHAR2(20 BYTE),
  st_rate NUMBER,
  CONSTRAINT sub_tasks_clins_fk1 FOREIGN KEY (fk_sub_tasks_id) REFERENCES eemrt.sub_tasks (sub_tasks_id) ON DELETE CASCADE
);