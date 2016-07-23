CREATE OR REPLACE PROCEDURE eemrt.SP_INSERT_AUDIT (P_USERID    VARCHAR2,
                                                   p_result    VARCHAR2)
AS
   PRAGMA AUTONOMOUS_TRANSACTION;
/*
Procedure : SP_INSERT_AUDIT
Author: Sridhar Kommana
Date Created : 11/05/2014
Purpose:  insert activity log
Update history:
sridhar kommana :
1) 04/30/2015 : ADDED PRAGMA AUTONOMOUS_TRANSACTION
2) 05/10/2016 : Added New update statement to support to show user online RTM S01
*/
BEGIN
      BEGIN
         UPDATE users
            SET LastTransaction = SYSDATE
          WHERE upper(username) = upper(P_USERID);

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

   INSERT INTO users_audit (USERNAME, loggedinDateTime, result)
        VALUES (P_USERID, SYSDATE, p_result);

       COMMIT;
    EXCEPTION
       WHEN OTHERS
       THEN
          NULL;

END SP_INSERT_AUDIT;
/