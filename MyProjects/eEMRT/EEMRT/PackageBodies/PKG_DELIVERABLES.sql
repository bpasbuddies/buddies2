CREATE OR REPLACE PACKAGE BODY eemrt.PKG_DELIVERABLES
AS
  /*
  Procedure : PKG_DELIVERABLES
  Author: Sridhar Kommana
  Date Created : 01/27/2016
  Purpose: Select Insert Update Delete DELIVERABLES records for eCert
  Update history:
  SP_GET_DELIVERABLES : Added by Sridhar on 1/27/2016
  Purpose : Get all deliverables based on the deliverable attributes
  */
  PROCEDURE SP_GET_DELIVERABLES(
      P_CONTRACT_NUMBER VARCHAR2 DEFAULT NULL ,
      p_WORK_ORDERS_ID  NUMBER DEFAULT 0 ,
      P_SUB_TASKS_ID    NUMBER DEFAULT 0 ,
      P_DELIVERABLE_ID DELIVERABLES.DELIVERABLE_ID%TYPE DEFAULT 0 ,
      P_DELIVERABLE_STATUS DELIVERABLES.DELIVERABLE_STATUS%TYPE DEFAULT NULL,
      p_UserId VARCHAR2 ,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
  BEGIN
    SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.SP_GET_DELIVERABLES P_CONTRACT_NUMBER='||P_CONTRACT_NUMBER||'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'P_SUB_TASKS_ID='||P_SUB_TASKS_ID);
    OPEN REC_CURSOR FOR 
    SELECT DELIVERABLE_ID, ltrim(rtrim(DELIVERABLE_NUMBER)) DELIVERABLE_NUMBER, DELIVERABLE_TYPE, DELIVERABLE_TITLE, 
            DUE_DATE_FREQUNCY, ACCEPTANCE_CRITERIA, TECHNICAL_REVIEWER, DELIVERABLE_STATUS, INSTRUCTIONS, D.WORK_ORDERS_ID, WORK_ORDER_NUMBER, 
            WORK_ORDER_TITLE, D.SUB_TASKS_ID, SUB_TASK_NUMBER, SUB_TASK_TITLE, CONTRACT_NUMBER, VENDOR, 
            CO_NAME, COR_NAME, TECHNICAL_REVIEWER_ID, CO_ID, COR_ID, task_info,
              (SELECT NVL(COUNT(DD.DELIVERABLE_ID),0) FROM DELIVERABLE_DETAIL DD WHERE DD.DELIVERABLE_ID = D.DELIVERABLE_ID) DetailCount
    FROM 
    DELIVERABLES D LEFT OUTER JOIN WORK_ORDERS W ON (D.WORK_ORDERS_ID = W.WORK_ORDERS_ID) 
    LEFT JOIN SUB_TASKS ST ON (D.SUB_TASKS_ID = ST.SUB_TASKS_ID) 
    WHERE ( CONTRACT_NUMBER = P_CONTRACT_NUMBER OR P_CONTRACT_NUMBER IS NULL) 
    AND (D.WORK_ORDERS_ID = P_WORK_ORDERS_ID OR P_WORK_ORDERS_ID = 0) 
    AND (D.SUB_TASKS_ID = P_SUB_TASKS_ID OR P_SUB_TASKS_ID = 0) 
    AND (DELIVERABLE_ID = P_DELIVERABLE_ID OR P_DELIVERABLE_ID = 0) 
    AND (DELIVERABLE_STATUS = P_DELIVERABLE_STATUS OR P_DELIVERABLE_STATUS IS NULL) 
    ORDER BY DELIVERABLE_NUMBER DESC;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN REC_CURSOR FOR SELECT 1
  AS
    DELIVERABLE_ID FROM dual;
  END SP_GET_DELIVERABLES ;
  PROCEDURE SP_GET_DELIVERABLE_DETAILS(
      P_CONTRACT_NUMBER VARCHAR2 DEFAULT NULL ,
      p_WORK_ORDERS_ID  NUMBER DEFAULT 0 ,
      P_SUB_TASKS_ID    NUMBER DEFAULT 0 ,
      P_DELIVERABLE_ID DELIVERABLES.DELIVERABLE_ID%TYPE DEFAULT 0 ,
      P_DELIVERABLE_DETAIL_ID NUMBER DEFAULT 0 ,
      P_DELIVERABLE_STATUS DELIVERABLES.DELIVERABLE_STATUS%TYPE DEFAULT NULL,
      p_UserId VARCHAR2 ,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
  BEGIN
    SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.SP_GET_DELIVERABLE_DETAILS P_CONTRACT_NUMBER='||P_CONTRACT_NUMBER||'P_DELIVERABLE_DETAIL_ID='||P_DELIVERABLE_DETAIL_ID|| 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
    OPEN REC_CURSOR FOR SELECT DELIVERABLE_DETAIL_ID, 
                              DELIVERABLE_ID, DELIVERABLE_NUMBER, 
                              DELIVERABLE_TYPE, DELIVERABLE_TITLE, DUE_DATE_FREQUNCY, 
                              ACCEPTANCE_CRITERIA, TECHNICAL_REVIEWER, DELIVERABLE_STATUS, 
                              INSTRUCTIONS, D.WORK_ORDERS_ID, WORK_ORDER_NUMBER, WORK_ORDER_TITLE, 
                              D.SUB_TASKS_ID, SUB_TASK_NUMBER, SUB_TASK_TITLE, CONTRACT_NUMBER, VENDOR, 
                              CO_NAME, COR_NAME, TECHNICAL_REVIEWER_ID, CO_ID, COR_ID, SUBMITTED_BY, SUBMITTED_ON, 
                              D.Submission_Title, D.Submission_Number, FYI_NOTIFICATION , comments , task_info
                        FROM DELIVERABLE_DETAIL D LEFT OUTER JOIN WORK_ORDERS W ON (D.WORK_ORDERS_ID = W.WORK_ORDERS_ID) 
                        LEFT JOIN SUB_TASKS ST ON (D.SUB_TASKS_ID = ST.SUB_TASKS_ID) WHERE ( CONTRACT_NUMBER = P_CONTRACT_NUMBER OR P_CONTRACT_NUMBER IS NULL) 
                        AND (D.WORK_ORDERS_ID = P_WORK_ORDERS_ID OR P_WORK_ORDERS_ID = 0) AND (D.SUB_TASKS_ID = P_SUB_TASKS_ID OR P_SUB_TASKS_ID = 0) 
                        AND (DELIVERABLE_ID = P_DELIVERABLE_ID OR P_DELIVERABLE_ID = 0) AND (DELIVERABLE_DETAIL_ID = P_DELIVERABLE_DETAIL_ID OR P_DELIVERABLE_DETAIL_ID 
                        = 0 ) AND (DELIVERABLE_STATUS = P_DELIVERABLE_STATUS OR P_DELIVERABLE_STATUS IS NULL) ORDER BY DELIVERABLE_NUMBER DESC;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN REC_CURSOR FOR SELECT 1
  AS
    DELIVERABLE_ID FROM dual;
  END SP_GET_DELIVERABLE_DETAILS ;
  PROCEDURE sp_insert_deliverables(
      P_DELIVERABLE_NUMBER DELIVERABLES.DELIVERABLE_NUMBER%TYPE,
      P_DELIVERABLE_TYPE DELIVERABLES.DELIVERABLE_TYPE%TYPE,
      P_DELIVERABLE_TITLE DELIVERABLES.DELIVERABLE_TITLE%TYPE,
      P_DUE_DATE_FREQUNCY DELIVERABLES.DUE_DATE_FREQUNCY%TYPE,
      P_ACCEPTANCE_CRITERIA DELIVERABLES.ACCEPTANCE_CRITERIA%TYPE,
      P_TECHNICAL_REVIEWER DELIVERABLES.TECHNICAL_REVIEWER%TYPE,
      P_DELIVERABLE_STATUS DELIVERABLES.DELIVERABLE_STATUS%TYPE,
      P_INSTRUCTIONS DELIVERABLES.INSTRUCTIONS%TYPE,
      P_WORK_ORDERS_ID DELIVERABLES.WORK_ORDERS_ID%TYPE,
      P_SUB_TASKS_ID DELIVERABLES.SUB_TASKS_ID%TYPE,
      P_CONTRACT_NUMBER DELIVERABLES.CONTRACT_NUMBER%TYPE,
      P_VENDOR DELIVERABLES.VENDOR%TYPE,
      P_CO_NAME DELIVERABLES.CO_NAME%TYPE,
      P_COR_NAME DELIVERABLES.COR_NAME%TYPE,
      P_TECHNICAL_REVIEWER_ID DELIVERABLES.TECHNICAL_REVIEWER_ID%TYPE,
      P_CO_ID DELIVERABLES.CO_ID%TYPE,
      P_COR_ID DELIVERABLES.COR_ID%TYPE,
      P_TASK_INFO DELIVERABLES.TASK_INFO%TYPE,
      P_CREATED_BY DELIVERABLES.CREATED_BY%TYPE,
      P_CREATED_ON DELIVERABLES.CREATED_ON%TYPE,
      p_id OUT DELIVERABLES.DELIVERABLE_ID%type,
      p_PStatus OUT VARCHAR2)
  AS
    v_id NUMBER:=0;
  BEGIN
    SP_INSERT_AUDIT(P_CREATED_BY, 'PKG_DELIVERABLES.sp_insert_deliverables P_CONTRACT_NUMBER='||P_CONTRACT_NUMBER||'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'P_SUB_TASKS_ID='||P_SUB_TASKS_ID);
    v_id := DELIVERABLES_SEQ.NEXTVAL;
    INSERT
    INTO DELIVERABLES
      (
        DELIVERABLE_ID,
        DELIVERABLE_NUMBER,
        DELIVERABLE_TYPE,
        DELIVERABLE_TITLE,
        DUE_DATE_FREQUNCY,
        ACCEPTANCE_CRITERIA,
        TECHNICAL_REVIEWER,
        DELIVERABLE_STATUS,
        INSTRUCTIONS,
        WORK_ORDERS_ID,
        SUB_TASKS_ID,
        CONTRACT_NUMBER,
        VENDOR,
        CO_NAME,
        COR_NAME,
        TECHNICAL_REVIEWER_ID,
        CO_ID,
        COR_ID,
        TASK_INFO,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        v_id,
        P_DELIVERABLE_NUMBER,
        P_DELIVERABLE_TYPE,
        P_DELIVERABLE_TITLE,
        P_DUE_DATE_FREQUNCY,
        P_ACCEPTANCE_CRITERIA,
        P_TECHNICAL_REVIEWER,
        DECODE(P_DELIVERABLE_STATUS,NULL, 'Created',P_DELIVERABLE_STATUS),
        P_INSTRUCTIONS,
        P_WORK_ORDERS_ID,
        P_SUB_TASKS_ID,
        P_CONTRACT_NUMBER,
        P_VENDOR,
        P_CO_NAME,
        P_COR_NAME,
        P_TECHNICAL_REVIEWER_ID,
        P_CO_ID,
        P_COR_ID,
        P_TASK_INFO,
        P_CREATED_BY,
        sysdate()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      p_id      := v_id;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SP_INSERT_AUDIT(P_CREATED_BY, 'PKG_DELIVERABLES.sp_insert_deliverables ERROR SQLERRM ='||SQLERRM || 'P_CONTRACT_NUMBER='||P_CONTRACT_NUMBER||'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'P_SUB_TASKS_ID='||P_SUB_TASKS_ID);
    p_PStatus := 'Error inserting Deliverables' ;
    p_id      := v_id;
  END sp_insert_deliverables ;
  PROCEDURE sp_update_deliverables
    (
      P_DELIVERABLE_ID DELIVERABLES.DELIVERABLE_ID%TYPE,
      P_DELIVERABLE_NUMBER DELIVERABLES.DELIVERABLE_NUMBER%TYPE,
      P_DELIVERABLE_TYPE DELIVERABLES.DELIVERABLE_TYPE%TYPE,
      P_DELIVERABLE_TITLE DELIVERABLES.DELIVERABLE_TITLE%TYPE,
      P_DUE_DATE_FREQUNCY DELIVERABLES.DUE_DATE_FREQUNCY%TYPE,
      P_ACCEPTANCE_CRITERIA DELIVERABLES.ACCEPTANCE_CRITERIA%TYPE,
      P_TECHNICAL_REVIEWER DELIVERABLES.TECHNICAL_REVIEWER%TYPE,
      P_TECHNICAL_REVIEWER_ID DELIVERABLES.TECHNICAL_REVIEWER_ID%TYPE,
      P_DELIVERABLE_STATUS DELIVERABLES.DELIVERABLE_STATUS%TYPE,
      P_INSTRUCTIONS DELIVERABLES.INSTRUCTIONS%TYPE,
      P_WORK_ORDERS_ID DELIVERABLES.WORK_ORDERS_ID%TYPE,
      P_SUB_TASKS_ID DELIVERABLES.SUB_TASKS_ID%TYPE,
      P_TASK_INFO DELIVERABLES.TASK_INFO%TYPE,      
      P_Updated_BY DELIVERABLES.Updated_by%TYPE,
      P_Updated_ON DELIVERABLES.Updated_on%TYPE,
      p_PStatus OUT VARCHAR2
    )
  AS
  BEGIN
    SP_INSERT_AUDIT(P_Updated_BY, 'PKG_DELIVERABLES.sp_update_deliverables P_DELIVERABLE_ID='||P_DELIVERABLE_ID||'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'P_SUB_TASKS_ID='||P_SUB_TASKS_ID);
    UPDATE DELIVERABLES
    SET DELIVERABLE_NUMBER  = P_DELIVERABLE_NUMBER,
      DELIVERABLE_TYPE      = P_DELIVERABLE_TYPE,
      DELIVERABLE_TITLE     = P_DELIVERABLE_TITLE,
      DUE_DATE_FREQUNCY     = P_DUE_DATE_FREQUNCY,
      ACCEPTANCE_CRITERIA   = P_ACCEPTANCE_CRITERIA,
      TECHNICAL_REVIEWER    = P_TECHNICAL_REVIEWER,
      TECHNICAL_REVIEWER_ID = P_TECHNICAL_REVIEWER_ID,
      DELIVERABLE_STATUS    = P_DELIVERABLE_STATUS,
      INSTRUCTIONS          = P_INSTRUCTIONS,
      WORK_ORDERS_ID        = P_WORK_ORDERS_ID,
      SUB_TASKS_ID          = P_SUB_TASKS_ID,
      TASK_INFO           = P_TASK_INFO,
      Updated_BY            = P_Updated_BY,
      Updated_ON            = sysdate()
    WHERE DELIVERABLE_ID    = P_DELIVERABLE_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SP_INSERT_AUDIT(P_Updated_BY, 'PKG_DELIVERABLES.sp_update_deliverables ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID||'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'P_SUB_TASKS_ID='||P_SUB_TASKS_ID);
    p_PStatus := 'Error updating Deliverables' ;
  END sp_update_deliverables;
  PROCEDURE sp_submit_deliverable(
      P_DELIVERABLE_ID DELIVERABLES.DELIVERABLE_ID%TYPE,
      P_FYI_NOTIFICATION DELIVERABLES.FYI_NOTIFICATION%TYPE,
      P_SUBMITTED_BY DELIVERABLE_DETAIL.SUBMITTED_BY%TYPE,
      P_SUBMISSION_TITLE DELIVERABLE_DETAIL.SUBMISSION_TITLE%TYPE,
      P_COMMENTS DELIVERABLE_DETAIL.COMMENTS%TYPE,
      P_Temp_id VARCHAR2,
      p_id OUT DELIVERABLES.DELIVERABLE_ID%type,
      p_PStatus OUT VARCHAR2)
  AS
    vSUBJECT            VARCHAR2(200)   :=NULL;
    vTITLE              VARCHAR2(200)   :=NULL;
    vDELIVERABLE_NUMBER VARCHAR2(200)   :=NULL;
    vCONTRACT           VARCHAR2(200)   :=NULL;
    vSENDER             VARCHAR2(200)   :='sridhar.ctr.kommanaboyina@faa.gov';
    vTechR              VARCHAR2(200)   :=NULL;
    vCOR                VARCHAR2(200)   :=NULL;
    vMESSAGE            VARCHAR2(32200) :=NULL;
    vMESSAGEHTML           VARCHAR2(32200) :=NULL;
    v_id                NUMBER          :=0;
    vCount              NUMBER          :=0;
  type t_TR_id
IS
  TABLE OF DELIVERABLE_TR_ROUTING.TECHNICAL_REVIEWER_ID%type INDEX BY pls_integer;
  vTRIds VARCHAR2(32200) :=NULL;
  v_array_TR_id apex_application_global.vc_arr2;
--type t_COR_id IS   TABLE OF DELIVERABLE_COR_ROUTING.COR_ID%type INDEX BY pls_integer;
  vCORIds VARCHAR2(32200) :=NULL;
  v_array_COR_id apex_application_global.vc_arr2;
  COR_return DELIVERABLE_COR_ROUTING.COR_ID%type;
  TR_return DELIVERABLE_TR_ROUTING.TECHNICAL_REVIEWER_ID%type;
  vFirstName USERS.FirstName%TYPE;
  vTORNAMES  VARCHAR2(3200) :=NULL;
type t_FYI_id
IS
  TABLE OF DELIVERABLE_DETAIL.FYI_NOTIFICATION%TYPE INDEX BY pls_integer;
  vFYIs VARCHAR2(32200) :=NULL;
  v_array_FYI apex_application_global.vc_arr2;
BEGIN
  BEGIN
    SELECT DELIVERABLE_TITLE,
      DELIVERABLE_NUMBER,
      contract_number,
      Technical_Reviewer,
      COR_NAME
    INTO vTITLE,
      vDELIVERABLE_NUMBER,
      vCONTRACT,
      vTechR,
      vCOR
    FROM deliverables
    WHERE DELIVERABLE_ID = P_DELIVERABLE_ID;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
    NULL;
  END;
vSUBJECT := 'Contract '||vCONTRACT||' Deliverable #'||vDELIVERABLE_NUMBER ||' Submitted';
SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
/* Email related requirement
Sends email notification  to:
• Technical Reviewer
• COR
eMail Subject: Contract <CONTRACT NUMBER> Deliverable Submitted
Body: <REVIEWER>,
A deliverable has been submitted for contract deliverable <DELIVERABLE TITLE> and is ready for review.  Please log in to eEMRT to review the deliverable.
If you have received this message in error, please contact the eEMRT Administrator. “
If FYI is NOT ‘null’ also sends email notification to FYI <email address>
Email Subject: FYI: Contract <CONTRACT NUMBER> Deliverable Submitted
Email message: “A deliverable has been submitted for contract deliverable <DELIVERABLE TITLE> and is now ready for review.
If you have received this message in error, please contact the eEMRT Administrator. “
*/
UPDATE DELIVERABLES
SET FYI_NOTIFICATION = P_FYI_NOTIFICATION,
  DELIVERABLE_STATUS = 'Ready for Review',
  Updated_BY         = P_SUBMITTED_BY,
  Updated_ON         = sysdate()
WHERE DELIVERABLE_ID = P_DELIVERABLE_ID;
IF SQL%FOUND THEN
  p_PStatus := 'SUCCESS' ;
  --  COMMIT;
END IF;
--Begin insert detail here once updating header.
BEGIN
  v_id := DELIVERABLES_Detail_SEQ.NEXTVAL;
  SELECT NVL(COUNT(DELIVERABLE_ID),0)+1
  INTO vCount
  FROM DELIVERABLE_DETAIL
  WHERE DELIVERABLE_ID = P_DELIVERABLE_ID;
  INSERT
  INTO DELIVERABLE_DETAIL
    (
      DELIVERABLE_DETAIL_ID,
      DELIVERABLE_ID,
      DELIVERABLE_NUMBER,
      DELIVERABLE_TYPE,
      DELIVERABLE_TITLE,
      DUE_DATE,
      ACCEPTANCE_CRITERIA,
      TECHNICAL_REVIEWER,
      DELIVERABLE_STATUS,
      INSTRUCTIONS,
      WORK_ORDERS_ID,
      SUB_TASKS_ID,
      CONTRACT_NUMBER,
      VENDOR,
      CO_NAME,
      COR_NAME,
      DUE_DATE_FREQUNCY,
      SUBMITTED_BY,
      SUBMITTED_ON,
      FYI_NOTIFICATION,
      TECHNICAL_REVIEWER_ID,
      CO_ID,
      COR_ID,
      SUBMISSION_NUMBER,
      SUBMISSION_TITLE,
      COMMENTS,
      TASK_INFO,
      CREATED_BY,
      CREATED_ON
    )
  SELECT v_id,
    DELIVERABLE_ID,
    DELIVERABLE_NUMBER,
    DELIVERABLE_TYPE,
    DELIVERABLE_TITLE,
    DUE_DATE,
    ACCEPTANCE_CRITERIA,
    TECHNICAL_REVIEWER,
    'Ready for Review',
    INSTRUCTIONS,
    WORK_ORDERS_ID,
    SUB_TASKS_ID,
    CONTRACT_NUMBER,
    VENDOR,
    CO_NAME,
    COR_NAME,
    DUE_DATE_FREQUNCY,
    P_SUBMITTED_BY,
    sysdate,
    P_FYI_NOTIFICATION,
    TECHNICAL_REVIEWER_ID,
    CO_ID,
    COR_ID,
    DELIVERABLE_NUMBER
    || '-'
    ||vCount,
    P_SUBMISSION_TITLE,
    P_COMMENTS,
    TASK_INFO,
    P_SUBMITTED_BY,
    sysdate
  FROM DELIVERABLES
  WHERE DELIVERABLE_ID = P_DELIVERABLE_ID ;
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    --  COMMIT;
    p_id := v_id;
  END IF;
END;
BEGIN
  IF P_Temp_id IS NOT NULL THEN
    UPDATE entityattachment
    SET entity_id                = v_id
    WHERE ltrim(trim(entity_id)) = ltrim(trim(P_Temp_id));
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      --   COMMIT;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  p_PStatus := 'Error submitting Attachment' ;
  RETURN;
END;
-- Get the TR_IDS for the record
BEGIN
  SELECT TECHNICAL_REVIEWER_ID
  INTO vTRIds
  FROM DELIVERABLE_DETAIL
  WHERE DELIVERABLE_DETAIL_ID = v_id ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables Cannot find Tech Reviewer id record  ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  ROLLBACK;
  p_PStatus := 'Cannot find Tech Reviewer id record for DELIVERABLE_DETAIL_ID= ' ||v_id;
  RETURN;
END;
-- Get the COR_IDS for the record
BEGIN
  SELECT COR_ID
  INTO vCORIds
  FROM DELIVERABLE_DETAIL
  WHERE DELIVERABLE_DETAIL_ID = v_id ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables Cannot find COR id record ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  ROLLBACK;
  p_PStatus := 'Cannot find COR id record for DELIVERABLE_DETAIL_ID= ' ||v_id;
  RETURN;
END;
BEGIN
  --  Start inserting routing recs for TOR
  v_array_TR_id := apex_util.string_to_table(vTRIds, ',');
  forall i IN 1..v_array_TR_id.count
  INSERT
  INTO DELIVERABLE_TR_ROUTING
    (
      DELIVERABLE_TR_ROUTING_ID,
      DELIVERABLE_DETAIL_ID,
      DELIVERABLE_ID,
      DELIVERABLE_STATUS,
      TECHNICAL_REVIEWER_ID,
      CREATED_BY,
      CREATED_ON
    )
  SELECT DELIVERABLES_Routing_SEQ.NEXTVAL,
    DELIVERABLE_DETAIL_ID,
    DELIVERABLE_ID,
    'Ready for Review',
    v_array_TR_id(i),
    P_SUBMITTED_BY,
    sysdate
  FROM DELIVERABLE_DETAIL
  WHERE DELIVERABLE_DETAIL_ID = v_id ;
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    COMMIT;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  p_PStatus := 'Error inserting routing' ;
END;
BEGIN
  --  Start inserting routing recs for COR
  v_array_COR_id := apex_util.string_to_table(vCORIds, ',');
  forall j IN 1..v_array_COR_id.count
  INSERT
  INTO DELIVERABLE_COR_ROUTING
    (
      DELIVERABLE_COR_ROUTING_ID,
      DELIVERABLE_DETAIL_ID,
      DELIVERABLE_ID,
      DELIVERABLE_STATUS,
      COR_ID,
      CREATED_BY,
      CREATED_ON
    )
  SELECT DELIVERABLES_Routing_SEQ.NEXTVAL,
    DELIVERABLE_DETAIL_ID,
    DELIVERABLE_ID,
    'Ready for Review',
    v_array_COR_id(j),
    P_SUBMITTED_BY,
    sysdate
  FROM DELIVERABLE_DETAIL
  WHERE DELIVERABLE_DETAIL_ID = v_id ;
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    COMMIT;
    vMESSAGE := 'A deliverable has been submitted for contract deliverable '||vTITLE||' and is now ready for review.  Please log in to eEMRT to review the deliverable.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
    vMESSAGEHTML :='A deliverable has been submitted for contract deliverable '||vTITLE||' and is now ready for review.  Please log into <a href="http://jactdfdvap346.act.faa.gov:8080/eEMRTHome/">eEMRT</a> to review the deliverable.'|| '</br></br>'|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  p_PStatus := 'Error inserting routing' ;
END;

--Start collecting names TORS

FOR rec IN (SELECT TECHNICAL_REVIEWER_ID,   email,  firstname  ||' '  ||lastname fullName
              FROM DELIVERABLE_TR_ROUTING,  users
WHERE TECHNICAL_REVIEWER_ID = username
AND DELIVERABLE_DETAIL_ID   = v_id
)
LOOP
  vTORNAMES:=rec.fullName||', '|| vTORNAMES;
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'Collect all Names  for TORs  from PKG_DELIVERABLES.sp_submit_deliverables  to TOR_ID =' || rec.TECHNICAL_REVIEWER_ID || ' vTORNAMES =' || vTORNAMES);
END LOOP;

--Then send emails to TORS

FOR rec IN (SELECT TECHNICAL_REVIEWER_ID,   email,  firstname  ||' '  ||lastname fullName
              FROM DELIVERABLE_TR_ROUTING,  users
WHERE TECHNICAL_REVIEWER_ID = username
AND DELIVERABLE_DETAIL_ID   = v_id
)
LOOP
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'EMAIL SENT to TOR  from PKG_DELIVERABLES.sp_submit_deliverables  to TOR_ID =' || rec.TECHNICAL_REVIEWER_ID || ' email =' || rec.email|| ' vTORNAMES =' || vTORNAMES   );
 --- SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => vTORNAMES ||  chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
  SP_SEND_HTML_EMAIL(
    P_FROM => vSENDER,
    P_TO => rec.email,    
    P_SUBJECT => vSUBJECT,
    --- P_TEXT => vTORNAMES ||  chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
    P_HTML => vTORNAMES ||  '</br></br>'|| vMESSAGEHTML || '</br></br>Thank you, </br></br>eEMRT Admin'
  );    
    
END LOOP;


--Start sending emails to CORS with Names of TORS

FOR rec IN
(SELECT COR_ID,
  email,
  firstname
  ||' '
  ||lastname fullName
FROM DELIVERABLE_COR_ROUTING,
  users
WHERE COR_ID              = username
AND DELIVERABLE_DETAIL_ID = v_id
)
LOOP
  -- COR_return := rec;
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'EMAIL SENT to COR from PKG_DELIVERABLES.sp_submit_deliverables  to COR_ID =' || rec.COR_ID || ' email =' || rec.email|| ' vTORNAMES =' || vTORNAMES   );
 -- SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE =>  vTORNAMES ||  chr(13)||chr(13)||  vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
  SP_SEND_HTML_EMAIL(
    P_FROM => vSENDER,
    P_TO => rec.email,    
    P_SUBJECT => vSUBJECT,
    --- P_TEXT => vTORNAMES ||  chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
    P_HTML => vTORNAMES ||  '</br></br>'|| vMESSAGEHTML || '</br></br>Thank you, </br></br>eEMRT Admin'
  );    
END LOOP;

IF P_FYI_NOTIFICATION IS NOT NULL THEN
  vFYIs               := P_FYI_NOTIFICATION;
  v_array_FYI         := apex_util.string_to_table(vFYIs, ';');
  FOR i IN 1..v_array_FYI.count
  LOOP
    vfirstname := INITCAP(SUBSTR(v_array_FYI(i),1,INSTR(v_array_FYI(i),'.')-1));
    --SP_INSERT_AUDIT(P_SUBMITTED_BY, 'EMAILS SENT to FYI from PKG_DELIVERABLES.sp_submit_deliverables  to P_FYI_NOTIFICATION =' || P_FYI_NOTIFICATION || ' email =' || v_array_FYI(i));
    vMESSAGE := 'A deliverable has been submitted for contract deliverable '||vTITLE||' and is now ready for review. '|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ' ;
    --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => v_array_FYI(i), SUBJECT => 'FYI: ' ||vSUBJECT||'', MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.' );
    vMESSAGEHTML :='A deliverable has been submitted for contract deliverable '||vTITLE||' and is now ready for review. </br></br> If you have received this message in error, please contact the eEMRT Administrator. ' ;
  SP_SEND_HTML_EMAIL(
    P_FROM => vSENDER,
    P_TO =>  v_array_FYI(i),    
    P_SUBJECT =>  'FYI: ' || vSUBJECT,
    --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.',
    P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>eEMRT Admin.</br></br>This is FYI email.. No Action required.'  );  
    vfirstname:= '';
  END LOOP;
END IF;

--Testing HTML EMAIL

--sp_send_html_email(    p_to   => vSENDER,    p_from   =>vSENDER,    p_subject =>vSUBJECT,        p_html  =>  vMESSAGE    );
    
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  SP_INSERT_AUDIT(P_SUBMITTED_BY, 'PKG_DELIVERABLES.sp_submit_deliverables ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  p_PStatus := 'Error submitting Deliverables' ;
END sp_submit_deliverable;


PROCEDURE sp_get_COs_CORs(
    p_UserId          VARCHAR2,
    p_CONTRACT_NUMBER VARCHAR2,
    COR_cursor OUT SYS_REFCURSOR)
IS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_get_COs_CORs ' || P_CONTRACT_NUMBER);
  OPEN COR_cursor FOR SELECT co.co_id ,
  co.co_name ,
  cos.cor_id ,
  cos.cor_name,
  C.CO_NAME contract_CO_NAME,
  C.COR_NAME contract_COR_NAME FROM CONTRACT C LEFT JOIN contracting_officers co ON UPPER(co.co_id)=UPPER(C.CO_NAME) LEFT JOIN Contracting_Officers_Reps cos ON UPPER(cos.cor_id)=UPPER(C.COR_NAME) WHERE CONTRACT_NUMBER=p_CONTRACT_NUMBER;
EXCEPTION
WHEN OTHERS THEN
  OPEN COR_cursor FOR SELECT 1
AS
  CO_NAME FROM dual;
END sp_get_COs_CORs;
PROCEDURE SP_GET_TR_ROUTINGS(
    P_CONTRACT_NUMBER DELIVERABLE_DETAIL.CONTRACT_NUMBER%TYPE,
    P_DELIVERABLE_TR_ROUTING_ID NUMBER DEFAULT 0 ,
    P_DELIVERABLE_ID DELIVERABLES.DELIVERABLE_ID%TYPE DEFAULT 0 ,
    P_DELIVERABLE_DETAIL_ID NUMBER DEFAULT 0 ,
    P_DELIVERABLE_STATUS DELIVERABLES.DELIVERABLE_STATUS%TYPE DEFAULT NULL,
    P_TECHNICAL_REVIEWER_ID DELIVERABLES.TECHNICAL_REVIEWER_ID%TYPE DEFAULT NULL,
    p_UserId VARCHAR2 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.SP_GET_TR_ROUTINGS P_DELIVERABLE_TR_ROUTING_ID='||P_DELIVERABLE_TR_ROUTING_ID||'P_DELIVERABLE_DETAIL_ID='||P_DELIVERABLE_DETAIL_ID|| 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  OPEN REC_CURSOR FOR SELECT DR.DELIVERABLE_TR_ROUTING_ID,
  DR.DELIVERABLE_DETAIL_ID,
  DR.DELIVERABLE_ID,
  DR.DELIVERABLE_STATUS,
  DR.TECHNICAL_REVIEWER_ID,
  DR.CREATED_BY,
  DR.CREATED_ON,
  DR.UPDATED_BY,
  DR.UPDATED_ON ,
  D.DELIVERABLE_NUMBER,
  D.DELIVERABLE_TYPE,
  D.DELIVERABLE_TITLE,
  D.Submission_Title,
  D.Submission_Number,
  DR.Comments,
  DR.Rating,
  D.CONTRACT_NUMBER,
  D.DELIVERABLE_STATUS DELIVERABLE_DETAIL_STATUS FROM DELIVERABLE_TR_ROUTING DR INNER JOIN DELIVERABLE_DETAIL D ON DR.DELIVERABLE_DETAIL_ID = D.DELIVERABLE_DETAIL_ID WHERE (DR.DELIVERABLE_ID = P_DELIVERABLE_ID OR P_DELIVERABLE_ID = 0) AND (D.CONTRACT_NUMBER = P_CONTRACT_NUMBER OR P_CONTRACT_NUMBER IS NULL) AND (DR.DELIVERABLE_TR_ROUTING_ID = P_DELIVERABLE_TR_ROUTING_ID OR P_DELIVERABLE_TR_ROUTING_ID = 0) AND (D.DELIVERABLE_DETAIL_ID = P_DELIVERABLE_DETAIL_ID OR P_DELIVERABLE_DETAIL_ID = 0) AND (DR.DELIVERABLE_STATUS = P_DELIVERABLE_STATUS OR P_DELIVERABLE_STATUS IS NULL) AND (Upper(DR.TECHNICAL_REVIEWER_ID) = Upper(P_TECHNICAL_REVIEWER_ID) OR P_TECHNICAL_REVIEWER_ID IS NULL )-- OR Upper(DR.CREATED_BY) = Upper(p_UserId))
  ORDER BY DR.CREATED_BY DESC;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 1
AS
  DELIVERABLE_ID FROM dual;
END SP_GET_TR_ROUTINGS ;
PROCEDURE sp_Review_deliverable(
    P_DELIVERABLE_TR_ROUTING_ID NUMBER ,
    P_Rating DELIVERABLE_TR_ROUTING.Rating%TYPE DEFAULT NULL,
    P_Comments DELIVERABLE_TR_ROUTING.Comments%TYPE DEFAULT NULL,
    p_UserId VARCHAR2,
    p_PStatus OUT VARCHAR2)
AS
  vStatus             VARCHAR2(200)   :='Ready for Review';
  vCount              NUMBER          :=0;
  vCountAll           NUMBER          :=0;
  vSUBJECT            VARCHAR2(200)   :=NULL;
  vTITLE              VARCHAR2(200)   :=NULL;
  vDELIVERABLE_NUMBER VARCHAR2(200)   :=NULL;
  vCONTRACT           VARCHAR2(200)   :=NULL;
  vSENDER             VARCHAR2(200)   :='sridhar.ctr.kommanaboyina@faa.gov';
  vTechR              VARCHAR2(200)   :=NULL;
  vCOR                VARCHAR2(200)   :=NULL;
  vMESSAGE            VARCHAR2(32200) :=NULL;
  vMessageHTML        VARCHAR2(32200) :=Null;
  v_id                NUMBER          :=0;
  V_FYI_NOTIFICATION  VARCHAR2(32200) :=NULL;
  vFYIs               VARCHAR2(32200) :=NULL;
  v_array_FYI apex_application_global.vc_arr2;
  vFirstName USERS.FirstName%TYPE;
BEGIN
  BEGIN
    SELECT DELIVERABLE_TITLE,
      DELIVERABLE_NUMBER,
      contract_number,
      Technical_Reviewer,
      COR_NAME,
      FYI_NOTIFICATION
    INTO vTITLE,
      vDELIVERABLE_NUMBER,
      vCONTRACT,
      vTechR,
      vCOR,
      V_FYI_NOTIFICATION
    FROM DELIVERABLE_DETAIL
    WHERE DELIVERABLE_DETAIL_ID =
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_TR_ROUTING
      WHERE DELIVERABLE_TR_ROUTING_ID = P_DELIVERABLE_TR_ROUTING_ID
      );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Review_deliverable ERROR SQLERRM ='||SQLERRM || ' P_DELIVERABLE_TR_ROUTING_ID='||P_DELIVERABLE_TR_ROUTING_ID);
    NULL;
  END;
  vSUBJECT    := 'Contract '||vCONTRACT||' Deliverable #'||vDELIVERABLE_NUMBER ||' Reviewed';
  vMESSAGE    := 'A technical review of deliverable '||vTITLE||' has been completed.  Please log in to eEMRT to perform the deliverable acceptance process.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
  vMESSAGEHTML :='A technical review of deliverable '||vTITLE||' has been completed.  Please log in to <a href="http://jactdfdvap346.act.faa.gov:8080/eEMRTHome/">eEMRT</a> to perform the deliverable acceptance process.</br></br>If you have received this message in error, please contact the eEMRT Administrator. ';
  
  IF P_Rating IS NOT NULL THEN
    --    IF Lower(P_Rating) IN ('outstanding', 'above average', 'average', 'below average', 'poor') THEN
    ---IF Lower(P_Rating) IN ('4', '3', '2', '1', '0') THEN commented based on email new requirement
   
    IF  P_Rating is NOT NULL THEN 
      vStatus := 'Review Process Completed';
    END IF;
  END IF;
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Review_deliverable P_DELIVERABLE_TR_ROUTING_ID='||P_DELIVERABLE_TR_ROUTING_ID||' P_Rating='||P_Rating);
  UPDATE DELIVERABLE_TR_ROUTING
  SET Rating                       = P_Rating,
    Comments                       = P_Comments,
    deliverable_status             =vStatus,
    Updated_BY                     = p_UserId,
    Updated_ON                     = sysdate()
  WHERE DELIVERABLE_TR_ROUTING_ID  = P_DELIVERABLE_TR_ROUTING_ID
  AND Upper(TECHNICAL_REVIEWER_ID) = Upper(p_UserId);
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    COMMIT;
  END IF;
  SELECT COUNT(DELIVERABLE_TR_ROUTING_ID)
  INTO vCount
  FROM DELIVERABLE_TR_ROUTING
  WHERE DELIVERABLE_DETAIL_ID IN
    (SELECT DELIVERABLE_DETAIL_ID
    FROM DELIVERABLE_TR_ROUTING
    WHERE DELIVERABLE_TR_ROUTING_ID = P_DELIVERABLE_TR_ROUTING_ID
    )
  AND deliverable_status IS NOT NULL
  AND deliverable_status  = 'Review Process Completed';
  SELECT COUNT(DELIVERABLE_TR_ROUTING_ID)
  INTO vCountAll
  FROM DELIVERABLE_TR_ROUTING
  WHERE DELIVERABLE_DETAIL_ID IN
    (SELECT DELIVERABLE_DETAIL_ID
    FROM DELIVERABLE_TR_ROUTING
    WHERE DELIVERABLE_TR_ROUTING_ID = P_DELIVERABLE_TR_ROUTING_ID
    );
  IF (vCountAll - vCount = 0 ) THEN
    SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Review_deliverable Updating parent table DELIVERABLE_DETAIL P_DELIVERABLE_TR_ROUTING_ID='||P_DELIVERABLE_TR_ROUTING_ID||' P_Rating='||P_Rating);
    UPDATE DELIVERABLE_DETAIL
    SET deliverable_status       = 'Review Process Completed',
      Updated_BY                 = p_UserId,
      Updated_ON                 = sysdate()
    WHERE DELIVERABLE_DETAIL_ID IN
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_TR_ROUTING
      WHERE DELIVERABLE_TR_ROUTING_ID = P_DELIVERABLE_TR_ROUTING_ID
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
    --Start sending Emails
    --Send COR email
    FOR rec IN
    (SELECT COR_ID,
      email,
      firstname
      ||' '
      ||lastname fullName
    FROM DELIVERABLE_COR_ROUTING,
      users
    WHERE COR_ID               = username
    AND DELIVERABLE_DETAIL_ID IN
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_TR_ROUTING
      WHERE DELIVERABLE_TR_ROUTING_ID = P_DELIVERABLE_TR_ROUTING_ID
      )
    )
    LOOP
      SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to COR from PKG_DELIVERABLES.sp_submit_deliverables  to COR_ID =' || rec.COR_ID || ' email =' || rec.email);
      --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
      SP_SEND_HTML_EMAIL(
        P_FROM => vSENDER,
        P_TO =>  rec.email,    
        P_SUBJECT =>  vSUBJECT,
        --- P_TEXT => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE|| chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
        P_HTML => rec.fullname ||', </br></br>'|| vMESSAGEHTML ||'</br></br>Thank you, </br></br> eEMRT Admin');    
    END LOOP;
    --send FYI emails
    IF V_FYI_NOTIFICATION IS NOT NULL THEN
      vFYIs               := V_FYI_NOTIFICATION;
      v_array_FYI         := apex_util.string_to_table(vFYIs, ';');
      FOR i IN 1..v_array_FYI.count
      LOOP
        vfirstname := INITCAP(SUBSTR(v_array_FYI(i),1,INSTR(v_array_FYI(i),'.')-1));
        vMESSAGE := 'Contract deliverable '||vTITLE||' has been reviewed and is now pending COR Acceptance.'|| chr(13)||chr(13)||'If you have received this message in error, please contact the eEMRT Administrator.';
        --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => v_array_FYI(i), SUBJECT => 'FYI: ' ||vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.' );
        vMESSAGEHTML := 'Contract deliverable '||vTITLE||' has been reviewed and is now pending COR Acceptance.</br></br>If you have received this message in error, please contact the eEMRT Administrator.';
      SP_SEND_HTML_EMAIL(
        P_FROM => vSENDER,
        P_TO =>  v_array_FYI(i),    
        P_SUBJECT =>  'FYI: ' ||vSUBJECT,
        --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.',
        P_HTML => vMESSAGEHTML || '</br></br>'||'Thank you, </br></br>'||'eEMRT Admin</br></br>' || 'This is FYI email.. No Action required.');    


        vfirstname:= '';
      END LOOP;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Review_deliverable ERROR SQLERRM ='||SQLERRM || ' P_DELIVERABLE_TR_ROUTING_ID='||P_DELIVERABLE_TR_ROUTING_ID);
  p_PStatus := 'Error updating DELIVERABLE_TR_ROUTING' ;
END sp_Review_deliverable;
PROCEDURE SP_GET_COR_ROUTINGS(
    P_CONTRACT_NUMBER DELIVERABLE_DETAIL.CONTRACT_NUMBER%TYPE,
    P_DELIVERABLE_COR_ROUTING_ID NUMBER DEFAULT 0 ,
    P_DELIVERABLE_ID DELIVERABLES.DELIVERABLE_ID%TYPE DEFAULT 0 ,
    P_DELIVERABLE_DETAIL_ID NUMBER DEFAULT 0 ,
    P_DELIVERABLE_ROUTING_STATUS DELIVERABLE_COR_ROUTING.DELIVERABLE_STATUS%TYPE DEFAULT NULL,
    P_DELIVERABLE_DETAIL_STATUS DELIVERABLE_Detail.DELIVERABLE_STATUS%TYPE DEFAULT NULL,
    P_COR_ID DELIVERABLES.COR_ID%TYPE DEFAULT NULL,
    p_UserId VARCHAR2 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.SP_GET_COR_ROUTINGS P_DELIVERABLE_COR_ROUTING_ID='||P_DELIVERABLE_COR_ROUTING_ID||'P_DELIVERABLE_DETAIL_ID='||P_DELIVERABLE_DETAIL_ID|| 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID ||'P_DELIVERABLE_DETAIL_ID='||P_DELIVERABLE_DETAIL_ID|| ' P_DELIVERABLE_ROUTING_STATUS='||P_DELIVERABLE_ROUTING_STATUS );
  OPEN REC_CURSOR FOR SELECT DR.DELIVERABLE_COR_ROUTING_ID,
  DR.DELIVERABLE_DETAIL_ID,
  DR.DELIVERABLE_ID,
  DR.DELIVERABLE_STATUS,
  DR.COR_ID,
  DR.CO_ID,
  DR.CREATED_BY,
  DR.CREATED_ON,
  DR.UPDATED_BY,
  DR.UPDATED_ON ,
  D.DELIVERABLE_NUMBER,
  D.DELIVERABLE_TYPE,
  D.DELIVERABLE_TITLE,
  D.Submission_Title,
  D.Submission_Number,
  DR.Comments,
  DR.ACCEPT,
  DR.CO_APPROVAL,
  D.DELIVERABLE_STATUS DELIVERABLE_DETAIL_STATUS,
  D.CONTRACT_NUMBER FROM DELIVERABLE_COR_ROUTING DR INNER JOIN DELIVERABLE_DETAIL D ON DR.DELIVERABLE_DETAIL_ID = D.DELIVERABLE_DETAIL_ID
  --   LEFT OUTER JOIN (select distinct DC.CO_ID,DC.DELIVERABLE_DETAIL_ID from  DELIVERABLE_CO_ROUTING DC ) DCC ON DCC.DELIVERABLE_DETAIL_ID = DR.DELIVERABLE_DETAIL_ID
  WHERE (DR.DELIVERABLE_ID = P_DELIVERABLE_ID OR P_DELIVERABLE_ID = 0) AND (D.CONTRACT_NUMBER = P_CONTRACT_NUMBER OR P_CONTRACT_NUMBER IS NULL) AND (DR.DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID OR P_DELIVERABLE_COR_ROUTING_ID = 0) AND (D.DELIVERABLE_DETAIL_ID = P_DELIVERABLE_DETAIL_ID OR P_DELIVERABLE_DETAIL_ID = 0) AND (DR.DELIVERABLE_STATUS = P_DELIVERABLE_ROUTING_STATUS OR P_DELIVERABLE_ROUTING_STATUS IS NULL) AND (D.DELIVERABLE_STATUS = P_DELIVERABLE_DETAIL_STATUS OR P_DELIVERABLE_DETAIL_STATUS IS NULL) AND (Upper(DR.COR_ID) = Upper(P_COR_ID) OR P_COR_ID IS NULL )-- OR Upper(DR.CREATED_BY) = Upper(p_UserId))
  ORDER BY DR.CREATED_BY DESC;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 1
AS
  DELIVERABLE_ID FROM dual;
END SP_GET_COR_ROUTINGS ;
PROCEDURE sp_Accept_deliverable(
    P_DELIVERABLE_COR_ROUTING_ID NUMBER ,
    P_Status DELIVERABLE_COR_ROUTING.Deliverable_Status%TYPE DEFAULT NULL,
    P_Comments DELIVERABLE_COR_ROUTING.Comments%TYPE DEFAULT NULL,
    P_CO_APPROVAL DELIVERABLE_COR_ROUTING.CO_APPROVAL%TYPE DEFAULT 'N',
    p_ACCEPT DELIVERABLE_COR_ROUTING.ACCEPT%TYPE DEFAULT 'N',
    p_CO_ID DELIVERABLE_CO_ROUTING.CO_ID%TYPE DEFAULT NULL,
    --  P_userRole VARCHAR2,
    p_UserId VARCHAR2,
    p_PStatus OUT VARCHAR2)
AS
  vCount              NUMBER          :=0;
  vCountAll           NUMBER          :=0;
  vSUBJECT            VARCHAR2(200)   :=NULL;
  vTITLE              VARCHAR2(200)   :=NULL;
  vDELIVERABLE_NUMBER VARCHAR2(200)   :=NULL;
  vCONTRACT           VARCHAR2(200)   :=NULL;
  vSENDER             VARCHAR2(200)   :='sridhar.ctr.kommanaboyina@faa.gov';
  vTechR              VARCHAR2(200)   :=NULL;
  vCOR                VARCHAR2(200)   :=NULL;
  vMESSAGE            VARCHAR2(32200) :=NULL;
  vMessageHTML        VARCHAR2(32200) :=Null;  
  v_id                NUMBER          :=0;
  V_FYI_NOTIFICATION  VARCHAR2(32200) :=NULL;
  vFYIs               VARCHAR2(32200) :=NULL;
  v_array_FYI apex_application_global.vc_arr2;
  vFirstName USERS.FirstName%TYPE;
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Accept_deliverable P_DELIVERABLE_COR_ROUTING_ID='||P_DELIVERABLE_COR_ROUTING_ID||' P_Status='||P_Status);
  BEGIN
    SELECT DELIVERABLE_TITLE,
      DELIVERABLE_NUMBER,
      contract_number,
      Technical_Reviewer,
      COR_NAME,
      FYI_NOTIFICATION
    INTO vTITLE,
      vDELIVERABLE_NUMBER,
      vCONTRACT,
      vTechR,
      vCOR,
      V_FYI_NOTIFICATION
    FROM DELIVERABLE_DETAIL
    WHERE DELIVERABLE_DETAIL_ID =
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_COR_ROUTING
      WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
      );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Accept_deliverable ERROR SQLERRM ='||SQLERRM || ' P_DELIVERABLE_COR_ROUTING_ID='||P_DELIVERABLE_COR_ROUTING_ID);
    NULL;
  END;
  /* IF P_userRole = 'CO' THEN
  UPDATE DELIVERABLE_CO_ROUTING
  SET Deliverable_Status          = P_Status,
  Comments                      = P_Comments,
  Updated_BY                    = p_UserId,
  Updated_ON                    = sysdate()
  WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
  AND Upper(CO_ID)                = Upper(p_UserId);*/
  -- elsif P_userRole                  = 'COR' THEN
  UPDATE DELIVERABLE_COR_ROUTING
  SET Deliverable_Status           = P_Status,
    Comments                       = P_Comments,
    ACCEPT                         = p_ACCEPT,
    CO_APPROVAL                    = 'Y', --P_CO_APPROVAL,  --- defaulted on 04012016 to support RTM ID D00C Approval flag removed and always yes
    CO_ID                          = P_CO_ID,
    Updated_BY                     = p_UserId,
    Updated_ON                     = sysdate()
  WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
  AND Upper(COR_ID)                = Upper(p_UserId);
  -- END IF;
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    --  COMMIT;
  END IF;
 -- IF P_CO_APPROVAL = 'Y' THEN  --- Commented on 04012016 to support RTM ID D00C Approval flag removed
    BEGIN
      --  Start inserting routing recs for CO
      IF P_CO_ID  IS NULL THEN
        p_PStatus := 'CO Name missing, Please select and submit again.' ;
        ROLLBACK;
        RETURN;
      END IF;
      SELECT COUNT(DELIVERABLE_DETAIL_ID)
      INTO vCount
      FROM DELIVERABLE_CO_ROUTING
      WHERE DELIVERABLE_DETAIL_ID =
        (SELECT DELIVERABLE_DETAIL_ID
        FROM DELIVERABLE_COR_ROUTING
        WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
        ) ;
      IF vCount = 0 THEN
        INSERT
        INTO DELIVERABLE_CO_ROUTING
          (
            DELIVERABLE_CO_ROUTING_ID,
            DELIVERABLE_DETAIL_ID,
            DELIVERABLE_ID,
            DELIVERABLE_STATUS,
            CO_ID,
            CREATED_BY,
            CREATED_ON
          )
        SELECT DELIVERABLES_Routing_SEQ.NEXTVAL,
          DELIVERABLE_DETAIL_ID,
          DELIVERABLE_ID,
          P_Status,
          P_CO_ID,
          p_UserId,
          sysdate
        FROM DELIVERABLE_DETAIL
        WHERE DELIVERABLE_DETAIL_ID =
          (SELECT DELIVERABLE_DETAIL_ID
          FROM DELIVERABLE_COR_ROUTING
          WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
          ) ;
        IF SQL%FOUND THEN
          p_PStatus := 'SUCCESS' ;
          COMMIT;
        END IF;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Accept_deliverable ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_COR_ROUTING_ID='||P_DELIVERABLE_COR_ROUTING_ID);
      p_PStatus := 'Error inserting routing' ;
      RETURN;
    END;
    p_PStatus := 'SUCCESS' ;
 -- END IF;
  --end of approval y/n
  IF p_ACCEPT = 'Y'  THEN 
  
  
          --  IF P_CO_APPROVAL = 'Y' THEN  --- Commented on 04012016 to support RTM ID D00C Approval flag removed
                                --send email to CO informing about approval process
              vSUBJECT := 'Contract '||vCONTRACT||' Deliverable #'||vDELIVERABLE_NUMBER ||' Deliverable Accepted by COR.';
              vMESSAGE := 'COR Acceptance has been performed for deliverable '||vTITLE||'.  Please log in to eEMRT to perform the approval process.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
              vMESSAGEHTML  := 'COR Acceptance has been performed for deliverable '||vTITLE||'.  Please log into <a href="http://jactdfdvap346.act.faa.gov:8080/eEMRTHome/">eEMRT</a> to perform the approval process.</br></br>'||'If you have received this message in error, please contact the eEMRT Administrator. ';
              FOR rec IN
              (SELECT email,
                firstname -- only one record expected
                ||' '
                ||lastname fullName
              FROM users
              WHERE upper(username) = upper(P_CO_ID)
              )
              LOOP
                SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to CO from PKG_DELIVERABLES.sp_Accept_deliverables  to P_CO_ID =' || P_CO_ID || ' email =' || rec.email);
              --  SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
              SP_SEND_HTML_EMAIL(
                P_FROM => vSENDER,
                P_TO => rec.email,    
                P_SUBJECT => vSUBJECT,
                --- P_TEXT => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
                P_HTML => rec.fullname ||', </br></br>'||  vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eEMRT Admin'
              );    
                  
                END LOOP;
        --    END IF;
  vSUBJECT := 'Contract '||vCONTRACT||' Deliverable #'||vDELIVERABLE_NUMBER ||' Deliverable Accepted by COR.';
  vMESSAGEHTML := 'Contract deliverable '||vTITLE||' has been accepted by the COR. Please log into <a href="http://jactdfdvap346.act.faa.gov:8080/eEMRTHome/">eEMRT</a>  to view detailed information.</br></br>'|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
                
    --Send TR email on approval
    FOR rec IN
    (SELECT TECHNICAL_REVIEWER_ID,
      email,
      firstname
      ||' '
      ||lastname fullName
    FROM DELIVERABLE_TR_ROUTING,
      users
    WHERE TECHNICAL_REVIEWER_ID = username
    AND DELIVERABLE_DETAIL_ID  IN
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_COR_ROUTING
      WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
      )
    )
    LOOP
      SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to COR from PKG_DELIVERABLES.sp_Accept_deliverables  to TECHNICAL_REVIEWER_ID =' || rec.TECHNICAL_REVIEWER_ID || ' email =' || rec.email);
    --  SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
      SP_SEND_HTML_EMAIL(
        P_FROM => vSENDER,
        P_TO => rec.email,    
        P_SUBJECT => vSUBJECT,
        --- P_TEXT =>  rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' ,
        P_HTML =>  vMESSAGEHTML ||'</br></br>Thank you, </br></br>'|| 'eEMRT Admin' 
      );        
    END LOOP;
    --Send Submitter email
    FOR rec IN
    (SELECT D.CREATED_BY,
      email,
      firstname -- only one record expected
      ||' '
      ||lastname fullName
    FROM DELIVERABLE_DETAIL D,
      users
    WHERE D.CREATED_BY         = username
    AND DELIVERABLE_DETAIL_ID IN
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_COR_ROUTING
      WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
      )
    )
    LOOP
      SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to Submitter from PKG_DELIVERABLES.sp_Accept_deliverables  to CREATED_BY =' || rec.CREATED_BY || ' email =' || rec.email);
