CREATE TABLE eemrt.contract_summary_gl_stage_old (
  stage_export_date DATE,
  contract_number VARCHAR2(30 BYTE),
  vendor_name VARCHAR2(60 BYTE),
  vendor_site_code VARCHAR2(60 BYTE),
  release_number VARCHAR2(20 BYTE),
  quantity_ordered NUMBER,
  quantity_cancelled NUMBER,
  quantity_received NUMBER,
  quantity_billed NUMBER,
  net_quantity_ordered NUMBER,
  obligation_balance NUMBER
);