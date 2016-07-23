CREATE TABLE eemrt.mitre_payment_instruction (
  po_number VARCHAR2(20 BYTE),
  line_num NUMBER,
  fund_year VARCHAR2(20 BYTE),
  ceiling_year VARCHAR2(20 BYTE),
  remaining_funding NUMBER,
  delphi_amt NUMBER,
  prism_amt NUMBER,
  invoice_number VARCHAR2(50 BYTE),
  invoice_amount NUMBER,
  invoice_delivery_date VARCHAR2(100 BYTE),
  program_title VARCHAR2(300 BYTE),
  refresh_date DATE
);