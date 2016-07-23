CREATE OR REPLACE PROCEDURE eemrt.SP_GET_Attachment_ID(
    p_EntityAttachment_ID VARCHAR2 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
  OPEN REC_CURSOR FOR SELECT EntityAttachment_ID, EntityType_ID, Entity_ID, eAttachment, Description, TableName FROM EntityAttachment WHERE EntityAttachment_ID = p_EntityAttachment_ID ORDER BY 1;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 1 FROM EntityAttachment;
END SP_GET_Attachment_ID;
/