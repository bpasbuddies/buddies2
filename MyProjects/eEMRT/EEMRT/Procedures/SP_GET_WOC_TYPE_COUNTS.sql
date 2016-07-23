CREATE OR REPLACE PROCEDURE eemrt.SP_GET_WOC_TYPE_COUNTS(
    p_UserId  varchar2 DEFAULT NULL,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WOC_TYPE_COUNTS
  Author: Sridhar Kommana
  Date Created : 11/05/2014
  Purpose:  group counts for different types of clin
  Update history:
  sridhar kommana :   
  1) 05/11/2015 : Added WO_FEE , AMOUNT_FUNDED to the data set
  2) 07/16/2015 : Modified query to fetch counts from WORK_ORDERS_CLINS and WO_LABOR_CATEGORY
  3) 08/15/2015 : Modified query to fetch totals from Sub-Task tables
  */
vCount NUMBER:=0;
BEGIN
 select count(WORK_ORDERS_ID) 
 into vCount
 from WORK_ORDERS 
 WHERE  WORK_ORDERS_ID = p_WORK_ORDERS_ID;
 if vCount > 0 then     
 BEGIN 
    OPEN REC_CURSOR FOR 
   select
          NVL(SUM(LaborHours),0)  as  LaborHours, 
          NVL(SUM(LaborAmt),0)  as  LaborAmt, 
          NVL(SUM(MaterialCount),0)  as  MaterialCount, 
          NVL(SUM(MaterialAmt),0)  as  MaterialAmt, 
          NVL(SUM(TravelAmt),0)  as  TravelAmt, 
          NVL(SUM(ODCAmt),0)  as  ODCAmt, 
          NVL(sum(WO_FEE),0)  as  WO_FEE, 
          NVL(SUM(AMOUNT_FUNDED),0) as  AMOUNT_FUNDED 
   FROM
   (   select
        nvl(SUM(DECODE(clin_type,'Labor', Hours)),0) as  LaborHours, 
        nvl(SUM(DECODE(clin_type,'Labor', Amt)),0)  as  LaborAmt, 
        nvl(SUM(DECODE(clin_type,'Material', Hours)),0) as  MaterialCount,       
        nvl(SUM(DECODE(clin_type,'Material', Amt)),0) as  MaterialAmt, 
        nvl(SUM(DECODE(clin_type,'Travel', Amt)),0) as  TravelAmt ,
        nvl(SUM(DECODE(clin_type,'ODC', Amt)),0) as  ODCAmt,
         NVL(WO_FEE,0) WO_FEE,
          (select   
        nvl(SUM(AMOUNT),0)  from LSD_WO_FUNDS LWF
      WHERE LWF.WORK_ORDERS_ID   = p_WORK_ORDERS_ID ) as AMOUNT_FUNDED
  
      from 
      ( 
 
       -- TASK ORDER CLINS 
     (           SELECT WOC.WO_CLIN_TYPE AS clin_type ,
                  FK_WORK_ORDERS_ID,
                  NVL(SUM(WOC.clin_hours),0)  AS Hours,
                  NVL(SUM(WOC.clin_Amount),0) AS Amt,
                   NVL(WO_FEE,0) as WO_FEE   
                FROM 
                WORK_ORDERS_CLINS WOC
                INNER JOIN WORK_ORDERS WO 
                ON WORK_ORDERS_ID = FK_WORK_ORDERS_ID
                AND (FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID)
                WHERE (WOC.WO_CLIN_TYPE   IN ( 'Labor', 'Material','Travel','ODC')
                )
                GROUP BY WOC.WO_CLIN_TYPE,
                  FK_WORK_ORDERS_ID ,
                  WO_FEE                 
       UNION   ALL -- Labor category portion for Work Orders
                SELECT 'Labor' AS clin_type ,
                  WLC.WORK_ORDERS_ID FK_WORK_ORDERS_ID,
                  NVL(SUM(WLC.LABOR_CATEGORY_hours),0) AS Hours,
                  NVL(SUM(WLC.LC_Amount),0)            AS Amt,
                    
                  NVL(WO_FEE,0) as WO_FEE 
 
                FROM WO_LABOR_CATEGORY WLC
                INNER JOIN WORK_ORDERS WO
                ON WO.WORK_ORDERS_ID = WLC.WORK_ORDERS_ID
                AND WLC.WORK_ORDERS_ID = p_WORK_ORDERS_ID 
                GROUP BY 'Labor' ,   WLC.WORK_ORDERS_ID,   WO_FEE)
       UNION ALL -- SUB-TASK CLINS 
                 ( SELECT  STC.ST_CLIN_TYPE AS clin_type ,
                          FK_SUB_TASKS_ID,
                          NVL(SUM(STC.clin_hours),0)  AS Hours,
                          NVL(SUM(STC.clin_Amount),0) AS Amt,
                           NVL(ST_FEE,0) as WO_FEE    
                  FROM SUB_TASKS_CLINS STC
                  INNER JOIN SUB_TASKS WO  ON SUB_TASKS_ID      = FK_SUB_TASKS_ID
                  AND (STC.WORK_ORDERS_ID = p_WORK_ORDERS_ID)
                        WHERE (STC.ST_CLIN_TYPE IN ( 'Labor', 'Material','Travel','ODC'))
                        GROUP BY STC.ST_CLIN_TYPE,
                          FK_SUB_TASKS_ID ,
                          ST_FEE )
                        --LWF.SUB_TASKS_ID
      UNION ALL -- Labor category portion for SUB-TASK Orders
              SELECT 'Labor' AS clin_type ,
                WLC.SUB_TASKS_ID FK_SUB_TASKS_ID,
                NVL(SUM(WLC.LABOR_CATEGORY_hours),0) AS Hours,
                NVL(SUM(WLC.LC_Amount),0)            AS Amt,
                NVL(ST_FEE,0) as WO_FEE   
              FROM ST_LABOR_CATEGORY WLC
              INNER JOIN SUB_TASKS WO
              ON WO.SUB_TASKS_ID   = WLC.SUB_TASKS_ID
              AND WLC.WORK_ORDERS_ID = p_WORK_ORDERS_ID
              GROUP BY 'Labor' ,
                WLC.SUB_TASKS_ID,
                ST_FEE   
      )  tblCounts
     GROUP BY WO_FEE
) TotalsTable  
 ;
    END;
 else
 OPEN REC_CURSOR FOR 
   SELECT    0 as LaborHours,  0 as LaborAmt, 0 as MaterialCount, 0 as MaterialAmt,  0 as TravelAmt,  0 as ODCAmt , 0 as  WO_FEE , 0 as AMOUNT_FUNDED from dual;
 end if;
    SP_INSERT_AUDIT(p_UserId,  'SP_GET_WOC_TYPE_COUNTS-Get group counts of Labor, ODC, Travel, Material  for WORK_ORDERS_ID='|| p_WORK_ORDERS_ID);     
    --SP_INSERT_AUDIT(p_UserId,  'SP_GET_WOC_TYPE_COUNTS p_WORK_ORDERS_ID='|| p_WORK_ORDERS_ID); 
    
   EXCEPTION  WHEN NO_DATA_FOUND THEN 
   OPEN REC_CURSOR FOR 
       
  SELECT    0 as LaborHours,  0 as LaborAmt, 0 as MaterialCount, 0 as MaterialAmt,  0 as TravelAmt,  0 as ODCAmt  , 0 as  WO_FEE , 0 as AMOUNT_FUNDED from dual;

    
 
  WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
       
   SELECT  0 as LaborHours,  0 as LaborAmt, 0 as MaterialCount, 0 as MaterialAmt,  0 as TravelAmt,  0 as ODCAmt  , 0 as  WO_FEE , 0 as AMOUNT_FUNDED from dual;

          
END SP_GET_WOC_TYPE_COUNTS;
/