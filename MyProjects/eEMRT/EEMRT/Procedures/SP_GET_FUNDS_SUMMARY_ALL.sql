CREATE OR REPLACE PROCEDURE eemrt.sp_get_funds_summary_all(
    p_UserId          VARCHAR2 DEFAULT NULL,
    p_CONTRACT_NUMBER VARCHAR2 DEFAULT NULL,
    contracts_cursor OUT SYS_REFCURSOR)
IS
  vContractNUM CONTRACT.CONTRACT_NUMBER%TYPE;
BEGIN
  vContractNUM := P_CONTRACT_NUMBER;
  SP_INSERT_AUDIT(p_UserId, 'sp_get_contracts_funds ' || vContractNUM);
  OPEN contracts_cursor 
  FOR SELECT 
          CONTRACT_NUMBER, SUM(QUANTITY_ORDERED) Total_Obligations,
          FISCAL_YEAR, FUND_TYPE 
      FROM DELPHI_CONTRACT_DETAIL 
      WHERE CONTRACT_NUMBER = vContractNUM 
      AND FISCAL_YEAR IS NOT NULL 
      Group by CONTRACT_NUMBER,  
          FISCAL_YEAR, FUND_TYPE 
      Order by CONTRACT_NUMBER,FISCAL_YEAR, FUND_TYPE ;
END sp_get_funds_summary_all;
/