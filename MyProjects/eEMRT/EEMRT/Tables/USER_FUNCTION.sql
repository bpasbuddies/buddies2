CREATE TABLE eemrt.user_function (
  "ID" NUMBER NOT NULL,
  token VARCHAR2(50 BYTE),
  "NAME" VARCHAR2(50 BYTE) NOT NULL,
  description VARCHAR2(250 BYTE),
  created_by VARCHAR2(20 BYTE),
  created_on DATE,
  modified_by VARCHAR2(20 BYTE),
  modified_on DATE,
  createdby VARCHAR2(20 BYTE),
  createdon DATE,
  modifiedby VARCHAR2(20 BYTE),
  modifiedon NUMBER,
  CONSTRAINT user_function_pk PRIMARY KEY ("ID")
);