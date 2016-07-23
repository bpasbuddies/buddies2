CREATE TABLE eemrt.std_userroles (
  role_id VARCHAR2(20 BYTE) NOT NULL,
  userrole VARCHAR2(2000 BYTE),
  created_by VARCHAR2(20 BYTE) DEFAULT 'SYS',
  created_on TIMESTAMP DEFAULT sysdate,
  CONSTRAINT std_userroles_pk PRIMARY KEY (role_id)
);