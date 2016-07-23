CREATE OR REPLACE PROCEDURE eemrt.sp_get_Organizations(
    p_rgn_cd VARCHAR2 DEFAULT NULL,
    Organizations_cursor OUT SYS_REFCURSOR)
IS
BEGIN
  OPEN Organizations_cursor FOR SELECT org_cd, org_cd|| ' - ' || org_title as org_title FROM organizations WHERE (rgn_cd = p_rgn_cd OR p_rgn_cd IS NULL);
EXCEPTION
WHEN OTHERS THEN
   OPEN Organizations_cursor FOR  SELECT 1 org_cd, 1 org_title FROM organizations;
END sp_get_Organizations;
/