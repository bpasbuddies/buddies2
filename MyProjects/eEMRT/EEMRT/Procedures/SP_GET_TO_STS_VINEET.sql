CREATE OR REPLACE PROCEDURE eemrt.sp_get_TO_STs_Vineet(
    p_UserId  varchar2,
    P_POP_ID varchar2 default NULL,
    p_contract_number  varchar2 ,
    TO_REC_CURSOR OUT SYS_REFCURSOR )
AS
  /*
  Procedure : sp_get_TO_STs
  Author: Sridhar Kommana
  Date Created : 01/15/2016
  Purpose:  Get Task orders an sub-tasks for each contract.
  Update history: 
  
  */
    p_status Varchar2(100) :=NULL;
BEGIN
    SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_TO_STs - Get Task Orders and sub-tasks List for a contract '||p_Contract_NUMBER  || 'P_POP_ID='||P_POP_ID);
   
      OPEN TO_REC_CURSOR
      FOR  
              SELECT WO.WORK_ORDERS_ID as ID,   null as ParentID,  WO.WORK_ORDER_Title as Title
              FROM Work_Orders WO
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)

              --LEFT OUTER JOIN SUB_TASKS  ST 
              --ON ST.WORK_ORDERS_ID = WO.WORK_ORDERS_ID                 
           
              
      UNION ALL 
              SELECT   ST.SUB_TASKS_ID as id, WO.WORK_ORDERS_ID as ParentID, ST.SUB_TASK_TITLE AS TITLE 
              FROM  SUB_TASKS  ST
              inner join WORK_ORDERS WO 
              ON WO.WORK_ORDERS_ID = ST.WORK_ORDERS_ID
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number              
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)
           
              ORDER BY parentid, title ; 
 
END sp_get_TO_STs_Vineet;
/