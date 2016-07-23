CREATE TABLE eemrt.contract_summary_gl_archive (
  vendor_name VARCHAR2(200 BYTE),
  po_number VARCHAR2(200 BYTE),
  qty_ordered NUMBER(19,2),
  udo_obligation_balance NUMBER(19,2),
  aeu_quantity_billed NUMBER(18,2),
  aep_quantity_received NUMBER(18,2),
  release_num VARCHAR2(10 BYTE) DEFAULT 9999,
  record_detail_desc VARCHAR2(1000 BYTE),
  quantity_cancelled NUMBER,
  quantity_received NUMBER,
  net_quantity_ordered NUMBER,
  created_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT SYSDATE,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  archive_date TIMESTAMP
);