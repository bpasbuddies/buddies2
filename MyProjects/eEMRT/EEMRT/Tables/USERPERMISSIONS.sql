CREATE TABLE eemrt.userpermissions (
  "ID" NUMBER NOT NULL,
  "NAME" VARCHAR2(20 BYTE),
  description VARCHAR2(200 BYTE),
  created_by VARCHAR2(20 BYTE),
  created_on DATE,
  modified_by VARCHAR2(20 BYTE),
  modified_on DATE,
  createdby VARCHAR2(20 BYTE),
  createdon DATE,
  modifiedby VARCHAR2(20 BYTE),
  modifiedon DATE,
  CONSTRAINT userpermissions_pk PRIMARY KEY ("ID")
);