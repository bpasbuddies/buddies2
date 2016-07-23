CREATE OR REPLACE PROCEDURE eemrt.SP_GET_WO_CLIN_DETAILS(
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_CLIN_ID VARCHAR2 DEFAULT NULL ,
    P_WOC_ID NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0 ,
    p_UserId VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WO_CLIN_DETAILS
  Author: Sridhar Kommana
  Date Created : 06/26/2015
  Purpose:  Get Clin details and type info for a work order
  Update history:
   */
BEGIN
   SP_INSERT_AUDIT(p_UserId, 'SP_GET_WO_CLIN_DETAILS: Get work order details P_CLIN_ID='||P_CLIN_ID|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);
 
   
  OPEN REC_CURSOR FOR 
  select  distinct
    CONTRACT_NUMBER, PERIOD_OF_PERFORMANCE_ID, POP_TYPE, CLIN_ID, sub_clin_id,  
    nvl(SUB_CLIN_NUMBER, CLIN_NUMBER)  CLIN_NUMBER_DISP , SUB_CLIN_NUMBER, CLIN_NUMBER,  DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) as SUB_CLIN_NUMBER_DISP,  LABOR_CATEGORY_ID, 
    (select CATEGORY_NAME from LABOR_CATEGORIES where LABOR_CATEGORIES.CATEGORY_ID = LABOR_CATEGORY_ID ) as  DESCRIPTION,   
    CLIN_TYPE , SUB_CLIN_TYPE, CLIN_TYPE_DISP,
    CLIN_SUB_CLIN , CLIN_TITLE , SUB_CLIN_TITLE, nvl(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP,
    CLIN_HOURS, CLIN_RATE,CLIN_AMOUNT, FK_WORK_ORDERS_ID as WORK_ORDERS_ID, WOC_ID,  WO_CLIN_HOURS, 0 AS WO_LABOR_CATEGORY_ID,    
     WO_CLIN_AMOUNT, LABOR_RATE_TYPE, SC_LABOR_RATE_TYPE,     
      Available_Hours_Qty ,Available_Amount,  
      Remaining_Hours_Qty,Remaining_Amount, LC_Exists
  from (   
  SELECT POP.CONTRACT_NUMBER, POP_TYPE, C.CLIN_ID, SC.sub_clin_id, C.PERIOD_OF_PERFORMANCE_ID, C.CLIN_NUMBER, SC.SUB_CLIN_NUMBER, SC.SUB_CLIN_TYPE ,C.CLIN_TYPE , 
  NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP , 
  C.CLIN_SUB_CLIN , C.CLIN_TITLE , SC.SUB_CLIN_TITLE ,  C.LABOR_CATEGORY_ID,   --L.CATEGORY_NAME AS DESCRIPTION,  
  NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) AS  CLIN_HOURS, 
  NVL(C.CLIN_RATE,0)+ NVL(SC.SUB_CLIN_RATE,0) AS  CLIN_RATE,
  NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS  CLIN_AMOUNT,
  W.WOC_ID,FK_WORK_ORDERS_ID, nvl(W.CLIN_HOURS,0)   WO_CLIN_HOURS, 
  nvl(W.CLIN_AMOUNT,0)   WO_CLIN_AMOUNT ,  
  ---( DECODE((select DECODE(count(CLC.clin_id),0,'N','Y')  from  clin_labor_category clc where clc.clin_id= C.CLIN_ID) ,'Y',(select sum(wlc.LABOR_CATEGORY_RATE*wlc.LABOR_CATEGORY_HOURS) from WO_LABOR_CATEGORY wlc Where wlc.WORK_ORDERS_ID = w.FK_WORK_ORDERS_ID AND wlc.clin_id=c.clin_id ), W.CLIN_AMOUNT ))   as  WO_CLIN_AMOUNT ,  
  
 (NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) - nvl(W.CLIN_HOURS,0)) as  Available_Hours_Qty ,
 ( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) - nvl(W.CLIN_AMOUNT,0) ) as  Available_Amount,
  -- 1 as  WO_Hours_Qty, 1 as WO_Amount,
 (NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) - nvl(W.CLIN_HOURS,0)) as  Remaining_Hours_Qty, 
 ( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) - nvl(W.CLIN_AMOUNT,0) ) as  Remaining_Amount,
 (select DECODE(count(CLC.clin_id),0,'N','Y')  from  clin_labor_category clc where clc.clin_id= C.CLIN_ID) as  LC_Exists,       
  C.LABOR_RATE_TYPE, SC.LABOR_RATE_TYPE as SC_LABOR_RATE_TYPE, RATE_TYPE
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) 
  INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID  
  INNER JOIN WORK_ORDERS_CLINS W ON (W.CLIN_ID = C.CLIN_ID OR  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )
  AND (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID )
  AND (C.CLIN_ID = P_CLIN_ID OR P_CLIN_ID is NULL) 
  AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0) 
  ) TBLCLINS 
--  WHERE Available_Hours_Qty >0   or Available_Amount>0
  order by WOC_ID, clin_id ;
  EXCEPTION
  WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
          SELECT   1 as   CONTRACT_NUMBER,  1 as   PERIOD_OF_PERFORMANCE_ID, 1 as POP_TYPE, 1 as   CLIN_ID, 1 as   sub_clin_id,  
                   1 as   CLIN_NUMBER_DISP , 1 as   SUB_CLIN_NUMBER, 1 as    CLIN_NUMBER,  1 as   LABOR_CATEGORY_ID,  1 as   DESCRIPTION,   
                   1 as   CLIN_TYPE ,  1 as   SUB_CLIN_TYPE,  1 as   CLIN_TYPE_DISP,
                   1 as   CLIN_SUB_CLIN ,  1 as   CLIN_TITLE ,  1 as   SUB_CLIN_TITLE,  1 as    CLIN_TITLE_DISP,
                   1 as   CLIN_HOURS,  1 as   CLIN_RATE,  1 as   CLIN_AMOUNT, 1 as LABOR_RATE_TYPE, 1 as SC_LABOR_RATE_TYPE,   1 as   WOC_ID, 1 as FK_WORK_ORDERS_ID,   1 as   WO_CLIN_HOURS,    1 as   WO_CLIN_AMOUNT
                   , 1 as  Available_Hours_Qty ,1 as  Available_Amount, --1 as  WO_Hours_Qty, 1 as WO_Amount,
                   1 as  Remaining_Hours_Qty,1 as  Remaining_Amount,
                   1 as LC_Exists ,1 AS LABOR_RATE_TYPE,
                1 AS RATE_TYPE FROM dual;
END SP_GET_WO_CLIN_DETAILS;
/