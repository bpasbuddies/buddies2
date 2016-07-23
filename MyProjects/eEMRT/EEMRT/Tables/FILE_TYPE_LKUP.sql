CREATE TABLE eemrt.file_type_lkup (
  file_type_id NUMBER NOT NULL,
  description VARCHAR2(1000 BYTE),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP
);