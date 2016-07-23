CREATE OR REPLACE PACKAGE BODY eemrt.PKG_SUB_TASKS AS
  /*
  Package Body : pkg_SUB_TASKS
  Author: Sridhar Kommana
  Date Created : 08/14/2015
  Purpose:  Insert Update Delete Sub Task and related tables  for eCert
  Update history:
  1) 10/16/2015 : Added call to a function for org Title, supporting multiple org codes 
  2) 05/02/2016 : Added new proc Delete_SUB_TASKS to delete for RTM-ID W00-31
*/

  PROCEDURE insert_SUB_TASKS(
      p_WORK_ORDERS_ID        IN SUB_TASKS.WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_SUB_TASK_NUMBER        IN SUB_TASKS.SUB_TASK_NUMBER%TYPE DEFAULT NULL,
      p_SUB_TASK_TITLE         IN SUB_TASKS.SUB_TASK_TITLE%TYPE DEFAULT NULL,
      p_START_DATE               IN SUB_TASKS.START_DATE%TYPE DEFAULT NULL,
      p_END_DATE                 IN SUB_TASKS.END_DATE%TYPE DEFAULT NULL,
      p_DESCRIPTION              IN SUB_TASKS.DESCRIPTION%TYPE DEFAULT NULL,
      p_ORGANIZATION             IN SUB_TASKS.ORGANIZATION%TYPE DEFAULT NULL,
      p_FAA_POC                  IN SUB_TASKS.FAA_POC%TYPE DEFAULT NULL,
      p_PERIOD_OF_PERFORMANCE_ID IN SUB_TASKS.PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL,
      p_Status                   IN SUB_TASKS.Status%TYPE DEFAULT NULL,
      p_ST_FEE                   IN SUB_TASKS.ST_FEE%TYPE DEFAULT 0,      
      p_CREATED_BY               IN SUB_TASKS.CREATED_BY%TYPE DEFAULT NULL,
      p_ID OUT SUB_TASKS.SUB_TASKS_ID%TYPE,
      p_PStatus OUT VARCHAR2  ) AS
    v_Temp_id NUMBER := SUB_TASK_ORDER_SEQ.NEXTVAL;      
  BEGIN
    SP_INSERT_AUDIT( p_CREATED_BY,'PKG_SUB_TASKS.insert_SUB_TASKS');
    INSERT
    INTO SUB_TASKS
      (        
        SUB_TASKS_ID,
        WORK_ORDERS_ID,
        SUB_TASK_NUMBER,
        SUB_TASK_TITLE,
        START_DATE,
        END_DATE,
        DESCRIPTION,
        ORGANIZATION,
        FAA_POC,
        PERIOD_OF_PERFORMANCE_ID,
        Status,
        ST_FEE,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        v_Temp_id,
        p_WORK_ORDERS_ID,
        p_SUB_TASK_NUMBER,
        p_SUB_TASK_TITLE,
        p_START_DATE,
        p_END_DATE,
        p_DESCRIPTION,
        p_ORGANIZATION,
        p_FAA_POC,
        p_PERIOD_OF_PERFORMANCE_ID,
        p_Status,
        p_ST_FEE,        
        p_CREATED_BY,
        sysdate()
      );
    p_ID := v_Temp_id;
    IF SQL%FOUND THEN
      SP_INSERT_AUDIT( p_CREATED_BY,' SUCCESS PKG_SUB_TASKS.insert_SUB_TASKS'||' Created  SUB_TASKS with p_SUB_TASK_NUMBER ='||p_SUB_TASK_NUMBER);
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN 
   p_ID := 0;
    ROLLBACK;
    p_PStatus := 'Error adding Sub Task order, Sub Task order number ' ||P_SUB_TASK_NUMBER ||'  is already used. ';
      SP_INSERT_AUDIT( p_CREATED_BY,'PKG_SUB_TASKS.insert_SUB_TASKS'||' Attempt to create  SUB_TASKS with SUB_TASK_NUMBER ='||p_SUB_TASK_NUMBER);  
  WHEN OTHERS THEN
   p_ID := 0;
    ROLLBACK;
    p_PStatus := 'Error inserting SUB_TASKS '||SQLERRM ;
      SP_INSERT_AUDIT( p_CREATED_BY,'ERROR PKG_SUB_TASKS.insert_SUB_TASKS'||'  SQLERRM ='||SQLERRM);  
  END insert_SUB_TASKS;
  -- update_SUB_TASKS
  PROCEDURE Update_SUB_TASKS(
      p_SUB_TASKS_ID        IN SUB_TASKS.SUB_TASKS_ID%TYPE DEFAULT NULL,      
      p_SUB_TASK_NUMBER        IN SUB_TASKS.SUB_TASK_NUMBER%TYPE DEFAULT NULL,
      p_SUB_TASK_TITLE         IN SUB_TASKS.SUB_TASK_TITLE%TYPE DEFAULT NULL,
      p_START_DATE               IN SUB_TASKS.START_DATE%TYPE DEFAULT NULL,
      p_END_DATE                 IN SUB_TASKS.END_DATE%TYPE DEFAULT NULL,
      p_DESCRIPTION              IN SUB_TASKS.DESCRIPTION%TYPE DEFAULT NULL,
      p_ORGANIZATION             IN SUB_TASKS.ORGANIZATION%TYPE DEFAULT NULL,
      p_FAA_POC                  IN SUB_TASKS.FAA_POC%TYPE DEFAULT NULL,      
      p_Status                   IN SUB_TASKS.Status%TYPE DEFAULT NULL,
      p_ST_FEE                   IN SUB_TASKS.ST_FEE%TYPE DEFAULT 0,      
      p_LAST_MODIFIED_BY         IN SUB_TASKS.LAST_MODIFIED_BY%TYPE DEFAULT NULL,      
      p_PStatus OUT VARCHAR2 ) 
      IS
  BEGIN
    SP_INSERT_AUDIT( P_LAST_MODIFIED_BY,'PKG_SUB_TASKS.Update_SUB_TASKS p_SUB_TASKS_ID='||p_SUB_TASKS_ID);
    Update SUB_TASKS           
    SET        
        SUB_TASK_NUMBER = p_SUB_TASK_NUMBER ,
        SUB_TASK_TITLE  = p_SUB_TASK_TITLE ,
        START_DATE  = p_START_DATE ,
        END_DATE = p_END_DATE ,
        DESCRIPTION = p_DESCRIPTION ,
        ORGANIZATION = p_ORGANIZATION ,
        FAA_POC = p_FAA_POC , 
        Status = p_Status ,
        ST_FEE = p_ST_FEE ,
        LAST_MODIFIED_BY = P_LAST_MODIFIED_BY ,
        LAST_MODIFIED_ON = sysdate() 
        WHERE SUB_TASKS_ID = p_SUB_TASKS_ID;
    IF SQL%FOUND THEN
      SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,' SUCCESS PKG_SUB_TASKS.Update_SUB_TASKS'||' Updated  SUB_TASKS with p_SUB_TASK_NUMBER ='||p_SUB_TASK_NUMBER);
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN 
 
    ROLLBACK;
    p_PStatus := 'Error updating Sub Task order, Sub Task order number ' ||P_SUB_TASK_NUMBER ||'  is already used. ';
      SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'PKG_SUB_TASKS.Update_SUB_TASKS'||' Attempt to update  SUB_TASKS with SUB_TASK_NUMBER ='||p_SUB_TASK_NUMBER);  
  WHEN OTHERS THEN
   
    ROLLBACK;
    p_PStatus := 'Error updating SUB_TASKS '||SQLERRM ;
      SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'ERROR PKG_SUB_TASKS.Update_SUB_TASKS'||'  SQLERRM ='||SQLERRM);  
  END Update_SUB_TASKS;


 PROCEDURE SP_GET_STCLINS(
    P_SubTaskID                   NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID           NUMBER DEFAULT 0 ,
    p_UserId                   VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_STCLINS
  Author: Sridhar Kommana
  Date Created : 08/13/2015
  Purpose:  Get Clin hours and type info for a sub-task
  Update history:
  */
  p_status VARCHAR2(100);
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_SUB_TASKS.SP_GET_STCLINS: Get sub-task CLIN details P_SubTaskID='||P_SubTaskID||  'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID);
  --pkg_work_orders.Delete_ST_CLINS_SESSION(p_UserId,p_status);
  OPEN REC_CURSOR FOR
  SELECT DISTINCT
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_NUMBER_DISP, NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, LABOR_CATEGORY_TITLE, 
    CLIN_TYPE_DISP, SUM(ST_CLIN_HOURS) ST_CLIN_HOURS , ST_CLIN_Rate, SUM(ST_CLIN_AMOUNT) ST_CLIN_AMOUNT
  FROM
          (
        SELECT C.CLIN_NUMBER,
        SC.SUB_CLIN_NUMBER,
        SC.SUB_CLIN_TYPE ,
        C.CLIN_TYPE ,
        NVL(ST_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) AS CLIN_TYPE_DISP,
        C.CLIN_SUB_CLIN ,
        C.CLIN_TITLE ,
        SC.SUB_CLIN_TITLE ,
        0 LABOR_CATEGORY_ID,
        ''                                              AS LABOR_CATEGORY_TITLE ,
        NVL(C.CLIN_HOURS,0) + NVL(SC.SUB_CLIN_HOURS,0)  AS CLIN_HOURS,
        NVL(C.CLIN_RATE,0)  + NVL(SC.SUB_CLIN_RATE,0)   AS CLIN_RATE,
        NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS CLIN_AMOUNT,
        W.STC_ID,
        WORK_ORDERS_ID,
        NVL(W.CLIN_HOURS,0) ST_CLIN_HOURS,
        ST_Rate AS ST_CLIN_RATE,
        NVL(W.CLIN_AMOUNT,0) ST_CLIN_AMOUNT ,
        C.LABOR_RATE_TYPE,
        SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
        RATE_TYPE
      FROM POP_CLIN C
      LEFT OUTER JOIN SUB_CLIN SC
      ON (SC.CLIN_ID = C.CLIN_ID )
      INNER JOIN PERIOD_OF_PERFORMANCE POP
      ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
      INNER JOIN SUB_TASKS_CLINS W
      ON ( (W.CLIN_ID       = C.CLIN_ID  AND W.SUB_CLIN_ID     = SC.SUB_CLIN_ID) OR ( W.CLIN_ID        = C.CLIN_ID  AND (W.SUB_CLIN_ID   IS NULL   OR W.SUB_CLIN_ID      =0) ) )
      AND (W.WORK_ORDERS_ID = p_WORK_ORDERS_ID ) 
      AND (W.FK_Sub_Tasks_ID = P_SubTaskID OR P_SubTaskID=0)
UNION
    SELECT 
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      'Labor' AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE ,
      CLC.LABOR_CATEGORY_ID,
      CLC.LABOR_CATEGORY_TITLE , --L.CATEGORY_NAME AS DESCRIPTION,
      NVL(C.CLIN_HOURS,0) + NVL(SC.SUB_CLIN_HOURS,0)  AS CLIN_HOURS,
      NVL(C.CLIN_RATE,0)  + NVL(SC.SUB_CLIN_RATE,0)   AS CLIN_RATE,
      NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS CLIN_AMOUNT,
      W.ST_LABOR_CATEGORY_ID STC_ID,
      WORK_ORDERS_ID,
      NVL(W.LABOR_CATEGORY_HOURS,0) ST_CLIN_HOURS,
      NVL(W.LABOR_CATEGORY_Rate,0) ST_CLIN_RATE,
      LC_AMOUNT AS ST_CLIN_AMOUNT ,
      C.LABOR_RATE_TYPE,
      SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
      RATE_TYPE
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC
    ON (SC.CLIN_ID = C.CLIN_ID)
    INNER JOIN PERIOD_OF_PERFORMANCE POP
    ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN ST_LABOR_CATEGORY W
    ON ( W.CLIN_ID = C.CLIN_ID
    OR ( W.CLIN_ID = SC.CLIN_ID ))
    INNER JOIN CLIN_LABOR_CATEGORY CLC
    ON CLC.LABOR_CATEGORY_ID    = W.LABOR_CATEGORY_ID
    AND CLC.CLIN_ID             = W.CLIN_ID
    AND (W.WORK_ORDERS_ID       = p_WORK_ORDERS_ID )
    AND (W.Sub_Tasks_ID = P_SubTaskID OR P_SubTaskID=0)
    ) TBLCLINS
  GROUP BY --- STC_ID,
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER
    ||SUB_CLIN_NUMBER,CLIN_NUMBER ) , NVL(SUB_CLIN_TITLE,CLIN_TITLE) , LABOR_CATEGORY_TITLE, CLIN_TYPE_DISP, ST_CLIN_Rate
  ORDER BY 1 ;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
  SELECT   0 SUB_CLIN_NUMBER_DISP, 0 CLIN_TITLE_DISP, 0 LABOR_CATEGORY_TITLE, 0 CLIN_TYPE_DISP, 0 ST_CLIN_HOURS , 0 ST_CLIN_Rate, 0 ST_CLIN_AMOUNT from dual;
