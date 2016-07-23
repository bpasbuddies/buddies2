CREATE OR REPLACE PACKAGE BODY eemrt."PKG_PERIOD_OF_PERFORMANCE" 
IS
-- insert_period_of_performanceert
PROCEDURE insert_period_of_performance(
    p_CONTRACT_NUMBER  IN period_of_performance.CONTRACT_NUMBER%type DEFAULT NULL,
    p_START_DATE       IN period_of_performance.START_DATE%type DEFAULT NULL,
    p_END_DATE         IN period_of_performance.END_DATE%type DEFAULT NULL,
    p_STATUS           IN period_of_performance.STATUS%type DEFAULT NULL,
    p_POP_TYPE         IN period_of_performance.POP_TYPE%type DEFAULT NULL,
 --   p_CEILING_HOURS    IN period_of_performance.CEILING_HOURS%type DEFAULT NULL,
    p_COMMITTED_HOURS  IN period_of_performance.COMMITTED_HOURS%type DEFAULT NULL,
    p_USED_HOURS       IN period_of_performance.USED_HOURS%type DEFAULT NULL,
 --   p_CEILING_AMOUNT   IN period_of_performance.CEILING_AMOUNT%type DEFAULT NULL,
    p_OBLIGATED_AMOUNT IN period_of_performance.OBLIGATED_AMOUNT%type DEFAULT NULL,
    p_EXPENDED_AMOUNT  IN period_of_performance.EXPENDED_AMOUNT%type DEFAULT NULL,
    p_CREATED_BY       IN period_of_performance.CREATED_BY%type DEFAULT NULL,
    p_PStatus OUT VARCHAR2 )
IS
  vSEQ NUMBER := pop_seq.NEXTVAL;
BEGIN
  INSERT
  INTO PERIOD_OF_PERFORMANCE
    (
      PERIOD_OF_PERFORMANCE_ID,
      CONTRACT_NUMBER,
      START_DATE,
      END_DATE,
      STATUS,
      POP_TYPE,
   --   CEILING_HOURS,
      COMMITTED_HOURS,
      USED_HOURS,
   --   CEILING_AMOUNT,
      OBLIGATED_AMOUNT,
      EXPENDED_AMOUNT,
      CREATED_BY,
      CREATED_ON
    )
    VALUES
    (
      vSEQ,
      p_CONTRACT_NUMBER,
      p_START_DATE,
      p_END_DATE,
      p_STATUS,
      p_POP_TYPE,
   --   p_CEILING_HOURS,
      p_COMMITTED_HOURS,
      p_USED_HOURS,
   --   p_CEILING_AMOUNT,
      p_OBLIGATED_AMOUNT,
      p_EXPENDED_AMOUNT,
      p_CREATED_BY,
      sysdate()
    );
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    COMMIT;
  END IF;
  IF p_STATUS = 'Active' THEN 
        update period_of_performance
        SET 
            STATUS   = 'Inactive',
            LAST_MODIFIED_BY = 'System' ,
            LAST_MODIFIED_ON = sysdate()
        WHERE period_of_performance_ID <> vSEQ
        AND CONTRACT_NUMBER = p_CONTRACT_NUMBER
        AND STATUS <> 'Closed';
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN 
NULL;
 WHEN OTHERS THEN
  ROLLBACK;
  p_PStatus := 'Error inserting period_of_performance' ;
END;

