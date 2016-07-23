CREATE TABLE eemrt.mitre_invoice_pv (
  line_num NUMBER,
  fund_year VARCHAR2(20 BYTE),
  ceiling_year VARCHAR2(20 BYTE),
  remaining_funding NUMBER,
  delphi_amt NUMBER,
  prism_amt NUMBER,
  invoice_amount NUMBER,
  invoice_delivery_date VARCHAR2(100 BYTE),
  program_title VARCHAR2(300 BYTE),
  po_number VARCHAR2(30 BYTE)
);