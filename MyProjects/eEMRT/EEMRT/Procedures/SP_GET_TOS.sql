CREATE OR REPLACE PROCEDURE eemrt.sp_get_TOs(
    p_UserId  varchar2,
    P_POP_ID varchar2 default NULL,
    p_contract_number  varchar2 ,
  --  P_WORK_ORDERS_ID number default 0,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_TOs
  Author: Sridhar Kommana
  Date Created : 08/28/2015
  Purpose:  Get Task orders for each contract.
  Update history: 
  
  */
    p_status Varchar2(100) :=NULL;
BEGIN
    SP_INSERT_AUDIT(p_UserId, 'sp_get_TOs - Get Task Orders List for a contract '||p_Contract_NUMBER  || 'P_POP_ID='||P_POP_ID);
   
      OPEN REC_CURSOR
      FOR  
              SELECT WO.WORK_ORDERS_ID,  WO.WORK_ORDER_NUMBER, WO.WORK_ORDER_Title, WO.ORGANIZATION ORGANIZATION, WO.FAA_POC  FAA_POC
              FROM Work_Orders WO
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)
           --   AND (WORK_ORDERS_ID = P_WORK_ORDERS_ID OR P_WORK_ORDERS_ID= 0) 
       /*       UNION  
              SELECT ST.SUB_TASKS_ID WORK_ORDERS_ID,
              ST.SUB_TASK_NUMBER WORK_ORDER_NUMBER, ST.SUB_TASK_TITLE WORK_ORDER_Title ,   ST.ORGANIZATION ORGANIZATION, ST.FAA_POC  FAA_POC
              FROM SUB_TASKS ST
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = ST.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number
              AND  (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)*/
       --       AND (SUB_TASKS_ID = P_WORK_ORDERS_ID OR P_WORK_ORDERS_ID= 0) 
              ORDER BY WORK_ORDER_NUMBER desc; 
 
END sp_get_TOs;
/