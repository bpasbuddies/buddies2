CREATE TABLE eemrt.entityattachment (
  entityattachment_id NUMBER NOT NULL,
  entitytype_id NUMBER NOT NULL,
  entity_id VARCHAR2(100 BYTE) NOT NULL,
  eattachment BLOB,
  description VARCHAR2(1000 BYTE),
  tablename VARCHAR2(100 BYTE),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  file_type_id NUMBER,
  CONSTRAINT entityattachment_pk PRIMARY KEY (entityattachment_id)
);