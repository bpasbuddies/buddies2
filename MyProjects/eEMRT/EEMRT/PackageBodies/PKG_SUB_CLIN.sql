CREATE OR REPLACE PACKAGE BODY eemrt."PKG_SUB_CLIN" 
AS
  PROCEDURE insert_SUB_CLIN(
      p_SUB_CLIN_NUMBER   IN SUB_CLIN.SUB_CLIN_NUMBER%type DEFAULT NULL,
      p_CLIN_ID           IN SUB_CLIN.CLIN_ID%type DEFAULT NULL,
      p_SUB_CLIN_TITLE    IN SUB_CLIN.SUB_CLIN_TITLE%type DEFAULT NULL,
      p_SUB_CLIN_TYPE     IN SUB_CLIN.SUB_CLIN_TYPE%TYPE,
      p_SUB_CLIN_HOURS    IN SUB_CLIN.SUB_CLIN_HOURS%type DEFAULT NULL,
      p_SUB_CLIN_RATE     IN SUB_CLIN.SUB_CLIN_RATE%type DEFAULT NULL,
      p_SUB_CLIN_AMOUNT   IN SUB_CLIN.SUB_CLIN_AMOUNT%type DEFAULT NULL,
      p_LABOR_CATEGORY_ID IN SUB_CLIN.LABOR_CATEGORY_ID%type DEFAULT NULL,
      p_LABOR_RATE_TYPE            IN     SUB_CLIN.LABOR_RATE_TYPE%TYPE DEFAULT NULL,      
      p_CREATED_BY        IN SUB_CLIN.CREATED_BY%type DEFAULT NULL,
      p_PStatus OUT VARCHAR2)
  /*
  Procedure : insert_SUB_CLIN
  Author: Sridhar Kommana
  Date Created : 04/24/2015
  Purpose:  Insert Sub-Clin information.
  Update history:  
  1) 04/22/2016 : sridhar kommana Added p_SUB_CLIN_TYPE per RTMID=  C02-15
  */      
  AS
    vCLIN_TYPE SUB_CLIN.SUB_CLIN_TYPE%TYPE;
    vCLIN_Number SUB_CLIN.SUB_CLIN_NUMBER%TYPE;
  BEGIN
        SP_INSERT_AUDIT (p_CREATED_BY, 'insert_SUB_CLIN');
    BEGIN 
      select clin_type , CLIN_Number
      into  vCLIN_TYPE, vCLIN_Number
      from  POP_CLIN
      where CLIN_ID = p_CLIN_ID;
      EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_PStatus := 'Cannot obtain Clin Type for Clinid:' ||p_CLIN_ID  ;
      RETURN;
    END;    
  
    INSERT
    INTO SUB_CLIN
      (
        SUB_CLIN_ID,
        SUB_CLIN_NUMBER,
        CLIN_ID,
        SUB_CLIN_TITLE,
        SUB_CLIN_TYPE,
        SUB_CLIN_HOURS,
        SUB_CLIN_RATE,
        SUB_CLIN_AMOUNT,
        LABOR_CATEGORY_ID,
        LABOR_RATE_TYPE,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        SUB_CLIN_SEQ.NEXTVAL,
        p_SUB_CLIN_NUMBER,
        p_CLIN_ID ,
        p_SUB_CLIN_TITLE ,
        p_SUB_CLIN_TYPE, --vCLIN_TYPE ,
        p_SUB_CLIN_HOURS ,
        p_SUB_CLIN_RATE ,
        p_SUB_CLIN_AMOUNT ,
        p_LABOR_CATEGORY_ID,
        p_LABOR_RATE_TYPE,
        p_CREATED_BY,
        sysdate()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
    update  sub_clin set sub_clin_title = sub_clin_number||'- Title' where sub_clin_title is null;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error Inserting SUB_CLIN' ;
  END insert_SUB_CLIN;
  PROCEDURE update_SUB_CLIN
    (
      p_SUB_CLIN_ID       IN SUB_CLIN.SUB_CLIN_ID%type DEFAULT NULL,
      p_SUB_CLIN_NUMBER   IN SUB_CLIN.SUB_CLIN_NUMBER%type DEFAULT NULL,
      p_SUB_CLIN_TITLE    IN SUB_CLIN.SUB_CLIN_TITLE%type DEFAULT NULL,
      p_SUB_CLIN_TYPE     IN SUB_CLIN.SUB_CLIN_TYPE%TYPE,
      p_SUB_CLIN_HOURS    IN SUB_CLIN.SUB_CLIN_HOURS%type DEFAULT NULL,
      p_SUB_CLIN_RATE     IN SUB_CLIN.SUB_CLIN_RATE%type DEFAULT NULL,
      p_SUB_CLIN_AMOUNT   IN SUB_CLIN.SUB_CLIN_AMOUNT%type DEFAULT NULL,
      p_LABOR_CATEGORY_ID IN SUB_CLIN.LABOR_CATEGORY_ID%type DEFAULT NULL,
       p_LABOR_RATE_TYPE            IN     SUB_CLIN.LABOR_RATE_TYPE%TYPE DEFAULT NULL,      
      p_LAST_MODIFIED_BY  IN SUB_CLIN.LAST_MODIFIED_BY%type DEFAULT NULL ,
      p_PStatus OUT VARCHAR2
    )
  /*
  Procedure : update_SUB_CLIN
  Author: Sridhar Kommana
  Date Created : 04/24/2015
  Purpose:  Update Sub-Clin information.
  Update history:  
  1) 04/22/2016 : sridhar kommana Added p_SUB_CLIN_TYPE per RTMID= C02-15
  */   
  AS
  
  BEGIN
          SP_INSERT_AUDIT (p_LAST_MODIFIED_BY, 'update_SUB_CLIN');
    UPDATE SUB_CLIN
    SET
     SUB_CLIN_NUMBER = p_SUB_CLIN_NUMBER,
      SUB_CLIN_TYPE     = p_SUB_CLIN_TYPE,
      SUB_CLIN_TITLE    = p_SUB_CLIN_TITLE,
      SUB_CLIN_HOURS    = p_SUB_CLIN_HOURS,
      SUB_CLIN_RATE     = p_SUB_CLIN_RATE,
      SUB_CLIN_AMOUNT   = p_SUB_CLIN_AMOUNT,
      LABOR_CATEGORY_ID = p_LABOR_CATEGORY_ID,
      LABOR_RATE_TYPE =  p_LABOR_RATE_TYPE,
      LAST_MODIFIED_BY  = p_LAST_MODIFIED_BY,
      LAST_MODIFIED_ON  = SYSDATE()
    WHERE SUB_CLIN_ID   = p_SUB_CLIN_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error Updating SUB_CLIN' ;
  END update_SUB_CLIN;
  PROCEDURE delete_SUB_CLIN(
      p_SUB_CLIN_ID IN SUB_CLIN.SUB_CLIN_ID%type,
      p_PStatus OUT VARCHAR2 )
  AS
  BEGIN
      SP_INSERT_AUDIT (p_SUB_CLIN_ID, 'delete_SUB_CLIN');  
    DELETE FROM SUB_CLIN WHERE SUB_CLIN_ID = p_SUB_CLIN_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error Deleting SUB_CLIN' ;
    NULL;
  END delete_SUB_CLIN;
  
PROCEDURE       SP_GET_SUB_CLIN_INFO(
    p_UserId     varchar2 DEFAULT NULL ,
    P_CLIN_ID number DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)    
AS
  /*
  Procedure : SP_GET_SUB_CLIN_INFO
  Author: Sridhar Kommana
  Date Created : 04/24/2015
  Purpose:  Get SUB_CLIN for each contract/Clin or get details when clin_id is passed.
  Update history:
  sridhar kommana :
  1) 05/04/2015 : Added p_USER fro auditing/debugging
  1) 05/04/2015 : Added sort by 1 so that 0 will come on top
  */
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'Get SUB Clin totals for CLIN_ID= '||P_CLIN_ID );
  SP_INSERT_AUDIT(p_UserId, 'SP_GET_SUB_CLIN_INFO  CLIN_ID= '||P_CLIN_ID );
  OPEN REC_CURSOR FOR 
  select  sum(SUB_CLIN_HOURS) as TOTHRS, sum(SUB_CLIN_AMOUNT) as TOTAMOUNT
  from SUB_CLIN
  WHERE CLIN_ID = P_CLIN_ID; 
  