END SP_GET_STCLINS;

PROCEDURE SP_GET_STC_TYPE_COUNTS(
    p_UserId       VARCHAR2 DEFAULT NULL,
    p_SUB_TASKS_ID NUMBER DEFAULT 0 ,
    -- p_WORK_ORDERS_ID NUMBER DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_STC_TYPE_COUNTS
  Author: Sridhar Kommana
  Date Created : 11/14/2015
  Purpose:  group counts for different types of clin
  Update history:
  */
  vCount NUMBER:=0;
BEGIN
  SELECT COUNT(SUB_TASKS_ID)
  INTO vCount
  FROM SUB_TASKS
  WHERE SUB_TASKS_ID = p_SUB_TASKS_ID;
  IF vCount          > 0 THEN
    BEGIN
      OPEN REC_CURSOR FOR SELECT NVL(SUM(DECODE(clin_type,'Labor', Hours)),0)
    AS
      LaborHours,
      NVL(SUM(DECODE(clin_type,'Labor', Amt)),0)
    AS
      LaborAmt,
      NVL(SUM(DECODE(clin_type,'Material', Hours)),0)
    AS
      MaterialCount,
      NVL(SUM(DECODE(clin_type,'Material', Amt)),0)
    AS
      MaterialAmt,
      NVL(SUM(DECODE(clin_type,'Travel', Amt)),0)
    AS
      TravelAmt ,
      NVL(SUM(DECODE(clin_type,'ODC', Amt)),0)
    AS
      ODCAmt,
      NVL(ST_FEE,0) ST_FEE ,
      --nvl(AMOUNT_FUNDED,0)
      (
      SELECT NVL(SUM(AMOUNT),0)
      FROM LSD_WO_FUNDS LWF
      INNER JOIN SUB_TASKS ST
      ON LWF.WORK_ORDERS_ID = ST.WORK_ORDERS_ID
      AND LWF.SUB_TASKS_ID  = ST.SUB_TASKS_ID
      WHERE ST.SUB_TASKS_ID = p_SUB_TASKS_ID      
      )
    AS
      AMOUNT_FUNDED FROM
      (SELECT STC.ST_CLIN_TYPE AS clin_type ,
        FK_SUB_TASKS_ID,
        NVL(SUM(STC.clin_hours),0)  AS Hours,
        NVL(SUM(STC.clin_Amount),0) AS Amt,
        ST_FEE
      FROM SUB_TASKS_CLINS STC
      INNER JOIN SUB_TASKS WO
      ON SUB_TASKS_ID      = FK_SUB_TASKS_ID
      AND (FK_SUB_TASKS_ID = p_SUB_TASKS_ID)
        --LEFT OUTER JOIN LSD_WO_FUNDS LWF
        --ON LWF.SUB_TASKS_ID  = FK_SUB_TASKS_ID
      WHERE (STC.ST_CLIN_TYPE IN ( 'Labor', 'Material','Travel','ODC'))
      GROUP BY STC.ST_CLIN_TYPE,
        FK_SUB_TASKS_ID ,
        ST_FEE
      --LWF.SUB_TASKS_ID
      UNION ALL -- Labor category portion
      SELECT 'Labor' AS clin_type ,
        WLC.SUB_TASKS_ID FK_SUB_TASKS_ID,
        NVL(SUM(WLC.LABOR_CATEGORY_hours),0) AS Hours,
        NVL(SUM(WLC.LC_Amount),0)            AS Amt,
        ST_FEE
      FROM ST_LABOR_CATEGORY WLC
      INNER JOIN SUB_TASKS WO
      ON WO.SUB_TASKS_ID   = WLC.SUB_TASKS_ID
      AND WLC.SUB_TASKS_ID = p_SUB_TASKS_ID
        --LEFT OUTER JOIN LSD_WO_FUNDS LWF
        --ON LWF.SUB_TASKS_ID   = WO.SUB_TASKS_ID
      GROUP BY 'Labor' ,
        WLC.SUB_TASKS_ID,
        ST_FEE
      ) tblCounts GROUP BY ST_FEE ;--, AMOUNT_FUNDED ;
    END;
  ELSE
    OPEN REC_CURSOR FOR SELECT 0
  AS
    LaborHours,
    0
  AS
    LaborAmt,
    0
  AS
    MaterialCount,
    0
  AS
    MaterialAmt,
    0
  AS
    TravelAmt,
    0
  AS
    ODCAmt ,
    0
  AS
    ST_FEE ,
    0
  AS
    AMOUNT_FUNDED FROM dual;
  END IF;
  SP_INSERT_AUDIT(p_UserId, 'PKG_SUB_TASKS.SP_GET_STC_TYPE_COUNTS-Get group counts of Labor, ODC, Travel, Material  for SUB_TASKS_ID='|| p_SUB_TASKS_ID);
  --SP_INSERT_AUDIT(p_UserId,  'PKG_SUB_TASKS.SP_GET_STC_TYPE_COUNTS p_SUB_TASKS_ID='|| p_SUB_TASKS_ID);
EXCEPTION
WHEN NO_DATA_FOUND THEN
  OPEN REC_CURSOR FOR SELECT 0
AS
  LaborHours,
  0
AS
  LaborAmt,
  0
AS
  MaterialCount,
  0
AS
  MaterialAmt,
  0
AS
  TravelAmt,
  0
AS
  ODCAmt ,
  0
AS
  ST_FEE ,
  0
AS
  AMOUNT_FUNDED FROM dual;
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 0
AS
  LaborHours,
  0
AS
  LaborAmt,
  0
AS
  MaterialCount,
  0
AS
  MaterialAmt,
  0
AS
  TravelAmt,
  0
AS
  ODCAmt ,
  0
AS
  WO_FEE ,
  0
AS
  AMOUNT_FUNDED FROM dual;
END SP_GET_STC_TYPE_COUNTS;

PROCEDURE       sp_get_Sub_Task_Orders(
    p_UserId  varchar2 DEFAULT NULL,
    P_SUB_TASKS_ID NUMBER DEFAULT 0 ,
    P_Work_Orders_ID NUMBER DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_Sub_Task_Orders
  Author: Sridhar Kommana
  Date Created : 08/10/2015
  Purpose:  Get sub Task orders to get details when SUB_TASKS_ID is passed.
  Update history: 06/20/2016 by Sridhar Kommana: Added call to delete sessions to fix issue reported

  */
    p_status Varchar2(100) :=NULL;
BEGIN
 
    SP_INSERT_AUDIT(p_UserId, 'PKG_SUB_TASKS.SP_get_Sub_Task_Orders - Get sub task Orders details for P_SUB_TASKS_ID '||P_SUB_TASKS_ID );
    pkg_work_orders.Delete_WO_CLINS_SESSION(p_UserId,p_status);
      OPEN REC_CURSOR
      FOR
          SELECT    
            ST.SUB_TASKS_ID,
            ST.WORK_ORDERS_ID,
            ST.SUB_TASK_NUMBER,
            ST.SUB_TASK_TITLE,
            ST.SUB_TASK_NUMBER || '  -  ' ||  ST.SUB_TASK_TITLE ST_TEXT,

            ST.START_DATE,
            ST.END_DATE,
            ST.DESCRIPTION,
            ST.ORGANIZATION, PKG_WORK_ORDERS.FN_GET_ORG_TITLE_FROM_SP(WO.ORGANIZATION) ORG_TITLE,
            ST.FAA_POC,
            ST.PERIOD_OF_PERFORMANCE_ID,
            ST.Status,
            ST.ST_FEE, 
            WO.WORK_ORDER_NUMBER,
            WO.WORK_ORDER_TITLE,
            
           (
           (
            select nvl(sum(W.CLIN_HOURS),0)  from SUB_TASKS_CLINS W WHERE  W.WORK_ORDERS_ID = ST.WORK_ORDERS_ID AND (W.FK_SUB_TASKS_ID=ST.SUB_TASKS_ID)
            AND ST_CLIN_TYPE= 'Labor'
            
            )
            + (
             select nvl(sum(nvl(W.LABOR_CATEGORY_Hours,0))  ,0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID  AND (W.SUB_TASKS_ID=ST.SUB_TASKS_ID) 
             )
            
           ) 
            as ST_HOURS,
            ((select nvl(sum(W.CLIN_AMOUNT),0)  from SUB_TASKS_CLINS W WHERE   W.WORK_ORDERS_ID = ST.WORK_ORDERS_ID AND (W.FK_SUB_TASKS_ID=ST.SUB_TASKS_ID )) 
            + (select nvl(sum(nvl(W.LC_AMOUNT,0))  ,0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID  AND (W.SUB_TASKS_ID=ST.SUB_TASKS_ID) )
            ) as ST_AMOUNT  , 
            (
       --SELECT TO_CHAR( NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' )
       SELECT   NVL(SUM(LWF.AMOUNT), 0 ) 
        FROM LSD_WO_FUNDS LWF
        WHERE -- POP.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND
          LWF.SUB_TASKS_ID =ST.SUB_TASKS_ID
        )
      AS
        ALLOCATED
                     
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


PROCEDURE SP_GET_SUB_TASK_INFO(
          p_UserId  varchar2,
          P_Work_Orders_ID NUMBER DEFAULT 0 ,
          REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
    Procedure : SP_GET_SUB_TASK_INFO
    Author: Srihari Gokina
    Date Created : 05/19/2016  
  Update history:
  05/20/2016 Sridhar Kommana Added new columns Sub_Task_Number_Disp and Sub_Task_Number
  05/20/2016 Sridhar Kommana Added Exception handler
  05/20/2016 Sridhar Kommana Removed Default null to userid
  */
    p_status Varchar2(100) :=NULL;
BEGIN
 
    SP_INSERT_AUDIT(p_UserId, 'PKG_SUB_TASKS.SP_GET_SUB_TASK_INFO - Get sub task INFO  FOR Work_Orders_ID '||P_Work_Orders_ID );
  
     OPEN REC_CURSOR
      FOR
          SELECT  SUB_TASKS_ID, Sub_Task_Number, SUB_TASKS_ID||'~'||Sub_Task_Number as Sub_Task_Number_Disp, SUB_TASK_TITLE                     
          FROM SUB_TASKS  
          WHERE Work_Orders_ID = P_Work_Orders_ID;       
    EXCEPTION WHEN OTHERS THEN
    OPEN REC_CURSOR FOR  SELECT
      NULL AS SUB_TASKS_ID, NULL AS Sub_Task_Number, NULL AS Sub_Task_Number_Disp, NULL AS SUB_TASK_TITLE  FROM SUB_TASKS   ;
          
END SP_GET_SUB_TASK_INFO;
 
 
PROCEDURE Delete_SUB_TASKS(
      p_SUB_TASKS_ID        IN SUB_TASKS.SUB_TASKS_ID%TYPE DEFAULT NULL,      
      P_LAST_MODIFIED_BY         IN SUB_TASKS.LAST_MODIFIED_BY%TYPE DEFAULT NULL,      
      p_PStatus OUT VARCHAR2 ) IS
  /*
  Procedure : Delete_SUB_TASKS
  Author: Sridhar Kommana
  Date Created : 05/02/2016
  Purpose:  delete sub-task for a given id
  Update history:
  05/02/2016 Sridhar Kommana Added status check before deleting.
  05/03/2016 Sridhar Kommana Added child_exists exception.
  */
    vStatus VARCHAR2(20);
    child_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(child_exists, -2292);
    /* raises ORA-02292 */
 

----
  BEGIN
    
    select status into  vStatus from SUB_TASKS           
            WHERE SUB_TASKS_ID = p_SUB_TASKS_ID ;
    SP_INSERT_AUDIT( P_LAST_MODIFIED_BY,'PKG_SUB_TASKS.Delete_SUB_TASKS p_SUB_TASKS_ID='||p_SUB_TASKS_ID ||'Status='||vStatus);

    IF vStatus = 'Active' THEN 
      p_PStatus := 'Cannot Delete Active Sub-task' ;
      RETURN;
    ELSE
      Delete from SUB_TASKS           
      WHERE SUB_TASKS_ID = p_SUB_TASKS_ID 
      and Status <> 'Active';
      IF SQL%FOUND THEN
        SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,' SUCCESS PKG_SUB_TASKS.Delete_SUB_TASKS'||' Deleted  SUB_TASKS with p_SUB_TASKS_ID ='||p_SUB_TASKS_ID);
        p_PStatus := 'SUCCESS' ;
        COMMIT;
      END IF;
   END IF; 
  EXCEPTION
  WHEN child_exists THEN
    p_PStatus := 'Cannot delete this sub-task, one or more clins exists for this sub-task.';
 
  WHEN OTHERS THEN
   
    ROLLBACK;
    p_PStatus := 'Error deleteing SUB_TASKS '||SQLERRM ;
      SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'ERROR PKG_SUB_TASKS.Delete_SUB_TASKS'||'  SQLERRM ='||SQLERRM);  
  END Delete_SUB_TASKS;    
END PKG_SUB_TASKS;
/