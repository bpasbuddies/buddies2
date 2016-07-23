CREATE OR REPLACE PROCEDURE eemrt.sp_Add_Contract_PRISM(
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
            p_PStatus := 'Contract '||v_contract_NUM||' has already been entered in eCERT  ' ;
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
      vMESSAGE  := 'A new contract '||v_contract_NUM||' for user '||p_CREATED_BY||' was attempted to put into eCert system, on the instance '||v_Instance||'.  Please review and verify the contract (if required)';
      
     SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
     SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Surekha.CTR.Kandula@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
     SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Christophe.CTR.Yee@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );

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
     
      SP_INSERT_AUDIT(p_CREATED_BY,  '   Contract created in eCERT contract, '||v_contract_NUM||'\'||'p_DO_NUM='||p_DO_NUM );
      --p_PStatus := 'The data for Contract '||TO_CHAR(p_CONTRACT_NUMBER)||' is being retrieved from PRISM and DELPHI.  You will be notified via email once data retrieval has been completed.  If you have not received an email within 24 hours, please notify the System Administrator';
      COMMIT;
    END IF;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    --p_PStatus := 'Error: Contract already exists, Please use another contract number' ;
    SP_INSERT_AUDIT(p_CREATED_BY,  '   duplicate insert in eCERT contract table attempted, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );   
    p_PStatus := 'Contract '||v_contract_NUM||' has already been entered in eCERT  ' ;
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
    SP_INSERT_AUDIT(p_CREATED_BY,  '   Contract inserted in eCERT contract summary table, '||p_CONTRACT_NUMBER||'\'||'p_DO_NUM='||p_DO_NUM );
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
                              P_HTML =>  vMESSAGE || '</br></br>Thank you, </br>eCERT Admin'  );    
        SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'sridhar.ctr.kommanaboyina@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  vMESSAGE || '</br></br>Thank you, </br>eCERT Admin'  );                    
        SP_SEND_HTML_EMAIL(P_FROM => vSENDER, P_TO => 'srihari.ctr.gokina@faa.gov', P_SUBJECT => vSUBJECT, 
                              P_HTML =>  vMESSAGE || '</br></br>Thank you, </br>eCERT Admin'  );  
                              
  END IF;
 -- SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Surekha.CTR.Kandula@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
  --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => 'Christophe.CTR.Yee@faa.gov', SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );  
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
/