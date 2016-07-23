CREATE TABLE eemrt.work_orders_clins_session (
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
  sub_tasks_id NUMBER
);