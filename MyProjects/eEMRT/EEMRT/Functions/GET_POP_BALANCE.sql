CREATE OR REPLACE FUNCTION eemrt.GET_POP_BALANCE(p_PERIOD_OF_PERFORMANCE_ID NUMBER ) RETURN NUMBER AS 
V_BALANCE_AMOUNT NUMBER(18,2);
BEGIN
 SP_INSERT_AUDIT('p_Admin' , 'GET_POP_BALANCE p_PERIOD_OF_PERFORMANCE_ID='|| p_PERIOD_OF_PERFORMANCE_ID); 
select SUM_CLIN_AMOUNT - (SELECT nvl(SUM(WOC.CLIN_AMOUNT),0) FROM WORK_ORDERS_CLINS WOC
 WHERE WOC.FK_PERIOD_OF_PERFORMANCE_ID = p_PERIOD_OF_PERFORMANCE_ID)  INTO V_BALANCE_AMOUNT
 FROM
      (
      SELECT PERIOD_OF_PERFORMANCE_ID,  (SUM(NVL(PC.CLIN_AMOUNT,0)) + SUM(NVL(S.SUB_CLIN_AMOUNT,0))) as SUM_CLIN_AMOUNT
      FROM POP_CLIN PC  
      LEFT OUTER JOIN SUB_CLIN S  
      ON S.clin_id = PC.clin_id
      WHERE PC.PERIOD_OF_PERFORMANCE_ID = p_PERIOD_OF_PERFORMANCE_ID
      GROUP BY PERIOD_OF_PERFORMANCE_ID
      ) TBLPCS;     
 
  RETURN V_BALANCE_AMOUNT;
END GET_POP_BALANCE;
/