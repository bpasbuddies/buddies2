CREATE TABLE eemrt.sub_tasks (
  sub_tasks_id NUMBER NOT NULL,
  work_orders_id NUMBER NOT NULL,
  sub_task_number VARCHAR2(20 BYTE) NOT NULL,
  sub_task_title VARCHAR2(1000 BYTE),
  start_date DATE,
  end_date DATE,
  description VARCHAR2(2000 BYTE),
  "ORGANIZATION" VARCHAR2(200 BYTE),
  faa_poc VARCHAR2(2000 BYTE),
  period_of_performance_id NUMBER,
  status VARCHAR2(20 BYTE),
  st_fee NUMBER,
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  CONSTRAINT sub_tasks_pk PRIMARY KEY (sub_tasks_id),
  CONSTRAINT sub_tasks_uk1 UNIQUE (sub_task_number,work_orders_id)
);