--      SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
      SP_SEND_HTML_EMAIL(
        P_FROM => vSENDER,
        P_TO => rec.email,    
        P_SUBJECT => vSUBJECT,
        --- P_TEXT =>  vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' ,
        P_HTML =>  vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eEMRT Admin' 
      );        
      
    END LOOP;
    --send FYI emails
    IF V_FYI_NOTIFICATION IS NOT NULL THEN
      vFYIs               := V_FYI_NOTIFICATION;
      v_array_FYI         := apex_util.string_to_table(vFYIs, ';');
      FOR i IN 1..v_array_FYI.count
      LOOP
        vfirstname := INITCAP(SUBSTR(v_array_FYI(i),1,INSTR(v_array_FYI(i),'.')-1));
        vMESSAGE := 'COR Acceptance has been performed for deliverable '||vTITLE||   chr(13)||chr(13)||'. If you have received this message in error, please contact the eEMRT Administrator. ';        
        vMESSAGEHTML := 'COR Acceptance has been performed for deliverable '||vTITLE||'.</br></br> If you have received this message in error, please contact the eEMRT Administrator. ';        
        SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to FYI after Acceptance from PKG_DELIVERABLES.sp_Accept_deliverables  to email =' || v_array_FYI(i));
        --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => v_array_FYI(i), SUBJECT => 'FYI: ' ||vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  v_array_FYI(i),    
          P_SUBJECT =>  'FYI: ' || vSUBJECT,
          --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.',
          P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>eEMRT Admin.</br></br>This is FYI email.. No Action required.'  );         
              vfirstname:= '';
      END LOOP;
    END IF;
  ELSE --Send TR email NOt accepted
    vSUBJECT := 'Contract '||vCONTRACT||' Deliverable #'||vDELIVERABLE_NUMBER ||' Deliverable Not Accepted by COR.';
    vMESSAGE := 'Contract deliverable '||vTITLE||' Not accepted by the COR. Please log into eEMRT to view detailed information.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
    vMESSAGEHTML := 'Contract deliverable '||vTITLE||' Not accepted by the COR. Please log into <a href="http://jactdfdvap346.act.faa.gov:8080/eEMRTHome/">eEMRT</a> to view detailed information.</br></br>'|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
    FOR rec IN
    (SELECT TECHNICAL_REVIEWER_ID,
      email,
      firstname
      ||' '
      ||lastname fullName
    FROM DELIVERABLE_TR_ROUTING,
      users
    WHERE TECHNICAL_REVIEWER_ID = username
    AND DELIVERABLE_DETAIL_ID  IN
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_COR_ROUTING
      WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
      )
    )
    LOOP
      SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to COR from PKG_DELIVERABLES.sp_Accept_deliverables  to TECHNICAL_REVIEWER_ID =' || rec.TECHNICAL_REVIEWER_ID || ' email =' || rec.email);
     -- SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  rec.email,    
          P_SUBJECT =>  vSUBJECT,
          --- P_TEXT => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
          P_HTML =>   vMESSAGEHTML || '</br></br>Thank you, </br></br>'|| 'eEMRT Admin' );      
    END LOOP;
    --Send Submitter email
    FOR rec IN
    (SELECT D.CREATED_BY,
      email,
      firstname -- only one record expected
      ||' '
      ||lastname fullName
    FROM DELIVERABLE_DETAIL D,
      users
    WHERE D.CREATED_BY         = username
    AND DELIVERABLE_DETAIL_ID IN
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_COR_ROUTING
      WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
      )
    )
    LOOP
      SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to Submitter from PKG_DELIVERABLES.sp_Accept_deliverables  to CREATED_BY =' || rec.CREATED_BY || ' email =' || rec.email);
