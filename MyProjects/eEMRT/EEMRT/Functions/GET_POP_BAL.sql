CREATE OR REPLACE FUNCTION eemrt.GET_POP_BAL(p_PERIOD_OF_PERFORMANCE_ID NUMBER ) RETURN NUMBER AS 
V_BALANCE_AMOUNT NUMBER(18,2);
BEGIN
 SP_INSERT_AUDIT('p_Admin' , 'GET_POP_BAL p_PERIOD_OF_PERFORMANCE_ID='|| p_PERIOD_OF_PERFORMANCE_ID); 
 select 
  sum (distinct DECODE(CLIN_SUB_CLIN,'N',BALANCE_CLIN_HRS*CLIN_RATE,CLIN_AMOUNT-(
    select nvl(sum(clin_amount),0)
    from work_orders_clins woc
    where   exists (select 1 from sub_clin sc where sc.sub_clin_id = WOC.SUB_CLIN_ID 
    and FK_PERIOD_OF_PERFORMANCE_ID = PERIOD_OF_PERFORMANCE_ID) 
  ) )) into  V_BALANCE_AMOUNT
  from   
   (

   SELECT C.PERIOD_OF_PERFORMANCE_ID,  
   C.CLIN_SUB_CLIN ,    
   C.CLIN_RATE ,
  (
  SELECT SUM(NVL(CLIN_AMOUNT,0)) + SUM(NVL(SUB_CLIN_AMOUNT,0))  FROM POP_CLIN PC  LEFT OUTER JOIN SUB_CLIN S  ON S.clin_id     = PC.clin_id  WHERE PC.CLIN_ID = C.CLIN_ID  
  ) AS  CLIN_AMOUNT, 
    --DECODE(C.CLIN_TYPE,'Labor', 
    ((SELECT SUM(NVL(CLIN_HOURS,0))+SUM(NVL(SUB_CLIN_HOURS,0)) FROM POP_CLIN PC LEFT OUTER JOIN SUB_CLIN S ON S.clin_id = PC.clin_id WHERE PC.CLIN_ID = C.CLIN_ID ) 
    - NVL(  (SELECT SUM(NVL(WOC.CLIN_HOURS,0)) 
    FROM WORK_ORDERS_CLINS WOC  WHERE WOC.FK_period_of_performance_id = C.PERIOD_OF_PERFORMANCE_ID  AND (C.clin_id  = WOC.clin_id)  ),0) )
  --, 0 )
  AS  BALANCE_CLIN_HRS  
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID 
  INNER JOIN LABOR_CATEGORIES L ON L.CATEGORY_ID = C.LABOR_CATEGORY_ID
  AND (C.PERIOD_OF_PERFORMANCE_ID = p_PERIOD_OF_PERFORMANCE_ID) 
  
 ) TBLCLINS  ;
  RETURN V_BALANCE_AMOUNT;
END GET_POP_BAL;
/