CREATE TABLE eemrt.contractors_t (
  contractor_id NUMBER NOT NULL,
  first_name VARCHAR2(100 BYTE) NOT NULL,
  middle_name VARCHAR2(20 BYTE),
  last_name VARCHAR2(100 BYTE) NOT NULL,
  email VARCHAR2(100 BYTE),
  contract_number VARCHAR2(100 BYTE),
  vendor VARCHAR2(200 BYTE),
  created_by VARCHAR2(20 BYTE),
  created_on TIMESTAMP,
  updated_by VARCHAR2(20 BYTE),
  updated_on TIMESTAMP,
  CONSTRAINT contractors_t_pk PRIMARY KEY (contractor_id)
);