--      SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  rec.email,    
          P_SUBJECT =>  vSUBJECT,
          --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
          P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>' ||'eEMRT Admin'); 
    END LOOP;
    --Send CO email
              FOR rec IN
                  (SELECT email,
                    firstname -- only one record expected
                    ||' '
                    ||lastname fullName
                  FROM users
                  WHERE upper(username) = upper(P_CO_ID)
                  )
                  LOOP
                    SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to CO from PKG_DELIVERABLES.sp_Accept_deliverables  to P_CO_ID =' || P_CO_ID || ' email =' || rec.email);
                  --  SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
                  SP_SEND_HTML_EMAIL(
                    P_FROM => vSENDER,
                    P_TO => rec.email,    
                    P_SUBJECT => vSUBJECT,
                    --- P_TEXT => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
                    P_HTML => rec.fullname ||', </br></br>'||  vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eEMRT Admin'
                  ); 
              END LOOP;
  END IF; 
  --end of Acceptance 
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Accept_deliverable Updating parent table DELIVERABLE_DETAIL P_DELIVERABLE_COR_ROUTING_ID='||P_DELIVERABLE_COR_ROUTING_ID||' P_Status='||P_Status);
  UPDATE DELIVERABLE_DETAIL
  SET deliverable_status       = 'Acceptance Process Completed',
    Updated_BY                 = p_UserId,
    Updated_ON                 = sysdate()
  WHERE DELIVERABLE_DETAIL_ID IN
    (SELECT DELIVERABLE_DETAIL_ID
    FROM DELIVERABLE_COR_ROUTING
    WHERE DELIVERABLE_COR_ROUTING_ID = P_DELIVERABLE_COR_ROUTING_ID
    );
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    COMMIT;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Accept_deliverable ERROR SQLERRM ='||SQLERRM || ' P_DELIVERABLE_COR_ROUTING_ID='||P_DELIVERABLE_COR_ROUTING_ID);
  p_PStatus := 'Error updating DELIVERABLE_COR_ROUTING' ;
