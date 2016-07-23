CREATE TABLE eemrt.managers (
  username VARCHAR2(25 BYTE) NOT NULL,
  firstname VARCHAR2(75 BYTE),
  lastname VARCHAR2(75 BYTE),
  middleinitial VARCHAR2(10 BYTE),
  phone VARCHAR2(25 BYTE),
  email VARCHAR2(100 BYTE),
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  status VARCHAR2(10 BYTE),
  routingsymbol VARCHAR2(100 BYTE),
  comments VARCHAR2(2000 BYTE),
  account_status VARCHAR2(20 BYTE),
  created_on DATE,
  mgr_emailid VARCHAR2(200 BYTE)
);