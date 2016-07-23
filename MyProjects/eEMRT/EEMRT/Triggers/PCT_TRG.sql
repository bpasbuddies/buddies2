CREATE OR REPLACE trigger eemrt.PCT_TRG  
   before insert on eemrt."PROGRAM_CLIN_TYPES" 
   for each row 
begin  
   if inserting then 
      if :NEW."PCT_ID" is null then 
         select PCT_ID_SEQ.nextval into :NEW."PCT_ID" from dual; 
      end if; 
   end if; 
end;
/