END sp_Accept_deliverable;

PROCEDURE SP_GET_CO_ROUTINGS(
    P_CONTRACT_NUMBER DELIVERABLE_DETAIL.CONTRACT_NUMBER%TYPE,
    P_DELIVERABLE_CO_ROUTING_ID NUMBER DEFAULT 0 ,
    P_DELIVERABLE_ID DELIVERABLES.DELIVERABLE_ID%TYPE DEFAULT 0 ,
    P_DELIVERABLE_DETAIL_ID NUMBER DEFAULT 0 ,
    P_DELIVERABLE_ROUTING_STATUS DELIVERABLE_CO_ROUTING.DELIVERABLE_STATUS%TYPE DEFAULT NULL,
    P_DELIVERABLE_DETAIL_STATUS DELIVERABLE_Detail.DELIVERABLE_STATUS%TYPE DEFAULT NULL,
    P_CO_ID DELIVERABLES.CO_ID%TYPE DEFAULT NULL,
    p_UserId VARCHAR2 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.SP_GET_CO_ROUTINGS P_DELIVERABLE_CO_ROUTING_ID='||P_DELIVERABLE_CO_ROUTING_ID||'P_DELIVERABLE_DETAIL_ID='||P_DELIVERABLE_DETAIL_ID|| 'P_DELIVERABLE_ID='||P_DELIVERABLE_ID);
  OPEN REC_CURSOR FOR SELECT DR.DELIVERABLE_CO_ROUTING_ID,
  DR.DELIVERABLE_DETAIL_ID,
  DR.DELIVERABLE_ID,
  DR.DELIVERABLE_STATUS,
  DR.CO_ID,
  DR.CREATED_BY,
  DR.CREATED_ON,
  DR.UPDATED_BY,
  DR.UPDATED_ON ,
  D.DELIVERABLE_NUMBER,
  D.DELIVERABLE_TYPE,
  D.DELIVERABLE_TITLE,
  D.Submission_Title,
  D.Submission_Number,
  DR.Comments,
  DR.APPROVE,
  D.DELIVERABLE_STATUS DELIVERABLE_DETAIL_STATUS,
  D.CONTRACT_NUMBER FROM DELIVERABLE_CO_ROUTING DR INNER JOIN DELIVERABLE_DETAIL D ON DR.DELIVERABLE_DETAIL_ID = D.DELIVERABLE_DETAIL_ID WHERE (DR.DELIVERABLE_ID = P_DELIVERABLE_ID OR P_DELIVERABLE_ID = 0) AND (D.CONTRACT_NUMBER = P_CONTRACT_NUMBER OR P_CONTRACT_NUMBER IS NULL) AND (DR.DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID OR P_DELIVERABLE_CO_ROUTING_ID = 0) AND (D.DELIVERABLE_DETAIL_ID = P_DELIVERABLE_DETAIL_ID OR P_DELIVERABLE_DETAIL_ID = 0) AND (DR.DELIVERABLE_STATUS = P_DELIVERABLE_ROUTING_STATUS OR P_DELIVERABLE_ROUTING_STATUS IS NULL) AND (D.DELIVERABLE_STATUS = P_DELIVERABLE_DETAIL_STATUS OR P_DELIVERABLE_DETAIL_STATUS IS NULL) AND (Upper(DR.CO_ID) = Upper(P_CO_ID) OR P_CO_ID IS NULL )-- OR Upper(DR.CREATED_BY) = Upper(p_UserId))
  ORDER BY DR.CREATED_BY DESC;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 1
