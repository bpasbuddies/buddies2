CREATE OR REPLACE TRIGGER eemrt.PROGRAM_TRG
BEFORE INSERT
ON eemrt.PROGRAM
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
-- For Toad:  Highlight column PGM_ID
  :new.PGM_ID := PGM_ID_SEQ.nextval;
END PROGRAM_TRG;
/