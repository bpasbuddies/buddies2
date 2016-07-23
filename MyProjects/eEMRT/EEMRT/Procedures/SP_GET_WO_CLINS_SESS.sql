CREATE OR REPLACE PROCEDURE eemrt.SP_GET_WO_CLINS_SESS(
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_CLIN_ID                  NUMBER DEFAULT NULL ,
    P_WOC_ID                   NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID           NUMBER DEFAULT 0 ,
    p_UserId                   VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WO_CLINS_SESS
  Author: Sridhar Kommana
  Date Created : 06/26/2015
  Purpose:  Get Clin details and type info for a work order session while creating a work order.
  Update history:
  */
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_GET_WO_CLINS_SESS: Get work order details P_CLIN_ID='||P_CLIN_ID|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);
  OPEN REC_CURSOR FOR SELECT DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER )AS SUB_CLIN_NUMBER_DISP, 
  NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, NULL AS   LABOR_CATEGORY_TITLE, NVL(WO_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) AS   CLIN_TYPE_DISP,
  W.CLIN_HOURS, WO_Rate, 
  W.CLIN_AMOUNT WO_CLIN_AMOUNT, 
  0 Remaining_Hours_Qty, 
  0 Remaining_Amount 
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID)

  INNER JOIN WORK_ORDERS_CLINS_SESSION W ON W.Clin_ID = C.CLIN_ID WHERE ( (W.CLIN_ID = C.CLIN_ID AND W.SUB_CLIN_ID = SC.SUB_CLIN_ID) 
  OR ( W.CLIN_ID = C.CLIN_ID AND (W.SUB_CLIN_ID IS NULL OR W.SUB_CLIN_ID =0) ) )
  --AND   (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID ) AND W.created_by=p_UserId AND (W.CLIN_ID = P_CLIN_ID OR P_CLIN_ID IS NULL) 
  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
  UNION ---Also include labor categories sessions
  SELECT
    --  DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) as SUB_CLIN_NUMBER_DISP,
    -- nvl(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP,
    CLIN_NUMBER AS SUB_CLIN_NUMBER_DISP,
    CLIN_TITLE CLIN_TITLE_DISP,
    CLC.LABOR_CATEGORY_TITLE,
    'Labor' AS CLIN_TYPE_DISP,
    NVL(W.LABOR_CATEGORY_HOURS,0) WO_CLIN_HOURS,
    NVL(W.LABOR_CATEGORY_Rate,0) WO_CLIN_RATE,
    LC_AMOUNT AS WO_CLIN_AMOUNT,
    0 Remaining_Hours_Qty,
    0 Remaining_Amount
  FROM POP_CLIN C --LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID)
    --INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
  INNER JOIN WO_LABOR_CATEGORY_SESSION W
  ON W.Clin_ID = C.CLIN_ID
  INNER JOIN CLIN_LABOR_CATEGORY CLC
  ON CLC.LABOR_CATEGORY_ID = W.LABOR_CATEGORY_ID
  AND CLC.CLIN_ID          = W.CLIN_ID
  WHERE W.CLIN_ID          = C.CLIN_ID
    --  ( (W.CLIN_ID = C.CLIN_ID AND  W.SUB_CLIN_ID = SC.SUB_CLIN_ID) OR ( W.CLIN_ID = C.CLIN_ID AND  (W.SUB_CLIN_ID Is NULL OR W.SUB_CLIN_ID =0) ) )
    ---AND (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.WORK_ORDERS_ID                 = p_WORK_ORDERS_ID )
  AND W.created_by                      =p_UserId
  AND (W.CLIN_ID                        = P_CLIN_ID
  OR P_CLIN_ID                         IS NULL)
  AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID  
  OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0);
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT NULL AS  CLIN_NUMBER_DISP FROM dual;
END SP_GET_WO_CLINS_SESS;
/