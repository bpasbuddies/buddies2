CREATE TABLE eemrt.contracting_officers_reps (
  cor_id VARCHAR2(20 BYTE) NOT NULL,
  cor_name VARCHAR2(75 BYTE),
  last_modified_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  last_modified_on TIMESTAMP DEFAULT sysdate,
  CONSTRAINT contracting_officers_reps_uk1 UNIQUE (cor_id)
);