-- update_period_of_performanceate
PROCEDURE update_period_of_performance
  (
    p_period_of_performance_ID IN period_of_performance.period_of_performance_ID%type ,
--    p_CONTRACT_NUMBER  IN period_of_performance.CONTRACT_NUMBER%type DEFAULT NULL,
    p_START_DATE       IN period_of_performance.START_DATE%type DEFAULT NULL,
    p_END_DATE         IN period_of_performance.END_DATE%type DEFAULT NULL,
    p_STATUS           IN period_of_performance.STATUS%type DEFAULT NULL,
    p_POP_TYPE         IN period_of_performance.POP_TYPE%type DEFAULT NULL,
 --   p_CEILING_HOURS    IN period_of_performance.CEILING_HOURS%type DEFAULT NULL,
    p_COMMITTED_HOURS  IN period_of_performance.COMMITTED_HOURS%type DEFAULT NULL,
    p_USED_HOURS       IN period_of_performance.USED_HOURS%type DEFAULT NULL,
  --  p_CEILING_AMOUNT   IN period_of_performance.CEILING_AMOUNT%type DEFAULT NULL,
    p_OBLIGATED_AMOUNT IN period_of_performance.OBLIGATED_AMOUNT%type DEFAULT NULL,
    p_EXPENDED_AMOUNT  IN period_of_performance.EXPENDED_AMOUNT%type DEFAULT NULL,
    p_LAST_MODIFIED_BY         IN period_of_performance.LAST_MODIFIED_BY%type DEFAULT NULL ,
    p_PStatus                   OUT VARCHAR2   )
IS
BEGIN
  update period_of_performance
  SET 
--      CONTRACT_NUMBER   = p_CONTRACT_NUMBER,
      START_DATE   = p_START_DATE,
      END_DATE   = p_END_DATE,
      STATUS   = p_STATUS,
      POP_TYPE   = p_POP_TYPE,
  --    CEILING_HOURS   = p_CEILING_HOURS,
      COMMITTED_HOURS = p_COMMITTED_HOURS,
      USED_HOURS    =   p_USED_HOURS,
  --    CEILING_AMOUNT   = p_CEILING_AMOUNT,
      OBLIGATED_AMOUNT = p_OBLIGATED_AMOUNT ,
      EXPENDED_AMOUNT  = p_EXPENDED_AMOUNT,
      LAST_MODIFIED_BY = p_LAST_MODIFIED_BY,
      LAST_MODIFIED_ON = sysdate()
  WHERE period_of_performance_ID = p_period_of_performance_ID;
  IF SQL%FOUND THEN  
      p_PStatus := 'SUCCESS' ;    
      COMMIT;
  END IF;
  IF p_STATUS = 'Active' THEN 
        update period_of_performance
        SET 
            STATUS   = 'Inactive',
            LAST_MODIFIED_BY = 'System' ,
            LAST_MODIFIED_ON = sysdate()
        WHERE period_of_performance_ID <> p_period_of_performance_ID
        AND CONTRACT_NUMBER = ( select CONTRACT_NUMBER from period_of_performance where period_of_performance_ID = p_period_of_performance_ID and rownum=1);
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN 
NULL;  
  WHEN OTHERS
    THEN 
     ROLLBACK;
     p_PStatus := 'Error updating period_of_performance' ;      
END;
-- delete_period_of_performance
PROCEDURE delete_period_of_performance(
    p_period_of_performance_ID IN period_of_performance.period_of_performance_ID%type , 
    p_PStatus                   OUT VARCHAR2  )
IS
BEGIN
  delete 
  FROM period_of_performance
  WHERE period_of_performance_ID = p_period_of_performance_ID;
  IF SQL%FOUND THEN  
      p_PStatus := 'SUCCESS' ;    
      COMMIT;
  END IF;  
  EXCEPTION  WHEN OTHERS
    THEN 
     ROLLBACK;
     p_PStatus := 'Error deleting period_of_performance' ;    
