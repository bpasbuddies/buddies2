CREATE TABLE eemrt.users_audit (
  username VARCHAR2(100 BYTE),
  loggedindatetime TIMESTAMP(9) DEFAULT sysdate,
  result VARCHAR2(200 BYTE)
);