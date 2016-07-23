CREATE OR REPLACE PROCEDURE eemrt.sp_get_Sub_Task_Orders(
    p_UserId  varchar2 DEFAULT NULL,
    P_SUB_TASKS_ID NUMBER DEFAULT 0 ,
    P_Work_Orders_ID NUMBER DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_Work_Orders
  Author: Sridhar Kommana
  Date Created : 08/10/2015
  Purpose:  Get sub Task orders to get details when SUB_TASKS_ID is passed.
  Update history: 
  sridhar kommana :
  */
    p_status Varchar2(100) :=NULL;
BEGIN
 
    SP_INSERT_AUDIT(p_UserId, 'sp_get_Sub_Task_Orders - Get sub task Orders details for P_SUB_TASKS_ID '||P_SUB_TASKS_ID );
  
      OPEN REC_CURSOR
      FOR
          SELECT    
            ST.SUB_TASKS_ID,
            ST.WORK_ORDERS_ID,
            ST.SUB_TASK_NUMBER,
            ST.SUB_TASK_TITLE,
            ST.START_DATE,
            ST.END_DATE,
            ST.DESCRIPTION,
            ST.ORGANIZATION,
            ST.FAA_POC,
            ST.PERIOD_OF_PERFORMANCE_ID,
            ST.Status,
            ST.ST_FEE, 
            WO.WORK_ORDER_NUMBER,
            WO.WORK_ORDER_TITLE,
           (
           (
            select nvl(sum(W.CLIN_HOURS),0)  from SUB_TASKS_CLINS W WHERE  W.WORK_ORDERS_ID = ST.WORK_ORDERS_ID AND (W.FK_SUB_TASKS_ID=ST.SUB_TASKS_ID)
            )
            + (
             select nvl(sum(nvl(W.LABOR_CATEGORY_Hours,0))  ,0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID  AND (W.SUB_TASKS_ID=ST.SUB_TASKS_ID) 
             )
            
           ) 
            as ST_HOURS,
            ((select nvl(sum(W.CLIN_AMOUNT),0)  from SUB_TASKS_CLINS W WHERE   W.WORK_ORDERS_ID = ST.WORK_ORDERS_ID AND (W.FK_SUB_TASKS_ID=ST.SUB_TASKS_ID )) 
            + (select nvl(sum(W.LC_AMOUNT),0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID  AND (W.SUB_TASKS_ID=ST.SUB_TASKS_ID) )
            ) as ST_AMOUNT  
                     
       FROM SUB_TASKS  ST 
            LEFT outer JOIN (select distinct org_cd, ORG_TITLE from organizations where rownum=1 ) O on ST.organization = O.org_cd
           -- inner join PERIOD_OF_PERFORMANCE POP 
      --ON POP.PERIOD_OF_PERFORMANCE_ID = ST.PERIOD_OF_PERFORMANCE_ID   
          inner join WORK_ORDERS WO 
          ON WO.WORK_ORDERS_ID = ST.WORK_ORDERS_ID
      AND (ST.SUB_TASKS_ID = P_SUB_TASKS_ID OR P_SUB_TASKS_ID= 0)  
      AND (ST.WORK_ORDERS_ID = P_Work_Orders_ID)-- OR P_Work_Orders_ID= 0)  
      
  
      ORDER BY 1;
 
        
END sp_get_Sub_Task_Orders;
/