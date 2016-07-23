CREATE TABLE eemrt.clin_labor_category (
  labor_category_id NUMBER NOT NULL,
  clin_id NUMBER NOT NULL,
  labor_category_title VARCHAR2(200 BYTE),
  std_labor_category_id NUMBER,
  labor_category_low_rate NUMBER(18,2) NOT NULL,
  approval_date DATE,
  comments VARCHAR2(2000 BYTE),
  created_by VARCHAR2(50 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT SYSDATE,
  last_modified_by VARCHAR2(50 BYTE),
  last_modified_on TIMESTAMP,
  labor_category_high_rate NUMBER(18,2),
  labor_category_rate NUMBER(18) NOT NULL,
  labor_category_hours NUMBER,
  contractor VARCHAR2(100 BYTE),
  vendor VARCHAR2(100 BYTE),
  lc_rate_type VARCHAR2(50 BYTE),
  labor_rate_type VARCHAR2(20 BYTE),
  contractor_id NUMBER(*,0),
  CONSTRAINT clin_labor_title_uk1 UNIQUE (clin_id,labor_category_title,labor_rate_type),
  CONSTRAINT labor_category_pk PRIMARY KEY (labor_category_id),
  CONSTRAINT clin_labor_fk1 FOREIGN KEY (clin_id) REFERENCES eemrt.pop_clin (clin_id)
);