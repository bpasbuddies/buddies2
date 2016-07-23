CREATE TABLE eemrt.contracting_officers (
  co_id VARCHAR2(20 BYTE) NOT NULL,
  co_name VARCHAR2(75 BYTE),
  last_modified_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  last_modified_on TIMESTAMP DEFAULT sysdate,
  CONSTRAINT contracting_officers_uk1 UNIQUE (co_id)
);