AS
  DELIVERABLE_ID FROM dual;
END SP_GET_CO_ROUTINGS;
PROCEDURE sp_Approve_deliverable(
    P_DELIVERABLE_CO_ROUTING_ID NUMBER ,
    P_Status DELIVERABLE_CO_ROUTING.Deliverable_Status%TYPE ,
    P_Comments DELIVERABLE_CO_ROUTING.Comments%TYPE DEFAULT NULL,
    P_APPROVE DELIVERABLE_CO_ROUTING.APPROVE%TYPE ,
    p_UserId VARCHAR2,
    p_PStatus OUT VARCHAR2)
AS
  vSUBJECT            VARCHAR2(200)   :=NULL;
  vTITLE              VARCHAR2(200)   :=NULL;
  vDELIVERABLE_NUMBER VARCHAR2(200)   :=NULL;
  vCONTRACT           VARCHAR2(200)   :=NULL;
  vSENDER             VARCHAR2(200)   :='sridhar.ctr.kommanaboyina@faa.gov';
  vTechR              VARCHAR2(200)   :=NULL;
  vCOR                VARCHAR2(200)   :=NULL;
  vMESSAGE            VARCHAR2(32200) :=NULL;
  vMESSAGEHTML        VARCHAR2(32200) :=NULL;
  v_id                NUMBER          :=0;
  V_FYI_NOTIFICATION  VARCHAR2(32200) :=NULL;
  vFYIs               VARCHAR2(32200) :=NULL;
  v_array_FYI apex_application_global.vc_arr2;
  vFirstName USERS.FirstName%TYPE;
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Approve_deliverable P_DELIVERABLE_CO_ROUTING_ID='||P_DELIVERABLE_CO_ROUTING_ID||' P_Status='||P_Status);
  BEGIN
    SELECT DELIVERABLE_TITLE,
      DELIVERABLE_NUMBER,
      contract_number,
      Technical_Reviewer,
      COR_NAME,
      FYI_NOTIFICATION
    INTO vTITLE,
      vDELIVERABLE_NUMBER,
      vCONTRACT,
      vTechR,
      vCOR,
      V_FYI_NOTIFICATION
    FROM DELIVERABLE_DETAIL
    WHERE DELIVERABLE_DETAIL_ID =
      (SELECT DELIVERABLE_DETAIL_ID
      FROM DELIVERABLE_CO_ROUTING
      WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID
      );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Accept_deliverable ERROR SQLERRM ='||SQLERRM || ' P_DELIVERABLE_COR_ROUTING_ID='||P_DELIVERABLE_CO_ROUTING_ID);
    NULL;
  END;
  UPDATE DELIVERABLE_CO_ROUTING
  SET Deliverable_Status          = P_Status , --'Approval Process Completed',
    Comments                      = P_Comments,
    APPROVE                       = P_APPROVE,
    Updated_BY                    = p_UserId,
    Updated_ON                    = sysdate()
  WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID
  AND Upper(CO_ID)                = Upper(p_UserId);
  UPDATE DELIVERABLE_DETAIL
  SET deliverable_status       = 'Approval Process Completed',
    Comments                   = P_Comments,
    Updated_BY                 = p_UserId,
    Updated_ON                 = sysdate()
  WHERE DELIVERABLE_DETAIL_ID IN
    (SELECT DELIVERABLE_DETAIL_ID
    FROM DELIVERABLE_CO_ROUTING
    WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID
    );
  IF SQL%FOUND THEN
    p_PStatus := 'SUCCESS' ;
    COMMIT;
    vSUBJECT    := 'Contract '||vCONTRACT||' Deliverable #'||vDELIVERABLE_NUMBER ||' Deliverable Approved.';
    vMESSAGE    := 'Contract deliverable '||vTITLE||' has been approved by the CO. Please log into eEMRT to view detailed information.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
    vMESSAGEHTML:= 'Contract deliverable '||vTITLE||' has been approved by the CO. Please log into <a href="http://jactdfdvap346.act.faa.gov:8080/eEMRTHome/">eEMRT</a> to view detailed information.</br></br>'||   'If you have received this message in error, please contact the eEMRT Administrator. ';
    IF P_APPROVE = 'Y' THEN
      --Send emails to FYI, submitter and TOR
      --Send TR email on approval
      FOR rec IN
      (SELECT TECHNICAL_REVIEWER_ID,
        email,
        firstname
        ||' '
        ||lastname fullName
      FROM DELIVERABLE_TR_ROUTING,
        users
      WHERE TECHNICAL_REVIEWER_ID = username
      AND DELIVERABLE_DETAIL_ID  IN
        (SELECT DELIVERABLE_DETAIL_ID
        FROM DELIVERABLE_CO_ROUTING
        WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID
        )
      )
      LOOP
        SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to COR from PKG_DELIVERABLES.sp_Approve_deliverable  to TECHNICAL_REVIEWER_ID =' || rec.TECHNICAL_REVIEWER_ID || ' email =' || rec.email);
        --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  rec.email,    
          P_SUBJECT =>  vSUBJECT,
          --- P_TEXT => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
          P_HTML => rec.fullname ||', </br></br>'|| vMESSAGEHTML ||'</br></br>Thank you, </br></br>'||'eEMRT Admin');         
      END LOOP;
      --Send Submitter email
      FOR rec IN
      (SELECT D.CREATED_BY,
        email,
        firstname -- only one record expected
        ||' '
        ||lastname fullName
      FROM DELIVERABLE_DETAIL D,
        users
      WHERE D.CREATED_BY         = username
      AND DELIVERABLE_DETAIL_ID IN
        (SELECT DELIVERABLE_DETAIL_ID
        FROM DELIVERABLE_CO_ROUTING
        WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID
        )
      )
      LOOP
        SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to Submitter from PKG_DELIVERABLES.sp_Approve_deliverable  to CREATED_BY =' || rec.CREATED_BY || ' email =' || rec.email);
        --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  rec.email,    
          P_SUBJECT =>  vSUBJECT,
          --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin',
          P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eEMRT Admin');         
        
      END LOOP;
      --send FYI emails
      IF V_FYI_NOTIFICATION IS NOT NULL THEN
        vFYIs               := V_FYI_NOTIFICATION;
        v_array_FYI         := apex_util.string_to_table(vFYIs, ';');
        FOR i IN 1..v_array_FYI.count
        LOOP
          vfirstname := INITCAP(SUBSTR(v_array_FYI(i),1,INSTR(v_array_FYI(i),'.')-1));
          SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to FYI after Acceptance from PKG_DELIVERABLES.sp_Approve_deliverable  to email =' || v_array_FYI(i));
          vMESSAGE    := 'Contract deliverable '||vTITLE||' has been approved by the CO.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';          
          vMESSAGEHTML    := 'Contract deliverable '||vTITLE||' has been approved by the CO.</br></br>'||   'If you have received this message in error, please contact the eEMRT Administrator. ';          
