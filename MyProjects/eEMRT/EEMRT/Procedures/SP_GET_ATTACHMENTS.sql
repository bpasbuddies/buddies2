CREATE OR REPLACE PROCEDURE eemrt.SP_GET_Attachments(
    p_UserId VARCHAR2 DEFAULT NULL,     
    p_Entity_ID VARCHAR2 DEFAULT NULL, 	
    p_EntityType_ID NUMBER  DEFAULT 0, 	
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'SP_GET_Attachments Get Attachment details for Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID);
  --SP_INSERT_AUDIT(p_UserId, 'SP_GET_Attachments  Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID);
 
     OPEN REC_CURSOR FOR 
    SELECT E.EntityAttachment_ID, 
             E.Entity_ID, 
             E.ENTITYTYPE_ID,
             E.eAttachment,
             E.FILE_TYPE_ID, FTL.DESCRIPTION
  as FILE_NAME    FROM   EntityAttachment E left outer join FILE_TYPE_LKUP FTL ON  E.FILE_TYPE_ID = FTL.FILE_TYPE_ID
      WHERE (Entity_ID = p_Entity_ID)--  OR p_Entity_ID is NULL)
       AND  (ENTITYTYPE_ID = p_ENTITYTYPE_ID  or p_EntityType_ID = 0 )
      ORDER BY 1;
      
      
EXCEPTION WHEN OTHERS
THEN 
SP_INSERT_AUDIT(p_UserId, 'Error SP_GET_Attachments Get Attachment details for Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID ||'SQLERROR='||SQLERRM);
      OPEN REC_CURSOR FOR 
      SELECT 1  
       FROM EntityAttachment;
End  SP_GET_Attachments;
/