END;


 PROCEDURE sp_get_pop(
    p_UserId                   VARCHAR2 DEFAULT NULL,
    p_Contract_NUMBER          VARCHAR2 DEFAULT NULL ,
    P_PERIOD_OF_PERFORMANCE_ID VARCHAR2 DEFAULT NULL,
    sum_cursor OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_pop
  Author: Sridhar Kommana
  Date Created : 11/05/2014
  Purpose:  Get POP Details for a given contract or POPID
  Update history:
  sridhar kommana :
  1) 07/16/2015 : Modified minus counts from WORK_ORDERS_CLINS and WO_LABOR_CATEGORY
  2) 08/15/2015 : Modified query minus from Sub-Task tables
  3) 01/14/2016 : Added Invoice_Amount  
  4) 07/01/2016 : Added Reamining hours correction 
  */
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'sp_get_pop: Get Period of performance details for contract '||p_Contract_NUMBER ||' P_PERIOD_OF_PERFORMANCE_ID = '||P_PERIOD_OF_PERFORMANCE_ID );
  --SP_INSERT_AUDIT(p_UserId, 'sp_get_pop '||p_Contract_NUMBER);
  OPEN sum_cursor FOR 
  SELECT PERIOD_OF_PERFORMANCE_ID, POP_TYPE_LABEL, CONTRACT_NUMBER, vendor, START_DATE, END_DATE, STATUS , POP_TYPE, CEILING_HOURS, COMMITTED_HOURS, USED_HOURS, BALANCE_HOURS, CEILING_AMOUNT, OBLIGATED_AMOUNT, 
         EXPENDED_AMOUNT,BALANCE_AMOUNT,  invoice_amount , INVOICE_LABOR_HOURS, (CEILING_AMOUNT - invoice_amount) AS Remaining_Amount, (CEILING_HOURS - INVOICE_LABOR_HOURS) AS Remaining_Hours
  FROM           
  (SELECT PERIOD_OF_PERFORMANCE_ID, pop_TYPE
AS
  POP_TYPE_LABEL, c.CONTRACT_NUMBER, c.vendor, p.START_DATE, p.END_DATE, p.STATUS , p.POP_TYPE,
  (SELECT NVL(SUM(CLIN_HOURS),0) + NVL(SUM(SUB_CLIN_HOURS),0)
  FROM POP_CLIN PC
  LEFT OUTER JOIN SUB_CLIN S
  ON S.clin_id                      = PC.clin_id
  WHERE PC.period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  )
AS
  CEILING_HOURS, (
  (SELECT NVL(SUM(CLIN_HOURS),0)
  FROM WORK_ORDERS_CLINS WOC
  WHERE WOC.FK_period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  AND WOC.CLIN_ID                      IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    AND C.Clin_Type                 <> 'Contract'
    )
  ) +
  (SELECT NVL(SUM(WLC.LABOR_CATEGORY_HOURS),0)
  FROM WO_LABOR_CATEGORY WLC
  WHERE WLC.CLIN_ID IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) +
  (SELECT NVL(SUM(CLIN_HOURS),0)
  FROM SUB_TASKS_CLINS WOC
  WHERE WOC.FK_period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  AND WOC.CLIN_ID                      IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    AND C.Clin_Type                 <> 'Contract'
    )
  ) +
  (SELECT NVL(SUM(WLC.LABOR_CATEGORY_HOURS),0)
  FROM ST_LABOR_CATEGORY WLC
  WHERE WLC.CLIN_ID IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) )
AS
  COMMITTED_HOURS, 0
AS
  "USED_HOURS",
  (SELECT NVL(SUM(CLIN_HOURS),0) + NVL(SUM(SUB_CLIN_HOURS),0)
  FROM POP_CLIN PC
  LEFT OUTER JOIN SUB_CLIN S
  ON S.clin_id                      = PC.clin_id
  WHERE PC.period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  ) -
  (
  (SELECT NVL(SUM(CLIN_HOURS),0)
  FROM WORK_ORDERS_CLINS WOC
  WHERE WOC.FK_period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  AND WOC.CLIN_ID                      IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    AND C.Clin_Type                 <> 'Contract'
    )
  ) +
  (SELECT NVL(SUM(WLC.LABOR_CATEGORY_HOURS),0)
  FROM WO_LABOR_CATEGORY WLC
  WHERE WLC.CLIN_ID IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) +
  (SELECT NVL(SUM(CLIN_HOURS),0)
  FROM SUB_TASKS_CLINS WOC
  WHERE WOC.FK_period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  AND WOC.CLIN_ID                      IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    AND C.Clin_Type                 <> 'Contract'
    )
  ) +
  (SELECT NVL(SUM(WLC.LABOR_CATEGORY_HOURS),0)
  FROM ST_LABOR_CATEGORY WLC
  WHERE WLC.CLIN_ID IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) )
