CREATE OR REPLACE PACKAGE BODY eemrt."PKG_ATTACHEMENTS" 
AS
  PROCEDURE SP_Add_Attachment(
      p_EntityType_ID NUMBER ,
      p_FILE_TYPE_ID  NUMBER,
      p_Entity_ID     VARCHAR2 ,
      p_eAttachment BLOB,
      p_Description VARCHAR2,
      p_TableName   VARCHAR2,
      p_User        VARCHAR2,
      p_PStatus OUT VARCHAR2 )
  IS
  BEGIN
    -- Need to check if he is a valid user from users table
    SP_INSERT_AUDIT(p_User, 'p_Entity_ID='||p_Entity_ID ||' p_Description='|| p_Description);
    IF p_Entity_ID = '0' THEN
      p_PStatus   := 'ERROR: Invalid Attachement id, Please refer user guide' ;
      RETURN;
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
  PROCEDURE SP_DELETE_Attachment
    (
      p_EntityAttachment_ID NUMBER,
      p_PStatus OUT VARCHAR2
    )
  IS
  BEGIN
    DELETE FROM EntityAttachment WHERE EntityAttachment_ID= p_EntityAttachment_ID;
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
  PROCEDURE SP_GET_Attachments(
      p_UserId        VARCHAR2 DEFAULT NULL,
      p_Entity_ID     VARCHAR2 DEFAULT NULL,
      p_EntityType_ID NUMBER DEFAULT 0,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
  BEGIN
    SP_INSERT_AUDIT(p_UserId, 'Get Attachment details for Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID);
    SP_INSERT_AUDIT(p_UserId, 'SP_GET_Attachments  Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID);
    OPEN REC_CURSOR FOR SELECT E.EntityAttachment_ID,
    E.Entity_ID,
    E.ENTITYTYPE_ID,
    E.eAttachment,
    E.FILE_TYPE_ID,
    FTL.DESCRIPTION,E.CREATED_BY,E.CREATED_ON
  AS
    FILE_NAME FROM EntityAttachment E left outer join FILE_TYPE_LKUP FTL ON E.FILE_TYPE_ID = FTL.FILE_TYPE_ID WHERE (Entity_ID = p_Entity_ID)--  OR p_Entity_ID is NULL)
    AND (ENTITYTYPE_ID                                                                     = p_ENTITYTYPE_ID OR p_EntityType_ID = 0 ) ORDER BY 1;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN REC_CURSOR FOR SELECT 1 FROM EntityAttachment;
  END SP_GET_Attachments;
  PROCEDURE SP_GET_entity_Attachments(
      p_UserId              VARCHAR2 DEFAULT NULL,
      p_Entity_ID           VARCHAR2 DEFAULT NULL,
      p_EntityAttachment_ID VARCHAR2 DEFAULT NULL,
      p_EntityType_ID       NUMBER DEFAULT 0,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
  BEGIN
    SP_INSERT_AUDIT(p_UserId, 'SP_GET_entity_Attachments Get Attachment details for Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID||' p_EntityAttachment_ID='||p_EntityAttachment_ID);
    -- SP_INSERT_AUDIT(p_UserId, 'SP_GET_entity_Attachments  Entity_ID '||p_Entity_ID||' p_EntityType_ID='||p_EntityType_ID||' p_EntityAttachment_ID='||p_EntityAttachment_ID);
    IF p_EntityAttachment_ID IS NOT NULL THEN --- Include attachement
      OPEN REC_CURSOR FOR SELECT E.EntityAttachment_ID,
      E.EntityType_ID,
      E.Entity_ID,
      E.eAttachment,
      E.Description,
      E.TableName,
      E.FILE_TYPE_ID,
      FTL.DESCRIPTION AS File_Type, E.CREATED_BY,E.CREATED_ON FROM EntityAttachment E left outer join FILE_TYPE_LKUP FTL ON E.FILE_TYPE_ID = FTL.FILE_TYPE_ID WHERE (Entity_ID = p_Entity_ID OR p_Entity_ID IS NULL) AND (EntityAttachment_ID = p_EntityAttachment_ID) AND (ENTITYTYPE_ID = p_ENTITYTYPE_ID)--) or p_EntityType_ID = 0 )
      ORDER BY 1;
    ELSE --- Do not include attachement
      OPEN REC_CURSOR FOR SELECT E.EntityAttachment_ID,
      E.EntityType_ID,
      E.Entity_ID,
      E.Description,
      E.TableName,
      E.FILE_TYPE_ID,
      FTL.DESCRIPTION AS File_Type, E.CREATED_BY,E.CREATED_ON  FROM EntityAttachment E left outer join FILE_TYPE_LKUP FTL ON E.FILE_TYPE_ID = FTL.FILE_TYPE_ID WHERE (Entity_ID = p_Entity_ID OR p_Entity_ID IS NULL) AND (EntityAttachment_ID = p_EntityAttachment_ID OR p_EntityAttachment_ID IS NULL ) AND (ENTITYTYPE_ID = p_ENTITYTYPE_ID )--or p_EntityType_ID = 0 )
      ORDER BY 1;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN REC_CURSOR FOR SELECT 1 FROM EntityAttachment;
  END SP_GET_entity_Attachments;
  PROCEDURE SP_GET_Entity_Details(
      p_Entity_ID           VARCHAR2 DEFAULT NULL,
      p_EntityAttachment_ID VARCHAR2 DEFAULT NULL,
      REC_CURSOR OUT SYS_REFCURSOR)
  AS
  BEGIN
    OPEN REC_CURSOR FOR SELECT EntityAttachment_ID,
    EntityType_ID,
    Entity_ID,
    Description,
    TableName,
    FILE_TYPE_ID FROM EntityAttachment WHERE (Entity_ID = p_Entity_ID OR p_Entity_ID IS NULL) AND (EntityAttachment_ID = p_EntityAttachment_ID OR p_EntityAttachment_ID IS NULL ) ORDER BY 1;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN REC_CURSOR FOR SELECT 1 FROM EntityAttachment;
  END SP_GET_Entity_Details;
  PROCEDURE sp_get_FILE_TYPES(
      P_FILE_TYPE_ID IN NUMBER,
      file_type_cursor OUT SYS_REFCURSOR)
  IS
  BEGIN
    OPEN file_type_cursor FOR SELECT FILE_TYPE_ID,
    DESCRIPTION
  AS
    FILE_TYPE FROM FILE_TYPE_LKUP WHERE (FILE_TYPE_ID = p_FILE_TYPE_ID OR p_FILE_TYPE_ID IS NULL);
  EXCEPTION
  WHEN OTHERS THEN
    OPEN file_type_cursor FOR SELECT 0 FILE_TYPE_ID,
    'None' FILE_TYPE FROM FILE_TYPE_LKUP;
  END sp_get_FILE_TYPES;
END PKG_ATTACHEMENTS;
/