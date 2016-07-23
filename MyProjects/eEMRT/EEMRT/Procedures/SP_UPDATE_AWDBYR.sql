CREATE OR REPLACE PROCEDURE eemrt.SP_Update_AwdByr(
    p_PStatus OUT VARCHAR2)
IS
  vbuyer        VARCHAR2(3000) := NULL;
  vContractType VARCHAR2(3000) := NULL;
  vContractNUM  VARCHAR2(100);
  vSENDER       VARCHAR2(200);
  vRECEIVER     VARCHAR2(200);
  vSUBJECT      VARCHAR2(200);
  vEMAIL        VARCHAR2(1000);
  vCount        NUMBER := 0;
   
  CURSOR BUYER_STAGE_CUR(p_Contract_Num varchar2)
  IS
 SELECT DISTINCT contract_number, buyer_name
    FROM PRISM_STAGE_VIEW  
    WHERE  contract_number = p_Contract_Num;
      --(SELECT DISTINCT contract_number FROM contract_temp WHERE BUYER IS NULL      );
  CURSOR AWARD_STAGE_CUR(p_Contract_Num varchar2)
  IS
 SELECT DISTINCT contract_number, AWARD_TYPE
    FROM PRISM_STAGE_VIEW  
    WHERE  contract_number = p_Contract_Num;

 
BEGIN
  SP_INSERT_AUDIT('SYS', 'Begin of SP_Update_AwdByr ' || sysdate() );
  FOR c IN (SELECT DISTINCT contract_number FROM contract WHERE BUYER IS NULL)
  LOOP 
        
    FOR i IN  BUYER_STAGE_CUR(c.contract_number)
    LOOP
      IF (LTRIM(RTRIM(i.buyer_name)) <> '' OR i.buyer_name IS NOT NULL) THEN
        vbuyer   := i.buyer_name||', '|| vbuyer;
      END IF;
      vContractNUM := i.contract_number;
      vCount       := vCount +1 ;
    END LOOP;

    FOR j IN AWARD_STAGE_CUR(c.contract_number)
    LOOP
      IF (LTRIM(RTRIM(j.award_type)) <> '' OR j.award_type IS NOT NULL) THEN
        vContractType                := j.award_type ||', '|| vContractType;
      END IF;
      vContractNUM := j.contract_number;
      vCount       := vCount +1 ;
    END LOOP;
      ---Update once after reaching the max record count
        SP_INSERT_AUDIT('SRI', 'SP_Update_AwdByr updating vbuyer=' || vbuyer ||'  and  vContractType=' || vContractType);
        UPDATE contract
        SET contract_type = vContractType, buyer  = vbuyer , last_modified_by = 'SP_Update_AwdByr', last_modified_on =sysdate()
        WHERE contract_number= vContractNUM;
        
        vbuyer := '';
        vContractNUM := '';
        vContractType := '';
        vContractNUM := '';
  END LOOP;
  Commit;
  p_PStatus := 'SUCCESS';
  SP_INSERT_AUDIT('SYS', 'End of SP_Update_AwdByr ' || sysdate() );
EXCEPTION
WHEN OTHERS THEN
  p_PStatus := 'ERROR:' || SQLERRM;
  ROLLBACK;
END SP_Update_AwdByr;
/