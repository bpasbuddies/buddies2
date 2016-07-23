CREATE OR REPLACE PROCEDURE eemrt.SP_UPDATE_COR_CONTRACT_ACCESS
(
    p_UserId VARCHAR2 DEFAULT NULL,
    p_UserName Users.USERNAME%TYPE,
    p_Contract_Number Contract.CONTRACT_NUMBER%TYPE,
    p_Status Contract.STATUS%TYPE,
    p_pStatus OUT VARCHAR2
)
IS
  tempRole VARCHAR2(20);
  fullName VARCHAR(200);
  email VARCHAR(200);
  taskAccessId NUMBER;
  mailSender VARCHAR(500) := 'sridhar.ctr.kommanaboyina@faa.gov';
  mailSubject VARCHAR(1000) := 'Request to add Contract ' || p_Contract_Number;
  mailMessage VARCHAR(5000);
  taskAccessCount NUMBER;
BEGIN
  
  SP_INSERT_AUDIT(p_UserId, 'SP_UPDATE_COR_CONTRACT_ACCESS update COR contract access status.');
  
  UPDATE CONTRACT C SET
    STATUS = UPPER(p_Status),
    LAST_MODIFIED_BY = p_UserId,
    LAST_MODIFIED_ON = SYSDATE
  WHERE LOWER(C.CREATED_BY) = LOWER(p_UserName) AND LOWER(C.CONTRACT_NUMBER) = LOWER(p_Contract_Number);

  /* EXCEPTION WHEN OTHERS THEN 
    BEGIN
      DBMS_OUTPUT.PUT_LINE(SQLERRM); 
      SP_INSERT_AUDIT(p_UserId, 'Error SP_UPDATE_COR_CONTRACT_ACCESS update COR contract access status: ' || SQLERRM);
      p_pStatus := 'Error: ' || SQLERRM;
      ROLLBACK; --TO SP_UPDATE_CONTRACT_ACCESS;
      RETURN;
    END; 
  */
  -- SP_INSERT_AUDIT(p_UserId, 'SP_UPDATE_COR_CONTRACT_ACCESS get user details from user table.');
  
  SELECT Role INTO tempRole FROM USERROLE WHERE LOWER(USERNAME) = LOWER(p_UserName);
  SELECT Email INTO email FROM USERROLE WHERE LOWER(USERNAME) = LOWER(p_UserName);
  
  fullName := GET_USER_FULLNAME(p_UserName);
  
  SELECT COUNT(CONTRACTNUMBER) INTO taskAccessCount FROM CONTRACT_TASK_ACCESS WHERE LOWER(USERNAME) = LOWER(p_UserName) AND LOWER(CONTRACTNUMBER) = LOWER(p_Contract_Number);
  
  IF taskAccessCount < 1 THEN
    BEGIN
      SP_INSERT_AUDIT(p_UserId, 'SP_UPDATE_COR_CONTRACT_ACCESS Inserting record into CONTRACT_TASK_ACCESS table.');
      taskAccessId := CONTRACT_TASK_ACCESS_SEQ.Nextval;
      
      INSERT INTO CONTRACT_TASK_ACCESS
      ( 
        ACCESS_ID,
        USERNAME, 
        CONTRACTNUMBER, 
        ROLE,
        COR,
        APPROVALDATE,
        STATUS,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        taskAccessId,
        UPPER(p_UserName),
        p_Contract_Number,
        tempRole,
        UPPER(p_UserName),
        SYSDATE,
        UPPER(p_status),
        p_UserId,
        SYSDATE
      );
      
      mailMessage := 'Your request to add contract number ' || p_Contract_Number || ' has been completed. Please login to eCERT to begin managing the contract. If you are receiving this message in error, please contact the eCERT Administrator.';
      
      EXCEPTION WHEN OTHERS THEN 
        BEGIN
          SP_INSERT_AUDIT(p_UserId, 'Error SP_UPDATE_COR_CONTRACT_ACCESS Inserting record into CONTRACT_TASK_ACCESS table: ' || SQLERRM);
          p_pStatus := 'Error: ' || SQLERRM;
          ROLLBACK;-- TO SP_UPDATE_CONTRACT_ACCESS;
          RETURN;
        END;
      COMMIT;
    END;
  ELSIF UPPER(p_Status) = 'APPROVED' THEN
    BEGIN
      UPDATE CONTRACT_TASK_ACCESS SET
        STATUS = UPPER(p_Status),
        UPDATED_BY = p_UserId,
        UPDATED_ON = SYSDATE
      WHERE LOWER(USERNAME) = LOWER(p_UserName) AND LOWER(CONTRACTNUMBER) = LOWER(p_Contract_Number);
      mailMessage := 'Your request to add contract number ' || p_Contract_Number || ' has been completed. Please login to eCERT to begin managing the contract. If you are receiving this message in error, please contact the eCERT Administrator.';
    END;
  ELSIF UPPER(p_Status) = 'DENIED' THEN
    BEGIN
      UPDATE CONTRACT_TASK_ACCESS SET
        STATUS = UPPER(p_Status),
        UPDATED_BY = p_UserId,
        UPDATED_ON = SYSDATE
      WHERE LOWER(USERNAME) = LOWER(p_UserName) AND LOWER(CONTRACTNUMBER) = LOWER(p_Contract_Number);
      mailMessage := 'Your request to add contract number ' || p_Contract_Number || ' could not be completed at this time. Please contact the eCERT Administrator for additional information';
    END;
  ELSIF UPPER(p_Status) = 'DELETED' THEN
    BEGIN
      UPDATE CONTRACT_TASK_ACCESS SET
        STATUS = UPPER(p_Status),
        UPDATED_BY = p_UserId,
        UPDATED_ON = SYSDATE
      WHERE LOWER(USERNAME) = LOWER(p_UserName) AND LOWER(CONTRACTNUMBER) = LOWER(p_Contract_Number);      
    END;
  END IF;
      
  COMMIT;
      
  p_pStatus := 'SUCCESS';

  DBMS_OUTPUT.PUT_LINE(mailMessage); 
  IF UPPER(p_Status) = 'APPROVED' OR UPPER(p_Status) = 'DENIED' THEN
    BEGIN
      SP_SEND_HTML_EMAIL(P_FROM => mailSender, P_TO => 'sai.laxman.ctr.allu@faa.gov', P_SUBJECT => mailSubject, P_HTML =>  'Sai Laxman Allu' ||  '</br></br>'|| mailMessage || '</br></br>Thank you, </br></br>eCERT Admin'  );    
      SP_SEND_HTML_EMAIL(P_FROM => mailSender, P_TO => 'sridhar.ctr.kommanaboyina@faa.gov', P_SUBJECT => mailSubject, P_HTML =>  'Sridhar Kommanaboyina' ||  '</br></br>'|| mailMessage || '</br></br>Thank you, </br></br>eCERT Admin'  );                    
      SP_SEND_HTML_EMAIL(P_FROM => mailSender, P_TO => 'srihari.ctr.gokina@faa.gov', P_SUBJECT => mailSubject, P_HTML =>  'Srihari Gokina' ||  '</br></br>'|| mailMessage || '</br></br>Thank you, </br></br>eCERT Admin'  );
   END;
  END IF;
END  SP_UPDATE_COR_CONTRACT_ACCESS;
/