CREATE OR REPLACE procedure eemrt.sp_get_contracts_summary(p_CREATED_BY varchar2 default NULL, contracts_cursor out
SYS_REFCURSOR)
Is
vCount Number :=0;
vROLE  VARCHAR2(20);
BEGIN
 select count(*) into vCount from CONTRACT_SUMMARY_GL;
  SELECT  
    ur.Role 
  INTO   
    vROLE   
  FROM users u,
    userRole ur
  WHERE u.userName = ur.UserName
  AND u.UserName   = p_CREATED_BY;  
    --SP_INSERT_AUDIT(p_CREATED_BY, 'sp_get_contracts_summary');
    SP_INSERT_AUDIT(p_CREATED_BY, 'sp_get_contracts_summary Get Contracts Summary details');
 --IF vCount > 0 THEN
  IF (vROLE ='Admin' OR  vROLE ='TOR')  THEN 
  Open contracts_cursor for
    SELECT PO_Number,  
           Vendor_Name,
           SUM(Qty_Ordered) Qty_Ordered,
           SUM(AEU_Quantity_Billed) Quantity_Billed ,
           SUM(NVL(AEP_QUANTITY_RECEIVED,0)) Quantity_Received,          
           SUM(Quantity_cancelled) Quantity_cancelled,
           SUM(UDO_OBLIGATION_BALANCE) Obligation_Balance  
 
      FROM CONTRACT_SUMMARY_GL 
      WHERE  EXISTS (select 1 from  CONTRACT where contract_number = PO_Number) 
      AND VENDOR_NAME is not null  
      GROUP BY PO_Number,Vendor_Name
      Order by PO_Number;
  ELSE
     Open contracts_cursor for
    SELECT PO_Number,  
           Vendor_Name,
           SUM(Qty_Ordered) Qty_Ordered,
           SUM(AEU_Quantity_Billed) Quantity_Billed ,
           SUM(NVL(AEP_QUANTITY_RECEIVED,0)) Quantity_Received,          
           SUM(Quantity_cancelled) Quantity_cancelled,
           SUM(UDO_OBLIGATION_BALANCE) Obligation_Balance  
           
      FROM CONTRACT_SUMMARY_GL 
      WHERE  EXISTS (select 1 from  CONTRACT where contract_number = PO_Number and (CREATED_BY = p_CREATED_BY OR INSTR(COR_NAME,p_CREATED_BY)>0 OR  INSTR(CO_NAME,p_CREATED_BY)>0 )) 
      AND VENDOR_NAME is not null  
      GROUP BY PO_Number,Vendor_Name
      Order by PO_Number;
   END IF;
   
  --END IF;
  EXCEPTION WHEN OTHERS THEN 
    Open contracts_cursor for
     SELECT '' PO_Number,  
           '' Vendor_Name,
          0 Qty_Ordered,
           0 Quantity_Billed ,
           0 Quantity_Received,          
           0 Quantity_cancelled,
           0 Obligation_Balance   from dual;
 End sp_get_contracts_summary;
/