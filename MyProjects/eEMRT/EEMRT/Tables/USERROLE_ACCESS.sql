CREATE TABLE eemrt.userrole_access (
  "ID" NUMBER NOT NULL,
  rolename VARCHAR2(200 BYTE),
  userfunctionid NUMBER,
  userpermissionid NUMBER,
  created_by VARCHAR2(20 BYTE),
  created_on DATE,
  modified_by VARCHAR2(20 BYTE),
  modified_on DATE,
  createdby VARCHAR2(20 BYTE),
  createdon DATE,
  modifiedby VARCHAR2(20 BYTE),
  modifiedon DATE,
  CONSTRAINT useraccess_pk PRIMARY KEY ("ID")
);