CREATE OR REPLACE PROCEDURE eemrt.P_insert_prism_info_in_stage(
    p_PStatus OUT VARCHAR2)
IS
 


  CURSOR CONTRACT_DO_CUR
  IS
   SELECT DISTINCT contract_number contract_number,substr(contract_number,1,instr(contract_number,'/')-1) contract_number_only, substr(contract_number,decode(instr(contract_number,'/'),0,200,instr(contract_number,'/'))+1) do_number 
    FROM contract
    where 1=1
    and buyer is null 
   and contract_number like '%/%';
   
    
  CURSOR CONTRACT_CUR
  IS
     SELECT DISTINCT contract_number contract_number,substr(contract_number,1,instr(contract_number,'/')-1) contract_number_only, substr(contract_number,decode(instr(contract_number,'/'),0,200,instr(contract_number,'/'))+1) do_number 
    FROM contract
    where 1=1
    and buyer is null 
   and contract_number NOT like '%/%';
    
BEGIN
  SP_INSERT_AUDIT('SYS', 'Before deleting the data in contract_stage table ' || sysdate() );
  
  delete from contract_prism_stage;
  commit;
  
  SP_INSERT_AUDIT('SYS', 'After deleting the data in contract_stage table ' || sysdate() );
  
  
  FOR CONTRACT_DO_REC IN CONTRACT_DO_CUR   LOOP 
  
   SP_INSERT_AUDIT('SYS', 'Before inserting prism data for buyer and award_type in contract_stage table with delivery orders' || sysdate() );
    
  INSERT INTO CONTRACT_prism_STAGE (  SELECT distinct contract_num, do_num,pr_buyer_name ,award_type,SYSDATE,NULL,AWARD_DATE
    FROM V_TSOCUFF_AWDS@PRISM
    where contract_num =contract_DO_rec.CONTRACT_NUMBER_ONLY
    AND DO_NUM = CONTRACT_DO_REC.DO_NUMBER);
   commit; 
   
   SP_INSERT_AUDIT('SYS', 'After inserting prism info for buyer and award_type in contract_stage table with delivery orders ' || sysdate() );
    
         
  END LOOP;
  
 FOR CONTRACT_REC IN CONTRACT_CUR   LOOP 
 
  SP_INSERT_AUDIT('SYS', 'Before inserting prism data for buyer and award_type in contract_stage table with no delivery orders' || sysdate() );
    
  
  INSERT INTO CONTRACT_prism_STAGE (  SELECT distinct contract_num, do_num,pr_buyer_name ,award_type,SYSDATE,NULL,AWARD_DATE
    FROM V_TSOCUFF_AWDS@PRISM
    where contract_num =contract_rec.CONTRACT_NUMBER
    AND DO_NUM IS NULL);
   commit; 
         
  SP_INSERT_AUDIT('SYS', 'After inserting prism info for buyer and award_type in contract_prism_stage table with no delivery orders ' || sysdate() );
    
  END LOOP;
  
  p_PStatus := 'SUCCESS';
  SP_INSERT_AUDIT('SYS', 'End of P_insert_prism_info_in_stage ' || sysdate() );
  
  
EXCEPTION
WHEN OTHERS THEN
  p_PStatus := 'ERROR:' || SQLERRM;
  ROLLBACK;
END P_insert_prism_info_in_stage;
/