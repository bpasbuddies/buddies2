CREATE TABLE eemrt.small_business_lkup (
  "ID" NUMBER NOT NULL,
  code VARCHAR2(50 BYTE),
  description VARCHAR2(1000 BYTE),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  CONSTRAINT small_business_pk PRIMARY KEY ("ID")
);