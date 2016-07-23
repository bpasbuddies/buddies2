CREATE OR REPLACE PROCEDURE eemrt.Update_Contract_Amounts(
    p_PStatus OUT VARCHAR2)
IS
  vMessage  VARCHAR2(32000);
  vSENDER   VARCHAR2(200);
  vRECEIVER VARCHAR2(200);
  vSUBJECT  VARCHAR2(200);
  vEMAIL    VARCHAR2(1000);
  vUpdated  VARCHAR2(10) :='N';
BEGIN
      SP_INSERT_AUDIT('SYS', 'BEGIN Update_Contract_Amounts' );
  MERGE INTO CONTRACT_SUMMARY_GL CS1 USING
  (SELECT STAGE_EXPORT_DATE,
    PO_Number,    
    QUANTITY_ORDERED,
    CST.QUANTITY_CANCELLED nqc,
    CST.QUANTITY_RECEIVED nqr ,
    CST.QUANTITY_BILLED nqb,
    CST.NET_QUANTITY_ORDERED nnqo,
    CST.OBLIGATION_BALANCE nob,
    CST.VENDOR_NAME nvn
  FROM stage_View CST
  ) tmp ON ( (CS1.PO_NUMBER  = TMP.PO_NUMBER)
    AND TRUNC(TMP.STAGE_EXPORT_DATE)=TRUNC(sysdate))
WHEN matched THEN
  UPDATE
  SET CS1.QTY_ORDERED         = TMP.QUANTITY_ORDERED,
    CS1.QUANTITY_CANCELLED    = TMP.nqc,
    CS1.AEP_QUANTITY_RECEIVED = nqr,
    CS1.AEU_QUANTITY_BILLED   = nqb,
    CS1.NET_QUANTITY_ORDERED  = nnqo,
    CS1.UDO_OBLIGATION_BALANCE= nob,
    CS1.VENDOR_NAME           = nvn,
    CS1.LAST_MODIFIED_BY      = 'SRI',
    CS1.LAST_MODIFIED_ON      = sysdate;
  IF SQL%FOUND THEN
    vUpdated  := 'Y';
    p_PStatus := SQL%ROWCOUNT || ' ROWS UPDATED';
    COMMIT;
  END IF;
  --Update Contract Table after populating contract_summary_gl with vendor_name
  UPDATE contract
  SET vendor =
    (SELECT vendor_name
    FROM CONTRACT_SUMMARY_GL
    WHERE PO_Number = contract_number
    );
  --- SEND EMAIL TO USERS after update
/* 
IF vUpdated = 'Y' THEN
    FOR i IN
    ( SELECT DISTINCT PO_NUMBER PO,
      gl.LAST_MODIFIED_BY usr ,
      VENDOR_NAME vn,
      u.EMAIL,
      u.FirstName
      || ' '
      || u.MiddleInitial
      || ' '
      || u.LastName FULLNAME
    FROM CONTRACT_SUMMARY_GL gl ,
      users u
    WHERE (u.userName               = gl.LAST_MODIFIED_BY
    AND email_sent                IS NULL
    OR email_sent                  = '')
    AND TRUNC(gl.LAST_MODIFIED_ON) = TRUNC(sysdate)
    )
    LOOP
      vMessage := 'Dear '||i.FULLNAME||', Contract ' ||i.PO|| ' with Vendor ' ||i.vn|| 'has been loaded in eCERT.  Please login to continue the contract completion process';
      vSENDER  := 'sridhar.ctr.kommanaboyina@faa.gov';
      --vRECEIVER := 'sridhar.ctr.kommanaboyina@faa.gov';
      vRECEIVER := i.EMAIL;-- 'skommana77@gmail.com';
      vSUBJECT  := 'eCert contract updated';
    --  SP_SEND_EMAIL( SENDER => vSENDER, RECEIVER => vRECEIVER, SUBJECT => vSUBJECT, MESSAGE => vMESSAGE );
      SP_INSERT_AUDIT(i.usr, 'EMAIL MESSAGE='||vMessage );
    END LOOP;
    p_PStatus := 'SUCCESS';
  ELSE
    p_PStatus := 'NO ROWS UPDATED';
  END IF;
  */
SP_INSERT_AUDIT('SYS', 'End Update_Contract_Amounts' );  
EXCEPTION
WHEN OTHERS THEN
  p_PStatus := 'ERROR:' || SQLERRM;
  ROLLBACK;
END Update_Contract_Amounts;
/