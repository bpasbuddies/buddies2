CREATE TABLE eemrt.sub_contractor (
  sub_contractor_id NUMBER,
  vendor_name VARCHAR2(200 BYTE),
  contract_number VARCHAR2(100 BYTE),
  poc_fname VARCHAR2(100 BYTE),
  poc_lname VARCHAR2(100 BYTE),
  poc_mname VARCHAR2(100 BYTE),
  small_business VARCHAR2(50 BYTE),
  created_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT SYSDATE,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP
);