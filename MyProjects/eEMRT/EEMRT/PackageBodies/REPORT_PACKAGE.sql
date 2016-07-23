CREATE OR REPLACE PACKAGE BODY eemrt."REPORT_PACKAGE" AS

  PROCEDURE sp_WO_LSD_Summary(
    p_contract_number  varchar2 DEFAULT NULL,
    p_WO_ID  number DEFAULT NULL,
     p_StartDate  varchar2 DEFAULT NULL,
     p_EndDate  varchar2 DEFAULT NULL,    
    p_UserId  varchar2 ,
    REC_CURSOR OUT SYS_REFCURSOR)
  AS
  vStartDate date;
  vEndDate date;
  BEGIN
  vStartDate :=to_date(p_StartDate, 'mm/dd/YYYY');
  vEndDate :=to_date(p_EndDate, 'mm/dd/YYYY');
  

   
   IF p_StartDate is not null and p_EndDate is not null then 
 SP_INSERT_AUDIT(p_UserId, 'REPORT_PACKAGE.sp_WO_LSD_Summary contract '||p_Contract_NUMBER ||' p_WO_ID = '||p_WO_ID   ||' p_StartDate = '||vStartDate  ||' p_EndDate = '||vEndDate );   
     OPEN REC_CURSOR
      FOR
        SELECT 
              DC.CONTRACT_NUMBER, DC.LSD, TO_CHAR(LWF.created_on, 'MM/DD/YYYY') Transaction_Date,  FISCAL_YEAR,   Fund_Type,
              DC.ACCOUNTING_CODE, DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNTING_CODE ACCOUNTING_STRING ,                            
              NVL( LWF.AMOUNT, 0 ) as Funded_Amount,      
              0.00 as INVOICED,               
               (NVL( LWF.AMOUNT, 0 )-0)   as BALANCE_AMOUNT
              FROM 
              LSD_WO_FUNDS LWF INNER JOIN DELPHI_CONTRACT_DETAIL DC              
              ON DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND LWF.LSD = DC.LSD
        Where  (LWF.CONTRACT_NUMBER = p_contract_number AND LWF.WORK_ORDERS_ID =  p_WO_ID)      
        AND Trunc(LWF.created_on)  >= vStartDate and trunc(LWF.created_on) <= vEndDate
        order by LWF.created_on desc ,DC.TASK_NUMBER; 
   ELSE
    SP_INSERT_AUDIT(p_UserId, 'REPORT_PACKAGE.sp_WO_LSD_Summary contract '||p_Contract_NUMBER ||' p_WO_ID = '||p_WO_ID   ||' p_StartDate = '||vStartDate  ||' p_EndDate = '||vEndDate );
        OPEN REC_CURSOR
      FOR
          SELECT 
              DC.CONTRACT_NUMBER, DC.LSD, TO_CHAR(LWF.created_on, 'MM/DD/YYYY') Transaction_Date,  FISCAL_YEAR,   Fund_Type,
              DC.ACCOUNTING_CODE, DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNTING_CODE ACCOUNTING_STRING ,                                 
              NVL( LWF.AMOUNT, 0 ) as Funded_Amount,      
              0.00 as INVOICED,               
               (NVL( LWF.AMOUNT, 0 )-0)   as BALANCE_AMOUNT
              FROM 
              LSD_WO_FUNDS LWF INNER JOIN DELPHI_CONTRACT_DETAIL DC              
              ON DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND LWF.LSD = DC.LSD
        Where  (LWF.CONTRACT_NUMBER = p_contract_number AND LWF.WORK_ORDERS_ID =  p_WO_ID)              
        order by LWF.created_on desc ,DC.TASK_NUMBER; 
  END IF;      
