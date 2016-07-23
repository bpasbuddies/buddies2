CREATE OR REPLACE PROCEDURE eemrt.sp_get_LaborCategories(
    p_UserId  varchar2 DEFAULT NULL,
    LaborCategories_cursor OUT SYS_REFCURSOR)
IS
  /*
  Procedure : sp_get_LaborCategories
  Author: Sridhar Kommana
  Date Created : 04/24/2015
  Purpose:  Get standard labor category information.
  Update history:
  sridhar kommana :
  1) 05/04/2015 : Added p_USER fro auditing/debugging
  1) 05/04/2015 : Added sort by 1 so that 0 will come on top
  */
BEGIN
  
  SP_INSERT_AUDIT(p_UserId, 'sp_get_LaborCategories ' );
 
  OPEN LaborCategories_cursor FOR SELECT CATEGORY_ID,CATEGORY_NAME FROM labor_categories order by 1;
EXCEPTION
WHEN OTHERS THEN
   OPEN LaborCategories_cursor FOR  SELECT 1 CATEGORY_ID, 1 CATEGORY_NAME FROM labor_categories;
END sp_get_LaborCategories;
/