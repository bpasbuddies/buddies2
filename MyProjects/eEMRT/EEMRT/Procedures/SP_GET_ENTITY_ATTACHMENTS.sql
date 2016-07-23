CREATE OR REPLACE PROCEDURE eemrt.SP_GET_entity_Attachments(
    p_UserId VARCHAR2 DEFAULT NULL, 
    p_Entity_ID VARCHAR2 DEFAULT NULL, 
    p_EntityAttachment_ID VARCHAR2  DEFAULT NULL,
    p_EntityType_ID NUMBER  DEFAULT 0,            
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'SP_GET_entity_Attachments Get Attachment details for Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID||' p_EntityAttachment_ID='||p_EntityAttachment_ID);
 -- SP_INSERT_AUDIT(p_UserId, 'SP_GET_entity_Attachments  Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID||' p_EntityAttachment_ID='||p_EntityAttachment_ID);
 if p_EntityAttachment_ID is not null then  --- Include attachement
     OPEN REC_CURSOR FOR
      SELECT E.EntityAttachment_ID,
             E.EntityType_ID, 
             E.Entity_ID, 
             E.eAttachment, 
             E.Description,
             E.TableName,
             E.FILE_TYPE_ID, FTL.DESCRIPTION AS File_Type
      FROM   EntityAttachment E left outer join FILE_TYPE_LKUP FTL ON  E.FILE_TYPE_ID = FTL.FILE_TYPE_ID
      WHERE (Entity_ID = p_Entity_ID  OR p_Entity_ID is NULL)
      AND  (EntityAttachment_ID = p_EntityAttachment_ID)
      AND  (ENTITYTYPE_ID = p_ENTITYTYPE_ID)--) or p_EntityType_ID = 0 )
      ORDER BY 1;
else                                          --- Do not include attachement
     OPEN REC_CURSOR FOR
      SELECT E.EntityAttachment_ID,
             E.EntityType_ID, 
             E.Entity_ID, 
             E.Description,
             E.TableName,
             E.FILE_TYPE_ID, FTL.DESCRIPTION AS File_Type
      FROM   EntityAttachment E left outer join FILE_TYPE_LKUP FTL ON  E.FILE_TYPE_ID = FTL.FILE_TYPE_ID 
      WHERE (Entity_ID = p_Entity_ID  OR p_Entity_ID is NULL)
      AND  (EntityAttachment_ID = p_EntityAttachment_ID  or p_EntityAttachment_ID is NULL )
       AND  (ENTITYTYPE_ID = p_ENTITYTYPE_ID  )--or p_EntityType_ID = 0 )
      ORDER BY 1;
end if;     
EXCEPTION WHEN OTHERS
THEN
      OPEN REC_CURSOR FOR
      SELECT 1 
       FROM EntityAttachment;
End  SP_GET_entity_Attachments;
/