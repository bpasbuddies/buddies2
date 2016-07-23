CREATE OR REPLACE PACKAGE eemrt.PKG_Contracts
IS
  /*
  Package : PKG_Contracts
  Author: Sridhar Kommana
  Date Created : 09/14/2015
  Purpose:  All procedures related to Contracts
  Update history:
  03/18/2016 Modified sp_get_contracts_summary and sp_get_contracts per RTM ID: W00a-10.
  */
  PROCEDURE sp_get_contracts_summary(
      p_CREATED_BY VARCHAR2 DEFAULT NULL,
      contracts_cursor OUT SYS_REFCURSOR);
  PROCEDURE sp_get_contracts(
      p_UserId          VARCHAR2 DEFAULT NULL,
      p_CONTRACT_NUMBER VARCHAR2 DEFAULT NULL,
      contracts_cursor OUT SYS_REFCURSOR) ;
  PROCEDURE SP_Activate_Contract(
      p_CONTRACT_NUMBER IN CONTRACT.CONTRACT_NUMBER%type,
      p_UPDATED_BY      IN CONTRACT.LAST_MODIFIED_BY%type,
      p_PStatus OUT VARCHAR2 );
  PROCEDURE sp_Add_Contract(
      p_CONTRACT_NUMBER IN CONTRACT.CONTRACT_NUMBER%type,
      p_DO_NUM          IN CONTRACT.DO_NUM%type ,
      p_CREATED_BY      IN CONTRACT.LAST_MODIFIED_BY%type DEFAULT 'APPUSER',
      p_PStatus OUT VARCHAR2 );
  PROCEDURE SP_Update_Contract(
      p_CONTRACT_NUMBER IN CONTRACT.CONTRACT_NUMBER%type,
      ---p_DO_NUM          IN CONTRACT.DO_NUM%type DEFAULT 9999 ,
      p_SMALL_BUSINESS       IN CONTRACT.SMALL_BUSINESS%type,
      p_small_business_Desig IN CONTRACT.small_business_Desig%TYPE,
      p_SUBCONTRACT_VENDOR CONTRACT.SUBCONTRACT_VENDOR%TYPE,
      p_Program    IN CONTRACT.Program%TYPE,
      p_CO_NAME    IN CONTRACT.CO_NAME%TYPE,
      p_COR_NAME   IN CONTRACT.COR_NAME%TYPE,
      p_org_cd     IN CONTRACT.organization%TYPE,
      p_UPDATED_BY IN CONTRACT.LAST_MODIFIED_BY%type DEFAULT 'APPUSER',
      p_CS_USERNAME IN CONTRACT.CS_USERNAME%TYPE DEFAULT NULL,
    p_PM_USERNAME IN CONTRACT.PM_USERNAME%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2 );

 PROCEDURE  SP_GET_ALL_VENDORS(
    p_UserId     varchar2 DEFAULT NULL ,
    p_SUB_CONTRACTOR_ID     NUMBER DEFAULT 0 ,
    p_VENDOR_NAME  varchar2 DEFAULT NULL ,
    p_CONTRACT_NUMBER  varchar2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR) ;
PROCEDURE sp_get_CORs(
    CORs_cursor OUT SYS_REFCURSOR);      
 PROCEDURE sp_get_COs(
    COs_cursor OUT SYS_REFCURSOR);    
 PROCEDURE sp_get_Organizations(
    p_UserId          VARCHAR2,
    p_rgn_cd VARCHAR2 DEFAULT NULL,
    Organizations_cursor OUT SYS_REFCURSOR);   
PROCEDURE sp_Add_Contract_PRISM(
    p_CONTRACT_NUMBER  IN CONTRACT.CONTRACT_NUMBER%type, 
    p_DO_NUM  IN CONTRACT.DO_NUM%type , 
    p_CREATED_BY       IN CONTRACT.LAST_MODIFIED_BY%type DEFAULT 'APPUSER',
    p_PStatus OUT VARCHAR2 );    

PROCEDURE sp_get_contracts_Info(
    p_UserId          VARCHAR2 DEFAULT NULL,
    p_CONTRACT_NUMBER VARCHAR2 DEFAULT NULL,
    contracts_cursor OUT SYS_REFCURSOR);    
    
END PKG_Contracts;
/