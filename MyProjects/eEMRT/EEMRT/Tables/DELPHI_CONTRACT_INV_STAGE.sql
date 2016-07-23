CREATE TABLE eemrt.delphi_contract_inv_stage (
  stage_date DATE,
  po_number VARCHAR2(50 BYTE),
  po_rev NUMBER,
  po_type VARCHAR2(30 BYTE),
  vendor_name VARCHAR2(150 BYTE),
  vendor_site_code VARCHAR2(2000 BYTE),
  line_item NUMBER,
  line_number NUMBER,
  line_type VARCHAR2(50 BYTE),
  release_number VARCHAR2(50 BYTE),
  rel_rev_num NUMBER,
  shipment_num NUMBER,
  quantity_ordered NUMBER,
  quantity_cancelled NUMBER,
  quantity_billed NUMBER,
  net_qty_ordered NUMBER,
  quantity_received NUMBER,
  obligation_balance NUMBER,
  uom VARCHAR2(50 BYTE),
  unit_price NUMBER,
  distribution_num NUMBER,
  charge_account VARCHAR2(150 BYTE),
  project_number VARCHAR2(30 BYTE),
  task_number VARCHAR2(30 BYTE),
  invoice_num VARCHAR2(50 BYTE),
  invoice_date DATE,
  inv_dist_line NUMBER,
  matching_type VARCHAR2(30 BYTE),
  multiplier NUMBER,
  "ACCOUNT" NUMBER,
  invoice_amount NUMBER,
  payment_status_flag CHAR
);