EXCEPTION
WHEN OTHERS THEN
OPEN REC_CURSOR FOR SELECT   1 as TOTHRS, 1 as TOTAMOUNT from DUAL;
END SP_GET_SUB_CLIN_INFO;  


PROCEDURE       SP_GET_SUB_CLIN(
    p_UserId     varchar2 DEFAULT NULL ,
    P_CLIN_ID     NUMBER DEFAULT 0 ,
    P_SUB_CLIN_ID NUMBER DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'SP_GET_SUB_CLIN Get SUB Clin details for CLIN_ID= '||P_CLIN_ID||' P_SUB_CLIN_ID='||P_SUB_CLIN_ID);
  --SP_INSERT_AUDIT(p_UserId, 'SP_GET_SUB_CLIN  CLIN_ID= '||P_CLIN_ID||' P_SUB_CLIN_ID='||P_SUB_CLIN_ID);
  OPEN REC_CURSOR FOR SELECT SUB_CLIN_ID, CLIN_ID, SUB_CLIN_NUMBER, SUB_CLIN_TITLE , 
  SUB_CLIN_TYPE , SUB_CLIN_HOURS , SUB_CLIN_RATE , LABOR_RATE_TYPE as SC_LABOR_RATE_TYPE ,
  SUB_CLIN_AMOUNT, LABOR_CATEGORY_ID, L.CATEGORY_NAME AS Standard_LABOR_CATEGORY
  FROM SUB_CLIN
  LEFT OUTER JOIN LABOR_CATEGORIES L ON L.CATEGORY_ID   = LABOR_CATEGORY_ID
  WHERE (CLIN_ID = P_CLIN_ID OR P_CLIN_ID= 0) AND  (SUB_CLIN_ID = P_SUB_CLIN_ID OR P_SUB_CLIN_ID= 0) ORDER BY 1;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 1 FROM SUB_CLIN ;
END SP_GET_SUB_CLIN;  
END PKG_SUB_CLIN;
/