--          SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => v_array_FYI(i), SUBJECT => 'FYI: ' ||vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  v_array_FYI(i),    
          P_SUBJECT =>   'FYI: ' ||vSUBJECT,
          --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.',
          P_HTML => vMESSAGEHTML || '</br></br>Thank you, </br></br>'||'eEMRT Admin</br></br>' || 'This is FYI email.. No Action required.');   
          
          vfirstname:= '';
        END LOOP;
      END IF;
    ELSE -- not approved scenario
      SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Approve_deliverable P_DELIVERABLE_CO_ROUTING_ID='||P_DELIVERABLE_CO_ROUTING_ID||' P_APPROVE='||P_APPROVE);
      vSUBJECT := 'Contract '||vCONTRACT||' Deliverable #'||vDELIVERABLE_NUMBER ||' Deliverable Not Approved by CO.';
      vMESSAGE := 'Contract deliverable '||vTITLE||' has not been approved by the CO. Please log into eEMRT to view detailed information.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
      vMESSAGEHTML := 'Contract deliverable '||vTITLE||' has not been approved by the CO. Please log into <a href="http://jactdfdvap346.act.faa.gov:8080/eEMRTHome/">eEMRT</a> to view detailed information.</br></br>'|| 'If you have received this message in error, please contact the eEMRT Administrator. ';
      FOR rec IN
      (SELECT TECHNICAL_REVIEWER_ID,
        email,
        firstname
        ||' '
        ||lastname fullName
      FROM DELIVERABLE_TR_ROUTING,
        users
      WHERE TECHNICAL_REVIEWER_ID = username
      AND DELIVERABLE_DETAIL_ID  IN
        (SELECT DELIVERABLE_DETAIL_ID
        FROM DELIVERABLE_CO_ROUTING
        WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID
        )
      )
      LOOP
        SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to COR from PKG_DELIVERABLES.sp_Approve_deliverable after non approval TECHNICAL_REVIEWER_ID =' || rec.TECHNICAL_REVIEWER_ID || ' email =' || rec.email);
        --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  rec.email,    
          P_SUBJECT =>   vSUBJECT,
          --- P_TEXT => rec.fullname ||', '|| chr(13)||chr(13)|| vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' ,
          P_HTML => rec.fullname ||', '|| '</br></br>'|| vMESSAGEHTML || '</br></br>'||'Thank you, '|| '</br></br>'||'eEMRT Admin' );   
        
        
        
      END LOOP;
      --Send Submitter email
      FOR rec IN
      (SELECT D.CREATED_BY,
        email,
        firstname -- only one record expected
        ||' '
        ||lastname fullName
      FROM DELIVERABLE_DETAIL D,
        users
      WHERE D.CREATED_BY         = username
      AND DELIVERABLE_DETAIL_ID IN
        (SELECT DELIVERABLE_DETAIL_ID
        FROM DELIVERABLE_CO_ROUTING
        WHERE DELIVERABLE_CO_ROUTING_ID = P_DELIVERABLE_CO_ROUTING_ID
        )
      )
      LOOP
        SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to Submitter from PKG_DELIVERABLES.sp_Approve_deliverable after non approval to CREATED_BY =' || rec.CREATED_BY || ' email =' || rec.email);
        --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => rec.email, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  rec.email,    
          P_SUBJECT =>   vSUBJECT,
          --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' ,
          P_HTML => vMESSAGEHTML || '</br></br>'||'Thank you, '|| '</br></br>'||'eEMRT Admin' );           
      END LOOP;
      --send FYI emails
      IF V_FYI_NOTIFICATION IS NOT NULL THEN
        vFYIs               := V_FYI_NOTIFICATION;
        v_array_FYI         := apex_util.string_to_table(vFYIs, ';');
        FOR i IN 1..v_array_FYI.count
        LOOP
          vfirstname := INITCAP(SUBSTR(v_array_FYI(i),1,INSTR(v_array_FYI(i),'.')-1));
          SP_INSERT_AUDIT(p_UserId, 'EMAIL SENT to FYI after non approval from PKG_DELIVERABLES.sp_Approve_deliverable  to email =' || v_array_FYI(i));
          vMESSAGE := 'Contract deliverable '||vTITLE||' has not been approved by the CO.'|| chr(13)||chr(13)|| 'If you have received this message in error, please contact the eEMRT Administrator. ';          
          vMESSAGEHTML:= 'Contract deliverable '||vTITLE||' has not been approved by the CO.'||'</br></br>'|| 'If you have received this message in error, please contact the eEMRT Administrator. ';          
          --SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => v_array_FYI(i), SUBJECT => 'FYI: ' ||vSUBJECT, MESSAGE => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.' );
        SP_SEND_HTML_EMAIL(
          P_FROM => vSENDER,
          P_TO =>  v_array_FYI(i),    
          P_SUBJECT => 'FYI: ' ||  vSUBJECT,
          --- P_TEXT => vMESSAGE || chr(13)||chr(13)||'Thank you, '|| chr(13)||chr(13)||'eEMRT Admin' || chr(13)||chr(13)||'This is FYI email.. No Action required.' ,
          P_HTML => vMESSAGEHTML || '</br></br>'||'Thank you, '|| '</br></br>'||'eEMRT Admin' ||'</br></br>'||'This is FYI email.. No Action required.'  );            
          vfirstname:= '';
        END LOOP;
      END IF;  -- end of V_FYI
    END IF;   -- end of Approve
  END IF; -- end of SQL
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  SP_INSERT_AUDIT(p_UserId, 'PKG_DELIVERABLES.sp_Approve_deliverable ERROR SQLERRM ='||SQLERRM || 'P_DELIVERABLE_CO_ROUTING_ID='||P_DELIVERABLE_CO_ROUTING_ID);
  p_PStatus := 'Error Approving' ;
END sp_Approve_deliverable;
END PKG_DELIVERABLES;
/