CREATE TABLE eemrt.tbl_summ_report_session (
  contract_number VARCHAR2(100 BYTE),
  lsd VARCHAR2(122 BYTE),
  work_orders_id NUMBER,
  transaction_date TIMESTAMP,
  fiscal_year VARCHAR2(16 BYTE),
  fund_type VARCHAR2(40 BYTE),
  accounting_code VARCHAR2(1000 BYTE),
  release_num VARCHAR2(150 BYTE),
  project_number VARCHAR2(150 BYTE),
  task_number VARCHAR2(150 BYTE),
  accounting_string VARCHAR2(1000 BYTE),
  funded_amount NUMBER,
  invoiced NUMBER,
  balance_amount NUMBER,
  created_by VARCHAR2(50 BYTE)
);