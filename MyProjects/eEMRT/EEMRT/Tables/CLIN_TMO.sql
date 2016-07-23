CREATE TABLE eemrt.clin_tmo (
  clin_tmo_id NUMBER NOT NULL,
  clin_id NUMBER NOT NULL,
  clin_title VARCHAR2(200 BYTE),
  clin_type VARCHAR2(200 BYTE),
  clin_amount NUMBER(18,2),
  created_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT SYSDATE,
  updated_by VARCHAR2(50 BYTE),
  updated_on TIMESTAMP DEFAULT SYSDATE,
  clin_number VARCHAR2(200 BYTE),
  CONSTRAINT clin_tmo_pk PRIMARY KEY (clin_tmo_id),
  CONSTRAINT clin_tmo_fk1 FOREIGN KEY (clin_id) REFERENCES eemrt.pop_clin (clin_id) ON DELETE CASCADE
);