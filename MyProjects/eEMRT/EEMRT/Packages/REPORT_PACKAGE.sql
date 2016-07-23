CREATE OR REPLACE PACKAGE eemrt."REPORT_PACKAGE" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

 PROCEDURE sp_WO_LSD_Summary(
    p_contract_number  varchar2 DEFAULT NULL,
    p_WO_ID  number DEFAULT NULL,
     p_StartDate  varchar2 DEFAULT NULL,
     p_EndDate  varchar2 DEFAULT NULL,
     p_UserId  varchar2 ,
     
    REC_CURSOR OUT SYS_REFCURSOR)
 ;
   PROCEDURE sp_MultiWO_LSD_Summary(
    p_contract_number  varchar2 DEFAULT NULL,
    p_WO_ID  varchar2 DEFAULT NULL,
     p_StartDate  varchar2 DEFAULT NULL,
     p_EndDate  varchar2 DEFAULT NULL,    
    p_UserId  varchar2 ,
    REC_CURSOR OUT SYS_REFCURSOR);

END REPORT_PACKAGE;
/