CREATE TABLE eemrt.user_userrole_access (
  "ID" NUMBER NOT NULL,
  username VARCHAR2(20 BYTE),
  useraccessid NUMBER,
  created_by VARCHAR2(20 BYTE),
  created_on DATE,
  modified_by VARCHAR2(20 BYTE),
  modified_on DATE,
  createdby VARCHAR2(20 BYTE),
  createdon DATE,
  modifiedby VARCHAR2(20 BYTE),
  modifiedon DATE,
  CONSTRAINT user_useraccess_pk PRIMARY KEY ("ID")
);