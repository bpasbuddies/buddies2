CREATE OR REPLACE PACKAGE BODY eemrt."PKG_INVOICE" 
AS
  /*
  Procedure : PKG_INVOICE
  Author: Sridhar Kommana
  Date Created : 11/24/2015
  Purpose:  All procedures and functions related to Invoice.
  Update history:
  sridhar kommana :
  1) 11/24/2015 : created
  2) 12/01/2015 : Added sp_insert_INV_DETAIL_SESSION
  3) 12/03/2015 : Added sp_insert_invoice : Add invoice header
  4) 12/03/2015 : Added Sp_Insert_Inv_Detail : Add invoice detail
  5) 12/03/2015 : Added Move_invoice_SESSION : Add invoice detail from session
  6) 12/08/2015 : Added CONTRACTOR_ID to invoice related procs
  7) 12/09/2015 : Added Sub_Clin_Number_Disp to Sp_Get_Invoice_Detail proc
  8) 12/14/2015 : Added new sp SP_GET_TASK_STCLINS
  9) 05/05/2016 : Added LCs and TMO records to SP_GET_INV_POP_CLINS
  10)06/29/2016 : Added new proc sp_get_Est_Fund_Depletion_Dt
  11)06/27/2016 : Added new Procedure : sp_get_Funding_Invoice_totals
  12)06/23/2016 : Added new Procedure : sp_get_inv_Monthly_Sums
  
  10.05/06/2016 : Srihari Gokina Added INVOICE_DUE_DATE to SPs. SP_GET_Invoice, Sp_Get_Invoice_Detail, sp_insert_invoice, sp_update_invoice
  */
  PROCEDURE Sp_Get_Invoice(
      P_Userid     VARCHAR2 ,
      P_Invoice_Id NUMBER DEFAULT 0 ,
      p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,
      P_Contract_Number Invoice.Contract_Number%Type DEFAULT NULL,
      Rec_Cursor OUT Sys_Refcursor)
  AS
    /*
    Procedure : SP_GET_Invoice
    Author: Sridhar Kommana
    Date Created : 11/24/2015
    Purpose: SP_GET_Invoice gets all invoice header records selected for a given contract and also for invoice_id.
    Update history:
    1) 11/24/2015 : Sridhar Kommana - created
    2) 12/03/2015 : Sridhar Kommana - Added new field Status
    3) 01/14/2016 : Sridhar Kommana - Added new parameter p_period_of_performance_id
    4) 03/29/2016 : Sridhar Kommana - Added pop_type to meet RTM ID:W00a-10 
    5) 06/10/2016 : Srihari Gokina -  Added Invoice Totals by Contract_Clin_Cost_Type to meet RTM ID:TM I00-05
    6) 06/13/2016 : Srihari Gokina -  Added Invoice Labor Hours to Result Set to meet RTM ID:TM I00-05
    7) 06/13/2016 :Sridhar Kommana -  Added Left join to Total_Invoice_Charges  Invoice Labor Hours to Result Set to fix missing records issue
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.SP_GET_Invoice Get Invoice headers for p_UserId= '||P_Userid|| '  P_INVOICE_ID= '||P_Invoice_Id);
    OPEN Rec_Cursor FOR 
    
    SELECT I.Invoice_Id, I.Contract_Number, I.Vendor, I.Invoice_Number, I.Invoice_Date, I.Invoice_Period_From, I.Invoice_Period_To, I.Invoice_Amount,
           I.status, I.Invoice_Received_Date , I.period_of_performance_id, pop.pop_type, I.INVOICE_DUE_DATE,
           NVL(ID.Total_Labor_Hours,0) AS Total_Labor_Hours, NVL(ID.Total_Labor_Charges,0) AS Total_Labor_Charges, NVL(ID.Total_Travel_Charges,0) Total_Travel_Charges, 
           NVL(ID.Total_Material_Charges,0) AS Total_Material_Charges, NVL(ID.Total_ODC_Charges,0) AS Total_ODC_Charges,  ID.Total_Invoice_Charges
    FROM Invoice I 
    INNER JOIN period_of_performance pop ON I.period_of_performance_id =  pop.period_of_performance_id  
    LEFT JOIN  
      (SELECT id.INVOICE_id, Total_Labor_Hours, Total_Labor_Charges, Total_Travel_Charges, Total_Material_Charges,Total_ODC_Charges,  Total_Invoice_Charges
       FROM 
            (SELECT INVOICE_id, SUM(Invoice_Amount) Total_Invoice_Charges 
              FROM Invoice_Detail Id --WHERE INVOICE_id = P_Invoice_Id 
              GROUP BY INVOICE_id) id
      LEFT JOIN 
         (SELECT INVOICE_id, SUM(Invoice_Amount) Total_Travel_Charges 
          FROM Invoice_Detail Id WHERE  Contract_Clin_Cost_Type = 'Travel'  -- INVOICE_id = P_Invoice_Id AND 
          GROUP BY INVOICE_id) ID_Travel  ON id.INVOICE_id = ID_Travel.INVOICE_id
      LEFT JOIN 
         (SELECT INVOICE_id, SUM(Invoice_Amount) Total_Material_Charges 
          FROM Invoice_Detail Id WHERE Contract_Clin_Cost_Type = 'Material' --INVOICE_id = P_Invoice_Id AND  
          GROUP BY INVOICE_id) ID_Material  ON id.INVOICE_id = ID_Material.INVOICE_id
      LEFT JOIN 
         (SELECT INVOICE_id, SUM(Invoice_Amount) Total_ODC_Charges 
          FROM Invoice_Detail Id WHERE Contract_Clin_Cost_Type = 'ODC'  -- INVOICE_id = P_Invoice_Id AND  
          GROUP BY INVOICE_id) ID_ODC  ON id.INVOICE_id = ID_ODC.INVOICE_id
      LEFT JOIN 
         (SELECT INVOICE_id, NVL(SUM(Invoice_Hours_Qty),0) Total_Labor_Hours , NVL(SUM(Invoice_Amount),0) Total_Labor_Charges
          FROM Invoice_Detail WHERE --INVOICE_id = P_Invoice_Id AND  
          Contract_Clin_Cost_Type = 'Labor' GROUP BY INVOICE_id ) ID_Total  ON id.INVOICE_id = ID_Total.INVOICE_id) ID ON ID.INVOICE_id =  I.INVOICE_id 
          Where (I.Invoice_Id = P_Invoice_Id OR P_Invoice_Id= 0) AND
                (I.period_of_performance_id = p_period_of_performance_id OR p_period_of_performance_id= 0)  AND 
                (I.Contract_Number = P_Contract_Number OR P_Contract_Number IS NULL) Order By 1 ;
    /*
    SELECT I.Invoice_Id, I.Contract_Number, I.Vendor, I.Invoice_Number, I.Invoice_Date, I.Invoice_Period_From, I.Invoice_Period_To, I.Invoice_Amount,
           I.status, I.Invoice_Received_Date , I.period_of_performance_id, pop.pop_type, I.INVOICE_DUE_DATE
    FROM Invoice I , period_of_performance pop
    Where I.period_of_performance_id =  pop.period_of_performance_id  
         AND (I.Invoice_Id = P_Invoice_Id OR P_Invoice_Id= 0) 
         AND (I.period_of_performance_id = p_period_of_performance_id OR p_period_of_performance_id= 0) 
         AND (I.Contract_Number = P_Contract_Number OR P_Contract_Number IS NULL) Order By 1;
    */     
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT 1 FROM Invoice ;
  END Sp_Get_Invoice;
  
  PROCEDURE Sp_Get_Invoice_View_Detail(
      P_Userid            VARCHAR2 DEFAULT NULL ,
      P_Invoice_Id        NUMBER ,
      P_Invoice_Detail_Id NUMBER DEFAULT 0 ,
      P_Work_Orders_Id NUMBER DEFAULT 0,
      p_Sub_Tasks_Id NUMBER DEFAULT 0,            
      Rec_Cursor OUT Sys_Refcursor)
  AS
    /*
    Procedure : Sp_Get_Invoice_View_Detail
    Author: Sridhar Kommana
    Date Created : 07/06/2016
    Purpose: Sp_Get_Invoice_View_Detail gets all invoice detail records selected invoice in view screen.
    Update history:
    sridhar kommana :
    1) 07/06/2016: created
    07/20/2016 : Added Sub_Clin_Title and Sub_Clin_Title_Disp 
 
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.Sp_Get_Invoice_View_Detail Get Invoice details for p_UserId= '||P_Userid|| '  P_Invoice_Detail_Id= '||P_Invoice_Detail_Id|| '  P_INVOICE_ID= '||P_Invoice_Id  || 'P_Work_Orders_Id='||P_Work_Orders_Id ||' p_Sub_Tasks_Id='||p_Sub_Tasks_Id);
    OPEN Rec_Cursor 
    FOR 
    SELECT Invoice_Detail_Id, Id.Invoice_Id, Id.Work_Orders_Id, Work_Order_Number, Id.Sub_Tasks_Id, Sub_Task_Number, Id.Clin_Id, Clin_Number ,Clin_Title, Id.Sub_Clin_Id,
    Sub_Clin_Number,Sub_Clin_Title, 
    DECODE(Clin_Sub_Clin, 'Y', Clin_Number ||Sub_Clin_Number,Clin_Number ) As Sub_Clin_Number_Disp,
    DECODE(Clin_Sub_Clin, 'Y', Clin_Title ||Sub_Clin_Title,Clin_Title ) As Sub_Clin_Title_Disp,
    Id.Clin_Type, Labor_Category, Contract_Clin_Cost_Type,CONTRACTOR_ID, Contractor_Employee_Name, Invoice_Hours_Qty, Invoice_Rate, Id.Invoice_Amount, I.INVOICE_DUE_DATE
    ,Travel_Auth, id.Description, odc_auth
    FROM Invoice_Detail Id 
    JOIN INVOICE I ON I.Invoice_Id = Id.Invoice_Id
    left outer join Work_Orders Wc ON Id.Work_Orders_Id = Wc.Work_Orders_Id 
    LEFT OUTER JOIN Sub_Tasks St ON Id.Sub_Tasks_Id = St.Sub_Tasks_Id 
    Inner Join Pop_Clin Pc ON Id.Clin_Id = Pc.Clin_Id 
    LEFT OUTER Join Sub_Clin Sc ON Id.Sub_Clin_Id = Sc.Sub_Clin_Id 
    WHERE (Id.Invoice_Id = P_Invoice_Id )--OR P_Invoice_Id= 0) 
      AND (Invoice_Detail_Id = P_Invoice_Detail_Id OR P_Invoice_Detail_Id= 0)
      AND (id.Work_Orders_Id = P_Work_Orders_Id)-- OR P_Work_Orders_Id= 0)
      AND (id.Sub_Tasks_Id = p_Sub_Tasks_Id)-- OR p_Sub_Tasks_Id= 0)
      Order By 1;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT 1 FROM Invoice_Detail ;
  END Sp_Get_Invoice_View_Detail;
  PROCEDURE Sp_Get_Invoice_Detail(
      P_Userid            VARCHAR2 DEFAULT NULL ,
      P_Invoice_Id        NUMBER ,
      P_Invoice_Detail_Id NUMBER DEFAULT 0 ,
      P_Work_Orders_Id NUMBER DEFAULT 0,
      p_Sub_Tasks_Id NUMBER DEFAULT 0,            
      Rec_Cursor OUT Sys_Refcursor)
  AS
    /*
    Procedure : SP_GET_Invoice_detail
    Author: Sridhar Kommana
    Date Created : 11/24/2015
    Purpose: SP_GET_Invoice_detail gets all invoice detail records selected invoice.
    Update history:
    sridhar kommana :
    1) 11/24/2015 : created
    03/18/2016 : Modified Join Work_Orders Wc to meet RTM ID:W00a-10
    06/08/2016 : Added Work order id and SUb task id as additional paramters
    07/20/2016 : Added Sub_Clin_Title and Sub_Clin_Title_Disp 
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.SP_GET_Invoice_detail Get Invoice details for p_UserId= '||P_Userid|| '  P_Invoice_Detail_Id= '||P_Invoice_Detail_Id|| '  P_INVOICE_ID= '||P_Invoice_Id  || 'P_Work_Orders_Id='||P_Work_Orders_Id ||' p_Sub_Tasks_Id='||p_Sub_Tasks_Id);
    OPEN Rec_Cursor 
    FOR 
    SELECT Invoice_Detail_Id, Id.Invoice_Id, Id.Work_Orders_Id, Work_Order_Number, Id.Sub_Tasks_Id, Sub_Task_Number, Id.Clin_Id, Clin_Number ,Clin_Title, Id.Sub_Clin_Id,
    Sub_Clin_Number, Sub_Clin_Title, 
    DECODE(Clin_Sub_Clin, 'Y', Clin_Number ||Sub_Clin_Number,Clin_Number ) As Sub_Clin_Number_Disp,
    DECODE(Clin_Sub_Clin, 'Y', Clin_Title ||Sub_Clin_Title,Clin_Title ) As Sub_Clin_Title_Disp,
    Id.Clin_Type, Labor_Category, Contract_Clin_Cost_Type,CONTRACTOR_ID, Contractor_Employee_Name, Invoice_Hours_Qty, Invoice_Rate, Id.Invoice_Amount, I.INVOICE_DUE_DATE
    ,Travel_Auth, id.Description, odc_auth
    FROM Invoice_Detail Id 
    JOIN INVOICE I ON I.Invoice_Id = Id.Invoice_Id
    left outer join Work_Orders Wc ON Id.Work_Orders_Id = Wc.Work_Orders_Id 
    LEFT OUTER JOIN Sub_Tasks St ON Id.Sub_Tasks_Id = St.Sub_Tasks_Id 
    Inner Join Pop_Clin Pc ON Id.Clin_Id = Pc.Clin_Id 
    LEFT OUTER Join Sub_Clin Sc ON Id.Sub_Clin_Id = Sc.Sub_Clin_Id 
    WHERE (Id.Invoice_Id = P_Invoice_Id )--OR P_Invoice_Id= 0) 
      AND (Invoice_Detail_Id = P_Invoice_Detail_Id OR P_Invoice_Detail_Id= 0)
      AND (id.Work_Orders_Id = P_Work_Orders_Id) -- OR P_Work_Orders_Id= 0)
      AND (id.Sub_Tasks_Id = p_Sub_Tasks_Id) -- OR p_Sub_Tasks_Id= 0)
/*
UNION 
    SELECT Invoice_Detail_Id, Id.Invoice_Id, Id.Work_Orders_Id, Work_Order_Number, Id.Sub_Tasks_Id, Sub_Task_Number, Id.Clin_Id, Clin_Number ,Clin_Title, Id.Sub_Clin_Id,
    Sub_Clin_Number, 
    DECODE(Clin_Sub_Clin, 'Y', Clin_Number ||Sub_Clin_Number,Clin_Number ) As Sub_Clin_Number_Disp,
    Id.Clin_Type, Labor_Category, Contract_Clin_Cost_Type,CONTRACTOR_ID, Contractor_Employee_Name, Invoice_Hours_Qty, Invoice_Rate, Id.Invoice_Amount, I.INVOICE_DUE_DATE
    ,Travel_Auth, id.Description, odc_auth
    FROM Invoice_Detail Id 
    JOIN INVOICE I ON I.Invoice_Id = Id.Invoice_Id
    left outer join Work_Orders Wc ON Id.Work_Orders_Id = Wc.Work_Orders_Id 
    LEFT OUTER JOIN Sub_Tasks St ON Id.Sub_Tasks_Id = St.Sub_Tasks_Id 
    Inner Join Pop_Clin Pc ON Id.Clin_Id = Pc.Clin_Id 
    LEFT OUTER Join Sub_Clin Sc ON Id.Sub_Clin_Id = Sc.Sub_Clin_Id 
    WHERE (Id.Invoice_Id = P_Invoice_Id )--OR P_Invoice_Id= 0) 
      AND (Invoice_Detail_Id = P_Invoice_Detail_Id OR P_Invoice_Detail_Id= 0)
      AND (id.Work_Orders_Id = P_Work_Orders_Id )
      AND (id.Sub_Tasks_Id = p_Sub_Tasks_Id ) --To support contract level */
      Order By 1;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT 1 FROM Invoice_Detail ;
  END Sp_Get_Invoice_Detail;

  
  PROCEDURE Sp_Get_Invoice_Charge_Totals(
      P_Userid       VARCHAR2 DEFAULT NULL ,
      P_Invoice_Id   NUMBER ,
      P_Cost_Type  VARCHAR2 DEFAULT NULL ,
      Rec_Cursor OUT Sys_Refcursor)
  AS
    /*
    Procedure : Sp_Get_Invoice_Cost_Type_Totals
    History:
    1) 05/16/2016 : Created  : Srihari Gokina   
    2) 05/19/2016 : Changed to Diffrent O/P Format -  Srihari Gokina   
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.Sp_Get_Invoice_Cost_Type_Totals Get Invoice Cost Type Totals for p_UserId= '||P_Userid|| '  P_INVOICE_ID= '||P_Invoice_Id);
    OPEN Rec_Cursor 
    FOR     
       SELECT id.INVOICE_id, Total_Labor_Hours, Total_Labor_Charges, Total_Travel_Charges, Total_Material_Charges,Total_ODC_Charges,  Total_Invoice_Charges
       FROM 
            (SELECT INVOICE_id, SUM(Invoice_Amount) Total_Invoice_Charges 
              FROM Invoice_Detail Id WHERE INVOICE_id = P_Invoice_Id GROUP BY INVOICE_id) id
      LEFT JOIN 
         (SELECT INVOICE_id, SUM(Invoice_Amount) Total_Travel_Charges 
          FROM Invoice_Detail Id WHERE INVOICE_id = P_Invoice_Id AND  Contract_Clin_Cost_Type = 'Travel'
          GROUP BY INVOICE_id) ID_Travel  ON id.INVOICE_id = ID_Travel.INVOICE_id
      LEFT JOIN 
         (SELECT INVOICE_id, SUM(Invoice_Amount) Total_Material_Charges 
          FROM Invoice_Detail Id WHERE INVOICE_id = P_Invoice_Id AND  Contract_Clin_Cost_Type = 'Material' 
          GROUP BY INVOICE_id) ID_Material  ON id.INVOICE_id = ID_Material.INVOICE_id
      LEFT JOIN 
         (SELECT INVOICE_id, SUM(Invoice_Amount) Total_ODC_Charges 
          FROM Invoice_Detail Id WHERE INVOICE_id = P_Invoice_Id AND  Contract_Clin_Cost_Type = 'ODC' 
          GROUP BY INVOICE_id) ID_ODC  ON id.INVOICE_id = ID_ODC.INVOICE_id
      LEFT JOIN 
         (SELECT INVOICE_id, SUM(Invoice_Hours_Qty) Total_Labor_Hours ,SUM(Invoice_Amount) Total_Labor_Charges
          FROM Invoice_Detail Id WHERE INVOICE_id = P_Invoice_Id AND  Contract_Clin_Cost_Type = 'Labor' GROUP BY INVOICE_id ) ID_Total  ON id.INVOICE_id = ID_Total.INVOICE_id;

    /*
        SELECT  INVOICE_id, Contract_Clin_Cost_Type, NVL(SUM(Invoice_Hours_Qty),0) Total_Labor_Hours , NVL(SUM(Invoice_Amount),0) Total_Charges
        FROM Invoice_Detail Id WHERE INVOICE_id = P_Invoice_Id AND  Contract_Clin_Cost_Type  IN ( 'Labor', 'Material','Travel','ODC')
        GROUP BY INVOICE_id, Contract_Clin_Cost_Type
        UNION
        SELECT  INVOICE_id, 'All_Cost_Types' AS Contract_Clin_Cost_Type, NVL(SUM(Invoice_Hours_Qty),0) Total_Labor_Hours , NVL(SUM(Invoice_Amount),0) Total_Charges
        FROM Invoice_Detail Id WHERE INVOICE_id = P_Invoice_Id 
        GROUP BY INVOICE_id;
    */

  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT 1 FROM Invoice_Detail ;
  END Sp_Get_Invoice_Charge_Totals;
  
  PROCEDURE sp_insert_invoice(
      p_userid VARCHAR2 ,
      p_contract_number          IN invoice.contract_number%TYPE,
      p_vendor                   IN invoice.vendor%TYPE,
      p_period_of_performance_id IN invoice.period_of_performance_id%TYPE,
      p_invoice_number           IN invoice.invoice_number%TYPE,
      p_invoice_date             IN invoice.invoice_date%TYPE,
      p_invoice_period_from      IN invoice.invoice_period_from%TYPE,
      p_invoice_period_to        IN invoice.invoice_period_to%TYPE,
      p_invoice_amount IN invoice.invoice_amount%TYPE,
      p_status IN invoice.status%TYPE,
      p_invoice_received_date IN invoice.invoice_received_date%TYPE,
      p_invoice_due_date         IN INVOICE.INVOICE_DUE_DATE%TYPE,
      p_Temp_Entity_id         IN INVOICE.Temp_Entity_id%TYPE DEFAULT NULL ,    
      p_id OUT invoice.Invoice_Id%type,
      p_pstatus OUT VARCHAR2  )
  AS
    /*
    Procedure : sp_insert_invoice
    Author: Sridhar Kommana
    Date Created : 12/03/2015
    Purpose: sp_insert_invoice inserts invoice header records for a given contract.
    Update history:
    sridhar kommana :
    1) 12/03/2015 : created
    */
    V_Inv_Id NUMBER:=0;
  BEGIN
    IF( p_userid IS NULL ) THEN
      P_Pstatus  := 'Error inserting sp_insert_invoice '||' Cannot insert with no user info' ;
      RETURN;
    END IF;
    Sp_Insert_Audit( P_Userid,'PKG_INVOICE.sp_insert_invoice contract_number= '||p_contract_number||' invoice_number='||p_invoice_number);
    V_Inv_Id := INVOICE_HDR_SEQ.Nextval;
    INSERT
    INTO Invoice
      (
        Invoice_Id,
        Contract_Number,
        Vendor,
        Period_Of_Performance_Id,
        Invoice_Number,
        Invoice_Date,
        Invoice_Period_From,
        Invoice_Period_To,
        Invoice_Amount,
        status,
        Invoice_Received_Date,
        INVOICE_DUE_DATE,
        Created_By,
        Created_On
      )
      VALUES
      (
        V_Inv_Id ,
        p_Contract_Number,
        p_Vendor,
        p_Period_Of_Performance_Id,
        p_Invoice_Number,
        p_Invoice_Date,
        p_Invoice_Period_From,
        p_Invoice_Period_To,
        p_Invoice_Amount,
        p_status,
        p_Invoice_Received_Date,
        p_invoice_due_date,
        P_Userid,
        Sysdate()
      );
    IF Sql%Found THEN
      P_Pstatus := 'SUCCESS' ;
      P_Id      := V_Inv_Id;
      COMMIT;
      if p_Temp_Entity_id is NOT NULL then
        Update entityAttachment set entity_id = V_Inv_Id , last_modified_by =P_Userid,last_modified_on=sysdate  where entity_id = p_Temp_Entity_id;
      end if;
    END IF;
  EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
           ROLLBACK;
         p_PStatus := 'The invoice number you have entered is already in use for this contract.  Please enter a unique invoice Number.';  
  WHEN OTHERS THEN
    ROLLBACK;
    P_Pstatus := 'Error inserting invoice '||Sqlerrm ;
    Sp_Insert_Audit( P_Userid,'Error PKG_INVOICE.sp_insert_invoice'||SQLERRM );
  END sp_insert_invoice ;
 
  PROCEDURE sp_update_invoice(
      p_userid VARCHAR2 ,      
      p_Invoice_Id          IN invoice.Invoice_Id%TYPE,
      p_invoice_number           IN invoice.invoice_number%TYPE,
      p_invoice_date             IN invoice.invoice_date%TYPE,
      p_invoice_period_from      IN invoice.invoice_period_from%TYPE,
      p_invoice_period_to        IN invoice.invoice_period_to%TYPE,
      p_invoice_amount IN invoice.invoice_amount%TYPE,
      p_status IN invoice.status%TYPE,      
      p_invoice_received_date IN invoice.invoice_received_date%TYPE, 
      p_invoice_due_date         IN INVOICE.INVOICE_DUE_DATE%TYPE,
      p_pstatus OUT VARCHAR2 )
  AS
    /*
    Procedure : sp_update_invoice
    Author: Sridhar Kommana
    Date Created : 12/03/2015
    Purpose: sp_update_invoice update invoice header records for a given invoice id.
    Update history:
    sridhar kommana :
    1) 12/03/2015 : created
    */
   
  BEGIN
    IF( p_Invoice_Id IS NULL ) THEN
      P_Pstatus  := 'Error updating sp_update_invoice '||' Cannot insert with no invoice id' ;
      RETURN;
    END IF;
    Sp_Insert_Audit( P_Userid,'PKG_INVOICE.sp_update_invoice p_invoice_period_from= '||p_invoice_period_from||' invoice_number='||p_invoice_number);
    
    UPDATE 
      Invoice SET     
        Invoice_Number = p_Invoice_Number,
        Invoice_Date = p_Invoice_Date,
        Invoice_Period_From = p_Invoice_Period_From,
        Invoice_Period_To = p_Invoice_Period_To,
        Invoice_Amount = p_Invoice_Amount,
        status = p_status,
        Invoice_Received_Date = p_Invoice_Received_Date,
        invoice_due_date= p_invoice_due_date,
        last_modified_by = P_Userid,
        Last_modified_on =  Sysdate()
   WHERE Invoice_Id = p_Invoice_Id;
    
    IF Sql%Found THEN
      P_Pstatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_Pstatus := 'Error updating invoice '||Sqlerrm ;
    Sp_Insert_Audit( P_Userid,'Error PKG_INVOICE.sp_update_invoice'||SQLERRM );
  END sp_update_invoice ;      

  PROCEDURE Sp_Get_Invoice_Detail_Session
    (
      P_Userid            VARCHAR2 ,
      P_Invoice_Id        NUMBER ,
      P_Invoice_Detail_Id NUMBER DEFAULT 0 ,
      Rec_Cursor OUT Sys_Refcursor
    )
  AS
    /*
    Procedure : SP_GET_Invoice_detail_SESSION
    Author: Sridhar Kommana
    Date Created : 11/24/2015
    Purpose: SP_GET_Invoice_detail gets all invoice detail records session invoice.
    Update history:
    sridhar kommana :
    1) 11/30/2015 : created
       03/18/2016 : Modified Join Work_Orders Wc to meet RTM ID:W00a-10
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.SP_GET_Invoice_detail_SESSION Get Invoice details for p_UserId= '||P_Userid|| '  P_INVOICE_ID= '||P_Invoice_Id);
    OPEN Rec_Cursor FOR SELECT Invoice_Detail_Id,
    Invoice_Id,
    Id.Work_Orders_Id,
    Work_Order_Number,
    Id.Sub_Tasks_Id,
    Sub_Task_Number,
    DECODE(Clin_Sub_Clin, 'Y', Clin_Number ||Sub_Clin_Number,Clin_Number ) As Sub_Clin_Number_Disp,
    Id.Clin_Id,
    Clin_Number ,
    Clin_Title,
    Id.Sub_Clin_Id,
    Sub_Clin_Number,
    Id.Clin_Type,
    Labor_Category,
    Contract_Clin_Cost_Type,
    CONTRACTOR_ID,
    Contractor_Employee_Name,
    Invoice_Hours_Qty,
    Invoice_Rate,
    Invoice_Amount 
    FROM Invoice_Detail_Session Id 
    LEFT OUTER Join Work_Orders Wc ON Id.Work_Orders_Id = Wc.Work_Orders_Id 
    LEFT OUTER Join Sub_Tasks St ON Id.Sub_Tasks_Id = St.Sub_Tasks_Id 
    Inner Join Pop_Clin Pc ON Id.Clin_Id = Pc.Clin_Id 
    LEFT OUTER Join Sub_Clin Sc ON Id.Sub_Clin_Id = Sc.Sub_Clin_Id 
    WHERE( Invoice_Id = P_Invoice_Id OR P_Invoice_Id= 0) 
    AND ( Invoice_Detail_Id = P_Invoice_Detail_Id OR P_Invoice_Detail_Id= 0)
    AND ( Id.CREATED_BY = P_Userid)
    Order By 1
    ;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT 1 FROM Invoice_Detail ;
  END Sp_Get_Invoice_Detail_Session;

  PROCEDURE Sp_Insert_Inv_Detail_Session
    (
      P_Userid VARCHAR2 ,
      P_Invoice_Id               IN Invoice_Detail_Session.Invoice_Id%Type DEFAULT NULL,
      P_Work_Orders_Id           IN Invoice_Detail_Session.Work_Orders_Id%Type DEFAULT NULL,
      P_Sub_Tasks_Id             IN Invoice_Detail_Session.Sub_Tasks_Id%Type DEFAULT NULL,
      P_Clin_Id                  IN Invoice_Detail_Session.Clin_Id%Type DEFAULT NULL,
      P_Sub_Clin_Id              IN Invoice_Detail_Session.Sub_Clin_Id%Type DEFAULT NULL,
      P_Clin_Type                IN Invoice_Detail_Session.Clin_Type%Type DEFAULT NULL,
      P_Labor_Category           IN Invoice_Detail_Session.Labor_Category%Type DEFAULT NULL,
      P_Contract_Clin_Cost_Type  IN Invoice_Detail_Session.Contract_Clin_Cost_Type%Type DEFAULT NULL,
      p_CONTRACTOR_ID            IN Invoice_Detail_Session.CONTRACTOR_ID%Type DEFAULT NULL,
      P_Contractor_Employee_Name IN Invoice_Detail_Session.Contractor_Employee_Name%Type DEFAULT NULL,
      P_Invoice_Hours_Qty        IN Invoice_Detail_Session.Invoice_Hours_Qty%Type DEFAULT NULL,
      P_Invoice_Rate             IN Invoice_Detail_Session.Invoice_Rate%Type DEFAULT NULL,
      P_Invoice_Amount           IN Invoice_Detail_Session.Invoice_Amount%Type DEFAULT NULL,
      p_id OUT invoice_detail_session.Invoice_Detail_Id%type,
      P_Pstatus OUT VARCHAR2
    )
  AS
    /*
    Procedure : Sp_Insert_Inv_Detail_Session
    Author: Sridhar Kommana
    Date Created : 12/02/2015
    Purpose: Sp_Insert_Inv_Detail_Session gets all invoice detail records session invoice.
    Update history:
    sridhar kommana :
    1) 12/02/2015 : created
    */
    V_Inv_Id NUMBER:=0;
  BEGIN
    IF( P_Invoice_Id =0 OR P_Invoice_Id IS NULL ) THEN
      P_Pstatus     := 'Error inserting sp_insert_INV_DETAIL_SESSION '||' Cannot insert 0 or Null' ;
      RETURN;
    END IF;
    Sp_Insert_Audit( P_Userid,'PKG_INVOICE.sp_insert_INV_DETAIL_SESSION p_INVOICE_ID= '||P_Invoice_Id||' p_INVOICE_HOURS_QTY='||P_Invoice_Hours_Qty||'  p_INVOICE_AMOUNT='||P_Invoice_Amount);
    V_Inv_Id := Invoice_Seq.Nextval;
    INSERT
    INTO Invoice_Detail_Session
      (
        Invoice_Detail_Id,
        Invoice_Id,
        Work_Orders_Id,
        Sub_Tasks_Id,
        Clin_Id,
        Sub_Clin_Id,
        Clin_Type,
        Labor_Category,
        Contract_Clin_Cost_Type,
        CONTRACTOR_ID,
        Contractor_Employee_Name,
        Invoice_Hours_Qty,
        Invoice_Rate,
        Invoice_Amount,
        Created_By,
        Created_On
      )
      VALUES
      (
        V_Inv_Id ,
        P_Invoice_Id,
        P_Work_Orders_Id,
        P_Sub_Tasks_Id,
        P_Clin_Id,
        P_Sub_Clin_Id,
        P_Clin_Type,
        P_Labor_Category,
        P_Contract_Clin_Cost_Type,
        p_CONTRACTOR_ID,
        P_Contractor_Employee_Name,
        P_Invoice_Hours_Qty,
        P_Invoice_Rate,
        P_Invoice_Amount,
        P_Userid,
        Sysdate()
      );
    IF Sql%Found THEN
      P_Pstatus := 'SUCCESS' ;
      P_Id      := V_Inv_Id;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_Pstatus := 'Error inserting sp_insert_INV_DETAIL_SESSION '||Sqlerrm ;
    Sp_Insert_Audit( P_Userid,'Error PKG_INVOICE.insert_sp_insert_INV_DETAIL_SESSION'||'||SQLERRM|| p_INVOICE_ID= '||P_Invoice_Id||' p_INVOICE_HOURS_QTY='||P_Invoice_Hours_Qty||'  p_INVOICE_AMOUNT='||P_Invoice_Amount);
  END Sp_Insert_Inv_Detail_Session;

  PROCEDURE Move_invoice_SESSION
    (
      p_invoice_id           IN invoice_detail_session.invoice_id%TYPE DEFAULT NULL,
      p_CREATED_BY           IN invoice_detail_session.CREATED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  AS 
    /*
    Procedure : Move_invoice_SESSION
    Author: Sridhar Kommana
    Date Created : 12/03/2015
    Purpose: Move_invoice_SESSION inserts invoice detail records from session table.
    Update history:
    sridhar kommana :
    1) 12/03/2015 : created
    */  
  BEGIN
    IF( p_invoice_id =0 OR p_invoice_id IS NULL ) THEN
      p_PStatus         := 'Error moving  invoice session '||' Cannot move with no id' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'PKG_INVOICE.Move_invoice_SESSION p_invoice_id= '||p_invoice_id );
    INSERT
    INTO Invoice_Detail(
        Invoice_Detail_Id,
        Invoice_Id,
        Work_Orders_Id,
        Sub_Tasks_Id,
        Clin_Id,
        Sub_Clin_Id,
        Clin_Type,
        Labor_Category,
        Contract_Clin_Cost_Type,
        CONTRACTOR_ID,
        Contractor_Employee_Name,
        Invoice_Hours_Qty,
        Invoice_Rate,
        Invoice_Amount,
        Created_By,
        Created_On
        )
      SELECT 
        Invoice_Detail_Id,
        Invoice_Id,
        Work_Orders_Id,
        Sub_Tasks_Id,
        Clin_Id,
        Sub_Clin_Id,
        Clin_Type,
        Labor_Category,
        Contract_Clin_Cost_Type,
        CONTRACTOR_ID,
        Contractor_Employee_Name,
        Invoice_Hours_Qty,
        Invoice_Rate,
        Invoice_Amount,
        Created_By,
        Created_On      
        FROM invoice_detail_session
        WHERE CREATED_BY      = p_CREATED_BY
        AND Invoice_Id = p_Invoice_Id
      ;
      
    DELETE invoice_detail_session
    WHERE CREATED_BY      = p_CREATED_BY
    AND Invoice_Id = p_Invoice_Id;
    
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error moving invoice_detail_session '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_invoice.Move_invoice_SESSION'||'||SQLERRM|| p_Invoice_Id= '||p_Invoice_Id );
  END Move_invoice_SESSION;   

  PROCEDURE delete_invoice_SESSION
    (
      p_CREATED_BY           IN invoice_detail_session.CREATED_BY%TYPE ,
      p_PStatus OUT VARCHAR2
    )
  AS 
    /*
    Procedure : delete_invoice_SESSION
    Author: Sridhar Kommana
    Date Created : 12/03/2015
    Purpose: delete_invoice_SESSION deletes invoice detail session records if user exits without saving the records to detail table.
    Update history:
    sridhar kommana :
    1) 12/03/2015 : created
    */  
  BEGIN
    IF( p_CREATED_BY IS NULL ) THEN
      p_PStatus         := 'Error deleteing   invoice session, Cannot delete with no id' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'PKG_INVOICE.delete_invoice_SESSION' );
    DELETE from invoice_detail_session
    WHERE CREATED_BY      = p_CREATED_BY;
    
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error deleting session record '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_invoice.delete_invoice_SESSION'||SQLERRM);
  END delete_invoice_SESSION;   
 
  PROCEDURE sp_insert_inv_detail (
   p_userid                            VARCHAR2,
   p_invoice_id                 IN     invoice_detail.invoice_id%TYPE DEFAULT NULL,
   p_work_orders_id             IN     invoice_detail.work_orders_id%TYPE DEFAULT NULL,
   p_sub_tasks_id               IN     invoice_detail.sub_tasks_id%TYPE DEFAULT NULL,
   p_clin_id                    IN     invoice_detail.clin_id%TYPE DEFAULT NULL,
   p_sub_clin_id                IN     invoice_detail.sub_clin_id%TYPE DEFAULT NULL,
   p_clin_type                  IN     invoice_detail.clin_type%TYPE DEFAULT NULL,
   p_labor_category             IN     invoice_detail.labor_category%TYPE DEFAULT NULL,
   p_contract_clin_cost_type    IN     invoice_detail.contract_clin_cost_type%TYPE DEFAULT NULL,
   p_CONTRACTOR_ID              IN     Invoice_Detail.CONTRACTOR_ID%TYPE DEFAULT NULL,
   p_contractor_employee_name   IN     invoice_detail.contractor_employee_name%TYPE DEFAULT NULL,
   p_invoice_hours_qty          IN     invoice_detail.invoice_hours_qty%TYPE DEFAULT NULL,
   p_invoice_rate               IN     invoice_detail.invoice_rate%TYPE DEFAULT NULL,
   p_invoice_amount             IN     invoice_detail.invoice_amount%TYPE DEFAULT NULL,
   p_Travel_Auth                IN     invoice_detail.Travel_Auth%TYPE DEFAULT NULL,
   p_Description                IN     invoice_detail.Description%TYPE DEFAULT NULL,
   p_ODC_Auth                   IN     invoice_detail.ODC_Auth%TYPE DEFAULT NULL,
   p_id                            OUT invoice_detail_session.Invoice_Detail_Id%TYPE,
   p_pstatus                       OUT VARCHAR2)
  AS
    /*
    Procedure : Sp_Insert_Inv_Detail
    Author: Sridhar Kommana
    Date Created : 12/03/2015
    Purpose: Sp_Insert_Inv_Detail inserts invoice detail records for a given invoice.
    Update history:
    sridhar kommana :
    1) 12/03/2015 : created
    2) 05/31/2016 : Added p_Travel_Auth and p_Description
    */
    V_Inv_Sess_Id NUMBER:=0;
  BEGIN
    IF( P_Invoice_Id =0 OR P_Invoice_Id IS NULL ) THEN
      P_Pstatus     := 'Error inserting sp_insert_INV_DETAIL Cannot insert 0 or Null' ;
      RETURN;
    END IF;
    Sp_Insert_Audit( P_Userid,'PKG_INVOICE.sp_insert_INV_DETAIL p_INVOICE_ID= '||P_Invoice_Id||' p_INVOICE_HOURS_QTY='||P_Invoice_Hours_Qty||'  p_INVOICE_AMOUNT='||P_Invoice_Amount);
    V_Inv_Sess_Id := Invoice_Seq.Nextval;
    INSERT
    INTO Invoice_Detail
      (
        Invoice_Detail_Id,
        Invoice_Id,
        Work_Orders_Id,
        Sub_Tasks_Id,
        Clin_Id,
        Sub_Clin_Id,
        Clin_Type,
        Labor_Category,
        Contract_Clin_Cost_Type,
        CONTRACTOR_ID,
        Contractor_Employee_Name,
        Invoice_Hours_Qty,
        Invoice_Rate,
        Invoice_Amount,
        Travel_Auth, 
        Description,
        ODC_Auth,
        Created_By,
        Created_On
      )
      VALUES
      (
        V_Inv_Sess_Id ,
        P_Invoice_Id,
        P_Work_Orders_Id,
        P_Sub_Tasks_Id,
        P_Clin_Id,
        P_Sub_Clin_Id,
        P_Clin_Type,
        P_Labor_Category,
        P_Contract_Clin_Cost_Type,
        p_CONTRACTOR_ID,
        P_Contractor_Employee_Name,
        P_Invoice_Hours_Qty,
        P_Invoice_Rate,
        P_Invoice_Amount,
        p_Travel_Auth, 
        p_Description, 
        p_ODC_Auth,
        P_Userid,
        Sysdate()
      );
    IF Sql%Found THEN
      P_Pstatus := 'SUCCESS' ;
      P_Id      := V_Inv_Sess_Id;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_Pstatus := 'Error inserting sp_insert_INV_DETAIL '||Sqlerrm ;
    Sp_Insert_Audit( P_Userid,'Error PKG_INVOICE.insert_sp_insert_INV_DETAIL'||'||SQLERRM|| p_INVOICE_ID= '||P_Invoice_Id||' p_INVOICE_HOURS_QTY='||P_Invoice_Hours_Qty||'  p_INVOICE_AMOUNT='||P_Invoice_Amount);
  END Sp_Insert_Inv_Detail;
  
  PROCEDURE sp_update_inv_detail
    (
      p_userid VARCHAR2 ,
      p_Invoice_Detail_Id IN invoice_detail.Invoice_Detail_Id%type DEFAULT NULL,
      p_invoice_hours_qty IN invoice_detail.invoice_hours_qty%type DEFAULT NULL,
      p_invoice_rate      IN invoice_detail.invoice_rate%type DEFAULT NULL,
      p_invoice_amount    IN invoice_detail.invoice_amount%type DEFAULT NULL,
      p_pstatus OUT VARCHAR2
    )
  AS
  BEGIN
    IF( p_Invoice_Detail_Id =0 OR p_Invoice_Detail_Id IS NULL ) THEN
      P_Pstatus            := 'Error inserting sp_update_inv_detail '||' Cannot update record 0 or Null' ;
      RETURN;
    END IF;
    Sp_Insert_Audit( P_Userid,'PKG_INVOICE.sp_update_inv_detail p_Invoice_Detail_Id= '||p_Invoice_Detail_Id||' p_INVOICE_HOURS_QTY='||P_Invoice_Hours_Qty||'  p_INVOICE_AMOUNT='||P_Invoice_Amount);
    UPDATE Invoice_Detail
    SET Invoice_Hours_Qty   = P_Invoice_Hours_Qty,
      Invoice_Rate          = P_Invoice_Rate,
      Invoice_Amount        = P_Invoice_Amount,
      Last_modified_by      = P_Userid,
      Last_modified_on      = Sysdate()
    WHERE Invoice_Detail_Id = p_Invoice_Detail_Id;
    IF Sql%Found THEN
      P_Pstatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_Pstatus := 'Error updating sp_update_inv_detail '||Sqlerrm ;
    Sp_Insert_Audit( P_Userid,'Error PKG_INVOICE.sp_update_inv_detail'||'||SQLERRM||  p_Invoice_Detail_Id= '||p_Invoice_Detail_Id||' p_INVOICE_HOURS_QTY='||P_Invoice_Hours_Qty||'  p_INVOICE_AMOUNT='||P_Invoice_Amount);
  END sp_update_inv_detail;

  PROCEDURE sp_delete_inv_detail
    (
      p_userid VARCHAR2 ,
      p_Invoice_Detail_Id IN invoice_detail.Invoice_Detail_Id%type DEFAULT NULL,
      p_pstatus OUT VARCHAR2
    )
  AS
  BEGIN
    IF( p_Invoice_Detail_Id =0 OR p_Invoice_Detail_Id IS NULL ) THEN
      P_Pstatus            := 'Error deleting sp_update_inv_detail '||' Cannot update record 0 or Null' ;
      RETURN;
    END IF;
    Sp_Insert_Audit( P_Userid,'PKG_INVOICE.sp_delete_inv_detail p_Invoice_Detail_Id= '||p_Invoice_Detail_Id);
    delete from Invoice_Detail 
    WHERE Invoice_Detail_Id = p_Invoice_Detail_Id;
    IF Sql%Found THEN
      P_Pstatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_Pstatus := 'Error deleting sp_delete_inv_detail '||Sqlerrm ;
    Sp_Insert_Audit( P_Userid,'Error PKG_INVOICE.sp_delete_inv_detail'||'||SQLERRM||  p_Invoice_Detail_Id= '||p_Invoice_Detail_Id);
  END sp_delete_inv_detail;  

  PROCEDURE SP_GET_TASK_STCLINS(
    p_UserId         VARCHAR2,
    P_SubTaskID      NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0  ,    
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,    
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,     
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_TASK_STCLINS
  Author: Sridhar Kommana
  Date Created : 12/14/2015
  Purpose:  Get Clin hours and type info for a TASK and sub-task based on the parameter
  Update history:
   03/18/2016 : Added new parameter p_period_of_performance_id to meet RTM ID:W00a-10
   05/31/2016 :Sridhar kommanab Added clinumber to title
   06/08/2016 : Sridhar kommanab added SUB_CLIN_DISP
  */
  p_status VARCHAR2(100);
BEGIN
  
  IF (P_SubTaskID <> 0 or P_SubTaskID > 0 ) THEN 
  SP_INSERT_AUDIT(p_UserId, 'PKG_INVOICE.SP_GET_TASK_STCLINS: Get sub-task CLIN details P_SubTaskID='||P_SubTaskID|| 'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'p_clin_sub_type='||p_clin_sub_type|| 'p_period_of_performance_id='||p_period_of_performance_id );  
  OPEN REC_CURSOR FOR
  SELECT 
      DISTINCT 
        DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ) AS SUB_CLIN_NUMBER_DISP, 
        DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_DISP,        
        NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, 
        LABOR_CATEGORY_TITLE, 
        CLIN_TYPE_DISP, 
        SUM(ST_CLIN_HOURS) CLIN_HOURS , 
        CLIN_Rate,
        SUM(ST_CLIN_AMOUNT) CLIN_AMOUNT,
        CLIN_ID, sub_clin_id,CLIN_TYPE as CLIN_TYPE_ORIG, LABOR_CATEGORY_ID--,STC_ID
  FROM
    (SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      NVL(ST_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE ,
      0 LABOR_CATEGORY_ID,
      Decode(C.LABOR_CATEGORY_ID, NULL, '', (select NVL(category_name,'NONE') from Labor_categories where category_id = C.LABOR_CATEGORY_ID))
          AS LABOR_CATEGORY_TITLE , 
      NVL(C.CLIN_HOURS,0) + NVL(SC.SUB_CLIN_HOURS,0)  AS CLIN_HOURS,
      NVL(C.CLIN_RATE,0)  + NVL(SC.SUB_CLIN_RATE,0)   AS CLIN_RATE,
      NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS CLIN_AMOUNT,
      W.STC_ID,
      WORK_ORDERS_ID,
      NVL(W.CLIN_HOURS,0) ST_CLIN_HOURS,
      ST_Rate AS ST_CLIN_RATE,
      NVL(W.CLIN_AMOUNT,0) ST_CLIN_AMOUNT ,
      C.LABOR_RATE_TYPE,
      SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
      RATE_TYPE
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID )
    INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN SUB_TASKS_CLINS W     ON ( (W.CLIN_ID        = C.CLIN_ID
    AND W.SUB_CLIN_ID      = SC.SUB_CLIN_ID)     OR ( W.CLIN_ID         = C.CLIN_ID
    AND (W.SUB_CLIN_ID    IS NULL     OR W.SUB_CLIN_ID       =0) ) )
    AND (W.WORK_ORDERS_ID  = p_WORK_ORDERS_ID  OR p_WORK_ORDERS_ID = 0 )   
    AND (W.FK_Sub_Tasks_ID = P_SubTaskID     OR P_SubTaskID         =0)
    AND (C.period_of_performance_id = p_period_of_performance_id     OR p_period_of_performance_id =0)    
    UNION
    SELECT 
          C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      'Labor' AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE ,
      CLC.LABOR_CATEGORY_ID,
      CLC.LABOR_CATEGORY_TITLE , --L.CATEGORY_NAME AS DESCRIPTION,
      NVL(C.CLIN_HOURS,0) + NVL(SC.SUB_CLIN_HOURS,0)  AS CLIN_HOURS,
      NVL(C.CLIN_RATE,0)  + NVL(SC.SUB_CLIN_RATE,0)   AS CLIN_RATE,
      NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS CLIN_AMOUNT,
      W.ST_LABOR_CATEGORY_ID STC_ID,
      WORK_ORDERS_ID,
      NVL(W.LABOR_CATEGORY_HOURS,0) ST_CLIN_HOURS,
      NVL(W.LABOR_CATEGORY_Rate,0) ST_CLIN_RATE,
      LC_AMOUNT AS ST_CLIN_AMOUNT ,
      C.LABOR_RATE_TYPE,
      SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
      RATE_TYPE
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC
    ON (SC.CLIN_ID = C.CLIN_ID)
    INNER JOIN PERIOD_OF_PERFORMANCE POP
    ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN ST_LABOR_CATEGORY W
    ON ( W.CLIN_ID = C.CLIN_ID
    OR ( W.CLIN_ID = SC.CLIN_ID ))
    INNER JOIN CLIN_LABOR_CATEGORY CLC
    ON CLC.LABOR_CATEGORY_ID = W.LABOR_CATEGORY_ID    AND CLC.CLIN_ID          = W.CLIN_ID
    AND (W.WORK_ORDERS_ID    = p_WORK_ORDERS_ID  OR p_WORK_ORDERS_ID = 0 )    AND (W.Sub_Tasks_ID      = P_SubTaskID    OR P_SubTaskID           =0)
    AND (C.period_of_performance_id = p_period_of_performance_id     OR p_period_of_performance_id =0)        
    ) TBLCLINS
  WHERE ( CLIN_TYPE_DISP = p_clin_sub_type or p_clin_sub_type is NULL)    
  --(DECODE(CLIN_SUB_CLIN, 'Y', SUB_CLIN_TYPE, CLIN_TYPE ) = p_clin_sub_type or p_clin_sub_type is NULL)    
  GROUP BY --- STC_ID,
  
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ),
   NVL(SUB_CLIN_TITLE,CLIN_TITLE) , 
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ),
    LABOR_CATEGORY_TITLE, CLIN_TYPE_DISP, CLIN_Rate,
    CLIN_ID, sub_clin_id,CLIN_TYPE, LABOR_CATEGORY_ID --,STC_ID
  ORDER BY 1 ;
  ELSE  -- Returning only TaskOrder part
    SP_INSERT_AUDIT(p_UserId, 'PKG_INVOICE.SP_GET_TASK_STCLINS: else part P_SubTaskID is null : Get sub-task CLIN details P_SubTaskID='||P_SubTaskID|| 'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'p_clin_sub_type='||p_clin_sub_type|| 'p_period_of_performance_id='||p_period_of_performance_id );  
  OPEN REC_CURSOR FOR
  SELECT DISTINCT
              --DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_NUMBER_DISP, 
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ) AS SUB_CLIN_NUMBER_DISP,              
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_DISP, 
              NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, 
              LABOR_CATEGORY_TITLE, 
              CLIN_TYPE_DISP, 
              SUM(WO_CLIN_HOURS) CLIN_HOURS , 
              WO_CLIN_Rate CLIN_Rate, 
              SUM(WO_CLIN_AMOUNT) CLIN_AMOUNT,
              CLIN_ID, sub_clin_id,CLIN_TYPE as CLIN_TYPE_ORIG, LABOR_CATEGORY_ID--,WOC_ID
  FROM
    (SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      NVL(WO_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE ,
      C.LABOR_CATEGORY_ID,
      Decode(C.LABOR_CATEGORY_ID, NULL, '', (select NVL(category_name,'NONE') from Labor_categories where category_id = C.LABOR_CATEGORY_ID))
          AS LABOR_CATEGORY_TITLE , 
      NVL(C.CLIN_HOURS,0) + NVL(SC.SUB_CLIN_HOURS,0)  AS CLIN_HOURS,
      NVL(C.CLIN_RATE,0)  + NVL(SC.SUB_CLIN_RATE,0)   AS CLIN_RATE,
      NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS CLIN_AMOUNT,
      W.WOC_ID,
      FK_WORK_ORDERS_ID,
      NVL(W.CLIN_HOURS,0) WO_CLIN_HOURS,
      WO_RATE AS WO_CLIN_RATE,
      NVL(W.CLIN_AMOUNT,0) WO_CLIN_AMOUNT ,

      C.LABOR_RATE_TYPE,
      SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
      RATE_TYPE
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC
    ON (SC.CLIN_ID = C.CLIN_ID )
   INNER JOIN PERIOD_OF_PERFORMANCE POP
   ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN WORK_ORDERS_CLINS W
    ON ( (W.CLIN_ID                       = C.CLIN_ID
    AND W.SUB_CLIN_ID                     = SC.SUB_CLIN_ID)
    OR ( W.CLIN_ID                        = C.CLIN_ID
    AND (W.SUB_CLIN_ID                   IS NULL
    OR W.SUB_CLIN_ID                      =0) ) )
    --AND (W.WOC_ID                         = P_WOC_ID    OR P_WOC_ID                           = 0)
    AND (W.FK_WORK_ORDERS_ID              = p_WORK_ORDERS_ID  OR p_WORK_ORDERS_ID = 0 )
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
UNION
    SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      'Labor' AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE ,
      CLC.LABOR_CATEGORY_ID,
      CLC.LABOR_CATEGORY_TITLE , --L.CATEGORY_NAME AS DESCRIPTION,
      NVL(C.CLIN_HOURS,0) + NVL(SC.SUB_CLIN_HOURS,0)  AS CLIN_HOURS,
      NVL(C.CLIN_RATE,0)  + NVL(SC.SUB_CLIN_RATE,0)   AS CLIN_RATE,
      NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS CLIN_AMOUNT,
      W.WO_LABOR_CATEGORY_ID WOC_ID,
      WORK_ORDERS_ID,
      NVL(W.LABOR_CATEGORY_HOURS,0) WO_CLIN_HOURS,
      NVL(W.LABOR_CATEGORY_Rate,0) WO_CLIN_RATE,
      LC_AMOUNT AS WO_CLIN_AMOUNT ,
      C.LABOR_RATE_TYPE,
      SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
      RATE_TYPE
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC
    ON (SC.CLIN_ID = C.CLIN_ID)
    INNER JOIN PERIOD_OF_PERFORMANCE POP
    ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN WO_LABOR_CATEGORY W
    ON ( W.CLIN_ID = C.CLIN_ID
    OR (
      W.CLIN_ID = SC.CLIN_ID ))
    INNER JOIN CLIN_LABOR_CATEGORY CLC
    ON CLC.LABOR_CATEGORY_ID    = W.LABOR_CATEGORY_ID
    AND CLC.CLIN_ID             = W.CLIN_ID
    --AND (W.WO_LABOR_CATEGORY_ID = P_WOC_ID     OR P_WOC_ID                 = 0)
    AND (W.WORK_ORDERS_ID       = p_WORK_ORDERS_ID OR p_WORK_ORDERS_ID = 0 )
    AND (C.period_of_performance_id = p_period_of_performance_id     OR p_period_of_performance_id =0)    
      --AND W.created_by=p_UserId
    --AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID    OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
    ) TBLCLINS 
  --WHERE (DECODE(CLIN_SUB_CLIN, 'Y', SUB_CLIN_TYPE, CLIN_TYPE ) = p_clin_sub_type or p_clin_sub_type is NULL)      
  WHERE ( CLIN_TYPE_DISP = p_clin_sub_type or p_clin_sub_type is NULL)    
  GROUP BY  CLIN_ID,sub_clin_id,CLIN_TYPE,LABOR_CATEGORY_ID,
  
   DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) , 
   NVL(SUB_CLIN_TITLE,CLIN_TITLE) ,
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ),
     LABOR_CATEGORY_TITLE, CLIN_TYPE_DISP, WO_CLIN_Rate--,WOC_ID
  ORDER BY 1 ;   
  END IF;   
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 0 SUB_CLIN_NUMBER_DISP, 0 CLIN_TITLE_DISP, 0 LABOR_CATEGORY_TITLE, 0 CLIN_TYPE_DISP, 0 CLIN_HOURS , 0 CLIN_Rate, 0 CLIN_AMOUNT FROM dual;
END SP_GET_TASK_STCLINS;    
    
  PROCEDURE SP_GET_INV_POP_CLINS(
    p_UserId         VARCHAR2,
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,   
    p_contract_number invoice.contract_number%type DEFAULT NULL,  
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,     
    REC_CURSOR OUT Sys_Refcursor)
