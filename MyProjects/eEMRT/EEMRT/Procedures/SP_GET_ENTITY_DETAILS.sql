CREATE OR REPLACE PROCEDURE eemrt.SP_GET_Entity_Details(
    p_Entity_ID VARCHAR2 DEFAULT NULL, 	
    p_EntityAttachment_ID VARCHAR2  DEFAULT NULL, 	
    REC_CURSOR OUT SYS_REFCURSOR)
AS
BEGIN
     OPEN REC_CURSOR FOR 
      SELECT EntityAttachment_ID, 
             EntityType_ID, 	
             Entity_ID, 	
             Description, 
             TableName,
             FILE_TYPE_ID
      FROM   EntityAttachment     
      WHERE (Entity_ID = p_Entity_ID  OR p_Entity_ID is NULL)
      AND  (EntityAttachment_ID = p_EntityAttachment_ID  or p_EntityAttachment_ID is NULL )
      ORDER BY 1;
      
      
EXCEPTION WHEN OTHERS
THEN 
      OPEN REC_CURSOR FOR 
      SELECT 1  
       FROM EntityAttachment;
End  SP_GET_Entity_Details;
/