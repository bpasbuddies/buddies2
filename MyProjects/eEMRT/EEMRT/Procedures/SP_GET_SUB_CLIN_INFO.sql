CREATE OR REPLACE PROCEDURE eemrt.SP_GET_SUB_CLIN_INFO(
    p_UserId     varchar2 DEFAULT NULL ,
    P_CLIN_ID number DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)    
AS
  /*
  Procedure : SP_GET_SUB_CLIN_INFO
  Author: Sridhar Kommana
  Date Created : 04/24/2015
  Purpose:  Get SUB_CLIN for each contract/Clin or get details when clin_id is passed.
  Update history:
  sridhar kommana :
  1) 05/04/2015 : Added p_USER fro auditing/debugging
  1) 05/04/2015 : Added sort by 1 so that 0 will come on top
  */
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'SP_GET_SUB_CLIN_INFO Get SUB Clin totals for CLIN_ID= '||P_CLIN_ID );
  --SP_INSERT_AUDIT(p_UserId, 'SP_GET_SUB_CLIN_INFO  CLIN_ID= '||P_CLIN_ID );
  OPEN REC_CURSOR FOR 
  select  sum(SUB_CLIN_HOURS) as TOTHRS, sum(SUB_CLIN_AMOUNT) as TOTAMOUNT
  from SUB_CLIN
  WHERE CLIN_ID = P_CLIN_ID; 
  
EXCEPTION
WHEN OTHERS THEN
OPEN REC_CURSOR FOR SELECT   1 as TOTHRS, 1 as TOTAMOUNT from DUAL;
END SP_GET_SUB_CLIN_INFO;
/