CREATE OR REPLACE PROCEDURE eemrt.SP_GET_User_Info(
    p_User_id Varchar2, p_Password Varchar2
    ,REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_User_Info
  Author: Sridhar Kommana
  Date Created : 11/05/2014
  Purpose:  Get user info after a successful AD authentication
  Update history:
  sridhar kommana :
  1) 04/30/2015 : Added more logs to Audit
  */
vCount Number ;
vStatus VARCHAR2(20);
vRole  VARCHAR2(20);

BEGIN

  select count(*) into vCount from users where upper(UserName) = upper(p_User_id);
  if vCount > 0 then

    SELECT ur.Role 
    into vRole
    FROM userRole ur 
    WHERE ur.userName = p_User_id;
    SP_INSERT_AUDIT(p_User_id, 'User successfully Logged in Role '||vRole);    
    OPEN REC_CURSOR FOR SELECT  u.UserName,  u.FirstName, 
     u.MiddleInitial, u.LastName , u.EMAIL, ur.Role user_type, u.FirstName || ' ' || u.MiddleInitial || ' ' || u.LastName   as  Full_Name, 'SUCCESS' as Status
    FROM users u, userRole ur 
    WHERE u.userName = ur.UserName    
    AND  u.UserName = p_User_id
    ORDER BY 1;
    RETURN;
  else
    SP_INSERT_AUDIT(p_User_id, 'Not valid user in ECert');
/* if no valid users ......*/ 
   OPEN REC_CURSOR FOR SELECT 'Invalid User/Password'  as Status from Dual;    
     RETURN;
 end if;
  EXCEPTION WHEN NO_DATA_FOUND then 
    SP_INSERT_AUDIT(p_User_id, 'UserName Not Found in eCert');
    OPEN REC_CURSOR FOR SELECT 'UserName Not Found'  as Status from Dual;    
   RETURN;
  WHEN OTHERS then 
    SP_INSERT_AUDIT(p_User_id, 'Cannot Validate Use in eCert');
    OPEN REC_CURSOR FOR SELECT  'Cannot Validate User'  as Status from Dual;    
   RETURN;
END SP_GET_User_Info;
/