as
  /*
  Procedure : SP_GET_INV_POP_CLINS
  Author: Sridhar Kommana
  Date Created : 03/20/2016
  Purpose:  Get Clin hours and type info for a contract to meet RTM ID:W00a-10
  Update history:
  1) 05/05/2016 : Added LCs and TMO records to SP_GET_INV_POP_CLINS   
  2) 05/06/2016 : Filtered out parent clins which has LCS
  3) 05/20/2016 : Sridhar Kommana  Modified  CLIN_TYPE_DISP to show sub clin if exisits
  4) 05/31/2016 :Sridhar kommanab Added clinumber to title
  5) 06/08/2016 : Sridhar kommanab added SUB_CLIN_DISP
  6) 06/10/2010 : Sridhar Kommana Added p_clin_sub_type 
  */

BEGIN
    SP_INSERT_AUDIT(p_UserId, 'PKG_INVOICE.SP_GET_INV_POP_CLINS: p_period_of_performance_id='||p_period_of_performance_id|| 'p_contract_number='||p_contract_number|| 'p_clin_sub_type='||p_clin_sub_type);  
  OPEN REC_CURSOR FOR
 SELECT DISTINCT
              DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ) AS SUB_CLIN_NUMBER_DISP, 
              DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_DISP,
              NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, 
              LABOR_CATEGORY_TITLE, 
              CLIN_TYPE_DISP, 
              SUM(CLIN_HOURS) CLIN_HOURS , 
              to_char(CLIN_Rate) as CLIN_Rate, 
              SUM(CLIN_AMOUNT) CLIN_AMOUNT,
              CLIN_ID, sub_clin_id,CLIN_TYPE as CLIN_TYPE_ORIG, LABOR_CATEGORY_ID
  FROM
    (
    SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      --C.CLIN_TYPE CLIN_TYPE_DISP,
      DECODE(CLIN_SUB_CLIN, 'Y', SUB_CLIN_TYPE, C.CLIN_TYPE ) AS CLIN_TYPE_DISP,       
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE ,
      C.LABOR_CATEGORY_ID,
     Decode(C.LABOR_CATEGORY_ID, NULL, '', (select NVL(category_name,'NONE') from Labor_categories where category_id = C.LABOR_CATEGORY_ID))          AS LABOR_CATEGORY_TITLE , 
      NVL(C.CLIN_HOURS,0) + NVL(SC.SUB_CLIN_HOURS,0)  AS CLIN_HOURS,
      NVL(C.CLIN_RATE,0)  + NVL(SC.SUB_CLIN_RATE,0)   AS CLIN_RATE,
      NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS CLIN_AMOUNT,
      C.LABOR_RATE_TYPE,
      SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
      RATE_TYPE
    FROM POP_CLIN C
    INNER JOIN Period_Of_Performance POP ON POP.PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID    
    AND C.HASLABORCATEGORIES<>'Y' 
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
    AND (POP.contract_number       = P_contract_number   OR P_contract_number IS NULL)    
    LEFT OUTER JOIN SUB_CLIN SC    ON (SC.CLIN_ID = C.CLIN_ID )       
    ) TBLCLINS 
  WHERE (DECODE(CLIN_SUB_CLIN, 'Y', SUB_CLIN_TYPE, CLIN_TYPE ) = p_clin_sub_type or p_clin_sub_type is NULL)
  GROUP BY    
                 DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ),
              DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ), 
              NVL(SUB_CLIN_TITLE,CLIN_TITLE), 
              LABOR_CATEGORY_TITLE, 
              CLIN_TYPE_DISP, 
              CLIN_HOURS , 
              CLIN_Rate, 
              CLIN_AMOUNT,
              CLIN_ID, sub_clin_id,CLIN_TYPE, LABOR_CATEGORY_ID

