CREATE TABLE eemrt.mitre_invoice_hdr (
  mih_invoice_number NUMBER NOT NULL,
  mih_invoice_start_date DATE NOT NULL,
  mih_invoice_end_date DATE NOT NULL,
  mih_invoice_received_date DATE NOT NULL,
  mih_invoice_amount FLOAT,
  mih_contract_number VARCHAR2(200 BYTE),
  mih_created_by VARCHAR2(50 BYTE),
  mih_created_on TIMESTAMP,
  mih_updated_by VARCHAR2(50 BYTE),
  mih_updated_on TIMESTAMP
);