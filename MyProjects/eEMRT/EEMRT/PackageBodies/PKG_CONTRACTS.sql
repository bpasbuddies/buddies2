CREATE OR REPLACE PACKAGE BODY eemrt.PKG_CONTRACTS
AS
  /*
  Package : PKG_Contracts
  Author: Sridhar Kommana
  Date Created : 09/14/2015
  Purpose:  All procedures related to Contracts
  Update history:
  03/18/2016 Modified sp_get_contracts_summary and sp_get_contracts per RTM ID: W00a-10.
  */
   PROCEDURE sp_get_contracts_summary(
      p_CREATED_BY VARCHAR2 DEFAULT NULL,
      contracts_cursor OUT SYS_REFCURSOR)
      
  /*
  Procedure : sp_get_contracts_summary
  Author: Sridhar Kommana
  Date Created : 09/14/2015
  Purpose:  gets summary totals of all amounts for every contract
  Update history:
  03/18/2016 Modified Added WO_COUNT  as per RTM ID: W00a-10.
  */      
  IS
  
    vCount NUMBER :=0;
    vROLE  VARCHAR2(20);
  BEGIN
    SELECT COUNT(*) INTO vCount FROM CONTRACT_SUMMARY_GL;
    SELECT ur.Role
    INTO vROLE
    FROM users u,
      userRole ur
    WHERE u.userName = ur.UserName
    AND u.UserName   = p_CREATED_BY;
    SP_INSERT_AUDIT(p_CREATED_BY, 'PKG_Contracts.SP_get_contracts_summary Get Contracts Summary List');
    --IF vCount > 0 THEN
    IF (vROLE ='Admin') THEN
      OPEN contracts_cursor FOR SELECT PO_Number,
      Vendor_Name,
      SUM(Qty_Ordered) Qty_Ordered,
      SUM(AEU_Quantity_Billed) Quantity_Billed ,
      SUM(NVL(AEP_QUANTITY_RECEIVED,0)) Quantity_Received,
      SUM(Quantity_cancelled) Quantity_cancelled,
      SUM(UDO_OBLIGATION_BALANCE) Obligation_Balance, 
      (select max(STAGE_DATE) from delphi_contract_detail )  STAGE_DATE,
      (select count(period_of_performance_id) from work_orders
          WHERE period_of_performance_id in (select period_of_performance_id from period_of_performance where contract_number = PO_Number )) WO_COUNT
      FROM CONTRACT_SUMMARY_GL,CONTRACT
      WHERE contract_number = PO_Number
     -- EXISTS  (SELECT 1 FROM CONTRACT WHERE contract_number = PO_Number      ) 
      AND VENDOR_NAME IS NOT NULL GROUP BY PO_Number,
      Vendor_Name Order by PO_Number;
    ELSE
      OPEN contracts_cursor FOR SELECT PO_Number,
      Vendor_Name,
      SUM(Qty_Ordered) Qty_Ordered,
      SUM(AEU_Quantity_Billed) Quantity_Billed ,
      SUM(NVL(AEP_QUANTITY_RECEIVED,0)) Quantity_Received,
      SUM(Quantity_cancelled) Quantity_cancelled,
      SUM(UDO_OBLIGATION_BALANCE) Obligation_Balance,
      (select max(STAGE_DATE) from delphi_contract_detail)  STAGE_DATE,
      (select count(period_of_performance_id) from work_orders
          WHERE period_of_performance_id in (select period_of_performance_id from period_of_performance where contract_number = PO_Number )) WO_COUNT      
            FROM CONTRACT_SUMMARY_GL CSG, CONTRACT C, CONTRACT_TASK_ACCESS CTA
      WHERE C.contract_number = PO_Number
      AND C.CONTRACT_NUMBER = CTA.CONTRACTNUMBER
     -- EXISTS  (SELECT 1 FROM CONTRACT WHERE contract_number = PO_Number      ) 