UNION ALL    
SELECT DISTINCT PC.CLIN_NUMBER AS SUB_CLIN_NUMBER_DISP,
      PC.CLIN_NUMBER AS SUB_CLIN_DISP,
       PC.CLIN_TITLE AS CLIN_TITLE_DISP,
       C.LABOR_CATEGORY_TITLE,
       'Labor' AS CLIN_TYPE_DISP,
       0 AS CLIN_HOURS,
       DECODE (
          RATE_TYPE,
          'Range',    C.LABOR_CATEGORY_LOW_RATE
                   || '-'
                   || C.LABOR_CATEGORY_HIGH_RATE,
          C.LABOR_CATEGORY_RATE)
          AS CLIN_Rate,
       0 AS CLIN_AMOUNT,
       C.CLIN_ID,
       NULL AS sub_clin_id,
       'Labor' AS CLIN_TYPE_ORIG,
       C.LABOR_CATEGORY_ID
  --FROM POP_CLIN PC INNER JOIN CLIN_LABOR_CATEGORY C ON PC.CLIN_ID = C.CLIN_ID WHERE C.CLIN_ID = 18190
    FROM POP_CLIN PC
    INNER JOIN CLIN_LABOR_CATEGORY C ON PC.CLIN_ID = C.CLIN_ID
    INNER JOIN Period_Of_Performance POP ON POP.PERIOD_OF_PERFORMANCE_ID = PC.PERIOD_OF_PERFORMANCE_ID    
    AND (PC.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
    AND (POP.contract_number       = P_contract_number   OR P_contract_number IS NULL) 
    AND  (PC.Clin_type= p_clin_sub_type or p_clin_sub_type is NULL)
UNION ALL
SELECT C.CLIN_NUMBER AS SUB_CLIN_NUMBER_DISP,
        C.CLIN_NUMBER AS SUB_CLIN_DISP,
       C.CLIN_TITLE AS CLIN_TITLE_DISP,
       '' AS LABOR_CATEGORY_TITLE,
       C.CLIN_TYPE AS CLIN_TYPE_DISP,
       0 AS CLIN_HOURS,
       NULL AS CLIN_Rate,
       C.CLIN_AMOUNT,
       C.CLIN_ID,
       NULL AS sub_clin_id,
       C.CLIN_TYPE AS CLIN_TYPE_ORIG,
       C.CLIN_TMO_ID AS LABOR_CATEGORY_ID
    FROM POP_CLIN PC
    INNER JOIN clin_tmo C ON PC.CLIN_ID = C.CLIN_ID AND C.CLIN_TYPE <> 'Labor'
    INNER JOIN Period_Of_Performance POP ON POP.PERIOD_OF_PERFORMANCE_ID = PC.PERIOD_OF_PERFORMANCE_ID    
    AND (PC.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
    AND (POP.contract_number       = P_contract_number   OR P_contract_number IS NULL)  
    AND  (c.Clin_type= p_clin_sub_type or p_clin_sub_type is NULL)
  ORDER BY 1 ;   
  
EXCEPTION WHEN OTHERS THEN   OPEN REC_CURSOR FOR SELECT 1  FROM dual;
END SP_GET_INV_POP_CLINS;    
 

PROCEDURE SP_GET_INV_LTMO_CLINS(
    p_UserId         VARCHAR2,
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,   
    p_contract_number invoice.contract_number%type DEFAULT NULL,  
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,  
    REC_CURSOR OUT SYS_REFCURSOR)
as
  /*
  Procedure : SP_GET_INV_LTMO_CLINS
  Author: Sridhar Kommana
  Date Created : 06/13/2016
  Purpose:  Gets list of clins under a contact to meet RTM ID:I00
  Update history:
  */

BEGIN
    SP_INSERT_AUDIT(p_UserId, 'PKG_INVOICE.SP_GET_INV_LTMO_CLINS: p_period_of_performance_id='||p_period_of_performance_id|| 'p_contract_number='||p_contract_number|| 'p_clin_sub_type='||p_clin_sub_type);  
  OPEN REC_CURSOR FOR
 
SELECT DISTINCT
              DECODE(CLIN_SUB_CLIN, 'Y', CLIN_ID||':'||sub_clin_id,CLIN_ID  ) AS SUB_CLIN_Id_DISP,
              DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ) AS SUB_CLIN_NUMBER_DISP, 
              DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_DISP,
              NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, 
              CLIN_ID, sub_clin_id
  FROM
    (
    SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      DECODE(CLIN_SUB_CLIN, 'Y', SUB_CLIN_TYPE, C.CLIN_TYPE ) AS CLIN_TYPE_DISP,       
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE
    FROM  Period_Of_Performance POP 
    INNER JOIN POP_CLIN C ON POP.PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID    
    AND C.HASLABORCATEGORIES<>'Y' 
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
    AND (POP.contract_number       = P_contract_number   OR P_contract_number IS NULL)    
    LEFT OUTER JOIN SUB_CLIN SC    ON (SC.CLIN_ID = C.CLIN_ID )
    WHERE (DECODE(CLIN_SUB_CLIN, 'Y', SUB_CLIN_TYPE, CLIN_TYPE ) = p_clin_sub_type or p_clin_sub_type is NULL)           
   
  
     
   
UNION ALL    
SELECT DISTINCT
      C.CLIN_ID,
      NULL AS sub_clin_id,
      PC.CLIN_NUMBER,
      NULL as SUB_CLIN_NUMBER,
      NULL AS SUB_CLIN_TYPE ,
      PC.CLIN_TYPE ,
      'Labor' AS  CLIN_TYPE_DISP,       
      PC.CLIN_SUB_CLIN ,
      PC.CLIN_TITLE ,
      NULL AS SUB_CLIN_TITLE
    FROM Period_Of_Performance POP 
     INNER JOIN POP_CLIN PC ON POP.PERIOD_OF_PERFORMANCE_ID = PC.PERIOD_OF_PERFORMANCE_ID
     INNER JOIN CLIN_LABOR_CATEGORY C ON PC.CLIN_ID = C.CLIN_ID    
    AND (PC.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
    AND (POP.contract_number       = P_contract_number   OR P_contract_number IS NULL) 
    AND  (PC.Clin_type= p_clin_sub_type or p_clin_sub_type is NULL)

UNION ALL
SELECT 
      C.CLIN_ID,
      NULL AS sub_clin_id,
      C.CLIN_NUMBER,
      NULL as SUB_CLIN_NUMBER,
      NULL AS SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      C.CLIN_TYPE  CLIN_TYPE_DISP,       
      PC.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      NULL AS SUB_CLIN_TITLE
    FROM Period_Of_Performance POP 
    INNER JOIN POP_CLIN PC ON POP.PERIOD_OF_PERFORMANCE_ID = PC.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN clin_tmo C ON PC.CLIN_ID = C.CLIN_ID AND C.CLIN_TYPE <> p_clin_sub_type         
    AND (PC.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
    AND (POP.contract_number       = P_contract_number   OR P_contract_number IS NULL)  
    AND  (c.Clin_type= p_clin_sub_type or p_clin_sub_type is NULL)
        
 ) TBLCLINS  ;
  
  
  
EXCEPTION WHEN OTHERS THEN   OPEN REC_CURSOR FOR SELECT 1  FROM dual;    
END SP_GET_INV_LTMO_CLINS    ;

  PROCEDURE SP_GET_TASK_STCLINS_LIST(
    p_UserId         VARCHAR2,
    P_SubTaskID      NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0  ,    
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE,    
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,     
    REC_CURSOR OUT SYS_REFCURSOR)
  AS 
    /*
  Procedure : SP_GET_TASK_STCLINS_LIST
  Author: Sridhar Kommana
  Date Created : 06/14/2016
  Purpose:  Get Clins list for a TASK and sub-task based on the parameter
  Update history:
  07/08/2016 : skommana : Added sub-task union to existing Task order clins : RTMID=I01-24
  
  */
   
  BEGIN
--    SP_INSERT_AUDIT(p_UserId, 'PKG_INVOICE.SP_GET_TASK_STCLINS_LIST:     P_SubTaskID='||P_SubTaskID|| 'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'p_clin_sub_type='||p_clin_sub_type|| 'p_period_of_performance_id='||p_period_of_performance_id );  
 IF P_SubTaskID = 0 THEN    
    SP_INSERT_AUDIT(p_UserId, 'PKG_INVOICE.SP_GET_TASK_STCLINS_LIST:  TASK ORDERS part    P_SubTaskID='||P_SubTaskID|| 'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'p_clin_sub_type='||p_clin_sub_type|| 'p_period_of_performance_id='||p_period_of_performance_id );  
 
 OPEN REC_CURSOR FOR
    SELECT DISTINCT
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_ID||':'||sub_clin_id,CLIN_ID) AS SUB_CLIN_ID_DISP,
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ) AS SUB_CLIN_NUMBER_DISP,              
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_DISP, 
      NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, 
      CLIN_TYPE_DISP, 
      CLIN_ID, sub_clin_id, CLIN_ID || sub_clin_id as CLIN_SUB_CLIN_ID ,
      CLIN_TYPE as CLIN_TYPE_ORIG
  FROM
    (
    SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      NVL(WO_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE 
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC
    ON (SC.CLIN_ID = C.CLIN_ID )
   INNER JOIN PERIOD_OF_PERFORMANCE POP
   ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN WORK_ORDERS_CLINS W
    ON ( (W.CLIN_ID                       = C.CLIN_ID
    AND W.SUB_CLIN_ID                     = SC.SUB_CLIN_ID)
    OR ( W.CLIN_ID                        = C.CLIN_ID
    AND (W.SUB_CLIN_ID                   IS NULL
    OR W.SUB_CLIN_ID                      =0) ) )
    AND (W.FK_WORK_ORDERS_ID              = p_WORK_ORDERS_ID  OR p_WORK_ORDERS_ID = 0 )
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID   OR P_PERIOD_OF_PERFORMANCE_ID = 0)
UNION
    SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      'Labor' AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE 
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC
    ON (SC.CLIN_ID = C.CLIN_ID)
    INNER JOIN PERIOD_OF_PERFORMANCE POP
    ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN WO_Labor_CATEGORY W
    ON ( W.CLIN_ID = C.CLIN_ID
    OR (
      W.CLIN_ID = SC.CLIN_ID ))
    INNER JOIN CLIN_Labor_CATEGORY CLC
    ON CLC.Labor_CATEGORY_ID    = W.Labor_CATEGORY_ID
    AND CLC.CLIN_ID             = W.CLIN_ID
    AND (W.WORK_ORDERS_ID       = p_WORK_ORDERS_ID OR p_WORK_ORDERS_ID = 0 )
    
    AND (C.period_of_performance_id = P_PERIOD_OF_PERFORMANCE_ID     OR P_PERIOD_OF_PERFORMANCE_ID =0)   

    
    ) 
    TBLCLINS 
        
  WHERE ( CLIN_TYPE_DISP = p_clin_sub_type or p_clin_sub_type is NULL)    
  ORDER BY 1 ; 
 
 ELSE  --for sub-tasks
     SP_INSERT_AUDIT(p_UserId, 'PKG_INVOICE.SP_GET_TASK_STCLINS_LIST:  SUB TASK ORDERS part    P_SubTaskID='||P_SubTaskID|| 'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'p_clin_sub_type='||p_clin_sub_type|| 'p_period_of_performance_id='||p_period_of_performance_id );  

  OPEN REC_CURSOR FOR
    SELECT DISTINCT
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_ID||':'||sub_clin_id,CLIN_ID) AS SUB_CLIN_ID_DISP,
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER||': '||SUB_CLIN_TITLE,CLIN_NUMBER||': '||CLIN_TITLE ) AS SUB_CLIN_NUMBER_DISP,              
      DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_DISP, 
      NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, 
      CLIN_TYPE_DISP, 
      CLIN_ID, sub_clin_id, CLIN_ID || sub_clin_id as CLIN_SUB_CLIN_ID ,
      CLIN_TYPE as CLIN_TYPE_ORIG
  FROM
    (
       ------begin of STS
    SELECT 
      C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      NVL(ST_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE 

      FROM POP_CLIN C
      LEFT OUTER JOIN SUB_CLIN SC
      ON (SC.CLIN_ID = C.CLIN_ID )
      INNER JOIN PERIOD_OF_PERFORMANCE POP
      ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
      INNER JOIN SUB_TASKS_CLINS W
      ON ( (W.CLIN_ID       = C.CLIN_ID  AND W.SUB_CLIN_ID     = SC.SUB_CLIN_ID) OR ( W.CLIN_ID        = C.CLIN_ID  AND (W.SUB_CLIN_ID   IS NULL   OR W.SUB_CLIN_ID      =0) ) )
      AND (W.WORK_ORDERS_ID = p_WORK_ORDERS_ID ) 
      AND (W.FK_Sub_Tasks_ID = P_SubTaskID)-- OR P_SubTaskID=0)
UNION
    SELECT 
       C.CLIN_ID,
      SC.sub_clin_id,
      C.CLIN_NUMBER,
      SC.SUB_CLIN_NUMBER,
      SC.SUB_CLIN_TYPE ,
      C.CLIN_TYPE ,
      'Labor' AS CLIN_TYPE_DISP,
      C.CLIN_SUB_CLIN ,
      C.CLIN_TITLE ,
      SC.SUB_CLIN_TITLE 
    FROM POP_CLIN C
    LEFT OUTER JOIN SUB_CLIN SC
    ON (SC.CLIN_ID = C.CLIN_ID)
    INNER JOIN PERIOD_OF_PERFORMANCE POP
    ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
    INNER JOIN ST_LABOR_CATEGORY W
    ON ( W.CLIN_ID = C.CLIN_ID
    OR ( W.CLIN_ID = SC.CLIN_ID ))
    INNER JOIN CLIN_LABOR_CATEGORY CLC
    ON CLC.LABOR_CATEGORY_ID    = W.LABOR_CATEGORY_ID
    AND CLC.CLIN_ID             = W.CLIN_ID
    AND (W.WORK_ORDERS_ID       = p_WORK_ORDERS_ID )
    AND (W.Sub_Tasks_ID = P_SubTaskID)-- OR P_SubTaskID=0)
    
    ------end of STS

    
    ) 
    TBLCLINS 
        
  WHERE ( CLIN_TYPE_DISP = p_clin_sub_type or p_clin_sub_type is NULL)    
  ORDER BY 1 ; 
 end if;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
      SELECT 
      0 
       SUB_CLIN_ID_DISP, 
       0 
       SUB_CLIN_NUMBER_DISP,              
      0 AS SUB_CLIN_DISP, 
      0  CLIN_TITLE_DISP, 
      0 CLIN_TYPE_DISP, 
      0 CLIN_ID, 
      0 sub_clin_id,
      0  CLIN_TYPE_ORIG
    FROM DUAL;

  END    SP_GET_TASK_STCLINS_LIST;

  PROCEDURE sp_get_inv_Monthly_Sums(
      p_userid     VARCHAR2 ,
      p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,
      p_contract_number invoice.contract_number%type ,
      rec_cursor OUT sys_refcursor)
        AS
    /*
    Procedure : sp_get_inv_Monthly_Sums
    Author: Sridhar Kommana
    Date Created : 06/23/2016
    Purpose: sp_get_inv_Monthly_Sums gets all invoice amounts by months
    Update history:
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.sp_get_inv_Monthly_Sums Get Invoice headers for p_UserId= '||P_Userid|| '  p_contract_number= '||p_contract_number|| '  p_period_of_performance_id= '||p_period_of_performance_id);
    OPEN Rec_Cursor FOR 
    SELECT TO_CHAR(i.invoice_date, 'MON YYYY') Month, POP.POP_TYPE,                 
                 sum(Id.Invoice_Amount) Invoice_Sum
            FROM Period_of_performance POP, Pop_Clin Pc, INVOICE I,Invoice_Detail Id  
            WHERE POP.PERIOD_OF_PERFORMANCE_ID=PC.PERIOD_OF_PERFORMANCE_ID
             AND Id.Clin_Id = Pc.Clin_Id
             AND I.Invoice_Id = Id.Invoice_Id
             AND POP.CONTRACT_NUMBER = P_Contract_Number --'DTFAWA-12-D-00011'
             AND (POP.PERIOD_OF_PERFORMANCE_ID = p_period_of_performance_id OR p_period_of_performance_id= 0 )--109
            group by TO_CHAR(i.invoice_date, 'MM YYYY'),TO_CHAR(i.invoice_date, 'MON YYYY'),POP.POP_TYPE 
            order by TO_CHAR(i.invoice_date, 'MM YYYY') ;     
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT NULL FROM Invoice ;
    
  END sp_get_inv_Monthly_Sums;

  PROCEDURE sp_delete_Draft_invoice
    (
      p_userid VARCHAR2 ,
      p_Invoice_Id IN invoice.Invoice_Id%type DEFAULT NULL,
      p_pstatus OUT VARCHAR2
    )
  AS
  BEGIN
    IF( p_Invoice_Id =0 OR p_Invoice_Id IS NULL ) THEN
      P_Pstatus            := 'Error deleting sp_delete_Draft_invoice '||' Cannot update record 0 or Null' ;
      RETURN;
    END IF;
    Sp_Insert_Audit( P_Userid,'PKG_INVOICE.sp_delete_Draft_invoice p_Invoice_Id= '||p_Invoice_Id);
    
    
    delete from Invoice 
    WHERE Invoice_Id = p_Invoice_Id
    AND status='Draft' 
     ;
    IF Sql%Found THEN
      P_Pstatus := 'SUCCESS' ;
      --ROLLBACK;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_Pstatus := 'Error deleting sp_delete_Draft_invoice '||Sqlerrm ;
    Sp_Insert_Audit( P_Userid,'Error PKG_INVOICE.sp_delete_Draft_invoice'||SQLERRM||  'p_Invoice_Id= '||p_Invoice_Id);
  END sp_delete_Draft_invoice;      
  
  PROCEDURE sp_get_Funding_Invoice_totals(
      p_userid     VARCHAR2 ,
      p_contract_number invoice.contract_number%type ,
      rec_cursor OUT sys_refcursor)
        AS
    /*
    Procedure : sp_get_Funding_Invoice_totals
    Author: Sridhar Kommana
    Date Created : 06/27/2016
    Purpose: sp_get_Funding_Invoice_totals gets total funding and invoice amounts by POP
    Update history:
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.sp_get_Funding_Invoice_totals Get Invoice headers for p_UserId= '||P_Userid|| '  p_contract_number= '||p_contract_number);--|| '  p_period_of_performance_id= '||p_period_of_performance_id);
    OPEN Rec_Cursor 
    FOR 
    SELECT POP.POP_TYPE ,                 
                 sum(Id.Invoice_Amount) Invoice_Sum,NVL( SUM(LWF.AMOUNT), 0 )  as ALLOCATED,  
                 NVL( SUM(LWF.AMOUNT), 0)  - NVL( sum(Id.Invoice_Amount),0) as Funding_Balance,
                 DC.Fiscal_Year
            FROM Period_of_performance POP, Pop_Clin Pc, INVOICE I,Invoice_Detail Id  , LSD_WO_FUNDS LWF ,DELPHI_CONTRACT_DETAIL DC 
            WHERE POP.PERIOD_OF_PERFORMANCE_ID=PC.PERIOD_OF_PERFORMANCE_ID
             AND Id.Clin_Id = Pc.Clin_Id
             AND I.Invoice_Id = Id.Invoice_Id             
             AND pop.contract_number= LWF.CONTRACT_NUMBER(+)
             AND DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND LWF.LSD = DC.LSD
             AND POP.CONTRACT_NUMBER = p_contract_number--'DTFAWA-12-D-00011'
            group by POP.POP_TYPE ,DC.Fiscal_Year  ;
        
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT NULL FROM Invoice ;
  END sp_get_Funding_Invoice_totals;     
  PROCEDURE sp_get_Est_Fund_Depletion_Dt(
      p_userid     VARCHAR2 ,
      p_contract_number invoice.contract_number%type ,
      rec_cursor OUT sys_refcursor)
        AS
       v_Months NUMBER:=0; 
       v_Avg_Monthly_spending  NUMBER:=0; 
       v_Remaining_Months NUMBER:=0; 
       v_Est_Deplition_date Date; 
    /*
    Procedure : sp_get_Est_Fund_Depletion_Dt
    Author: Sridhar Kommana
    Date Created : 06/29/2016
    Purpose: sp_get_Est_Fund_Depletion_Dt gets  Estimated Funding Depletion Date dashboard
    Update history:
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.sp_get_Est_Fund_Depletion_Dt Get Invoice headers for p_UserId= '||P_Userid|| '  p_contract_number= '||p_contract_number);--|| '  p_period_of_performance_id= '||p_period_of_performance_id);
    
    --Time Elapsed in Months since contract start date
          SELECT  months_between(sysdate, Pop.Start_Date ) 
          into v_Months 
          from Period_of_performance POP 
          WHERE
          POP.CONTRACT_NUMBER = p_contract_number
          AND POP_TYPE= 'Base';
    --Calculate Average Monthly spending
         select
            (
            select sum(Id.Invoice_Amount)  
            FROM Period_of_performance POP, Pop_Clin Pc, INVOICE I,Invoice_Detail Id  
            WHERE POP.PERIOD_OF_PERFORMANCE_ID = PC.PERIOD_OF_PERFORMANCE_ID
             AND Id.Clin_Id = Pc.Clin_Id
             AND I.Invoice_Id = Id.Invoice_Id             
             AND POP.CONTRACT_NUMBER = p_contract_number)
             /v_Months 
          into v_Avg_Monthly_spending 
          from dual; 
    --Calculate Months to go 
          select (
                SELECT NVL(SUM(LWF.AMOUNT), 0)  - NVL( sum(Id.Invoice_Amount),0)             
                  FROM Period_of_performance POP, Pop_Clin Pc, INVOICE I,Invoice_Detail Id  , LSD_WO_FUNDS LWF ,DELPHI_CONTRACT_DETAIL DC 
                  WHERE POP.PERIOD_OF_PERFORMANCE_ID = PC.PERIOD_OF_PERFORMANCE_ID
                   AND Id.Clin_Id = Pc.Clin_Id
                   AND I.Invoice_Id = Id.Invoice_Id             
                   AND pop.contract_number= LWF.CONTRACT_NUMBER(+)
                   AND DC.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND LWF.LSD = DC.LSD
                   AND POP.CONTRACT_NUMBER = p_contract_number) / v_Avg_Monthly_spending 
            into v_Remaining_Months       
            from dual;  
        select sysdate() + v_Remaining_Months
        into v_Est_Deplition_date
        from dual;
        
    OPEN Rec_Cursor 
    FOR 
    SELECT 
        ROUND(v_Months,2) as Months_Elapsed , ROUND(v_Avg_Monthly_spending,2)  as Avg_Monthly_spending, ROUND(v_Remaining_Months,2) as Remaining_Months, v_Est_Deplition_date as Est_Deplition_date
    FROM 
        DUAL;
        
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT NULL FROM Invoice ;
  END sp_get_Est_Fund_Depletion_Dt;    
PROCEDURE sp_get_invoice_detail_Item(
      p_userid            VARCHAR2 ,
      p_invoice_id        NUMBER ,
      p_invoice_detail_id NUMBER ,
      rec_cursor OUT sys_refcursor)  
  AS
    /*
    Procedure : sp_get_invoice_detail_Item
    Author: Sridhar Kommana
    Date Created : 07/07/2016
    Purpose: sp_get_invoice_detail_Item gets one invoice detail record 
    Update history:
    sridhar kommana :
    1) 07/06/2016: created
 
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.sp_get_invoice_detail_Item Get Invoice details for p_UserId= '||P_Userid|| '  P_Invoice_Detail_Id= '||P_Invoice_Detail_Id|| '  P_INVOICE_ID= '||P_Invoice_Id);
    OPEN Rec_Cursor 
    FOR 
    SELECT Invoice_Detail_Id, Id.Invoice_Id, Id.Work_Orders_Id, Work_Order_Number, Id.Sub_Tasks_Id, Sub_Task_Number, Id.Clin_Id, Clin_Number ,Clin_Title, Id.Sub_Clin_Id,
    Sub_Clin_Number, 
    DECODE(Clin_Sub_Clin, 'Y', Clin_Number ||Sub_Clin_Number,Clin_Number ) As Sub_Clin_Number_Disp,
    Id.Clin_Type, Labor_Category, Contract_Clin_Cost_Type,CONTRACTOR_ID, Contractor_Employee_Name, Invoice_Hours_Qty, Invoice_Rate, Id.Invoice_Amount, I.INVOICE_DUE_DATE
    ,Travel_Auth, id.Description, odc_auth
    FROM Invoice_Detail Id 
    JOIN INVOICE I ON I.Invoice_Id = Id.Invoice_Id
    left outer join Work_Orders Wc ON Id.Work_Orders_Id = Wc.Work_Orders_Id 
    LEFT OUTER JOIN Sub_Tasks St ON Id.Sub_Tasks_Id = St.Sub_Tasks_Id 
    Inner Join Pop_Clin Pc ON Id.Clin_Id = Pc.Clin_Id 
    LEFT OUTER Join Sub_Clin Sc ON Id.Sub_Clin_Id = Sc.Sub_Clin_Id 
    WHERE (Id.Invoice_Id = P_Invoice_Id )
      AND (Invoice_Detail_Id = P_Invoice_Detail_Id)
      Order By 1;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT 1 FROM Invoice_Detail ;
  END sp_get_invoice_detail_Item;

   PROCEDURE sp_get_Task_CLIN_LC_TITLE (p_user                VARCHAR2 DEFAULT NULL ,
                                   p_CLIN_ID             VARCHAR2 DEFAULT NULL ,
                                   p_sub_task            VARCHAR2 DEFAULT 'N' ,
                                   LC_TITLE_cursor   OUT SYS_REFCURSOR)
   IS
   /*
   Procedure : sp_get_Task_CLIN_LC_TITLE
   Author: Sridhar Kommana
   Date Created : 07/15/2016
   Purpose:  Get Task LCS
   Update history:Ad
   */
   BEGIN
      SP_INSERT_AUDIT (
         p_USER,
         'PKG_POP_CLIN.sp_get_Task_CLIN_LC_TITLE for p_CLIN_ID= ' || p_CLIN_ID || ' p_sub_task= ' || p_sub_task
      );

     
    
    IF p_sub_task = 'N' THEN     
     OPEN LC_TITLE_cursor FOR  
     SELECT   CLC.LABOR_CATEGORY_ID,
                    CLC.LABOR_CATEGORY_TITLE,
                    WLC.LABOR_CATEGORY_RATE,
                    CLC.LABOR_CATEGORY_HIGH_RATE,
                    CLC.LABOR_CATEGORY_LOW_RATE,
                    CLC.LC_RATE_TYPE
                    
             FROM   WO_LABOR_CATEGORY WLC, CLIN_LABOR_CATEGORY CLC
             WHERE WLC.CLIN_ID = CLC.CLIN_ID
             AND CLC.LABOR_CATEGORY_ID = WLC.LABOR_CATEGORY_ID
             AND   CLC.clin_id = p_CLIN_ID
         ORDER BY   2;
     ELSE
      OPEN LC_TITLE_cursor FOR
       SELECT   CLC.LABOR_CATEGORY_ID,
                    CLC.LABOR_CATEGORY_TITLE,
                    SLC.LABOR_CATEGORY_RATE,
                    CLC.LABOR_CATEGORY_HIGH_RATE,
                    CLC.LABOR_CATEGORY_LOW_RATE,
                    CLC.LC_RATE_TYPE
                    
             FROM   ST_LABOR_CATEGORY SLC, CLIN_LABOR_CATEGORY CLC
             WHERE SLC.CLIN_ID = CLC.CLIN_ID
             AND CLC.LABOR_CATEGORY_ID = SLC.LABOR_CATEGORY_ID
             AND   CLC.clin_id = p_CLIN_ID
         ORDER BY   2;
      END IF;         
         
   EXCEPTION
      WHEN OTHERS
      THEN
         OPEN LC_TITLE_cursor FOR
            SELECT NULL  LABOR_CATEGORY_ID,
                   NULL  LABOR_CATEGORY_TITLE,
                   NULL  LABOR_CATEGORY_RATE,
                   NULL  LABOR_CATEGORY_HIGH_RATE,
                   NULL  LABOR_CATEGORY_LOW_RATE,
                   NULL  LC_RATE_TYPE
              FROM   DUAL;
   END sp_get_Task_CLIN_LC_TITLE;      
END Pkg_Invoice;
/