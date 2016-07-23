CREATE OR REPLACE PACKAGE eemrt."PKG_USERS" 
IS
  /*
  Package : PKG_Users
  Author: Sridhar Kommana
  Date Created : 09/14/2015
  Purpose:  All procedures related to users
  Update history:
  */
 PROCEDURE sp_Add_AD_User(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_FullName OUT VARCHAR2,
                        p_PStatus OUT VARCHAR2);  
 PROCEDURE sp_Find_FAA_User(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        p_PStatus OUT VARCHAR2);      
 PROCEDURE sp_Add_FAA_User(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        p_UserStatus VARCHAR2,                       
                        p_PStatus OUT VARCHAR2);                               
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
      p_PStatus OUT VARCHAR2 );
  PROCEDURE sp_update_User(
      p_Admin USERS.USERNAME%TYPE,
      p_USER USERS.USERNAME%TYPE,
      p_ROLE USERROLE.ROLE%TYPE,
      p_Request_Status USERS.STATUS%TYPE,
      p_Comments USERS.Comments%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2 );
      
PROCEDURE SP_DELETE_USER
    (
      p_Admin USERS.USERNAME%TYPE,
      p_USER USERS.USERNAME%TYPE,
      p_Comments USERS.Comments%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    );
    
  PROCEDURE SP_GET_User_Info(
      p_User_id  VARCHAR2,
      p_Password VARCHAR2 ,
      REC_CURSOR OUT SYS_REFCURSOR);
  PROCEDURE SP_GET_User_Information(
      p_User_id  VARCHAR2,
      REC_CURSOR OUT SYS_REFCURSOR);      
  PROCEDURE SP_LOGINUSER(
      p_User_id  VARCHAR2 ,
      p_Password VARCHAR2,
      p_PStatus OUT VARCHAR2,
      p_UserName OUT VARCHAR2);
  PROCEDURE SP_GET_Users(
      p_User_id VARCHAR2 DEFAULT NULL ,
      REC_CURSOR OUT SYS_REFCURSOR);
  PROCEDURE SP_GET_UserNames(
      p_User_id VARCHAR2,
      REC_CURSOR OUT SYS_REFCURSOR);
  PROCEDURE SP_GET_User_Mgr_Info(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        REC_CURSOR OUT SYS_REFCURSOR);
  
  PROCEDURE SP_GET_App_User_Mgr_Info(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        p_ROLE USERROLE.ROLE%TYPE,
                        p_MGR_EMAIL  VARCHAR2,
                        REC_CURSOR OUT SYS_REFCURSOR);
  
  
  PROCEDURE SP_LOGIN_Email_USER(
      p_Email  VARCHAR2 ,
      p_UserName OUT VARCHAR2);      
      
  PROCEDURE sp_mgr_update
    (
      p_mgr USERS.USERNAME%TYPE,
      p_USER USERS.USERNAME%TYPE,
      p_ROLE USERROLE.ROLE%TYPE,
      p_Request_Status USERS.STATUS%TYPE,
      p_Comments USERS.Comments%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )   ;   
  PROCEDURE sp_get_Contract_Task_access(
                        p_USERNAME  USERS.USERNAME%TYPE,
                        REC_CURSOR OUT SYS_REFCURSOR);
                        
PROCEDURE SP_Get_Contract_Access_Users(
                        p_userid    VARCHAR2,
                        p_contract_number   CONTRACT_TASK_ACCESS.CONTRACTNUMBER%TYPE,
                        REC_CURSOR OUT SYS_REFCURSOR);                          
PROCEDURE SP_Get_Contract_Access_Users_A(
                        p_userid      IN VARCHAR2,
                        p_Access_id   IN CONTRACT_TASK_ACCESS.Access_id%TYPE,
                        REC_CURSOR    OUT SYS_REFCURSOR);      
                        
 PROCEDURE sp_get_Roles(
      p_UserID VARCHAR2,
      Roles_cursor OUT SYS_REFCURSOR);      
      
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
      p_pstatus           OUT VARCHAR2);

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
      p_PStatus OUT VARCHAR2 );

PROCEDURE SP_GET_USER_CONTRACTS_ACCESS(
                        p_userid    IN VARCHAR2,
                        p_USERNAME  IN USERS.USERNAME%TYPE,
                        REC_CURSOR  OUT SYS_REFCURSOR);

      
END PKG_Users;
/