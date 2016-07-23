CREATE OR REPLACE PROCEDURE eemrt.SP_Activate_Contract(
    p_CONTRACT_NUMBER IN CONTRACT.CONTRACT_NUMBER%type,
    p_UPDATED_BY IN CONTRACT.LAST_MODIFIED_BY%type,
    p_PStatus OUT VARCHAR2 )
IS
 
  vCount Number :=0;
BEGIN

  SELECT count(*) 
  into vCount 
  from PERIOD_OF_PERFORMANCE
  WHERE contract_number = p_Contract_NUMBER
  and  upper(STATUS) ='ACTIVE';
  if vCount >0 then   
    UPDATE Contract
    SET Status   = 'ACTIVE',
        LAST_MODIFIED_BY     = p_UPDATED_BY,
        LAST_MODIFIED_ON     = sysdate
    WHERE Contract_number  = p_CONTRACT_NUMBER;
  
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
   else
      p_PStatus := 'Cannot Activate Contract. Contract number:' || p_Contract_NUMBER ||' does not have a period of performance record with Active status';
      Return;
   end if;
   
  EXCEPTION  WHEN OTHERS THEN
    p_PStatus := 'Error Activating Contract ' ||SQLERRM;  
END SP_Activate_Contract;
/