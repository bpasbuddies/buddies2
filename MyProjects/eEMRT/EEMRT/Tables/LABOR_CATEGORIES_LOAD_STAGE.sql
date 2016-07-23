CREATE TABLE eemrt.labor_categories_load_stage (
  contract_number VARCHAR2(100 BYTE),
  pop VARCHAR2(30 BYTE),
  clin_number VARCHAR2(50 BYTE),
  vendor VARCHAR2(300 BYTE),
  labor_category_title VARCHAR2(300 BYTE),
  standard_labor_category VARCHAR2(300 BYTE),
  "LOCATION" VARCHAR2(50 BYTE),
  rate_type VARCHAR2(30 BYTE),
  rate NUMBER,
  minumum NUMBER,
  maximum NUMBER,
  approval VARCHAR2(100 BYTE),
  comments VARCHAR2(1000 BYTE),
  created_by VARCHAR2(200 BYTE),
  created_date DATE
);