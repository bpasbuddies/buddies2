CREATE TABLE eemrt.sub_clin (
  sub_clin_id NUMBER NOT NULL,
  sub_clin_number VARCHAR2(50 BYTE),
  clin_id NUMBER,
  sub_clin_title VARCHAR2(100 BYTE),
  sub_clin_type VARCHAR2(100 BYTE),
  sub_clin_hours NUMBER,
  sub_clin_rate NUMBER(18,2),
  sub_clin_amount NUMBER(18,2),
  created_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT SYSDATE,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  labor_category_id NUMBER,
  labor_rate_type VARCHAR2(20 BYTE),
  CONSTRAINT sub_clin_uk1 UNIQUE (sub_clin_number,clin_id),
  PRIMARY KEY (sub_clin_id),
  CONSTRAINT fk_clin_id FOREIGN KEY (clin_id) REFERENCES eemrt.pop_clin (clin_id)
);