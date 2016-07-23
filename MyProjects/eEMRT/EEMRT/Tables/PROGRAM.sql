CREATE TABLE eemrt."PROGRAM" (
  pgm_id NUMBER NOT NULL,
  pgm_name VARCHAR2(50 CHAR) NOT NULL,
  pgm_desc VARCHAR2(200 CHAR),
  pgm_created_by VARCHAR2(50 BYTE) DEFAULT 'SYS' NOT NULL,
  pgm_created_on TIMESTAMP DEFAULT SYSDATE NOT NULL,
  pgm_updated_by VARCHAR2(50 BYTE),
  pgm_updated_on TIMESTAMP,
  pgm_ceiling_amount NUMBER,
  CONSTRAINT pk_program PRIMARY KEY (pgm_id)
);