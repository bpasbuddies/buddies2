CREATE TABLE eemrt.program_contracts (
  pgc_id NUMBER NOT NULL,
  pgc_pgm_id NUMBER,
  pgc_contract_number VARCHAR2(200 BYTE),
  pgc_created_by VARCHAR2(20 BYTE),
  pgc_created_on TIMESTAMP DEFAULT SYSDATE,
  pgc_last_modified_by VARCHAR2(20 BYTE),
  pgc_last_modified_on TIMESTAMP,
  CONSTRAINT program_contracts_pk PRIMARY KEY (pgc_id),
  CONSTRAINT fk_contractnumber FOREIGN KEY (pgc_contract_number) REFERENCES eemrt.contract (contract_number),
  FOREIGN KEY (pgc_pgm_id) REFERENCES eemrt."PROGRAM" (pgm_id)
);