CREATE OR REPLACE PACKAGE eemrt."PKG_ATTACHEMENTS" 
IS
  /*
  Package : PKG_Attachements
  Author: Sridhar Kommana
  Date Created : 09/15/2015
  Purpose:  All procedures related to Attachements
  Update history:
  */
  PROCEDURE SP_Add_Attachment(
    p_EntityType_ID NUMBER ,
    p_FILE_TYPE_ID NUMBER,
    p_Entity_ID VARCHAR2 , 	
    p_eAttachment BLOB, 	
    p_Description VARCHAR2, 
    p_TableName VARCHAR2, 
    p_User VARCHAR2, 
    p_PStatus OUT VARCHAR2 ); 
    
 PROCEDURE SP_DELETE_Attachment(
    p_EntityAttachment_ID NUMBER,
    p_PStatus OUT VARCHAR2 );    
 PROCEDURE       SP_GET_Attachments(
    p_UserId VARCHAR2 DEFAULT NULL,     
    p_Entity_ID VARCHAR2 DEFAULT NULL, 	
    p_EntityType_ID NUMBER  DEFAULT 0, 	
    REC_CURSOR OUT SYS_REFCURSOR);    
PROCEDURE       SP_GET_entity_Attachments(
    p_UserId VARCHAR2 DEFAULT NULL, 
    p_Entity_ID VARCHAR2 DEFAULT NULL, 
    p_EntityAttachment_ID VARCHAR2  DEFAULT NULL,
    p_EntityType_ID NUMBER  DEFAULT 0,            
    REC_CURSOR OUT SYS_REFCURSOR);
PROCEDURE SP_GET_Entity_Details(
    p_Entity_ID VARCHAR2 DEFAULT NULL, 	
    p_EntityAttachment_ID VARCHAR2  DEFAULT NULL, 	
    REC_CURSOR OUT SYS_REFCURSOR);
 PROCEDURE sp_get_FILE_TYPES(
P_FILE_TYPE_ID IN Number,
    file_type_cursor OUT SYS_REFCURSOR);
    
END PKG_Attachements;
/