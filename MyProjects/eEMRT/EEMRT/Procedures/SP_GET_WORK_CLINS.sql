CREATE OR REPLACE PROCEDURE eemrt.sp_get_Work_Clins(
  P_WORK_ORDER_ID NUMBER DEFAULT 0 , 
    P_WOC_ID NUMBER DEFAULT 0 ,     
    P_POP_ID NUMBER DEFAULT 0 ,  
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN REC_CURSOR 
  FOR 
  SELECT    
        WOC_ID, FK_WORK_ORDERS_ID, FK_PERIOD_OF_PERFORMANCE_ID, WO.WORK_ORDER_NUMBER, W.CLIN_ID, P.CLIN_NUMBER,
        W.SUB_CLIN_ID, S.SUB_CLIN_NUMBER, W.CLIN_HOURS WO_HOURS , W.CLIN_AMOUNT WO_AMOUNT
  FROM WORK_ORDERS_CLINS W
  INNER JOIN WORK_ORDERS WO
    ON WO.WORK_ORDERS_ID = W.FK_WORK_ORDERS_ID
  LEFT JOIN POP_CLIN P ON
      W.CLIN_ID = P.CLIN_ID
  LEFT JOIN SUB_CLIN S ON
      W.sub_clin_id = S.sub_clin_id
  WHERE (WOC_ID = P_WOC_ID
    OR P_WOC_ID = 0)
    AND (FK_WORK_ORDERS_ID = P_WORK_ORDER_ID
      OR P_WORK_ORDER_ID = 0)
  AND (FK_PERIOD_OF_PERFORMANCE_ID
        = P_POP_ID OR P_POP_ID= 0) 
  ORDER BY 1;
  
EXCEPTION
WHEN OTHERS THEN
     OPEN REC_CURSOR 
     FOR SELECT  1 as WOC_ID, 1 as FK_WORK_ORDERS_ID, 1 as FK_PERIOD_OF_PERFORMANCE_ID, 1 as WORK_ORDER_NUMBER, 1 as CLIN_ID, 1 as CLIN_NUMBER,
        1 as SUB_CLIN_ID, 1 as SUB_CLIN_NUMBER, 1 as WO_HOURS , 1 as  WO_AMOUNT from dual;
END sp_get_Work_Clins;
/