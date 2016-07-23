CREATE TABLE eemrt.program_clin_types (
  pct_id NUMBER NOT NULL,
  pct_program VARCHAR2(20 BYTE) NOT NULL,
  pct_clin_type VARCHAR2(20 BYTE) NOT NULL,
  pct_created_by VARCHAR2(20 BYTE),
  pct_created_on TIMESTAMP,
  pct_last_modified_by VARCHAR2(20 BYTE),
  pct_last_modified_on TIMESTAMP,
  pct_clintype_order NUMBER,
  CONSTRAINT pct_pk PRIMARY KEY (pct_id)
);