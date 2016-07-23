CREATE OR REPLACE PROCEDURE eemrt.sp_get_contracts(
      p_UserId          VARCHAR2 DEFAULT NULL,
      p_CONTRACT_NUMBER VARCHAR2 DEFAULT NULL,
      contracts_cursor OUT SYS_REFCURSOR)
            
 /*  Procedure : sp_get_contracts
      Author: Sridhar Kommana
      Date Created : 09/14/2015
      Purpose:  Lists out all contract related info bassed on the parameters passed.
      Update history:
      03/18/2016 Modified Added WO_COUNT  as per RTM ID: W00a-10.
      03/24/2016 Modified Added ST_COUNT  as per RTM ID: W00a-10.   
      04/16/2016 SriHari Gokina added LC_COUNT per RTM ID W00a-10w      
      04/21/2016 Sridhar Kommana Added new col contract_task_type per RTM-ID D00b-05
      06/30/2016 Sai Allu - added new columns to select statement ( CS_USERNAME, PM_USERNAME ).
      07/06/2016 Sai Allu - Added new column to select statement ( award date ).
 */
  IS
    vContractNUM CONTRACT.CONTRACT_NUMBER%TYPE;
  BEGIN
    vContractNUM := P_CONTRACT_NUMBER;
    SP_INSERT_AUDIT(p_UserId, 'PKG_Contracts.SP_get_contracts ' || vContractNUM);
    OPEN contracts_cursor FOR SELECT * FROM
    ( WITH tblPOP AS
    (SELECT P.CONTRACT_NUMBER , MIN(P.Start_date) CONTRACT_START_DATE, MAX(P.END_DATE) CONTRACT_END_DATE
    FROM PERIOD_OF_PERFORMANCE P
    WHERE (P.CONTRACT_NUMBER = vContractNUM OR vContractNUM IS NULL) ---'DTFAWA-11-X-80007'
    GROUP BY P.CONTRACT_NUMBER )
    
  SELECT C.CONTRACT_NUMBER,
    C.DO_NUM,
    tblPOP.CONTRACT_START_DATE,
    tblPOP.CONTRACT_END_DATE,
    (SELECT SUM(NVL(CLIN_AMOUNT,0))+ SUM(NVL(SUB_CLIN_AMOUNT,0)) FROM POP_CLIN PC
      LEFT OUTER JOIN SUB_CLIN S  ON S.clin_id = PC.clin_id WHERE PC.PERIOD_OF_PERFORMANCE_ID IN
      (SELECT PERIOD_OF_PERFORMANCE_ID FROM PERIOD_OF_PERFORMANCE WHERE contract_number = vContractNUM) ) CONTRACT_CEILING_VALUE,
    (SELECT SUM(NVL(CLIN_HOURS,0))+ SUM(NVL(SUB_CLIN_HOURS,0)) FROM POP_CLIN PC 
      LEFT OUTER JOIN SUB_CLIN S  ON S.clin_id = PC.clin_id  WHERE PC.PERIOD_OF_PERFORMANCE_ID IN
      (SELECT PERIOD_OF_PERFORMANCE_ID FROM PERIOD_OF_PERFORMANCE WHERE contract_number = vContractNUM )) CONTRACT_CEILING_HOURS,
    C.VENDOR,
    C.SUBCONTRACT_VENDOR,
    C.SMALL_BUSINESS,
    C.small_business_Desig,
    C.CONTRACT_CATEGORY,
    CO_NAME ,
    COR_NAME,
    Program,
    c.contract_type,
    c.buyer,
    C.organization,
    ORG_TITLE,
    c.status,
    (SELECT period_of_performance_id FROM PERIOD_OF_PERFORMANCE WHERE CONTRACT_NUMBER = vContractNUM AND STATUS = 'Active' AND ROWNUM =1 ) AS Active_POPID,
    (SELECT POP_TYPE FROM PERIOD_OF_PERFORMANCE WHERE CONTRACT_NUMBER = vContractNUM AND STATUS = 'Active' AND ROWNUM =1 ) AS Active_POP_TYPE,
    NET_QUANTITY_ORDERED,
    CS.QUANTITY_CANCELLED,
    SUM(NVL(AEP_QUANTITY_RECEIVED,0)) QUANTITY_RECEIVED,
    SUM(CS.Qty_Ordered ) AMOUNT_FUNDED,
    SUM(CS.AEU_Quantity_Billed) AMOUNT_USED,
    SUM(UDO_OBLIGATION_BALANCE) Balance,
    (SELECT MAX(DCD.STAGE_DATE) FROM DELPHI_CONTRACT_DETAIL DCD WHERE contract_number = vContractNUM ) STAGE_DATE,
    (SELECT COUNT(period_of_performance_id) FROM work_orders
         WHERE period_of_performance_id in (SELECT period_of_performance_id FROM period_of_performance WHERE contract_number = C.CONTRACT_NUMBER )) WO_COUNT,
    (SELECT COUNT(period_of_performance_id) FROM SUB_TASKS
         WHERE period_of_performance_id in (SELECT period_of_performance_id FROM period_of_performance WHERE contract_number = C.CONTRACT_NUMBER )) ST_COUNT, 
    (SELECT COUNT(  LABOR_CATEGORY_ID) FROM CLIN_LABOR_CATEGORY WHERE CLIN_ID IN
         (SELECT CLIN_ID FROM POP_CLIN WHERE period_of_performance_id in (SELECT period_of_performance_id FROM period_of_performance WHERE contract_number = C.CONTRACT_NUMBER))) LC_COUNT 
    , c.Contract_task_Type
    , c.CS_USERNAME
    , c.PM_USERNAME
    , C.AWARD_DATE
  FROM CONTRACT C
  LEFT JOIN (SELECT DISTINCT org_cd, ORG_TITLE FROM organizations ) O ON C.organization = O.org_cd
  LEFT OUTER JOIN tblPOP ON C.CONTRACT_NUMBER = tblPOP.CONTRACT_NUMBER
  INNER JOIN CONTRACT_SUMMARY_GL CS ON CS.PO_NUMBER = C.CONTRACT_NUMBER AND (C.CONTRACT_NUMBER = vContractNUM OR vContractNUM IS NULL)
  GROUP BY C.CONTRACT_NUMBER,
    C.DO_NUM,
    tblPOP.CONTRACT_START_DATE,
    tblPOP.CONTRACT_END_DATE,
    CONTRACT_CEILING_VALUE,
    CONTRACT_CEILING_HOURS,
    C.VENDOR,
    C.SUBCONTRACT_VENDOR,
    C.SMALL_BUSINESS,
    C.small_business_Desig,
    C.CONTRACT_CATEGORY,
    C.CO_NAME,
    C.COR_NAME,
    Program,
    c.contract_type,
    c.buyer,
    C.organization,
    ORG_TITLE,
    c.status,
    NET_QUANTITY_ORDERED,
    CS.QUANTITY_CANCELLED,
    CS.QUANTITY_RECEIVED,
    CS.AEP_QUANTITY_RECEIVED,
    CS.UDO_OBLIGATION_BALANCE
    , c.Contract_task_Type
    , c.CS_USERNAME
    , c.PM_USERNAME
    , C.AWARD_DATE
    ) TblContracts ;
    --SP_INSERT_AUDIT(p_UserId, 'Get contract details for contract '||vContractNUM);
  END sp_get_contracts;
/