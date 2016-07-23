CREATE OR REPLACE PROCEDURE eemrt.sp_get_pop_type(    p_UserId  varchar2 DEFAULT NULL,
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
  
  SP_INSERT_AUDIT(p_UserId, 'sp_get_pop_type ' );
 

  OPEN pop_cursor FOR 
    select PERIOD_OF_PERFORMANCE_ID , POP_TYPE  , status from PERIOD_OF_PERFORMANCE where CONTRACT_NUMBER = P_CONTRACT_NUMBER  
    --union     select POP_TYPE ||status pop_type , status from PERIOD_OF_PERFORMANCE where CONTRACT_NUMBER = P_CONTRACT_NUMBER  and status<>'Active'
    order by status;
  
EXCEPTION
WHEN OTHERS THEN
   OPEN pop_cursor FOR  select 1 as POP_TYPE from PERIOD_OF_PERFORMANCE ;
END sp_get_pop_type;
/