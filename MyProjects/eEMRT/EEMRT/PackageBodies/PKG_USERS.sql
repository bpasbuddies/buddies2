CREATE OR REPLACE PACKAGE BODY eemrt.PKG_USERS
AS
  /*
  Package Body : PKG_Users
  Author: Sridhar Kommana
  Date Created : 09/14/2015
  Purpose:  All procedures related to users
  Update history:
  10/21/2015 : Added new proc to add new user from AD DB
  04/06/2016 : Added new sp sp_Add_FAA_User requirement id S00 
  04/07/2016 : Added new sp SP_GET_User_Mgr_Info requirement id S00 
  04/11/2016 : Added new sp sp_Find_FAA_User requirement id S00
    04/11/2016 : updated sp sp_Add_FAA_User to send email to the manager requirement id S00 
    04/12/2016 : Added sp sp_update_FAA_User requirement id S00 
    05/05/2016 : Added new procedure sp_get_Contract_Task_access to Get Contract Access records for a user
  05/05/2016 : Srihari Gokina - Added new procedure SP_DELETE_USER 
  06/13/2016 : Sridhar Kommana -- Added decode to routing symbol
     
  */
 PROCEDURE sp_user_Login_update
    (
      p_USER USERS.USERNAME%TYPE
    )
    /*
    Procedure : sp_user_Login_update
    Author: Sridhar Kommana
    Date Created : 05/03/2016
    Purpose:  update last login
    Update history:
 
    */    
  IS
  BEGIN

      UPDATE USERS
      SET LastLogin = SYSDATE()
      WHERE USERNAME     = p_USER;
      IF SQL%FOUND THEN
        COMMIT;
      SP_INSERT_AUDIT(p_USER, 'PKG_USERS.sp_user_Login_update  updated lastlogin for p_USER='|| p_USER||', '||'with success');        
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      SP_INSERT_AUDIT(p_USER, 'PKG_USERS.sp_user_Login_update could not update lastlogin for p_USER='|| p_USER||', '||'SQLERRM='||SQLERRM);
      RETURN ;
 
  END sp_user_Login_update;

