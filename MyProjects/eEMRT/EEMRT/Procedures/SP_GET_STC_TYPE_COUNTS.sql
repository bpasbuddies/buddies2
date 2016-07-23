CREATE OR REPLACE PROCEDURE eemrt.SP_GET_STC_TYPE_COUNTS(
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
  SP_INSERT_AUDIT(p_UserId, 'SP_GET_STC_TYPE_COUNTS-Get group counts of Labor, ODC, Travel, Material  for SUB_TASKS_ID='|| p_SUB_TASKS_ID);
  --SP_INSERT_AUDIT(p_UserId,  'SP_GET_STC_TYPE_COUNTS p_SUB_TASKS_ID='|| p_SUB_TASKS_ID);
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
/