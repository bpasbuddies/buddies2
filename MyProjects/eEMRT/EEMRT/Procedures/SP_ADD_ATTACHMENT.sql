CREATE OR REPLACE PROCEDURE eemrt.SP_Add_Attachment(
    p_EntityType_ID NUMBER ,
    p_FILE_TYPE_ID NUMBER,
    p_Entity_ID VARCHAR2 , 	
    p_eAttachment BLOB, 	
    p_Description VARCHAR2, 
    p_TableName VARCHAR2, 
    p_User VARCHAR2, 
    p_PStatus OUT VARCHAR2 )
IS
BEGIN
-- Need to check if he is a valid user from users table
SP_INSERT_AUDIT(p_User, 'SP_Add_Attachment p_Entity_ID='||p_Entity_ID ||' p_Description='|| p_Description);

 IF p_Entity_ID = '0' THEN
   p_PStatus := 'ERROR: Invalid Attachement id, Please refer user guide' ;
   Return;
 END IF;

  INSERT
  INTO EntityAttachment
    (
      EntityAttachment_ID, 	
      EntityType_ID, 	
      FILE_TYPE_ID,
      Entity_ID, 	
      eAttachment, 	
      Description , 
      TableName, 
      CREATED_BY, 
      CREATED_ON 
    )
    VALUES
    (
      EntityAttachment_SEQ.NEXTVAL, 	
      p_EntityType_ID, 
      p_FILE_TYPE_ID,
      p_Entity_ID,
      p_eAttachment, 	
      p_Description, 
      p_TableName, 
      p_User, 
      sysdate
    );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    ELSE      
      p_PStatus := 'COULD NOT INSERT DATA' ;

    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    p_PStatus := 'Error inserting Document ' || SQLERRM ;
    RETURN ;
END SP_Add_Attachment;
/