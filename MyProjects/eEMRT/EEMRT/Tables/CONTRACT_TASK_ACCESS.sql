CREATE TABLE eemrt.contract_task_access (
  access_id NUMBER,
  username VARCHAR2(20 BYTE),
  contractnumber VARCHAR2(100 BYTE),
  taskorder VARCHAR2(100 BYTE),
  "ROLE" VARCHAR2(100 BYTE),
  cor VARCHAR2(100 BYTE),
  approvaldate TIMESTAMP,
  created_by VARCHAR2(100 BYTE) DEFAULT 'sys',
  created_on TIMESTAMP DEFAULT sysdate,
  updated_by VARCHAR2(100 BYTE) DEFAULT 'sys',
  updated_on TIMESTAMP DEFAULT sysdate,
  status VARCHAR2(100 BYTE),
  subtask VARCHAR2(100 BYTE),
  comments VARCHAR2(2000 BYTE)
);