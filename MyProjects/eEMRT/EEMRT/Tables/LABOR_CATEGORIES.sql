CREATE TABLE eemrt.labor_categories (
  category_id NUMBER NOT NULL,
  category_name VARCHAR2(2000 BYTE) NOT NULL,
  pgm_name VARCHAR2(50 BYTE),
  "CATEGORY" VARCHAR2(200 BYTE),
  isactive NUMBER(1) DEFAULT 1
);