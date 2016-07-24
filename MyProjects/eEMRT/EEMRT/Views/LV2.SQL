CREATE OR REPLACE FORCE VIEW eemrt.lv1 (username,loggedindatetime,result) AS
select "USERNAME","LOGGEDINDATETIME","RESULT" from USERS_AUDIT  order by LOGGEDINDATETIME desc;
