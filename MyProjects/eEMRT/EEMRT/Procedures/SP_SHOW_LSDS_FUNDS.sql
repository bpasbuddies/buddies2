CREATE OR REPLACE PROCEDURE eemrt.sp_Show_LSDs_Funds(
    p_UserId          VARCHAR2 DEFAULT NULL,
    p_contract_number  varchar2 DEFAULT NULL,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
/*
  Procedure : sp_Show_LSDs_Funds
  Author: Sridhar Kommana
  Date Created : 03/30/2015
  Purpose:  GET LSDs and related funded information for funding screen.
  Update history: 
  
 
*/
BEGIN
     SP_INSERT_AUDIT(p_UserId, 'sp_Show_LSDs_Funds  GET LSDs and related funded information for funding screen. p_contract_number '||p_contract_number);
     OPEN REC_CURSOR
      FOR
        SELECT 
              DC.CONTRACT_NUMBER, DC.LSD,
              DC.ACCOUNTING_CODE,   DC.Fiscal_Year, DC.Fund_Type, DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNTING_CODE ACCOUNTING_STRING ,              
              to_char( NVL( DC.QUANTITY_ORDERED, 0 ), '999,999,999,999,999.99' ) QUANTITY_ORDERED,
              to_char( NVL( DC.QUANTITY_CANCELLED, 0 ), '999,999,999,999,999.99' ) QUANTITY_CANCELLED,
              to_char( NVL( DC.QUANTITY_RECEIVED, 0 ), '999,999,999,999,999.99' ) QUANTITY_RECEIVED, 
              to_char( NVL( DC.QUANTITY_BILLED, 0 ), '999,999,999,999,999.99' )  QUANTITY_BILLED, 
              to_char( NVL( DC.OBLIGATED_BALANCE, 0 ), '999,999,999,999,999.99' )  OBLIGATED_BALANCE, 
              to_char( NVL( DC.BALANCE_AMOUNT, 0 ), '999,999,999,999,999.99' )  BALANCE_AMOUNT,
              to_char( NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' ) as ALLOCATED, 
              to_char( NVL( DC.BALANCE_AMOUNT, 0 )- NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' ) as AMT_AVAIL_TO_ALLOC              
              FROM DELPHI_CONTRACT_DETAIL DC 
              LEFT OUTER JOIN LSD_WO_FUNDS LWF              
              ON DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND LWF.LSD = DC.LSD
        Where  (DC.CONTRACT_NUMBER = p_contract_number)    
        having (NVL(DC.BALANCE_AMOUNT, 0 )- NVL( SUM(LWF.AMOUNT),0))>0
        GROUP BY  DC.CONTRACT_NUMBER, DC.LSD,
              DC.ACCOUNTING_CODE, DC.Fiscal_Year, DC.Fund_Type,DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNT  ,
              DC.QUANTITY_ORDERED, DC.QUANTITY_CANCELLED, DC.QUANTITY_RECEIVED, DC.QUANTITY_BILLED, DC.OBLIGATED_BALANCE, DC.BALANCE_AMOUNT
        order by LSD;   
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
        SELECT   1 as CONTRACT_NUMBER, 1 as LSD,
        --1 as WORK_ORDERS_ID, 1 as WORK_ORDER_NUMBER, 
        1 as ACCOUNTING_CODE, 1 as RELEASE_NUM,  1 as PROJECT_NUMBER, 1 as TASK_NUMBER, 1 as ACCOUNTING_STRING ,
        1 as QUANTITY_ORDERED, 1 as QUANTITY_CANCELLED, 1 as QUANTITY_RECEIVED, 1 as QUANTITY_BILLED, 1 as OBLIGATED_BALANCE, 1 as BALANCE_AMOUNT, 
        1 as ALLOCATED,1 as AMT_AVAIL_TO_ALLOC
        FROM Dual;
END sp_Show_LSDs_Funds;
/