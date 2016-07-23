CREATE OR REPLACE FUNCTION eemrt.GET_CLIN_BALANCE(p_clin_id NUMBER ) RETURN NUMBER AS 
V_BALANCE_AMOUNT NUMBER(18,2);
BEGIN
 SP_INSERT_AUDIT('p_Admin' , 'GET_CLIN_BALANCE p_clin_id='|| p_clin_id);          
select SUM_CLIN_AMOUNT - 
--(SELECT nvl(SUM(WOC.CLIN_AMOUNT),0) FROM WORK_ORDERS_CLINS WOC WHERE WOC.clin_id = p_clin_id) 
     (SELECT nvl(SUM(NVL(WOC.CLIN_AMOUNT,0)),0)  FROM WORK_ORDERS_CLINS WOC    WHERE 
  --WOC.FK_period_of_performance_id = C.PERIOD_OF_PERFORMANCE_ID    and
  exists (select 1 from sub_clin scc where scc.sub_clin_id = WOC.SUB_CLIN_ID and scc.clin_id = p_clin_id))
                   --   and FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID                    
                      
 
 
 INTO V_BALANCE_AMOUNT
 FROM
      (
      SELECT  (SUM(NVL(PC.CLIN_AMOUNT,0)) + SUM(NVL(S.SUB_CLIN_AMOUNT,0))) as SUM_CLIN_AMOUNT
      FROM POP_CLIN PC  
      LEFT OUTER JOIN SUB_CLIN S  
      ON S.clin_id = PC.clin_id
      WHERE PC.clin_id = p_clin_id
   --   GROUP BY PC.clin_id
      ) TBLPCS;     
 
  RETURN V_BALANCE_AMOUNT;
END GET_CLIN_BALANCE;
/