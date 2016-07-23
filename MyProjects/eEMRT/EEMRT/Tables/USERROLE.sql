CREATE TABLE eemrt.userrole (
  username VARCHAR2(25 BYTE) NOT NULL,
  "ROLE" VARCHAR2(10 BYTE) NOT NULL,
  contract_number VARCHAR2(75 BYTE),
  last_modified_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  last_modified_on TIMESTAMP DEFAULT sysdate,
  CONSTRAINT userrole_uk1 UNIQUE (username)
);