PROCEDURE sp_Add_AD_User(
      p_USERNAME USERS.USERNAME%TYPE,
      p_ROLE USERROLE.ROLE%TYPE,
      p_FullName OUT VARCHAR2,
      p_PStatus OUT VARCHAR2)
  IS
    vCount    NUMBER :=0 ;
    vADCount  NUMBER :=0 ;
    vSENDER   VARCHAR2(200);
    vRECEIVER VARCHAR2(200);
    vSUBJECT  VARCHAR2(200);
    vMESSAGE  VARCHAR2(32000);
    vEMAIL    VARCHAR2(1000);
    vFullName VARCHAR2(250);
    v_Instance Varchar2(100);
 
    
  BEGIN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_AD_User p_USERNAME=' ||p_USERNAME);
     select sys_context('USERENV','INSTANCE_NAME')  into  v_Instance from dual;  
    SELECT COUNT(*)
    INTO vADCount
    FROM --AD_USERS
      FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
    WHERE upper(SAMACCOUNTNAME) = Upper(p_USERNAME);
    IF vADCount                 < 1 THEN
      p_PStatus                := 'User '||p_USERNAME||' Not found in FAA Active Directory, Please check your username and try again';
      RETURN ;
    END IF;
    SELECT COUNT(*)
    INTO vCount
    FROM users u
    WHERE upper(u.userName) = Upper(p_USERNAME);
    vSENDER                := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER              := 'sridhar.ctr.kommanaboyina@faa.gov';
    --vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT := 'eemrt User Account Request';
    BEGIN
      IF vCount    > 0 THEN
        p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
        RETURN ;
      END IF;
      INSERT
      INTO USERS
        (
          USERNAME,
          FIRSTNAME,
          LASTNAME,
          MIDDLEINITIAL,
          PHONE,
          EMAIL,
          STATUS,
          RoutingSymbol,
          LAST_MODIFIED_BY,
          LAST_MODIFIED_ON
        )
      SELECT upper(SAMACCOUNTNAME),
        FIRSTNAME,
        LASTNAME,
        MIDDLEINITIAL,
        OFFICEPHONENUMBER,
        INTERNETADDRESS,
        'Pending',
        ---level5,
         DECODE(level5 , NULL, level6, level5)  ,
 

        p_USERNAME,
        SYSDATE()
      FROM  FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
      WHERE upper(SAMACCOUNTNAME) = Upper(p_USERNAME);
      IF SQL%FOUND THEN
        --   p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
      RETURN ;
    WHEN OTHERS THEN
      SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_AD_User p_USERNAME=' ||p_USERNAME ||'Error = '|| SQLERRM);
      p_PStatus := 'Error inserting User ' || SQLERRM ;
      RETURN ;
    END;
    --USERROLE
    INSERT
    INTO USERROLE
      (
        USERNAME,
        ROLE,
        LAST_MODIFIED_BY,
        LAST_MODIFIED_ON
      )
      VALUES
      (
        upper(p_USERNAME),
        p_ROLE,
        p_USERNAME,
        SYSDATE()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ; -- TODO modify the message to commented skommana 10212015
      COMMIT;
      SELECT FIRSTNAME
        || ' '
        || NVL(MIDDLEINITIAL,' ')
        ||''
        || LASTNAME
      INTO vFullName
      FROM Users
      WHERE username = upper(p_USERNAME);
      p_FullName    := vFullName ;
      --  vMESSAGE  := 'A new account request has been received for '||p_FIRSTNAME||' ' || p_MIDDLEINITIAL||' '|| p_LASTNAME ||' requesting the role of '||p_ROLE||' in eemrt.  Please login to review and process the request';
      vMESSAGE := 'A new account request has been received for '||vFullName ||' requesting the role of '||p_ROLE||' in eemrt on the instance '||v_Instance|| '.  Please login to review and process the request';
      SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
      SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Nicole.CTR.St.Cyr@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error inserting User Role ' || SQLERRM ;
  END sp_Add_AD_User;
   
PROCEDURE sp_Find_FAA_User(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        p_PStatus OUT VARCHAR2)
  IS
    vCount    NUMBER :=0 ;
    vADCount  NUMBER :=0 ;
    vMGRCount  NUMBER :=0 ;
    vSENDER   VARCHAR2(200);
    vRECEIVER VARCHAR2(200);
    vSUBJECT  VARCHAR2(200);
    vMESSAGE  VARCHAR2(32000);
    vEMAIL    VARCHAR2(1000);
    vFullName VARCHAR2(250);
  v_Instance Varchar2(100);
 
    
  BEGIN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User p_USERNAME=' ||p_USERNAME);
     select sys_context('USERENV','INSTANCE_NAME')  into  v_Instance from dual;  
     
    SELECT COUNT(*)
    INTO vCount
    FROM users u
    WHERE upper(u.userName) = Upper(p_USERNAME);
    
   /* IF vCount                  > 0 THEN
      p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
      RETURN;
    END IF;
     */ 
    SELECT COUNT(*)
    INTO vADCount
    FROM --AD_USERS
      FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
    WHERE upper(SAMACCOUNTNAME) = Upper(p_USERNAME);
    IF vADCount                 < 1 THEN
      p_PStatus                := 'User '||p_USERNAME||' Not found in FAA Active Directory, Please check your username and try again';
      RETURN ;
    END IF;

--Check FAA manager email address if exists 
    SELECT COUNT(*)
    INTO vMGRCount
    FROM --AD_USERS
      FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
    WHERE Upper(INTERNETADDRESS) = Upper(p_MGR_EMAIL);
    IF vMGRCount                 < 1 THEN
      p_PStatus                := 'EMAIL '||p_MGR_EMAIL||' Not found in FAA Active Directory, Please check manager email id and try again';
      RETURN ;
    END IF;
    
    SELECT COUNT(*)
    INTO vCount
    FROM users u
    WHERE upper(u.userName) = Upper(p_USERNAME);
    vSENDER                := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER              := 'sridhar.ctr.kommanaboyina@faa.gov';
    --vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT := 'eemrt User Account Request';
    /*
    BEGIN
      IF vCount    > 0 THEN
        p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
        RETURN ;
      END IF;
      INSERT
      INTO USERS
        (
          USERNAME,
          FIRSTNAME,
          LASTNAME,
          MIDDLEINITIAL,
          PHONE,
          EMAIL,
          STATUS,
          RoutingSymbol,
          MGR_EMAILID,
          LAST_MODIFIED_BY,
          LAST_MODIFIED_ON
        )
      SELECT upper(SAMACCOUNTNAME),
        FIRSTNAME,
        LASTNAME,
        MIDDLEINITIAL,
        OFFICEPHONENUMBER,
        INTERNETADDRESS,
        'Created',
        level5,
        p_MGR_EMAIL,
        p_USERNAME,
        SYSDATE()
      FROM  FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
      WHERE upper(SAMACCOUNTNAME) = Upper(p_USERNAME);
      IF SQL%FOUND THEN
        --   p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
      RETURN ;
    WHEN OTHERS THEN
      SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User p_USERNAME=' ||p_USERNAME ||'Error = '|| SQLERRM);
      p_PStatus := 'Error inserting User ' || SQLERRM ;
      RETURN ;
    END;
    --USERROLE
    INSERT
    INTO USERROLE
      (
        USERNAME,
        ROLE,
        LAST_MODIFIED_BY,
        LAST_MODIFIED_ON
      )
      VALUES
      (
        upper(p_USERNAME),
        p_ROLE,
        p_USERNAME,
        SYSDATE()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ; -- TODO modify the message to commented skommana 10212015
      COMMIT;
    END IF;
      EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error inserting User Role ' || SQLERRM ;
    
    ---Insert MGR record
    vMGRCount := 0;
    SELECT COUNT(*)
    INTO vMGRCount
    FROM Managers M 
    WHERE upper(M.EMAIL) = Upper(p_MGR_EMAIL);
    */
   /* 
    IF vMGRCount    = 0 THEN 
    BEGIN 
      INSERT
      INTO Managers
        (
          USERNAME,
          FIRSTNAME,
          LASTNAME,
          MIDDLEINITIAL,
          PHONE,
          EMAIL,
          STATUS,
          RoutingSymbol,
          MGR_EMAILID,
          LAST_MODIFIED_BY,
          LAST_MODIFIED_ON
        )
      SELECT upper(SAMACCOUNTNAME),
        FIRSTNAME,
        LASTNAME,
        MIDDLEINITIAL,
        OFFICEPHONENUMBER,
        INTERNETADDRESS,
        'Created',
        level5,
        p_MGR_EMAIL,
        p_USERNAME,
        SYSDATE()
      FROM  FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
      WHERE upper(INTERNETADDRESS) = Upper(p_MGR_EMAIL);
      IF SQL%FOUND THEN
        --   p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
      RETURN ;
    WHEN OTHERS THEN
      SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User p_USERNAME=' ||p_USERNAME ||'Error = '|| SQLERRM);
      p_PStatus := 'Error inserting User ' || SQLERRM ;
      RETURN ;
    END;
     
  ELSE
      SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User Manager already inserted =' ||p_USERNAME ||'p_MGR_EMAIL = '|| p_MGR_EMAIL);
  END IF;
*/
p_PStatus := 'SUCCESS' ;
  END sp_Find_FAA_User;
   
PROCEDURE sp_Add_FAA_User(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        p_UserStatus VARCHAR2,                       
                        p_PStatus OUT VARCHAR2)
  IS
    vCount    NUMBER :=0 ;
    vADCount  NUMBER :=0 ;
    vMGRCount  NUMBER :=0 ;
    vSENDER   VARCHAR2(200);
    vRECEIVER VARCHAR2(200);
    vSUBJECT  VARCHAR2(200);
    vMESSAGEHTML  VARCHAR2(32000);
    vEMAIL    VARCHAR2(1000);
    vFullName VARCHAR2(250);
  v_Instance Varchar2(100);
 
    
  BEGIN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User p_USERNAME=' ||p_USERNAME);
     select sys_context('USERENV','INSTANCE_NAME')  into  v_Instance from dual;  
    SELECT COUNT(*)
    INTO vADCount
    FROM --AD_USERS
      FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
    WHERE upper(SAMACCOUNTNAME) = Upper(p_USERNAME);
    IF vADCount                 < 1 THEN
      p_PStatus                := 'User '||p_USERNAME||' Not found in FAA Active Directory, Please check your username and try again';
      RETURN ;
    END IF;

--Check FAA manager email address if exists 
    SELECT COUNT(*)
    INTO vMGRCount
    FROM --AD_USERS
      FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
    WHERE Upper(INTERNETADDRESS) = Upper(p_MGR_EMAIL);
    IF vMGRCount                 < 1 THEN
      p_PStatus                := 'EMAIL '||p_MGR_EMAIL||' Not found in FAA Active Directory, Please check manager email id and try again';
      RETURN ;
    END IF;
    
    SELECT COUNT(*)
    INTO vCount
    FROM users u
    WHERE upper(u.userName) = Upper(p_USERNAME);
    vSENDER                := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER              := 'sridhar.ctr.kommanaboyina@faa.gov';
    --vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT := 'eemrt User Account Request';
    BEGIN
      IF vCount    > 0 THEN
        p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
        RETURN ;
      END IF;
      INSERT
      INTO USERS
        (
          USERNAME,
          FIRSTNAME,
          LASTNAME,
          MIDDLEINITIAL,
          PHONE,
          EMAIL,
          STATUS,
          RoutingSymbol,
          MGR_EMAILID,
        --  EMPLOYEE_TYPE,
          LAST_MODIFIED_BY,
          LAST_MODIFIED_ON
        )
      SELECT upper(SAMACCOUNTNAME),
        FIRSTNAME,
        LASTNAME,
        MIDDLEINITIAL,
        OFFICEPHONENUMBER,
        INTERNETADDRESS,
        p_UserStatus,
        --level5,
        DECODE(level5 , NULL, level6, level5) ,        
        p_MGR_EMAIL,
       --DECODE(intstr(p_USERNAME,'CTR'),1, 'Contractor','FED'),
        p_USERNAME,
        SYSDATE()
      FROM  FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
      WHERE upper(SAMACCOUNTNAME) = Upper(p_USERNAME);
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
      RETURN ;
    WHEN OTHERS THEN
      SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User p_USERNAME=' ||p_USERNAME ||'Error = '|| SQLERRM);
      p_PStatus := 'Error inserting User ' || SQLERRM ;
      RETURN ;
    END;
    --USERROLE
/*    INSERT
    INTO USERROLE
      (
        USERNAME,
        ROLE,
        LAST_MODIFIED_BY,
        LAST_MODIFIED_ON
      )
      VALUES
      (
        upper(p_USERNAME),
        p_ROLE,
        p_USERNAME,
        SYSDATE()
      );
      
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ; 
      COMMIT;
    END IF;
      EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error inserting User Role ' || SQLERRM ;

*/
--Start sending email here
      SELECT FIRSTNAME
        || ' '
        || NVL(MIDDLEINITIAL,' ')
        ||''
        || LASTNAME
      INTO vFullName
      FROM Users
      WHERE username = upper(p_USERNAME);
              vSUBJECT := 'Approval for eemrt User Account.';
              vSENDER := 'sridhar.ctr.kommanaboyina@faa.gov';
              vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
              vMESSAGEHTML  := 'A request from '||vFullName||' for the role of '||p_ROLE||' has been received to access the electronic Contract Enterprise Reporting Tool (eemrt).  The request requires the approval of a Manager in order to proceed.</br></br>'||'Please select the <a href="http://jactdfdvap346.act.faa.gov:8080/eemrtWeb/UserRoles/ApproveAccountRequest.aspx?username='||p_USERNAME||'='||trunc(sysdate)||'">eemrt</a> link to process the request.</br></br>'||'If you have received this request in error or have additional questions, please contact the <a href="mailto:sjawn.h.wade@faa.gov">eemrt Administrator</a>. ';
            --vMESSAGEHTML  := 'A request from '||vFullName||' for the role of '||p_ROLE||' has been received to access the electronic Contract Enterprise Reporting Tool (eemrt).  The request requires the approval of a Manager in order to proceed.</br></br>'||'Please select the <a href="http://localhost:56781/eemrtWeb/UserRoles/ApproveAccountRequest.aspx?username='||p_USERNAME||'='||trunc(sysdate)||'">eemrt</a> link to process the request.</br></br>'||'If you have received this request in error or have additional questions, please contact the <a href="mailto:sjawn.h.wade@faa.gov">eemrt Administrator</a>. ';
            
              SP_SEND_HTML_EMAIL(
                P_FROM => vSENDER,
                P_TO => vRECEIVER,    
                P_SUBJECT => vSUBJECT,                
                P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eemrt Admin');
                vRECEIVER := 'sai.laxman.ctr.allu@faa.gov';
              SP_SEND_HTML_EMAIL(
                P_FROM => vSENDER,
                P_TO => vRECEIVER,    
                P_SUBJECT => vSUBJECT,                
                P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eemrt Admin');

--End of email send
      
    
    ---Insert MGR record
    vMGRCount := 0;
    SELECT COUNT(*)
    INTO vMGRCount
    FROM Managers M 
    WHERE upper(M.EMAIL) = Upper(p_MGR_EMAIL);
    
    IF vMGRCount    = 0 THEN 
    BEGIN 
      INSERT
      INTO Managers
        (
          USERNAME,
          FIRSTNAME,
          LASTNAME,
          MIDDLEINITIAL,
          PHONE,
          EMAIL,
          STATUS,
          RoutingSymbol,
          MGR_EMAILID,
          LAST_MODIFIED_BY,
          LAST_MODIFIED_ON
        )
      SELECT upper(SAMACCOUNTNAME),
        FIRSTNAME,
        LASTNAME,
        MIDDLEINITIAL,
        OFFICEPHONENUMBER,
        INTERNETADDRESS,
        'Created',
        --level5,
        DECODE(level5 , NULL, level6, level5) ,        
        p_MGR_EMAIL,
        p_USERNAME,
        SYSDATE()
      FROM  FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
      WHERE upper(INTERNETADDRESS) = Upper(p_MGR_EMAIL);
      IF SQL%FOUND THEN
        --   p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
    NULL;
      --p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
      RETURN ;
    WHEN OTHERS THEN
      SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User p_USERNAME=' ||p_USERNAME ||'Error = '|| SQLERRM);
      p_PStatus := 'Error inserting User ' || SQLERRM ;
      RETURN ;
    END;
     
  ELSE
      SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_Add_FAA_User Manager already inserted =' ||p_USERNAME ||'p_MGR_EMAIL = '|| p_MGR_EMAIL);
  END IF;

  END sp_Add_FAA_User;
  
PROCEDURE sp_Add_User(
      p_USERNAME USERS.USERNAME%TYPE,
      p_FIRSTNAME USERS.FIRSTNAME%TYPE,
      p_LASTNAME USERS.LASTNAME%TYPE,
      p_MIDDLEINITIAL USERS.MIDDLEINITIAL%TYPE,
      p_PHONE USERS.PHONE%TYPE,
      p_EMAIL USERS.EMAIL%TYPE,
      p_LAST_MODIFIED_BY USERS.LAST_MODIFIED_BY%TYPE,
      p_ROLE USERROLE.ROLE%TYPE,
      p_RoutingSymbol USERS.RoutingSymbol%TYPE,
      p_PStatus OUT VARCHAR2 )
  IS
    vCount    NUMBER :=0 ;
    vSENDER   VARCHAR2(200);
    vRECEIVER VARCHAR2(200);
    vSUBJECT  VARCHAR2(200);
    vMESSAGE  VARCHAR2(32000);
    vEMAIL    VARCHAR2(1000);
  BEGIN
    SP_INSERT_AUDIT(p_LAST_MODIFIED_BY, 'sp_Add_User p_USERNAME=' ||p_USERNAME);
    SELECT COUNT(*)
    INTO vCount
    FROM users u
    WHERE u.userName = p_USERNAME;
    vSENDER         := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER       := 'sridhar.ctr.kommanaboyina@faa.gov';
    --vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT := 'eemrt User Account Request';
    BEGIN
      IF vCount    > 0 THEN
        p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
        RETURN ;
      END IF;
      INSERT
      INTO USERS
        (
          USERNAME,
          FIRSTNAME,
          LASTNAME,
          MIDDLEINITIAL,
          PHONE,
          EMAIL,
          STATUS,
          RoutingSymbol,
          LAST_MODIFIED_BY,
          LAST_MODIFIED_ON
        )
        VALUES
        (
          p_USERNAME,
          p_FIRSTNAME,
          p_LASTNAME,
          p_MIDDLEINITIAL,
          p_PHONE,
          p_EMAIL,
          'Pending',
          p_RoutingSymbol,
          p_LAST_MODIFIED_BY,
          SYSDATE()
        );
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      p_PStatus := 'User '||p_USERNAME||' is already found in eemrt';
      RETURN ;
    WHEN OTHERS THEN
      SP_INSERT_AUDIT(p_LAST_MODIFIED_BY, 'sp_Add_User p_USERNAME=' ||p_USERNAME ||'Error = '|| SQLERRM);
      
      p_PStatus := 'Error inserting User ' || SQLERRM ;
      RETURN ;
    END;
    --USERROLE
    INSERT
    INTO USERROLE
      (
        USERNAME,
        ROLE,
        LAST_MODIFIED_BY,
        LAST_MODIFIED_ON
      )
      VALUES
      (
        p_USERNAME,
        p_ROLE,
        p_LAST_MODIFIED_BY,
        SYSDATE()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      vMESSAGE  := 'A new account request has been received for '||p_FIRSTNAME||' ' || p_MIDDLEINITIAL||' '|| p_LASTNAME ||' requesting the role of '||p_ROLE||' in eemrt.  Please login to review and process the request';
      COMMIT;
      SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
      SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Nicole.CTR.St.Cyr@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
      
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error inserting User Role ' || SQLERRM ;
  END sp_Add_User;
 
PROCEDURE sp_update_User
    (
      p_Admin USERS.USERNAME%TYPE,
      p_USER USERS.USERNAME%TYPE,
      p_ROLE USERROLE.ROLE%TYPE,
      p_Request_Status USERS.STATUS%TYPE,
      p_Comments USERS.Comments%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
    vCount         NUMBER :=0 ;
    vSENDER        VARCHAR2(200);
    vRECEIVER      VARCHAR2(200);
    vSUBJECT       VARCHAR2(200);
    vMESSAGE       VARCHAR2(32000);
    vEMAIL         VARCHAR2(1000);
    vAccountStatus VARCHAR2(20):=NULL;
  BEGIN
    IF p_Request_Status            = 'Approved' THEN
      vAccountStatus              := 'Active';
      vMESSAGE                    := 'Your access to eemrt has been approved for the role of '||p_ROLE||'.  You can access eemrt via this link http://'||GET_SITE_IP||'/eemrtHome/default.aspx. Please review the User Guide for instructions on how to use eemrt.  Please contact the eemrt Administrator if you are unable to log in.';
    Elsif p_Request_Status         = 'Denied' THEN
      IF LTRIM(RTRIM(p_Comments)) IS NULL OR LTRIM(RTRIM(p_Comments)) = '' THEN
        p_PStatus                 := 'Error updating, Please provide a reason in comments section for denying the request.';
        RETURN ;
      END IF;
      vAccountStatus := 'Cancelled';
      vMESSAGE       := 'Your access to eemrt has been denied for the role of '||p_ROLE||' or the following reason. "'||p_Comments||'" Please contact the eemrt Administrator for any further questions.';
    ELSE
      vAccountStatus := 'Pending';
    END IF;
    SP_INSERT_AUDIT(p_Admin, 'PKG_USERS.sp_update_User '|| p_Admin||', '||p_USER||', '||p_Role||', '||p_Request_Status||', '||p_Comments);
    SELECT u.EMAIL INTO vEMAIL FROM users u WHERE u.UserName = p_USER;
    vSENDER   := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER := vEMAIL ;--'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT  := 'eemrt User Account Update';
    BEGIN
      UPDATE USERS
      SET Account_STATUS = vAccountStatus,
        Status           = p_Request_Status,
        Comments         = p_Comments,
        LAST_MODIFIED_BY = p_Admin,
        LAST_MODIFIED_ON = SYSDATE()
      WHERE USERNAME     = p_USER;
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      p_PStatus := 'Error updating User ' || SQLERRM ;
      RETURN ;
    END;
    --USERROLE
    UPDATE USERROLE
    SET ROLE           = p_ROLE,
      LAST_MODIFIED_BY = p_Admin,
      LAST_MODIFIED_ON = SYSDATE()
    WHERE USERNAME     = p_USER;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
      IF (p_Request_Status = 'Approved' OR p_Request_Status = 'Denied') THEN
        SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
        SP_INSERT_AUDIT(p_Admin, 'PKG_USERS.sp_update_User Email Sent '|| vSENDER||', '||vRECEIVER||', '||vSUBJECT);
      END IF;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error updating User Role ' || SQLERRM ;
  END sp_update_User;
 
PROCEDURE SP_DELETE_USER
    (
      p_Admin USERS.USERNAME%TYPE,
      p_USER USERS.USERNAME%TYPE,
      p_Comments USERS.Comments%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
    vSENDER        VARCHAR2(200);
    vRECEIVER      VARCHAR2(200);
    vSUBJECT       VARCHAR2(200);
    vMESSAGE       VARCHAR2(32000);
    vEMAIL         VARCHAR2(1000);
    vAccountStatus VARCHAR2(20);
    vStatus VARCHAR2(20);
  BEGIN
       vAccountStatus   := 'Inactivate';
       vStatus          :='Deleted';
       vMESSAGE         := 'Your access to eemrt has been Deleted. You can not access eemrt. Please contact the eemrt Administrator if you questions.';

    SP_INSERT_AUDIT(p_Admin, 'PKG_USERS.SP_DELETE_USER '|| p_Admin||', '||p_USER||', '||p_Comments);
    SELECT u.EMAIL INTO vEMAIL FROM users u WHERE u.UserName = p_USER;
    vSENDER   := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER := vEMAIL ;--'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT  := 'eemrt User Account Deleted';
    BEGIN
      UPDATE USERS 
      SET Account_STATUS = vAccountStatus,
          Status           = vStatus,
          Comments         = p_Comments,
        LAST_MODIFIED_BY = p_Admin,
        LAST_MODIFIED_ON = SYSDATE()
      WHERE USERNAME     = p_USER;
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      p_PStatus := 'Error Deleting/updating User ' || SQLERRM ;
      RETURN ;
    END;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
       SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
       SP_INSERT_AUDIT(p_Admin, 'PKG_USERS.SP_DELETE_USER Email Sent '|| vSENDER||', '||vRECEIVER||', '||vSUBJECT);

    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error Deleting/updating User Role ' || SQLERRM ;
  END SP_DELETE_USER;
 
PROCEDURE SP_GET_User_Info(
      p_User_id  VARCHAR2,
      p_Password VARCHAR2 ,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
    /*
    Procedure : SP_GET_User_Info
    Author: Sridhar Kommana
    Date Created : 11/05/2014
    Purpose:  Get user info after a successful AD authentication
    Update history:
    sridhar kommana :
    1) 04/30/2015 : Added more logs to Audit
    2) 10/27/2015 : Added check for user status
    
    
    */
    vCount  NUMBER ;
    vStatus VARCHAR2(20);
    vRole   VARCHAR2(20);
  BEGIN
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_User_Info Get user info after a successful AD authentication');
    SELECT COUNT(*)
    INTO vCount
    FROM users
    WHERE upper(UserName) = upper(p_User_id)
    AND Status = 'Approved'
    AND account_status='Active'    ;
    IF vCount             > 0 THEN
      SELECT ur.Role INTO vRole FROM userRole ur WHERE ur.userName = p_User_id;
      SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.SP_GET_User_Info User successfully Logged in Role '||vRole);
      OPEN REC_CURSOR FOR 
      SELECT u.UserName,
      u.FirstName,
      u.MiddleInitial,
      u.LastName ,
      u.EMAIL,
      ur.Role user_type,
      u.FirstName || ' ' || u.MiddleInitial || ' ' || u.LastName   AS      Full_Name,
      'SUCCESS' AS Status,
      lastLogin ,APPROVAL_DATE
      FROM users u,
      userRole ur 
    WHERE u.userName = ur.UserName 
    AND u.UserName = p_User_id 
   -- AND STATUS = 'Approved'
    ORDER BY 1;
      RETURN;
    ELSE
      SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_User_Info Not a valid user in eemrt');
      /* if no valid users ......*/
      OPEN REC_CURSOR FOR SELECT null as UserName,
       null as FirstName,
      null as MiddleInitial,
      null as LastName ,
      null as EMAIL,
      null as  user_type,
      null as   Full_Name,
      'Invalid User in eemrt ' AS Status ,
      NULL as lastLogin 
   FROM Dual;
      RETURN;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.SP_GET_User_Info UserName Not Found in eemrt');
    OPEN REC_CURSOR FOR SELECT null as UserName,
       null as FirstName,
      null as MiddleInitial,
      null as LastName ,
      null as EMAIL,
      null as  user_type,
      null as   Full_Name,
      'Invalid User in eemrt ' AS Status ,
      NULL as lastLogin 
   FROM Dual;
    RETURN;
  WHEN OTHERS THEN
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.SP_GET_User_Info Cannot Validate Use in eemrt');
    OPEN REC_CURSOR FOR SELECT null as UserName,
       null as FirstName,
      null as MiddleInitial,
      null as LastName ,
      null as EMAIL,
      null as  user_type,
      null as   Full_Name,
      'Invalid User in eemrt ' AS Status ,
      NULL as lastLogin 
   FROM Dual;
    RETURN;
  END SP_GET_User_Info;
  
PROCEDURE SP_GET_User_Information(
    p_User_id VARCHAR2,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_User_Information
  Author: Sridhar Kommana
  Date Created : 04/11/2016
  Purpose:  Get user info for a given username
  Update history:
  Sridhar Kommana 04/15/2016  Added new columns  u.created_on, su.role_id , role_description 
  Sridhar Kommana 04/21/2016  changed to outer join for userRole table as the role is not yet inserted.  
  */
  vCount  NUMBER ;
  vStatus VARCHAR2(20);
  vRole   VARCHAR2(20);
  v_User_id   VARCHAR2(200);
BEGIN
 -- SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_User_Information Get user info');
  v_User_id := Replace(p_User_id,'-' ,'');
  SP_INSERT_AUDIT(v_User_id, 'PKG_USERS.sp_GET_User_Information Get user info');
  SELECT COUNT(*)
  INTO vCount
  FROM users
  WHERE upper(UserName) = upper(v_User_id);
  --AND Status = 'Approved';
  IF vCount > 0 THEN
   -- SELECT ur.Role INTO vRole FROM userRole ur WHERE ur.userName = p_User_id;
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_User_Information  '||vRole);
    OPEN REC_CURSOR FOR SELECT u.UserName,
    u.FirstName,
    u.MiddleInitial,
    u.LastName ,
    u.EMAIL,
    u.Phone,
    ur.Role user_type,
    u.FirstName || ' ' || u.MiddleInitial || ' ' || u.LastName AS full_Name,    'SUCCESS'  AS Status, NVL(M.Username, 'MGR')   AS    mgr_id , 
    u.routingsymbol , 
    u.created_on, 
    su.role_id , 
    su.userrole role_description ,
    lastLogin , u.account_status, u.comments, APPROVAL_DATE, u.LAST_MODIFIED_BY, u.LAST_MODIFIED_ON, u.STATUS, u.MGR_EMAILID
    FROM users u,
    userRole ur ,
    managers m , Std_Userroles su
    WHERE u.userName = ur.UserName(+)
    AND m.email(+)=U.Mgr_Emailid 
    AND su.role_id(+) = ur.Role
    AND upper(u.UserName) = upper(v_User_id) 
    ORDER BY 1;
    RETURN;
  ELSE
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_User_Information Not a valid user in eemrt');
    /* if no valid users ......*/
    OPEN REC_CURSOR FOR SELECT 'Invalid User in eemrt '
  AS
    Status FROM Dual;
    RETURN;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_User_Information UserName Not Found in eemrt');
  OPEN REC_CURSOR FOR SELECT 'UserName Not Found' AS   Status FROM Dual;
  RETURN;
WHEN OTHERS THEN
  SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_User_Information Cannot Validate Use in eemrt');
  OPEN REC_CURSOR FOR SELECT 'Cannot Validate User' AS   Status FROM Dual;
  RETURN;
END SP_GET_User_Information;
    
PROCEDURE SP_GET_User_Mgr_Info(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        REC_CURSOR OUT SYS_REFCURSOR)
  AS
    /*
    Procedure : SP_GET_User_Mgr_Info
    Author: Sridhar Kommana
    Date Created : 04/06/2016
    Purpose:  Get user info and manager information
    Update history:
    
    */
    vCount  NUMBER ;
    vStatus VARCHAR2(20);
    vRole   VARCHAR2(20);
  BEGIN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_User_Mgr_Info Get user info after a successful AD authentication');
   
    
    
      OPEN REC_CURSOR FOR 
      SELECT 
        upper(SAMACCOUNTNAME) UserName,
        FIRSTNAME,
        LASTNAME,
        MIDDLEINITIAL,
         FirstName || ' ' ||  MiddleInitial || ' ' || LastName AS Full_Name,
        OFFICEPHONENUMBER Phone,
        INTERNETADDRESS EMAIL,
         --level5 Routingsymbol
         DECODE(level5 , NULL, level6, level5) as Routingsymbol
   
         
      FROM  FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
      WHERE upper(SAMACCOUNTNAME) = Upper(p_USERNAME)
 
 UNION ALL
 
    SELECT  upper(SAMACCOUNTNAME) UserName,
        FIRSTNAME,
        LASTNAME,
        MIDDLEINITIAL,
         FirstName || ' ' ||  MiddleInitial || ' ' || LastName AS Full_Name,
        OFFICEPHONENUMBER Phone,
        INTERNETADDRESS EMAIL,
       --  level5 Routingsymbol
         DECODE(level5 , NULL, level6, level5) as Routingsymbol          
         FROM
    FAA_PROFILE.PUBLICPROFILEVIEW@PEIS
    WHERE Upper(INTERNETADDRESS) = Upper(p_MGR_EMAIL);
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_User_Mgr_Info UserName Not Found in AD');
    OPEN REC_CURSOR FOR SELECT 'User Not Found'  AS Status FROM Dual;
    RETURN;
  WHEN OTHERS THEN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_User_Mgr_Info Cannot Validate Use in AD');
    OPEN REC_CURSOR FOR 
    SELECT 'Cannot Validate User'  AS   Status FROM Dual;
    RETURN;
  END SP_GET_User_Mgr_Info;
 
PROCEDURE SP_GET_App_User_Mgr_Info(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        REC_CURSOR OUT SYS_REFCURSOR)
  AS
    /* Procedure : SP_GET_App_User_Mgr_Info
           Author: Srihari Gokina
    Date Created : 05/04/2016
          Purpose: Get user info and manager information from Local Tables Users 
   Update history:     
              05/09/2016 Added new column return APPROVAL_DATE
    */
    
    vCount  NUMBER ;
    vStatus VARCHAR2(20);
    vRole   VARCHAR2(20);
  BEGIN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_App_User_Mgr_Info Get user info From Local Tables (USERS )');
    
      OPEN REC_CURSOR FOR 
      SELECT UPPER(USERNAME) UserName, FIRSTNAME, LASTNAME, MIDDLEINITIAL, FirstName || ' ' ||  MiddleInitial || ' ' || LastName AS Full_Name,
             PHONE Phone, EMAIL, ROUTINGSYMBOL, COMMENTS, CREATED_ON CREATEDON,APPROVAL_DATE
       FROM USERS
       WHERE upper(USERNAME) = Upper(p_USERNAME) 
 UNION ALL 
      SELECT USERNAME, FIRSTNAME, LASTNAME, MIDDLEINITIAL, 
             FirstName || ' ' ||  MiddleInitial || ' ' || LastName AS Full_Name, 
             PHONE Phone, EMAIL, ROUTINGSYMBOL, COMMENTS, CREATED_ON CREATEDON, null as APPROVAL_DATE
      FROM MANAGERS
      WHERE Upper(EMAIL) = Upper(p_MGR_EMAIL);
    
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_App_User_Mgr_Info UserName Not Found in Local Table USERS');
       OPEN REC_CURSOR FOR SELECT 'User Not Found'  AS Status FROM Dual;
       RETURN;
  WHEN OTHERS THEN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_App_User_Mgr_Info Having Issues in getting User info from Local Tables');
    OPEN REC_CURSOR FOR 
    SELECT 'Issue Getting User Info'  AS   Status FROM Dual;
    RETURN;
  END SP_GET_App_User_Mgr_Info;
  
PROCEDURE SP_LOGIN_Email_USER(
      p_Email VARCHAR2 ,
      p_UserName OUT VARCHAR2)
  AS
    /*
    Procedure : SP_LOGIN_Email_USER
    Author: Sridhar Kommana
    Date Created : 10/13/2015
    Purpose:  Get user login info before AD authentication
    Update history:
    sridhar kommana :
    1) 04/30/2015 : Added more logs to Audit
    2) 05/03/2016 : Added call to  sp_user_Login_update(vUser) to update last login for RTM_ID S01
    */
    vCount  NUMBER ;
    vUser   VARCHAR2(20);
    vStatus VARCHAR(20);
  BEGIN
    SP_INSERT_AUDIT(p_Email, 'PKG_USERS.SP_LOGIN_Email_USER Login Attempt made');
    p_UserName := 'INVALID';
    SELECT COUNT(*),
      Username
    INTO vCount,
      vUser
    FROM users
    WHERE upper(EMAIL) = upper(p_Email)
    GROUP BY Username;
    IF vCount     > 0 THEN
      p_UserName := vUser;
      SP_INSERT_AUDIT(p_Email, 'PKG_USERS.SP_LOGIN_Email_USER User found in eemrt');
      sp_user_Login_update(vUser);
      RETURN;
    ELSE
      SP_INSERT_AUDIT(p_Email, 'PKG_USERS.SP_LOGIN_Email_USER User not found in eemrt');
      p_UserName := 'INVALID';
      RETURN;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(p_Email, 'PKG_USERS.SP_LOGIN_Email_USER UserName Not Found in eemrt');
    p_UserName := 'INVALID';
    RETURN;
  WHEN OTHERS THEN
    SP_INSERT_AUDIT(p_Email, 'PKG_USERS.SP_LOGIN_Email_USER Cannot Validate Use in eemrt');
    p_UserName := 'INVALID';
    RETURN;
  END SP_LOGIN_Email_USER;

PROCEDURE SP_LOGINUSER(
      p_User_id  VARCHAR2 ,
      p_Password VARCHAR2,
      p_PStatus OUT VARCHAR2,
      p_UserName OUT VARCHAR2)
  AS
    /*
    Procedure : SP_LOGINUSER
    Author: Sridhar Kommana
    Date Created : 11/05/2014
    Purpose:  Get user login info before AD authentication
    Update history:
    sridhar kommana :
    1) 04/30/2015 : Added more logs to Audit
    2) 05/03/2016 : Added call to  sp_user_Login_update(vUser) to update last login for RTM_ID S01
    */
    vCount  NUMBER ;
    vStatus VARCHAR(20);
  BEGIN
   -- SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_LOGINUSER Login Attempt made');
    p_UserName := NULL;
    SELECT COUNT(*)
    INTO vCount
    FROM users
    WHERE upper(userName) = upper(p_User_id); -- and password= p_Password;
    IF vCount             > 0 THEN
      --select u.FirstName || ' ' || u.MiddleInitial || ' ' || u.LastName into p_UserName from Users u where userName = p_User_id;
      p_PStatus := 'SUCCESS';
      SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_LOGINUSER User found in eemrt');
       sp_user_Login_update(p_User_id);
      RETURN;
    ELSE
      SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_LOGINUSER User not found in eemrt');
      p_PStatus  := 'Invalid User/Password';
      p_UserName := NULL;
      RETURN;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_LOGINUSER UserName Not Found in eemrt');
    p_PStatus  := 'UserName Not Found';
    p_UserName := NULL;
    RETURN;
  WHEN OTHERS THEN
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_LOGINUSER Cannot Validate Use in eemrt');
    p_PStatus  := 'Cannot Validate User';
    p_UserName := NULL;
    RETURN;
  END SP_LOGINUSER;

PROCEDURE SP_GET_Users(
      p_User_id VARCHAR2 DEFAULT NULL ,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
    vCount  NUMBER ;
    vStatus VARCHAR(20);
  BEGIN
    OPEN REC_CURSOR FOR SELECT TO_CHAR(U.CREATED_ON, 'MM/DD/YYYY') "User Request Date" ,
    U.USERNAME "User Account" ,
    ROLE "User Role",
    U.FIRSTNAME || ' ' || U.MIDDLEINITIAL || ' ' || U.LASTNAME "Full Name",
    U.Email "Email" ,
    Phone "Phone",
    --SUBSTR(SUBSTR(ROUTINGSYMBOL, -7), instr(SUBSTR(ROUTINGSYMBOL, -7),'/')+1) "Routing Symbol",
    ROUTINGSYMBOL "Routing Symbol",
    STATUS "User Request Status",
    ACCOUNT_STATUS "User Account Status" ,
    TO_CHAR(U.LAST_MODIFIED_ON, 'MM/DD/YYYY') "Action Date"
    --U.FIRSTNAME,
    --- U.MIDDLEINITIAL, U.LASTNAME ,
    --CONTRACT_NUMBER, ,
    ,
    COMMENTS,
    TO_CHAR(U.APPROVAL_DATE, 'MM/DD/YYYY') APPROVAL_DATE,
    TRUNC(U.lastLogin,'MI') lastLogin,   LastTransaction
          
      FROM users u,
    userRole ur --    , users_audit ua
    
    WHERE u.userName = ur.UserName  and (ACCOUNT_STATUS <> 'Inactive' or  ACCOUNT_STATUS is NULL)
   -- AND u.userName = ua.UserName(+)
    -- AND  (u.UserName = p_User_id OR p_User_id = NULL)
    ORDER BY U.created_on desc ;
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_Users Admin Page');
    RETURN;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    OPEN REC_CURSOR FOR SELECT 'UserName Not Found'
  AS
    Status FROM Dual;
    RETURN;
  WHEN OTHERS THEN
    OPEN REC_CURSOR FOR SELECT 'Cannot get Users'
  AS
    Status FROM Dual;
    RETURN;
  END SP_GET_Users; 

PROCEDURE SP_GET_UserNames(
      p_User_id VARCHAR2  ,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
    vCount  NUMBER ;
    vStatus VARCHAR(20);
  BEGIN
    OPEN REC_CURSOR FOR SELECT u.UserName,
    u.FirstName || ' ' || u.MiddleInitial || ' ' || u.LastName
  AS
    Full_Name FROM users u,
    userRole ur WHERE u.userName = ur.UserName and ACCOUNT_STATUS <> 'Inactive' ORDER BY 1;
    SP_INSERT_AUDIT(p_User_id, 'PKG_USERS.sp_GET_UserNames Get user name details for username');
    RETURN;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    OPEN REC_CURSOR FOR SELECT 'UserName Not Found'
  AS
    Status FROM Dual;
    RETURN;
  WHEN OTHERS THEN
    OPEN REC_CURSOR FOR SELECT 'Cannot get Users'
  AS
    Status FROM Dual;
    RETURN;
  END SP_GET_UserNames;
  
PROCEDURE sp_mgr_update
    (
      p_mgr USERS.USERNAME%TYPE,
      p_USER USERS.USERNAME%TYPE,
      p_ROLE USERROLE.ROLE%TYPE,
      p_Request_Status USERS.STATUS%TYPE,
      p_Comments USERS.Comments%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
    /*
    Procedure : sp_mgr_update
    Author: Sridhar Kommana
    Date Created : 04/12/2016
    Purpose:  Approve or not approve user request by a manager
    Update history:
    04/21/2016 Added UserRole insert to meet the requirement id : S00a-18
    05/09/2016 Added APPROVAL_DATE to have specific approval date. 
    */    
  IS
    vCount         NUMBER :=0 ;
    vSENDER        VARCHAR2(200);
    vRECEIVER      VARCHAR2(200);
    vSUBJECT       VARCHAR2(200);
    vMESSAGEHTML       VARCHAR2(32000);
    vEMAIL         VARCHAR2(1000);
    vAccountStatus VARCHAR2(20):=NULL;
    sendemail VARCHAR2(20) := 'N' ;
  BEGIN
    IF p_Request_Status           =  'Approved' THEN
      vAccountStatus              := 'Active';
      vMESSAGEHTML                := 'Your access to eemrt has been approved for the role of '||p_ROLE||'.  You can access eemrt via this link <a href="http://jactdfdvap346.act.faa.gov:8080/eemrtHome/">eemrt</a>.</br></br>Please review the User Guide for instructions on how to use eemrt. </br></br> Please contact the eemrt Administrator if you are unable to log in.';
      sendemail                   := 'Y' ;
      BEGIN
  
        UPDATE USERS
        SET Account_STATUS = vAccountStatus,
          Status           = p_Request_Status,
          Comments         = p_Comments,
          LAST_MODIFIED_BY = p_Mgr,
          LAST_MODIFIED_ON = SYSDATE(), 
          APPROVAL_DATE = sysdate()
        WHERE USERNAME     = p_USER;
        IF SQL%FOUND THEN
          p_PStatus := 'SUCCESS' ;
          COMMIT;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        p_PStatus := 'Error updating User ' || SQLERRM ;
        RETURN ;
      END;    
        
    Elsif p_Request_Status         = 'Not Approved' THEN
     /* 
      
      IF LTRIM(RTRIM(p_Comments)) IS NULL OR LTRIM(RTRIM(p_Comments)) = '' THEN
        p_PStatus                 := 'Error updating, Please provide a reason in comments section for denying the request.';
        RETURN ;
      END IF;       
      
      */
      vAccountStatus := 'Not Approved' ; ---'Cancelled';
      vMESSAGEHTML       := 'Your access to eemrt has been denied for the role of '||p_ROLE||'" Please contact the eemrt Administrator for any further questions.';
      sendemail := 'Y' ;
    BEGIN

      UPDATE USERS
      SET Account_STATUS = vAccountStatus,
        Status           = p_Request_Status,
        Comments         = p_Comments,
        LAST_MODIFIED_BY = p_Mgr,
        LAST_MODIFIED_ON = SYSDATE()
        
      WHERE USERNAME     = p_USER;
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      p_PStatus := 'Error updating User ' || SQLERRM ;
      RETURN ;
    END;      
    ELSE
      vAccountStatus := 'Pending Approval';
      sendemail := 'N' ;
    BEGIN

      UPDATE USERS
      SET Account_STATUS = vAccountStatus,
        Status           = p_Request_Status,
        Comments         = p_Comments,
        LAST_MODIFIED_BY = p_Mgr,
        LAST_MODIFIED_ON = SYSDATE()
      WHERE USERNAME     = p_USER;
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      p_PStatus := 'Error updating User ' || SQLERRM ;
      RETURN ;
    END;      
    END IF;
    SP_INSERT_AUDIT(p_Mgr, 'PKG_USERS.sp_mgr_update '|| p_Mgr||', '||p_USER||', '||p_Role||', '||p_Request_Status||', '||p_Comments);
    SELECT u.EMAIL INTO vEMAIL FROM users u WHERE u.UserName = p_USER;
    vSENDER   := 'sridhar.ctr.kommanaboyina@faa.gov';
    -----  User Roles 
       SP_INSERT_AUDIT(p_Mgr, 'PKG_USERS.sp_mgr_update inserting into userRoles p_Mgr='|| p_Mgr||', '||'p_USER='||p_USER);
    SELECT COUNT(*)
    INTO vCount
    FROM userrole
    WHERE upper(userName) = upper(p_USER);  
   BEGIN 
    IF vCount   = 0 THEN
        INSERT 
        INTO USERROLE
          (
            USERNAME,
            ROLE,
            LAST_MODIFIED_BY,
            LAST_MODIFIED_ON
          )
          VALUES
          (
            upper(p_USER),
            'eemrt User',
            p_USER,
            SYSDATE()
          );
              
        IF SQL%FOUND THEN
          p_PStatus := 'SUCCESS' ; 
          COMMIT;
        END IF;
            END IF ;
          EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        p_PStatus := 'Error inserting User Role ' || SQLERRM ;
      END;
--Start sending email here
      If sendemail = 'Y' then 
              vSUBJECT := 'Approval for eemrt User Account.';
              vSENDER := 'sridhar.ctr.kommanaboyina@faa.gov';
              vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
              SP_SEND_HTML_EMAIL(
                P_FROM => vSENDER,
                P_TO => vRECEIVER,    
                P_SUBJECT => vSUBJECT,                
                P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eemrt Admin');
      end if;
--End of email send

  END sp_mgr_update;
  
PROCEDURE sp_get_Contract_Task_access(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        REC_CURSOR OUT SYS_REFCURSOR)
  AS
    /*
    Procedure : sp_get_Contract_Task_access
    Author: Sridhar Kommana
    Date Created : 05/05/2016
    Purpose:  Get contract access information
    Update history: 
    1) 05/20/2016 : Sridhar Kommana - Added comments col
    */
    
    vCount  NUMBER ;
    vStatus VARCHAR2(20);
    vRole   VARCHAR2(20);
  BEGIN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_get_Contract_Task_access Get contract access information');   
    
      OPEN REC_CURSOR FOR 
      SELECT 
       Access_id, UserName, ContractNumber, TaskOrder, Role, COR, ApprovalDate, STATUS, comments
       from Contract_Task_Access
       WHERE upper(USERNAME) = upper(p_USERNAME);
    EXCEPTION    
        WHEN OTHERS THEN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.sp_get_Contract_Task_access Error'||SQLERRM);
    OPEN REC_CURSOR FOR 
    SELECT  NULL AS Access_id,  
      NULL AS  UserName,NULL AS  ContractNumber, NULL AS TaskOrder,NULL AS  Role,NULL AS  COR,NULL AS  ApprovalDate, NULL as STATUS
       from Contract_Task_Access
    RETURN;
  END sp_get_Contract_Task_access;
 
PROCEDURE SP_Get_Contract_Access_Users(
                        p_userid            IN VARCHAR2,
                        p_contract_number   IN CONTRACT_TASK_ACCESS.CONTRACTNUMBER%TYPE,
                        REC_CURSOR OUT SYS_REFCURSOR)
  AS
    /*
    Procedure : SP_Get_Contract_Users
    Purpose:  Get Users related to Contract Passed in as Input Parameter
    Date Created : 05/31/2016  --  Srihari Gokina      
    Update history: 
          1) Update by Sai Allu on 06/23/2016 - Converted where clause values to upper case.
    */    
    
  BEGIN
    Sp_Insert_Audit( P_Userid,'PKG_USERS.SP_Get_Contract_Access_Users contract_number= '||p_contract_number);    
      OPEN REC_CURSOR FOR 
      SELECT Access_id, C.CONTRACT_NUMBER, C.VENDOR ,U.UserName,U.FIRSTNAME, U.MIDDLEINITIAL , U.LASTNAME, 
            U.FIRSTNAME ||' ' || U.MIDDLEINITIAL ||' ' || U.LASTNAME AS FULLNAME, U.EMAIL User_EMail, U.MGR_EMAILID MGR_EMAILID, U.PHONE, U.ROUTINGSYMBOL, 
              TaskOrder, WO.WORK_ORDER_NUMBER, WO.WORK_ORDER_TITLE,
              SUBTASK , ST.SUB_TASK_NUMBER, ST.SUB_TASK_TITLE,
              UR.ROLE_ID,UR.USERROLE , COR, ApprovalDate, U.STATUS User_Status, CTA.STATUS as Access_Status, CTA.comments as Access_Comments , CTA.CREATED_ON AS Request_On
      FROM Contract_Task_Access CTA
      JOIN USERS U ON UPPER(U.USERNAME) = UPPER(CTA.USERNAME)
      JOIN STD_USERROLES UR ON UPPER(UR.ROLE_ID) = UPPER(CTA.ROLE)
      JOIN Contract C ON UPPER(C.CONTRACT_NUMBER) = UPPER(CTA.CONTRACTNUMBER)
      LEFT JOIN WORK_ORDERS WO ON UPPER(WO.WORK_ORDERS_ID) = UPPER(CTA.TaskOrder)
      LEFT JOIN SUB_TASKS ST ON UPPER(ST.SUB_TASKS_ID) = UPPER(CTA.SUBTASK)
      WHERE upper(C.CONTRACT_NUMBER) = upper(p_contract_number);
       
    EXCEPTION    
        WHEN OTHERS THEN
    SP_INSERT_AUDIT(P_Userid, 'PKG_USERS.SP_Get_Contract_Access_Users Error : '|| p_contract_number ||SQLERRM);
    OPEN REC_CURSOR FOR 
    SELECT  NULL AS Access_id, NULL AS  CONTRACT_NUMBER, NULL AS  VENDOR ,NULL AS  UserName, NULL AS FIRSTNAME, NULL AS  MIDDLEINITIAL , NULL AS LASTNAME,
          NULL AS FULLNAME,          NULL AS User_EMail, NULL AS MGR_EMAILID , NULL AS PHONE, 
          NULL AS ROUTINGSYMBOL, NULL AS TaskOrder, NULL AS WORK_ORDER_NUMBER, NULL AS WORK_ORDER_TITLE,
          NULL AS SUBTASK , NULL AS SUB_TASK_NUMBER, NULL AS SUB_TASK_TITLE,
          NULL AS ROLE_ID, NULL AS USERROLE, NULL AS COR, NULL AS ApprovalDate, NULL AS  User_Status, NULL AS  Access_Status, NULL AS  Access_Comments, NULL AS  Request_On
          from Contract_Task_Access
    RETURN;
  END SP_Get_Contract_Access_Users;

PROCEDURE SP_Get_Contract_Access_Users_A(
                        p_userid            IN VARCHAR2,
                        p_Access_id   IN CONTRACT_TASK_ACCESS.Access_id%TYPE,
                        REC_CURSOR OUT SYS_REFCURSOR)
  AS
    /*
    Procedure : SP_Get_Contract_Users
    Purpose:  Get User/UserAccess Related Info Based on Input Parameter Access_id
    Date Created : 06/02/2016  --  Srihari Gokina      
    Update history: 
          1) Update by Sai Allu on 06/23/2016 - Converted where clause values to upper case.
    */    
    
  BEGIN
    Sp_Insert_Audit( P_Userid,'PKG_USERS.SP_Get_Contract_Access_Users_A p_Access_id = '||p_Access_id);    
      OPEN REC_CURSOR FOR 
      SELECT Access_id, C.CONTRACT_NUMBER, C.VENDOR ,U.UserName,U.FIRSTNAME, U.MIDDLEINITIAL , U.LASTNAME, 
            U.FIRSTNAME ||' ' || U.MIDDLEINITIAL ||' ' || U.LASTNAME AS FULLNAME, U.EMAIL User_EMail, U.MGR_EMAILID MGR_EMAILID, U.PHONE, U.ROUTINGSYMBOL, 
              TaskOrder, WO.WORK_ORDER_NUMBER, WO.WORK_ORDER_TITLE,
              SUBTASK , ST.SUB_TASK_NUMBER, ST.SUB_TASK_TITLE,
              UR.ROLE_ID,UR.USERROLE , COR, ApprovalDate, U.STATUS User_Status, CTA.STATUS as Access_Status, CTA.comments as Access_Comments , CTA.CREATED_ON AS Request_On
      FROM Contract_Task_Access CTA
      JOIN USERS U ON UPPER(U.USERNAME) = UPPER(CTA.USERNAME)
      JOIN STD_USERROLES UR ON UPPER(UR.ROLE_ID) = UPPER(CTA.ROLE)
      JOIN Contract C ON UPPER(C.CONTRACT_NUMBER) = UPPER(CTA.CONTRACTNUMBER)
      LEFT JOIN WORK_ORDERS WO ON UPPER(WO.WORK_ORDERS_ID) = UPPER(CTA.TaskOrder)
      LEFT JOIN SUB_TASKS ST ON UPPER(ST.SUB_TASKS_ID) = UPPER(CTA.SUBTASK)
      WHERE Access_id = p_Access_id;
       
    EXCEPTION    
        WHEN OTHERS THEN
    SP_INSERT_AUDIT(P_Userid, 'PKG_USERS.SP_Get_Contract_Access_Users_A Error for Access_id: '|| p_Access_id || ' ' ||SQLERRM);
    OPEN REC_CURSOR FOR 
    SELECT  NULL AS Access_id, NULL AS  CONTRACT_NUMBER, NULL AS  VENDOR ,NULL AS  UserName, NULL AS FIRSTNAME, NULL AS  MIDDLEINITIAL , NULL AS LASTNAME,
          NULL AS FULLNAME,          NULL AS User_EMail, NULL AS MGR_EMAILID , NULL AS PHONE, 
          NULL AS ROUTINGSYMBOL, NULL AS TaskOrder, NULL AS WORK_ORDER_NUMBER, NULL AS WORK_ORDER_TITLE,
          NULL AS SUBTASK , NULL AS SUB_TASK_NUMBER, NULL AS SUB_TASK_TITLE,
          NULL AS ROLE_ID, NULL AS USERROLE, NULL AS COR, NULL AS ApprovalDate, NULL AS  User_Status, NULL AS  Access_Status, NULL AS  Access_Comments, NULL AS  Request_On
          from Contract_Task_Access
    RETURN;
  END SP_Get_Contract_Access_Users_A;
 
  
PROCEDURE SP_INSERT_CONTRACT_TASK_ACCESS(
      p_userid            IN VARCHAR2,
      P_USERNAME          IN CONTRACT_TASK_ACCESS.USERNAME%TYPE,
      p_contract_number   IN CONTRACT_TASK_ACCESS.CONTRACTNUMBER%TYPE,
      p_taskorder         IN CONTRACT_TASK_ACCESS.TASKORDER%TYPE,
      p_subtask           IN CONTRACT_TASK_ACCESS.SUBTASK%TYPE DEFAULT NULL,
      p_role              IN CONTRACT_TASK_ACCESS.ROLE%TYPE,
      p_cor               IN CONTRACT_TASK_ACCESS.COR%TYPE,
      p_approvaldate      IN CONTRACT_TASK_ACCESS.APPROVALDATE%TYPE,
      p_status            IN CONTRACT_TASK_ACCESS.STATUS%TYPE,
      p_comments          IN CONTRACT_TASK_ACCESS.comments%TYPE,
      p_id                OUT CONTRACT_TASK_ACCESS.ACCESS_ID%TYPE,
      p_pstatus           OUT VARCHAR2)
  AS
    /*
    Procedure : SP_INSERT_CONTRACT_TASK_ACCESS
    Purpose: SP_INSERT_CONTRACT_TASK_ACCESS inserts Contract Task Access.
    History: 
        1) 05/18/2016 : Srihari Gokina - Created     
     Update history : 
         1) 05/20/2016 : Sridhar Kommana - Added comments col
         2. 05/23/2016 : Srihari Gokina - Verify already exists...User with Role, Contract, Task, SubTask?
         3) 05/23/2016 : Sridhar Kommana -Added/Modified logs, included logs even exiting with errors
         4) 05/23/2016 : Sridhar Kommana - Added Condition to print taskorder and subTask only if not null
         5) 06/02/2016 : Srihari Gokina - Added eMail Stuff.
    */
    vCount    NUMBER :=0 ;  
    V_Inv_Id NUMBER:=0;
    vSENDER        VARCHAR2(200);
    vRECEIVER      VARCHAR2(200);
    vSUBJECT       VARCHAR2(200);
    vMESSAGE       VARCHAR2(32000);
    vEMAIL         VARCHAR2(1000);
    vCORIds VARCHAR2(32200) :=NULL;
    vCORUserIds VARCHAR2(32200) :=NULL;
    v_array_COR_id apex_application_global.vc_arr2;
    vlocEMAIL         VARCHAR2(1000);
    vLocFullName      VARCHAR2(200);
    
  BEGIN
  
    IF p_status    = 'Approved' THEN
      vMESSAGE     := 'Your access to Contract: '|| p_contract_number || ' has been approved for the role of '||p_role;
    Elsif p_status = 'Denied' THEN
      vMESSAGE     := 'Your access to Contract: '|| p_contract_number || ' has been Denied for the role of '||p_role;
    Elsif p_status = 'Pending' THEN
      vMESSAGE     := 'A request from '|| P_USERNAME || ' to access contract '||p_contract_number || ' for the role of ' ||p_role || ' has been received. Please log in to eemrt to process the request.'
                        || chr(13)||chr(13)|| ' If you have received this message in error, please contact the eemrt Administrator. ';
    END IF;  
    
    SELECT u.EMAIL INTO vEMAIL FROM users u WHERE u.UserName = P_USERNAME;
    vSENDER   := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER := vEMAIL ;--'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT  := 'Contract Access Request';
    
   -- Get the COR_IDS for the record
  BEGIN 
    SELECT COR_NAME
    INTO vCORIds
    FROM CONTRACT WHERE CONTRACT_NUMBER = p_contract_number;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      SP_INSERT_AUDIT(P_Userid, 'PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS Cannot find COR id record ERROR SQLERRM ='||SQLERRM || ' p_contract_number ='||p_contract_number);
    ROLLBACK;
    p_PStatus := 'Cannot find COR id record for CONTRACT= ' || p_contract_number;
    RETURN;
  END;     

    
    Sp_Insert_Audit( P_Userid,'PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS contract_number= '||p_contract_number||' TaskOrder_number='||p_taskorder);    
    IF( p_userid IS NULL ) THEN
      P_Pstatus  := 'Error inserting PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS '||' Cannot insert with no user info' ;
      Sp_Insert_Audit( P_Userid,'PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS ERROR, could not insert with Null userid contract_number= '||p_contract_number||' TaskOrder_number='||p_taskorder);          
      RETURN;
    END IF;
    
    SELECT COUNT(*) INTO vCount
    FROM CONTRACT_TASK_ACCESS 
    WHERE UPPER(USERNAME) = UPPER(P_USERNAME) AND UPPER(CONTRACTNUMBER) = UPPER(p_Contract_Number) 
        AND UPPER(TASKORDER) = UPPER(p_taskorder) AND UPPER(NVL(SUBTASK,0)) = UPPER(NVL(p_subtask,0)) AND UPPER(ROLE) = UPPER(P_ROLE);
    
    BEGIN
      IF vCount    > 0 THEN
        p_PStatus := 'User '||p_USERNAME|| ' has already access to ' ||p_contract_number||' (Contract) ';--||p_taskorder|| ' (Task)';  -- ' is already found in eemrt';
          IF p_taskorder IS NOT NULL THEN
              p_PStatus := p_PStatus || ' /' || p_taskorder || ' (Task Order)';
          END IF;
          IF p_subtask IS NOT NULL THEN
              p_PStatus := p_PStatus || ' /' || p_subtask || ' (SubTask)';
          END IF;

      Sp_Insert_Audit( P_Userid,'PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS ERROR,'||p_PStatus|| 'p_contract_number = '||p_contract_number||' TaskOrder_number='||p_taskorder);          
          
        RETURN ;
      END IF;
    
      V_Inv_Id := CONTRACT_TASK_ACCESS_SEQ.Nextval;
  
      INSERT
      INTO CONTRACT_TASK_ACCESS
          ( ACCESS_ID,
            USERNAME, 
            CONTRACTNUMBER,
            TASKORDER,
            SUBTASK,
            ROLE,
            COR,
            APPROVALDATE,
            STATUS,
            comments,
            CREATED_BY,
            CREATED_ON
          )
          VALUES
          ( V_Inv_Id ,
            P_USERNAME,
            p_Contract_Number,
            p_taskorder,
            p_subtask,
            p_role,
            p_cor,
            p_approvaldate,
            p_status,
            p_comments,
            P_Userid,
            Sysdate()
          );
        IF Sql%Found THEN
          P_Pstatus := 'SUCCESS' ;
          P_Id      := V_Inv_Id;

          IF (p_status = 'Approved' OR p_status = 'Denied') THEN
            SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
            SP_INSERT_AUDIT(p_userid, 'PKG_USERS.sp_update_User Email Sent '|| vSENDER||', '||vRECEIVER||', '||vSUBJECT);
          END IF;       
          
          SELECT CHR(39) || REPLACE(COR_NAME, ',', ''',''') || CHR(39) INTO vCORUserIds FROM CONTRACT WHERE CONTRACT_NUMBER = p_contract_number ;                                       
          vCORIds := vCORUserIds; -- 'SRIHARI CTR GOKINA';            
          v_array_COR_id := apex_util.string_to_table(vCORIds, ',');  
          
          SP_INSERT_AUDIT(p_userid, 'Pending - ' || v_array_COR_id.COUNT); 
          
  
         IF (p_status = 'Pending') THEN            
            SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to CORs from PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS  for CONTRACT Number ='|| p_contract_number);
            SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'sai.laxman.ctr.allu@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  'Sai Laxman Allu' ||  '</br></br>'|| vMESSAGE || '</br></br>Thank you, </br></br>eemrt Admin'  );    
            SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'sridhar.ctr.kommanaboyina@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  'Sridhar Kommanaboyina' ||  '</br></br>'|| vMESSAGE || '</br></br>Thank you, </br></br>eemrt Admin'  );                    
            SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'srihari.ctr.gokina@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  'Srihari Gokina' ||  '</br></br>'|| vMESSAGE || '</br></br>Thank you, </br></br>eemrt Admin'  );    

         /*
            FOR rec IN
               (SELECT email, firstname || ' ' ||lastname fullName FROM users WHERE upper(username) IN ( vCORIds ))                
            LOOP
                  SP_INSERT_AUDIT(p_userid, 'Pending' || ' - Testing');
                  SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to COR from PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS  for CONTRACT Number ='|| p_contract_number);
                  SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eemrt Admin' );  
            END LOOP;
          */
          END IF;

          COMMIT;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;          
          Sp_Insert_Audit( P_Userid,'Error PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS'||SQLERRM );  
          P_Pstatus := 'Error inserting Contract Task Access '||Sqlerrm ;
      RETURN ;
    END;  
  END SP_INSERT_CONTRACT_TASK_ACCESS ;

PROCEDURE SP_UPDATE_CONTRACT_TASK_ACCESS
    (
      p_userid            IN VARCHAR2,
      P_USERNAME          IN CONTRACT_TASK_ACCESS.USERNAME%TYPE,
      p_MGR_EMAIL         IN VARCHAR2,
      p_contract_number   IN CONTRACT_TASK_ACCESS.CONTRACTNUMBER%TYPE,
      p_taskorder         IN CONTRACT_TASK_ACCESS.TASKORDER%TYPE  DEFAULT NULL,
      p_subtask           IN CONTRACT_TASK_ACCESS.SUBTASK%TYPE DEFAULT NULL,
      p_role              IN CONTRACT_TASK_ACCESS.ROLE%TYPE,
      p_status            IN CONTRACT_TASK_ACCESS.STATUS%TYPE,
      p_PStatus OUT VARCHAR2
    )
  IS
  
    /*    Procedure : SP_UPDATE_CONTRACT_TASK_ACCESS
             Purpose: SP_UPDATE_CONTRACT_TASK_ACCESS Update Contract Task Access.
          05/18/2016 : Srihari Gokina - Created     
          Update history : 
            1) 06/02/2016 : Sridhar Kommana - Fixing Issue with Update.
            2. 06/02/2016 : Srihari Gokina - Added eMail Stuff.
            3. 06/07/2016 : Srihari Gokina - SP, not to look for MGR eMail ID.
    */
 
    vSENDER        VARCHAR2(200);
    vRECEIVER      VARCHAR2(200);
    vSUBJECT       VARCHAR2(200);
    vMESSAGE       VARCHAR2(32000);
    vEMAIL         VARCHAR2(1000);
    
  BEGIN
  
    IF p_status    = 'Approved' THEN
      vMESSAGE     := 'Your access to Contract: '|| p_contract_number || ' has been approved for the role of '||p_role;
    Elsif p_status = 'Denied' THEN
      vMESSAGE     := 'Your access to Contract: '|| p_contract_number || ' has been Denied for the role of '||p_role;
    END IF;
    
    SELECT u.EMAIL INTO vEMAIL FROM users u WHERE u.UserName = P_USERNAME;
    vSENDER   := 'sridhar.ctr.kommanaboyina@faa.gov';
    vRECEIVER := vEMAIL ;--'sridhar.ctr.kommanaboyina@faa.gov';
    vSUBJECT  := 'eemrt User Contract Access Update';

          SP_INSERT_AUDIT(p_userid, 'PKG_USERS.SP_UPDATE_CONTRACT_TASK_ACCESS '|| P_USERNAME||', '||p_MGR_EMAIL||', '||p_contract_number||', '||p_Role||','||p_status);
          
          p_PStatus := 'Error updating Contract Access for User:' || P_USERNAME || ', Contract:' || p_contract_number;
         
          IF p_taskorder IS NOT NULL THEN
              p_PStatus := p_PStatus || ' /' || p_taskorder || ' (Task Order)';
          END IF;
          IF p_subtask IS NOT NULL THEN
              p_PStatus := p_PStatus || ' /' || p_subtask || ' (SubTask)';
          END IF;
         
    BEGIN

      -- CONTRACT LEVEL
      IF p_taskorder IS NULL AND p_subtask IS NULL THEN
        UPDATE CONTRACT_TASK_ACCESS
        SET ROLE = p_role , Status = p_status, UPDATED_BY = p_userid , UPDATED_ON = sysdate
        WHERE USERNAME = P_USERNAME AND CONTRACTNUMBER = p_contract_number 
             -- AND  USERNAME   = ( SELECT  USERNAME  FROM USERS WHERE UPPER(MGR_EMAILID) = UPPER(p_MGR_EMAIL) and USERNAME  = P_USERNAME )
              AND TASKORDER IS NULL AND SUBTASK IS NULL;   
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
        RETURN;
      END IF;
      END IF;
      
      -- TASKORDER LEVEL
      IF p_taskorder IS NOT NULL AND p_subtask IS NULL THEN
        UPDATE CONTRACT_TASK_ACCESS
        SET ROLE = p_role , Status = p_status, UPDATED_BY = p_userid  , UPDATED_ON = sysdate
        WHERE USERNAME = P_USERNAME AND CONTRACTNUMBER = p_contract_number 
              -- AND  USERNAME   = ( SELECT  USERNAME  FROM USERS WHERE UPPER(MGR_EMAILID) = UPPER(p_MGR_EMAIL) and USERNAME  = P_USERNAME )  -- 
              AND TASKORDER = p_taskorder AND SUBTASK IS NULL;        
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
                RETURN;
      END IF;
      END IF;
      
      -- SUBTASK LEVEL
      IF p_taskorder IS NOT NULL AND p_subtask IS NOT NULL THEN          
        SP_INSERT_AUDIT(p_userid, 'PKG_USERS.SP_UPDATE_CONTRACT_TASK_ACCESS both not null '|| P_USERNAME||', '||p_MGR_EMAIL||', '||p_contract_number||', '||p_Role||','||p_status||'p_taskorder='||p_taskorder||'p_subtask='||p_subtask);       
        UPDATE CONTRACT_TASK_ACCESS
        SET ROLE = p_role , Status = p_status, UPDATED_BY = p_userid  , UPDATED_ON = sysdate
        WHERE  USERNAME  =  P_USERNAME  AND  CONTRACTNUMBER  =  p_contract_number  
             -- AND  USERNAME   = ( SELECT  USERNAME  FROM USERS WHERE UPPER(MGR_EMAILID) = UPPER(p_MGR_EMAIL) and USERNAME  = P_USERNAME )
              AND  TASKORDER  =  p_taskorder  AND  SUBTASK   =  p_subtask  ;        
            IF SQL%FOUND THEN
                  p_PStatus := 'SUCCESS' ;                  
          COMMIT;
        RETURN;
      END IF;
      END IF;  
      /*
      IF SQL%FOUND THEN
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF; 
      */
        IF (p_PStatus = 'SUCCESS' ) THEN
         IF (p_status = 'Approved' OR p_status = 'Denied') THEN
            SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
            SP_INSERT_AUDIT(p_userid, 'PKG_USERS.sp_update_User Email Sent '|| vSENDER||', '||vRECEIVER||', '||vSUBJECT);
          END IF;
        END IF;      
    EXCEPTION
    WHEN OTHERS THEN
      p_PStatus := p_PStatus  || SQLERRM ;
      RETURN ;
    END;
  END SP_UPDATE_CONTRACT_TASK_ACCESS;
  
PROCEDURE SP_GET_USER_CONTRACTS_ACCESS(
                        p_userid    IN VARCHAR2,
                        p_USERNAME  USERS.USERNAME%TYPE,
                        REC_CURSOR OUT SYS_REFCURSOR)
  AS
/*  Procedure : SP_GET_USER_CONTRACTS_BY_ACCESS
    -- Srihari Gokina      Date Created : 06/01/2016
    Purpose:  Get All Contracts that User has the  access to his Role.
    Update history: 
    1)      */
   
    vRole   VARCHAR2(20);
  BEGIN
    SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_USER_CONTRACTS_ACCESS Get contracts for t access information');   
    
      SELECT ROLE INTO vRole FROM USERROLE WHERE USERNAME = UPPER(p_USERNAME);
    
      IF vRole = 'Admin' THEN 
        OPEN REC_CURSOR FOR       
        SELECT Access_id, UserName, ContractNumber, TaskOrder, SUBTASK, Role, COR, ApprovalDate, STATUS, comments
         from Contract_Task_Access;
         -- WHERE upper(Role) = upper('Admin');
     END IF;
        IF vRole = 'CO' THEN 
        OPEN REC_CURSOR FOR       
        SELECT Access_id, UserName, ContractNumber, TaskOrder, SUBTASK, Role, COR, ApprovalDate, STATUS, comments
         from Contract_Task_Access
         WHERE upper(Role) = upper('CO');
     END IF;
    EXCEPTION    
        WHEN OTHERS THEN
        SP_INSERT_AUDIT(p_USERNAME, 'PKG_USERS.SP_GET_USER_CONTRACTS_ACCESS Error'||SQLERRM);
    OPEN REC_CURSOR FOR 
    SELECT  NULL AS Access_id,  NULL AS  UserName,NULL AS  ContractNumber, NULL AS TaskOrder,NULL AS SUBTASK, NULL AS  Role, NULL AS  COR, NULL AS  ApprovalDate, NULL as STATUS
       from Contract_Task_Access
    RETURN;
  END SP_GET_USER_CONTRACTS_ACCESS;
 
 PROCEDURE sp_get_Roles(
      p_UserID VARCHAR2,
      Roles_cursor OUT SYS_REFCURSOR)
  IS
     /*
      Procedure : sp_get_Roles
      Author: Sridhar Kommana
      Date Created : 05/16/2016
      Purpose:  Get User Roles 
      Update history:
      
      */
  BEGIN
  SP_INSERT_AUDIT(p_UserID, 'PKG_USERS.sp_get_Roles');
    OPEN Roles_cursor FOR SELECT Role_id, USERROLE from Std_Userroles order by Userrole; 
  EXCEPTION
  WHEN OTHERS THEN
     OPEN Roles_cursor FOR  SELECT Null as Role_id , Null as USERROLE from Std_Userroles;
  END sp_get_Roles;  
END PKG_USERS;
/