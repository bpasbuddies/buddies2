CREATE OR REPLACE PROCEDURE eemrt.sp_get_LSD_WO_SUMMARY(
    p_UserId  varchar2 DEFAULT NULL,
    p_contract_number  varchar2 DEFAULT NULL,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
/*
  Procedure : sp_get_LSD_WO_SUMMARY
  Author: Sridhar Kommana
  Date Created : 03/19/2015
  Purpose:  GET SUMMARY of  LSD_WO_FUNDS ALLOCATED
  Update history: 
  
  sridhar kommana :
  1) 03/23/2015 : Formatted number cols to show decimal points
  2) 03/30/2015 : Changed to outer join to show all LSDs regardless of work order allocations.
 
*/
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'sp_get_LSD_WO_SUMMARY - Contract Funding Summary Page p_contract_number='||p_contract_number );
     OPEN REC_CURSOR
      FOR
        SELECT 
              DC.CONTRACT_NUMBER, DC.LSD,
              DC.ACCOUNTING_CODE, DC.Fiscal_Year, DC.Fund_Type, TO_CHAR(DC.OBLIGATION_EXPIRATION_DATE, 'MM/DD/YYYY') OBLIGATION_EXPIRATION_DATE, to_char(DC.EXPENDITURE_EXPIRATION_DATE, 'MM/DD/YYYY') EXPENDITURE_EXPIRATION_DATE,DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNTING_CODE ACCOUNTING_STRING ,              
              to_char( NVL( DC.QUANTITY_ORDERED, 0 ), '999,999,999,999,999.99' ) QUANTITY_ORDERED,
              to_char( NVL( DC.QUANTITY_CANCELLED, 0 ), '999,999,999,999,999.99' ) QUANTITY_CANCELLED,
              to_char( NVL( DC.QUANTITY_RECEIVED, 0 ), '999,999,999,999,999.99' ) QUANTITY_RECEIVED, 
              to_char( NVL( DC.QUANTITY_BILLED, 0 ), '999,999,999,999,999.99' )  QUANTITY_BILLED, 
              to_char( NVL( DC.OBLIGATED_BALANCE, 0 ), '999,999,999,999,999.99' )  OBLIGATED_BALANCE, 
              to_char( NVL( DC.BALANCE_AMOUNT, 0 ), '999,999,999,999,999.99' )  BALANCE_AMOUNT,
              to_char( NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' ) as AMT_ALLOC_TO_WO, 
              0.00 as INVOICE_PENDING 
              FROM  DELPHI_CONTRACT_DETAIL DC 
              LEFT OUTER JOIN  LSD_WO_FUNDS LWF ON DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER
                    AND LWF.LSD = DC.LSD
        Where  (DC.contract_number = p_contract_number)
        GROUP BY  DC.CONTRACT_NUMBER, DC.LSD,
              DC.ACCOUNTING_CODE,DC.Fiscal_Year, DC.Fund_Type, DC.OBLIGATION_EXPIRATION_DATE, DC.EXPENDITURE_EXPIRATION_DATE, DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNT  ,
              DC.QUANTITY_ORDERED, DC.QUANTITY_CANCELLED, DC.QUANTITY_RECEIVED, DC.QUANTITY_BILLED, DC.OBLIGATED_BALANCE, DC.BALANCE_AMOUNT 
        order by   LSD;  
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
        SELECT   1 as CONTRACT_NUMBER, 1 as LSD,
        --1 as WORK_ORDERS_ID, 1 as WORK_ORDER_NUMBER, 
        1 as ACCOUNTING_CODE, 1 as RELEASE_NUM,  1 as PROJECT_NUMBER, 1 as TASK_NUMBER, 1 as ACCOUNTING_STRING ,
        1 as QUANTITY_ORDERED, 1 as QUANTITY_CANCELLED, 1 as QUANTITY_RECEIVED, 1 as QUANTITY_BILLED, 1 as OBLIGATED_BALANCE, 1 as BALANCE_AMOUNT, 
        1 as AMT_ALLOC_TO_WO, 1 as INVOICE_PENDING
        FROM Dual;
END sp_get_LSD_WO_SUMMARY;
/