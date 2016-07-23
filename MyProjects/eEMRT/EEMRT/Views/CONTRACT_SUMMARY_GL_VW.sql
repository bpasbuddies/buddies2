CREATE OR REPLACE FORCE VIEW eemrt.contract_summary_gl_vw (vendor_name,po_number,qty_ordered,udo_obligation_balance,aeu_quantity_billed,aep_quantity_received,record_detail_desc,quantity_cancelled,quantity_received,net_quantity_ordered,email_sent) AS
SELECT 
  VENDOR_NAME,
  PO_NUMBER ,
  QTY_ORDERED,
  UDO_OBLIGATION_BALANCE,
  AEU_QUANTITY_BILLED,
  AEP_QUANTITY_RECEIVED,  
  RECORD_DETAIL_DESC,
  QUANTITY_CANCELLED,
  QUANTITY_RECEIVED,
  NET_QUANTITY_ORDERED,
  EMAIL_SENT
FROM contract_summary_gl;