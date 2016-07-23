CREATE TABLE eemrt.work_orders_clins (
  woc_id NUMBER,
  fk_work_orders_id NUMBER,
  fk_period_of_performance_id NUMBER,
  clin_id NUMBER,
  sub_clin_id NUMBER,
  clin_hours NUMBER(18,2),
  clin_amount NUMBER(18,2),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  wo_clin_type VARCHAR2(20 BYTE),
  wo_rate NUMBER,
  CONSTRAINT work_orders_clins_fk1 FOREIGN KEY (fk_work_orders_id) REFERENCES eemrt.work_orders (work_orders_id),
  CONSTRAINT work_orders_clins_fk2 FOREIGN KEY (clin_id) REFERENCES eemrt.pop_clin (clin_id)
);