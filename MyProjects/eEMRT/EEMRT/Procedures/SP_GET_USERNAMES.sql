CREATE OR REPLACE PROCEDURE eemrt.SP_GET_UserNames(
    REC_CURSOR OUT SYS_REFCURSOR)
AS
vCount Number ;
vStatus VARCHAR(20);
BEGIN
    OPEN REC_CURSOR FOR SELECT  u.UserName,   u.FirstName || ' ' || u.MiddleInitial || ' ' || u.LastName   as  Full_Name
    FROM users u, userRole ur 
    WHERE u.userName = ur.UserName    
    ORDER BY 1;
    RETURN;
  EXCEPTION WHEN NO_DATA_FOUND then 
    OPEN REC_CURSOR FOR SELECT 'UserName Not Found'  as Status from Dual;    
   RETURN;
  WHEN OTHERS then 
    OPEN REC_CURSOR FOR SELECT  'Cannot get Users'  as Status from Dual;    
   RETURN;
END SP_GET_UserNames;
/