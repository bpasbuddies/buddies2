CREATE OR REPLACE PROCEDURE eemrt.sp_get_COs(
    COs_cursor OUT SYS_REFCURSOR)
IS
BEGIN
  OPEN COs_cursor FOR 
      
       select distinct  UPPER(CO_ID) CO_ID, CO_NAME from (
      SELECT 
           CO_ID, CO_NAME 
      FROM CONTRACTING_OFFICERS  
      UNION
      SELECT  
           U.USERNAME CO_ID ,     DECODE(U.MIDDLEINITIAL, NULL, U.FIRSTNAME ||' '|| U.LASTNAME,U.FIRSTNAME || ' ' || U.MIDDLEINITIAL || ' ' || U.LASTNAME )    "CO_NAME"      
      FROM users u, userRole ur 
      WHERE u.userName = ur.UserName 
      AND ROLE='CO' 
--     AND U.USERNAME NOT LIKE  ('% CTR %') 

      )t
      ORDER BY CO_NAME;    
EXCEPTION
WHEN OTHERS THEN
   OPEN COs_cursor FOR  SELECT 1 CO_ID, 1 CO_NAME FROM CONTRACTING_OFFICERS;
END sp_get_COs;
/