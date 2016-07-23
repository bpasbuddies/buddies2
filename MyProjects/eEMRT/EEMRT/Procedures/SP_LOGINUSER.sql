CREATE OR REPLACE PROCEDURE eemrt.SP_LOGINUSER(
    p_User_id Varchar2  , p_Password Varchar2, p_PStatus OUT VARCHAR2, p_UserName OUT VARCHAR2)
AS
  /*
  Procedure : SP_LOGINUSER
  Author: Sridhar Kommana
  Date Created : 11/05/2014
  Purpose:  Get user login info before AD authentication
  Update history:
  sridhar kommana :
  1) 04/30/2015 : Added more logs to Audit
  */
vCount Number ;
vStatus VARCHAR(20);
BEGIN
  SP_INSERT_AUDIT(p_User_id, 'Login Attempt made');
  p_UserName := NULL;
  select count(*) into vCount from users where  upper(userName) = upper(p_User_id); -- and password= p_Password;
  if vCount > 0 then    
    --select u.FirstName || ' ' || u.MiddleInitial || ' ' || u.LastName into p_UserName from Users u where userName = p_User_id;
    p_PStatus := 'SUCCESS';
   SP_INSERT_AUDIT(p_User_id, 'User found in eCert');
    RETURN;
  else
     SP_INSERT_AUDIT(p_User_id, 'User not found in eCert');
     p_PStatus := 'Invalid User/Password';
     p_UserName := NULL;
     RETURN;
  end if;
  EXCEPTION WHEN NO_DATA_FOUND then 
    SP_INSERT_AUDIT(p_User_id, 'UserName Not Found in eCert');
    p_PStatus := 'UserName Not Found';
    p_UserName := NULL;
   RETURN;
  WHEN OTHERS then 
      SP_INSERT_AUDIT(p_User_id, 'Cannot Validate Use in eCert');
     p_PStatus := 'Cannot Validate User';
     p_UserName := NULL;
    RETURN;
END SP_LOGINUSER;
/