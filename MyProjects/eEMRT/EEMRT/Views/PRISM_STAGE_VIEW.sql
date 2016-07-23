CREATE OR REPLACE FORCE VIEW eemrt.prism_stage_view (contract_number,buyer_name,award_type,created_on,last_modified_on) AS
select DECODE(DO_NUMBER,NULL,CONTRACT_NUMBER,  CONTRACT_NUMBER||'/'||DO_NUMBER ) as contract_number , 
  BUYER_NAME,AWARD_TYPE,CREATED_ON, LAST_MODIFIED_ON FROM CONTRACT_PRISM_STAGE WHERE BUYER_NAME IS NOT NULL;