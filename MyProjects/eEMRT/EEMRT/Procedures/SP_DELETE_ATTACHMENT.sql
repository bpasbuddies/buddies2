CREATE OR REPLACE PROCEDURE eemrt.SP_DELETE_Attachment(
    p_EntityAttachment_ID NUMBER,
    p_PStatus OUT VARCHAR2 )
IS
BEGIN

  DELETE from  EntityAttachment
  WHERE
      EntityAttachment_ID= p_EntityAttachment_ID;
  
    SP_INSERT_AUDIT('SP_DELETE_Attachment', p_EntityAttachment_ID);
    
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    ELSE      
      p_PStatus := 'COULD NOT Delete Document' ;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    p_PStatus := 'Error Deleting Document ' || SQLERRM ;
    RETURN ;
END SP_DELETE_Attachment;
/