/*EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
        SELECT   1 as CONTRACT_NUMBER, 1 as LSD,
        --1 as WORK_ORDERS_ID, 1 as WORK_ORDER_NUMBER, 
        1 as ACCOUNTING_CODE, 1 as RELEASE_NUM,  1 as PROJECT_NUMBER, 1 as TASK_NUMBER, 1 as ACCOUNTING_STRING ,
        
        1 as Funded_Amount,1 as BALANCE_AMOUNT
        FROM Dual;*/
  END sp_WO_LSD_Summary;

  PROCEDURE sp_MultiWO_LSD_Summary(
    p_contract_number  varchar2 DEFAULT NULL,
    p_WO_ID  varchar2 DEFAULT NULL,
     p_StartDate  varchar2 DEFAULT NULL,
     p_EndDate  varchar2 DEFAULT NULL,    
    p_UserId  varchar2 ,
    REC_CURSOR OUT SYS_REFCURSOR)
  AS
  vStartDate date;
  vEndDate date;
  v_array_WO_id apex_application_global.vc_arr2;
  BEGIN
  vStartDate :=to_date(p_StartDate, 'mm/dd/YYYY');
  vEndDate :=to_date(p_EndDate, 'mm/dd/YYYY');
  
  v_array_WO_id    := apex_util.string_to_table(p_WO_ID, ',');
   
   IF p_StartDate is not null and p_EndDate is not null then 
 SP_INSERT_AUDIT(p_UserId, 'REPORT_PACKAGE.sp_MultiWO_LSD_Summary contract '||p_Contract_NUMBER ||' p_WO_ID = '||p_WO_ID   ||' p_StartDate = '||vStartDate  ||' p_EndDate = '||vEndDate );   
     OPEN REC_CURSOR
      FOR
        SELECT 
              DC.CONTRACT_NUMBER, DC.LSD, LWF.created_on Transaction_Date,  Substr(DC.ACCOUNTING_CODE,12,4) Fiscal_Year, Substr(DC.ACCOUNTING_CODE,1,10) Fund_Type,
              DC.ACCOUNTING_CODE, DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNTING_CODE ACCOUNTING_STRING ,                            
              NVL( LWF.AMOUNT, 0 ) as Funded_Amount,      
              0.00 as INVOICED,               
               (NVL( LWF.AMOUNT, 0 )-0)   as BALANCE_AMOUNT
              FROM 
              LSD_WO_FUNDS LWF INNER JOIN DELPHI_CONTRACT_DETAIL DC              
              ON DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND LWF.LSD = DC.LSD
        Where  (LWF.CONTRACT_NUMBER = p_contract_number AND LWF.WORK_ORDERS_ID =  p_WO_ID)      
        AND Trunc(LWF.created_on)  >= vStartDate and trunc(LWF.created_on) <= vEndDate
        order by LWF.created_on desc ,DC.TASK_NUMBER; 
   ELSE
   BEGIN
      SP_INSERT_AUDIT(p_UserId, 'REPORT_PACKAGE.sp_MultiWO_LSD_Summary contract NO DATE '||p_Contract_NUMBER ||' p_WO_ID = '||p_WO_ID    );
      forall i IN 1..v_array_WO_id.count      
       
        insert into tbl_Summ_report_session
            SELECT 
                DC.CONTRACT_NUMBER, DC.LSD,LWF.WORK_ORDERS_ID, LWF.created_on Transaction_Date,  Substr(DC.ACCOUNTING_CODE,12,4) Fiscal_Year, Substr(DC.ACCOUNTING_CODE,1,10) Fund_Type,
                DC.ACCOUNTING_CODE, DC.RELEASE_NUM, DC.PROJECT_NUMBER, DC.TASK_NUMBER,DC.ACCOUNTING_CODE ACCOUNTING_STRING ,                                 
                NVL( LWF.AMOUNT, 0 ) as Funded_Amount,      
                0.00 as INVOICED,               
                 (NVL( LWF.AMOUNT, 0 )-0)   as BALANCE_AMOUNT,p_UserId
                FROM 
                LSD_WO_FUNDS LWF INNER JOIN DELPHI_CONTRACT_DETAIL DC              
                ON DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND LWF.LSD = DC.LSD
          Where  (LWF.CONTRACT_NUMBER = p_contract_number AND LWF.WORK_ORDERS_ID =  v_array_WO_id(i))              ;
          --order by LWF.created_on desc ,DC.TASK_NUMBER; 
        
    END;     
     OPEN REC_CURSOR
      FOR
        SELECT * from tbl_Summ_report_session where created_by = p_userId;
      delete from   tbl_Summ_report_session where created_by = p_userId;
  END IF;      
/*EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
        SELECT   1 as CONTRACT_NUMBER, 1 as LSD,
        --1 as WORK_ORDERS_ID, 1 as WORK_ORDER_NUMBER, 
        1 as ACCOUNTING_CODE, 1 as RELEASE_NUM,  1 as PROJECT_NUMBER, 1 as TASK_NUMBER, 1 as ACCOUNTING_STRING ,
        
        1 as Funded_Amount,1 as BALANCE_AMOUNT
        FROM Dual;*/
  END sp_MultiWO_LSD_Summary;

END REPORT_PACKAGE;
/