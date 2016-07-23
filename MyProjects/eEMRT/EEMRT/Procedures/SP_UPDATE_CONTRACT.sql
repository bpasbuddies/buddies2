CREATE OR REPLACE PROCEDURE eemrt.SP_Update_Contract(
    p_CONTRACT_NUMBER IN CONTRACT.CONTRACT_NUMBER%type,
    ---p_DO_NUM          IN CONTRACT.DO_NUM%type DEFAULT 9999 ,
    p_SMALL_BUSINESS IN CONTRACT.SMALL_BUSINESS%type,
    p_small_business_Desig IN CONTRACT.small_business_Desig%TYPE,
    p_SUBCONTRACT_VENDOR CONTRACT.SUBCONTRACT_VENDOR%TYPE,    
    p_Program IN  CONTRACT.Program%TYPE,
    p_CO_NAME IN CONTRACT.CO_NAME%TYPE,
    p_COR_NAME IN CONTRACT.COR_NAME%TYPE,
    p_org_cd IN CONTRACT.organization%TYPE,
    p_UPDATED_BY IN CONTRACT.LAST_MODIFIED_BY%type DEFAULT 'APPUSER',
    p_PStatus OUT VARCHAR2 )
IS
  vStatus VARCHAR2(4000) ;
BEGIN
    UPDATE Contract
    SET SUBCONTRACT_VENDOR   = p_SUBCONTRACT_VENDOR,
        SMALL_BUSINESS       = p_SMALL_BUSINESS,
        small_business_Desig = p_small_business_Desig,
        Program              = p_Program,
        CO_NAME              = p_CO_NAME,
        COR_NAME             = p_COR_NAME,
        organization         = p_org_cd,
        LAST_MODIFIED_BY     = p_UPDATED_BY,
        LAST_MODIFIED_ON     = sysdate
    WHERE Contract_number  = p_CONTRACT_NUMBER;

    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION    WHEN OTHERS THEN
    p_PStatus := 'Error updating Contract ' ||SQLERRM;  
END SP_Update_Contract;
/