--      AND (CONTRACT.CREATED_BY = p_CREATED_BY
--      OR INSTR(CONTRACT.COR_NAME,p_CREATED_BY)>0
  --    OR INSTR(CONTRACT.CO_NAME,p_CREATED_BY) >0 )
     -- ) 
      AND VENDOR_NAME IS NOT NULL GROUP BY PO_Number,
      Vendor_Name Order by PO_Number;
    END IF;
    --END IF;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN contracts_cursor FOR SELECT '' PO_Number,
    '' Vendor_Name,
    0 Qty_Ordered,
    0 Quantity_Billed ,
    0 Quantity_Received,
    0 Quantity_cancelled,
    0 Obligation_Balance,
    0 STAGE_DATE FROM dual;
  END sp_get_contracts_summary;
  
  PROCEDURE sp_get_contracts(
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
      07/11/2016 Srihari Gokina - Added PGM_NAME to SP.
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
    
  SELECT PGM_NAME, PGM_CEILING_AMOUNT, C.CONTRACT_NUMBER,     C.DO_NUM,     tblPOP.CONTRACT_START_DATE,    tblPOP.CONTRACT_END_DATE,
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
  LEFT JOIN (SELECT  PGM_ID, PGM_NAME,PGC_CONTRACT_NUMBER, PGM_CEILING_AMOUNT FROM PROGRAM JOIN PROGRAM_CONTRACTS ON  PGM_ID = PGC_PGM_ID) PGM ON (PGC_CONTRACT_NUMBER =C.CONTRACT_NUMBER) --= vContractNUM OR vContractNUM IS NULL)
  GROUP BY PGM_NAME, PGM_CEILING_AMOUNT, C.CONTRACT_NUMBER,
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

  PROCEDURE SP_Activate_Contract(
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

 PROCEDURE sp_Add_Contract(
    p_CONTRACT_NUMBER  IN CONTRACT.CONTRACT_NUMBER%type, 
    p_DO_NUM  IN CONTRACT.DO_NUM%type , 
    p_CREATED_BY       IN CONTRACT.LAST_MODIFIED_BY%type DEFAULT 'APPUSER',
    p_PStatus OUT VARCHAR2 )
IS
  vContract_count NUMBER;
  vSENDER         VARCHAR2(200);
  vRECEIVER       VARCHAR2(200);
  vSUBJECT        VARCHAR2(200);
  vMESSAGE        VARCHAR2(32000);
  vEMAIL          VARCHAR2(1000);
  vROLE           VARCHAR2(10); 
  vFull_Name      VARCHAR2(1000);
  vDO_NUM   VARCHAR2(10) := 9999;
  v_Award_date VARCHAR2(20);
  v_contract_NUM  VARCHAR2(1000); --Contract.Contract_Number%TYPE;
  v_co_name contract.co_Name%TYPE :=NULL;
  v_cor_name contract.cor_Name%TYPE :=NULL;
  v_Status   VARCHAR2(1000);
  
BEGIN

v_contract_NUM := p_CONTRACT_NUMBER;
if (p_DO_NUM is NOT NULL) OR  (RTRIM(LTRIM(p_DO_NUM)) != '') THEN
 v_contract_NUM := p_CONTRACT_NUMBER||'/'||p_DO_NUM;
END IF;
    BEGIN 
     SELECT COUNT(CONTRACT_NUMBER)
      INTO vContract_count
      FROM Contract
      WHERE CONTRACT_NUMBER  = v_contract_NUM  ;
     SP_INSERT_AUDIT(p_CREATED_BY,  'pkg_Contracts.sp_Add_Contract Checking  in eEMRT  '||LENGTH(v_contract_NUM)||' Char, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );      
      if vContract_count > 0 then 
            p_PStatus := 'Error: Contract '||v_contract_NUM||' has already been entered in eEMRT  ' ;
            RETURN ;
      end if;
     exception when NO_DATA_FOUND then
        NULL;
    END;
      
      
      vContract_count:=0;

--p_CONTRACT_NUMBER  := RTRIM(LTRIM(p_CONTRACT_NUMBER)) ||'/'|| RTRIM(LTRIM(vDO_NUM));
     
  SELECT --u.EMAIL,
    ur.Role user_type --,
    --u.FirstName    || ' '    || u.MiddleInitial    || ' '    || u.LastName
  INTO  --vEMAIL,
    vROLE
    --,    --vFull_Name
  FROM users u,
    userRole ur
  WHERE u.userName = ur.UserName
  AND u.UserName   = p_CREATED_BY; 
  
  IF vROLE = 'COR' THEN 
      v_cor_name := p_CREATED_BY;
  ELSIF vROLE = 'CO' THEN 
      v_co_name := p_CREATED_BY;  
  END IF;
  
  vSENDER   := 'sridhar.ctr.kommanaboyina@faa.gov';
  vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
  --vRECEIVER := vEMAIL;-- 'skommana77@gmail.com';
  vSUBJECT  := 'eEMRT Add Contract';
  BEGIN
    /*IF p_CONTRACT_NUMBER NOT LIKE 'DTF%' THEN   --Commented by Sridhar 10152015
      p_PStatus := 'Error: Contract number should start with DTF' ;
      RETURN ;
    END IF;*/
    /*
    IF LENGTH(p_CONTRACT_NUMBER) < 17 THEN
      p_PStatus                 := 'Error: Contract number should be atleast 17 characters' ;
      RETURN ;
    END IF;*/
     SP_INSERT_AUDIT(p_CREATED_BY,  'pkg_Contracts.sp_Add_Contract   Contract Create attempted, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );     
     
    IF LENGTH(v_contract_NUM) > 0 THEN -- 17 OR LENGTH(v_contract_NUM) <= 22 THEN      --Commented by Sridhar 10152015
      sp_Add_Contract_PRISM(  p_CONTRACT_NUMBER ,   p_DO_NUM  ,  p_CREATED_BY , v_Status);
      IF LENGTH(v_Status) > 0 AND v_Status = 'SUCCESS-01' THEN
        p_PStatus := 'The data for Contract ' || p_CONTRACT_NUMBER || ' is being retrieved from PRISM and DELPHI. You will be notified via email once data retrieval has been completed. If you have not received an email within 24 hours, please notify the System Administrator';
       ELSE
          p_PStatus := v_Status;
      END IF;
            /*p_PStatus := 'Contract '||v_contract_NUM||' is being retrieved from PRISM, you will be notified shortly via Email about the status.' ;*/
            SP_INSERT_AUDIT(p_CREATED_BY,  'pkg_Contracts.sp_Add_Contract calling sp_Add_Contract_PRISM  with , '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );                 
            Return;
    ELSE
      vContract_count := 0;
      p_PStatus       := 'Error: Please enter a valid contract number';   --Commented by Sridhar 10152015
      --p_PStatus       := 'Error: Contract number should be atleast 17 characters and should be of format  "DTFXXX-##-X-#####" or  "DTFXXX-##-X-#####/####"' ;
      RETURN ;
    END IF;
    END;
  
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_PStatus := 'Error inserting Contract*  ' || SQLERRM ;
END sp_Add_Contract;

PROCEDURE sp_Add_Contract_PRISM(
    p_CONTRACT_NUMBER  IN CONTRACT.CONTRACT_NUMBER%type, 
    p_DO_NUM  IN CONTRACT.DO_NUM%type , 
    p_CREATED_BY       IN CONTRACT.LAST_MODIFIED_BY%type DEFAULT 'APPUSER',
    p_PStatus OUT VARCHAR2 )
IS
  vContract_count NUMBER;
  vSENDER         VARCHAR2(200);
  vRECEIVER       VARCHAR2(200);
  vRECEIVER_usr    VARCHAR2(200);
  vSUBJECT        VARCHAR2(200);
  vMESSAGE        VARCHAR2(32000);
  vEMAIL          VARCHAR2(1000);
  vROLE           VARCHAR2(10);
  vFull_Name      VARCHAR2(1000);
  vDO_NUM   VARCHAR2(10) := 9999;
  v_Award_date VARCHAR2(20);
  v_contract_NUM  VARCHAR2(1000); -- Contract.Contract_Number%TYPE;
  v_co_name contract.co_Name%TYPE :=NULL;
  v_cor_name contract.cor_Name%TYPE :=NULL;
  v_Instance Varchar2(100);
  V_Inv_Id NUMBER;
  v_ID NUMBER;
  v_PSTATUS VARCHAR2(200);  
BEGIN
v_contract_NUM := p_CONTRACT_NUMBER;
if (p_DO_NUM is NOT NULL) OR  (RTRIM(LTRIM(p_DO_NUM)) != '') THEN
 v_contract_NUM := p_CONTRACT_NUMBER||'/'||p_DO_NUM;
END IF;
 

-- select instance_name into  v_Instance from v$instance;
 select sys_context('USERENV','INSTANCE_NAME')  into  v_Instance from dual;
 
     /*SELECT COUNT(CONTRACT_NUMBER)
      INTO vContract_count
      FROM Contract
      WHERE CONTRACT_NUMBER  = v_contract_NUM  ;
     SP_INSERT_AUDIT(p_CREATED_BY,  'pkg_Contracts.sp_Add_Contract_PRISM   '||LENGTH(v_contract_NUM)||' Char, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );      
      if vContract_count > 0 then 
            p_PStatus := 'Contract '||v_contract_NUM||' has already been entered in eEMRT  ' ;
            RETURN ;
      End if;
      */
      vContract_count:=0;

--p_CONTRACT_NUMBER  := RTRIM(LTRIM(p_CONTRACT_NUMBER)) ||'/'|| RTRIM(LTRIM(vDO_NUM));
     
  SELECT u.EMAIL,
    ur.Role user_type --,
    --u.FirstName    || ' '    || u.MiddleInitial    || ' '    || u.LastName
  INTO  vEMAIL,
    vROLE
    --,    --vFull_Name
  FROM users u,
    userRole ur
  WHERE u.userName = ur.UserName
  AND u.UserName   = p_CREATED_BY; 
  
  IF vROLE = 'COR' THEN 
      v_cor_name := p_CREATED_BY;
  ELSIF vROLE = 'CO' THEN 
      v_co_name := p_CREATED_BY;  
  END IF;
  
  vSENDER   := 'sridhar.ctr.kommanaboyina@faa.gov';
  vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
  vRECEIVER_usr := vEMAIL;
  vSUBJECT  := 'New Add Contract Request';
  BEGIN
  /*  IF p_CONTRACT_NUMBER NOT LIKE 'DTF%' THEN
      p_PStatus := 'Error: Contract number should start with DTF' ;
      RETURN ;
    END IF;*/
   /* IF LENGTH(p_CONTRACT_NUMBER) < 17 THEN
      p_PStatus                 := 'Error: Contract number should be atleast 17 characters' ;
      RETURN ;
    END IF;*/
     SP_INSERT_AUDIT(p_CREATED_BY,  'pkg_Contracts.sp_Add_Contract_PRISM   Contract Create attempted, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );     
    IF LENGTH(v_contract_NUM) = 17 THEN
     SP_INSERT_AUDIT(p_CREATED_BY,  'pkg_Contracts.sp_Add_Contract_PRISM   17 Char, '||v_contract_NUM||'\'||'p_DO_NUM='||p_DO_NUM );  
     SELECT COUNT(contract_num)
      INTO vContract_count
      FROM V_TSOCUFF_AWDS@PRISM
      WHERE contract_num  = p_CONTRACT_NUMBER ; --'DTFAWA-09-C-00071'  ;    
    -- elsIF LENGTH(v_contract_NUM) <= 22 THEN
    else
     SP_INSERT_AUDIT(p_CREATED_BY,  'pkg_Contracts.sp_Add_Contract_PRISM  <= 22 condition '||LENGTH(v_contract_NUM)||' Char, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );
     SELECT COUNT(contract_num)
      INTO vContract_count
      FROM V_TSOCUFF_AWDS@PRISM
      WHERE contract_num  = p_CONTRACT_NUMBER 
      and do_num  = P_DO_NUM; --'DTFAWA-09-C-00071/0001'  ;
/*    elsIF LENGTH(p_CONTRACT_NUMBER) < 22 THEN
      SELECT COUNT(contract_num)
      INTO vContract_count
      FROM V_TSOCUFF_AWDS@PRISM
      WHERE DECODE(do_num, NULL, contract_num, contract_num
        ||'/'
        ||do_num ) = p_CONTRACT_NUMBER ; --'DTFAWA-09-C-00071/0001'   ;
      SP_INSERT_AUDIT('WEB', LENGTH(p_CONTRACT_NUMBER) ||'   Contract='||p_CONTRACT_NUMBER);*/
 
   -- ELSE
     -- vContract_count := 0;
      ---p_PStatus       := 'Error: Contract number should be atleast 17 characters and should be of format  "DTFXXX-##-X-#####" or  "DTFXXX-##-X-#####/####"' ;
      --RETURN ;
    END IF;
    IF vContract_count = 0 THEN
      --  p_PStatus := 'Error: This contract number does not exist in PRISM, Contract number should be atleast 17 characters and should be of format  "DTFXXX-##-X-#####" or  "DTFXXX-##-X-#####/####"' ;
      p_PStatus := 'Contract '||v_contract_NUM||' was not  found in PRISM, please check the number and re-submit. ';
     SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER_usr, SUBJECT => vSUBJECT, MESSAGE => p_PStatus );           
      vMESSAGE  := 'A new contract '||v_contract_NUM||' for user '||p_CREATED_BY||' was attempted to put into eEMRT system, on the instance '||v_Instance||'.  Please review and verify the contract (if required)';
      
     SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
     SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Surekha.CTR.Kandula@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
     SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Stephen.Martinez@bpaservices.com', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );

      RETURN ;
    END IF;
        SP_INSERT_AUDIT(p_CREATED_BY,  '   Contract found in PRISM, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );     
vDO_NUM := p_DO_NUM;
/*if vDO_NUM is null or vDO_NUM ='' then 
  vDO_NUM := 9999;
end if;
*/
  INSERT
  INTO Contract
    (
      CONTRACT_NUMBER ,
      CO_NAME, 
      COR_NAME,
      STATUS,
      CREATED_BY,
      CREATED_ON,
      LAST_MODIFIED_BY
    )
    VALUES
    (
     v_contract_NUM,      
      v_co_name, 
      v_cor_name,
      'PENDING',
      p_CREATED_BY,
      sysdate(),
      p_CREATED_BY
    );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS-01' ;
       --vMESSAGE  := 'A new contract '||v_contract_NUM||' for user '||p_CREATED_BY||' in '||vROLE||' has been loaded in the system. We will notify you once PRISM and DELPHI data related this contract is loaded ';
  --   SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER_usr, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );    
     
      SP_INSERT_AUDIT(p_CREATED_BY,  '   Contract created in eEMRT contract, '||v_contract_NUM||'\'||'p_DO_NUM='||p_DO_NUM );
      --p_PStatus := 'The data for Contract '||TO_CHAR(p_CONTRACT_NUMBER)||' is being retrieved from PRISM and DELPHI.  You will be notified via email once data retrieval has been completed.  If you have not received an email within 24 hours, please notify the System Administrator';
      COMMIT;
    END IF;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    --p_PStatus := 'Error: Contract already exists, Please use another contract number' ;
    SP_INSERT_AUDIT(p_CREATED_BY,  '   duplicate insert in eEMRT contract table attempted, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );   
    p_PStatus := 'Contract '||v_contract_NUM||' has already been entered in eEMRT  ' ;
    RETURN ;
  WHEN OTHERS THEN
    p_PStatus := 'Error inserting Contract ' || SQLERRM ;
    RETURN ;
  END;
  --CONTRACT_SUMMARY_GL
  INSERT INTO CONTRACT_SUMMARY_GL
  (
      PO_NUMBER, --RELEASE_NUM,
      CREATED_BY,
      CREATED_ON,
      LAST_MODIFIED_BY
    )
    VALUES
    (
     v_contract_NUM,
      p_CREATED_BY,
      sysdate(),
      p_CREATED_BY
    );
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS-01' ;
    SP_INSERT_AUDIT(p_CREATED_BY,  '   Contract inserted in eEMRT contract summary table, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );
    SELECT 
      u.FirstName || ' ' || u.LastName
    INTO  vFull_Name
    FROM users u
    WHERE u.userName = p_CREATED_BY;
  
    vMESSAGE := 'A new contract ' || v_contract_NUM  || ' for user ' || vFull_Name || ' has been submitted in the system.  Please review and verify the COR Designation Letter (if required) and perform  the appropriate action.';
    --vMESSAGE  := 'A new contract '||v_contract_NUM||' for user '||p_CREATED_BY||' in '||vROLE||' has been loaded in the system, on the instance '||v_Instance||'.   Please review and verify the COR Designation Letter (if required)';
    -- p_PStatus := 'The data for Contract '||TO_CHAR(p_CONTRACT_NUMBER)||' is being retrieved from PRISM and DELPHI.  You will be notified via email once data retrieval has been completed.  If you have not received an email within 24 hours, please notify the System Administrator';
    COMMIT;
    
     SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'sai.laxman.ctr.allu@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  vMESSAGE || '</br></br>Thank you, </br>eEMRT Admin'  );    
        SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'sridhar.ctr.kommanaboyina@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  vMESSAGE || '</br></br>Thank you, </br>eEMRT Admin'  );                    
        SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'srihari.ctr.gokina@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  vMESSAGE || '</br></br>Thank you, </br>eEMRT Admin'  );  
                              
  END IF;
 -- SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Surekha.CTR.Kandula@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
  --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Stephen.Martinez@bpaservices.com', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );  
  --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
 /*
  PKG_USERS.SP_INSERT_CONTRACT_TASK_ACCESS(
    P_USERID => p_CREATED_BY,
    P_USERNAME => p_CREATED_BY,
    P_CONTRACT_NUMBER => v_contract_NUM,
    P_TASKORDER => NULL,
    P_SUBTASK => NULL,
    P_ROLE => vROLE,
    P_COR => v_cor_name,
    P_APPROVALDATE => NULL,
    P_STATUS => 'Pending',
    P_COMMENTS => 'Contract Add Screen',
    P_ID => v_ID,
    P_PSTATUS => v_PSTATUS
  );
   
      
      V_Inv_Id := CONTRACT_TASK_ACCESS_SEQ.Nextval;
  
      INSERT
      INTO CONTRACT_TASK_ACCESS
          ( ACCESS_ID,
            USERNAME, 
            CONTRACTNUMBER,
            TASKORDER,
            SUBTASK,
            ROLE,
            COR,
            APPROVALDATE,
            STATUS,
            comments,
            CREATED_BY,
            CREATED_ON
          )
          VALUES
          ( V_Inv_Id ,
            p_CREATED_BY,
            v_contract_NUM,
            NULL,
             NULL,
            vROLE,
            v_cor_name,
            NULL,
            'Pending',
             'Contract Add Screen',
            p_CREATED_BY,
            Sysdate()
          );
        IF Sql%Found THEN
          P_Pstatus := 'SUCCESS' ;
 
            SP_INSERT_AUDIT(p_CREATED_BY, 'PKG_Contracts.sp_Add_Contract_PRISM Added Contact successfully to Contract Task Access '||v_contract_NUM);
          COMMIT;
        END IF;
        
        */
  RETURN;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_PStatus := 'Error inserting Contract Summary ' || SQLERRM ;
END sp_Add_Contract_PRISM;

 PROCEDURE SP_Update_Contract(
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
    p_CS_USERNAME IN CONTRACT.CS_USERNAME%TYPE DEFAULT NULL,
    p_PM_USERNAME IN CONTRACT.PM_USERNAME%TYPE DEFAULT NULL,
    p_PStatus OUT VARCHAR2 )
IS
  vStatus VARCHAR2(4000) ;
BEGIN
    UPDATE Contract
    SET SUBCONTRACT_VENDOR    = p_SUBCONTRACT_VENDOR,
        SMALL_BUSINESS        = p_SMALL_BUSINESS,
        small_business_Desig  = p_small_business_Desig,
        Program               = p_Program,
        CO_NAME               = p_CO_NAME,
        COR_NAME              = p_COR_NAME,
        organization          = p_org_cd,
        LAST_MODIFIED_BY      = p_UPDATED_BY,
        LAST_MODIFIED_ON      = sysdate,
        CS_USERNAME           = p_CS_USERNAME,
        PM_USERNAME           = p_PM_USERNAME
    WHERE Contract_number  = p_CONTRACT_NUMBER;

    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION    WHEN OTHERS THEN
    p_PStatus := 'Error updating Contract ' ||SQLERRM;  
END SP_Update_Contract;

 PROCEDURE  SP_GET_ALL_VENDORS(
    p_UserId     varchar2 DEFAULT NULL ,
    p_SUB_CONTRACTOR_ID     NUMBER DEFAULT 0 ,
    p_VENDOR_NAME  varchar2 DEFAULT NULL ,
    p_CONTRACT_NUMBER  varchar2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN

  SP_INSERT_AUDIT(p_UserId, 'SP_GET_ALL_VENDORS  p_CONTRACT_NUMBER= '||p_CONTRACT_NUMBER||' P_SUB_CONTRACTOR_ID='||P_SUB_CONTRACTOR_ID);
  OPEN REC_CURSOR FOR 
  SELECT SUB_CONTRACTOR_ID, VENDOR_NAME, CONTRACT_NUMBER , POC_FNAME , POC_FNAME, POC_FNAME , SMALL_BUSINESS
  FROM SUB_CONTRACTOR  
  WHERE (SUB_CONTRACTOR_ID = p_SUB_CONTRACTOR_ID OR p_SUB_CONTRACTOR_ID= 0) 
  AND  (VENDOR_NAME = p_VENDOR_NAME OR p_VENDOR_NAME IS NULL) 
  AND  (CONTRACT_NUMBER = p_CONTRACT_NUMBER OR p_CONTRACT_NUMBER IS NULL) 
UNION  
  SELECT 0 as SUB_CONTRACTOR_ID, VENDOR VENDOR_NAME, CONTRACT_NUMBER , '' POC_FNAME ,'' POC_FNAME, '' POC_FNAME , '' SMALL_BUSINESS
  FROM CONTRACT  
  WHERE (CONTRACT_NUMBER = p_CONTRACT_NUMBER)   
  ORDER BY 1;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 1 FROM SUB_CONTRACTOR ;
END SP_GET_ALL_VENDORS;

PROCEDURE sp_get_CORs(
    CORs_cursor OUT SYS_REFCURSOR)
IS
BEGIN
  OPEN CORs_cursor FOR 
    select distinct  UPPER(COR_ID) COR_ID, COR_NAME from (
    SELECT  COR_ID, COR_NAME 
      FROM Contracting_Officers_Reps 
      UNION
      SELECT 
           CO_ID, CO_NAME 
      FROM CONTRACTING_OFFICERS  
      UNION
      SELECT  
           U.USERNAME COR_ID ,     DECODE(U.MIDDLEINITIAL, NULL, U.FIRSTNAME ||' '|| U.LASTNAME,U.FIRSTNAME || ' ' || U.MIDDLEINITIAL || ' ' || U.LASTNAME )   "COR_NAME"      
      FROM users u, userRole ur 
      WHERE u.userName = ur.UserName 
      AND ROLE in ('COR', 'CO')
     --  AND U.USERNAME NOT LIKE  ('% CTR %') 
     
      ) t
      ORDER BY COR_NAME;  
  
EXCEPTION
WHEN OTHERS THEN
   OPEN CORs_cursor FOR  SELECT 1 COR_ID, 1 COR_NAME FROM Contracting_Officers_Reps;
END sp_get_CORs;
 
 PROCEDURE sp_get_COs(
    COs_cursor OUT SYS_REFCURSOR)
IS
BEGIN
  OPEN COs_cursor FOR 
      
       select distinct  UPPER(CO_ID) CO_ID, CO_NAME from (
      SELECT 
           CO_ID, CO_NAME 
      FROM CONTRACTING_OFFICERS  
      UNION
      SELECT  
           U.USERNAME CO_ID ,     DECODE(U.MIDDLEINITIAL, NULL, U.FIRSTNAME ||' '|| U.LASTNAME,U.FIRSTNAME || ' ' || U.MIDDLEINITIAL || ' ' || U.LASTNAME )    "CO_NAME"      
      FROM users u, userRole ur 
      WHERE u.userName = ur.UserName 
      AND ROLE='CO' 
--     AND U.USERNAME NOT LIKE  ('% CTR %') 

      )t
      ORDER BY CO_NAME;    
EXCEPTION
WHEN OTHERS THEN
   OPEN COs_cursor FOR  SELECT 1 CO_ID, 1 CO_NAME FROM CONTRACTING_OFFICERS;
END sp_get_COs;

 PROCEDURE sp_get_Organizations(
     p_UserId          VARCHAR2,
    p_rgn_cd VARCHAR2 DEFAULT NULL,
    Organizations_cursor OUT SYS_REFCURSOR)
IS
BEGIN
SP_INSERT_AUDIT(p_UserId, 'PKG_CONTRACTS.sp_get_Organizations');
  OPEN Organizations_cursor FOR SELECT distinct org_cd, org_cd|| ' - ' || org_title
AS
  org_title FROM organizations WHERE (rgn_cd = p_rgn_cd OR p_rgn_cd IS NULL)
  ORDER BY org_cd;
EXCEPTION
WHEN OTHERS THEN
   OPEN Organizations_cursor FOR  SELECT 1 org_cd, 1 org_title FROM organizations;
END sp_get_Organizations;

PROCEDURE sp_get_contracts_Info(
    p_UserId          VARCHAR2 DEFAULT NULL,
    p_CONTRACT_NUMBER VARCHAR2 DEFAULT NULL,
    contracts_cursor OUT SYS_REFCURSOR)
  /*  Procedure : sp_get_contracts_Info
  Author: Sridhar Kommana
  Date Created : 06/17/2016
  Purpose:  Lists out all contract related info bassed on the parameters passed.
  Update history:
  */
IS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_Contracts.sp_get_contracts_Info ' || p_CONTRACT_NUMBER);
  OPEN contracts_cursor FOR SELECT C.CONTRACT_NUMBER, C.VENDOR, C.CO_NAME , C.COR_NAME, C.status FROM CONTRACT C
  WHERE (CONTRACT_NUMBER = p_CONTRACT_NUMBER OR p_CONTRACT_NUMBER IS NULL);
END sp_get_contracts_Info;


END PKG_CONTRACTS;
/