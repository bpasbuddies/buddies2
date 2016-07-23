CREATE TABLE eemrt.entitytype (
  entitytype_id NUMBER NOT NULL,
  description VARCHAR2(1000 BYTE),
  table_name VARCHAR2(100 BYTE),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  CONSTRAINT entitytype_pk PRIMARY KEY (entitytype_id)
);