AS
  BALANCE_HOURS,
  (SELECT NVL(SUM(CLIN_AMOUNT),0) + NVL(SUM(SUB_CLIN_AMOUNT),0)
  FROM POP_CLIN PC
  LEFT OUTER JOIN SUB_CLIN S
  ON S.clin_id                      = PC.clin_id
  WHERE PC.period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  )AS  CEILING_AMOUNT, 
  p.OBLIGATED_AMOUNT, --Amount ceiling
  P.EXPENDED_AMOUNT,                  -- Total invoice Amount  ,
  (SELECT NVL(SUM(CLIN_AMOUNT),0) + NVL(SUM(SUB_CLIN_AMOUNT),0)
  FROM POP_CLIN PC
  LEFT OUTER JOIN SUB_CLIN S
  ON S.clin_id                      = PC.clin_id
  WHERE PC.period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  ) -
  (
  (SELECT NVL(SUM(CLIN_AMOUNT),0)
  FROM WORK_ORDERS_CLINS WOC
  WHERE WOC.FK_period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  AND WOC.CLIN_ID                      IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) +
  (SELECT NVL(SUM( WLC.LC_AMOUNT),0)
  FROM WO_LABOR_CATEGORY WLC
  WHERE WLC.CLIN_ID IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) +
  (SELECT NVL(SUM(CLIN_AMOUNT),0)
  FROM SUB_TASKS_CLINS WOC
  WHERE WOC.FK_period_of_performance_id = p.PERIOD_OF_PERFORMANCE_ID
  AND WOC.CLIN_ID                      IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) +
  (SELECT NVL(SUM( WLC.LC_AMOUNT),0)
  FROM ST_LABOR_CATEGORY WLC
  WHERE WLC.CLIN_ID IN
    (SELECT C.CLIN_ID
    FROM pop_clin c
    WHERE c.PERIOD_OF_PERFORMANCE_ID = p.PERIOD_OF_PERFORMANCE_ID
    )
  ) )
AS
  BALANCE_AMOUNT , 
  (SELECT NVL(sum(invoice_amount),0) from invoice where Period_Of_Performance_Id = P_PERIOD_OF_PERFORMANCE_ID) as invoice_amount ,
  (SELECT NVL(SUM(INVOICE_HOURS_QTY),0) from invoice_detail WHERE 
  INVOICE_ID IN (SELECT INVOICE_ID from invoice where Period_Of_Performance_Id = P_PERIOD_OF_PERFORMANCE_ID )
    AND  Contract_Clin_Cost_Type = 'Labor' ) 
   AS INVOICE_LABOR_HOURS
  
  FROM contract c , PERIOD_OF_PERFORMANCE p
  WHERE (c.contract_number = p_Contract_NUMBER OR P_Contract_Number IS NULL) AND
  (P.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR P_PERIOD_OF_PERFORMANCE_ID IS NULL) AND
  c.CONTRACT_NUMBER = p.CONTRACT_NUMBER  ) TAB
  order by PERIOD_OF_PERFORMANCE_ID ASC;
END sp_get_pop;

PROCEDURE sp_get_pop_type(    p_UserId  varchar2 DEFAULT NULL,
  P_CONTRACT_NUMBER VARCHAR2, 

    pop_cursor OUT SYS_REFCURSOR)
IS
  /*
  Procedure : sp_get_pop_type
  Author: Sridhar Kommana
  Date Created : 05/07/2015
  Purpose:  Get pop type for current contract
  Update history:
 
  */
BEGIN
  
    SP_INSERT_AUDIT(p_UserId, 'sp_get_pop_type - Get POP Type List for a contract '||p_Contract_NUMBER  );
 

  OPEN pop_cursor FOR 
    select PERIOD_OF_PERFORMANCE_ID , POP_TYPE  , status from PERIOD_OF_PERFORMANCE where CONTRACT_NUMBER = P_CONTRACT_NUMBER  
    --union     select POP_TYPE ||status pop_type , status from PERIOD_OF_PERFORMANCE where CONTRACT_NUMBER = P_CONTRACT_NUMBER  and status<>'Active'
    order by status;
  
EXCEPTION
WHEN OTHERS THEN
   OPEN pop_cursor FOR  select 1 as POP_TYPE from PERIOD_OF_PERFORMANCE ;
END sp_get_pop_type;

END pkg_period_of_performance;
/