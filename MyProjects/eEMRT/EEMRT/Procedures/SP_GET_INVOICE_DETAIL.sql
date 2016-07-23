CREATE OR REPLACE PROCEDURE eemrt.Sp_Get_Invoice_Detail(
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
    */
  BEGIN
    Sp_Insert_Audit(P_Userid, 'PKG_INVOICE.SP_GET_Invoice_detail Get Invoice details for p_UserId= '||P_Userid|| '  P_Invoice_Detail_Id= '||P_Invoice_Detail_Id|| '  P_INVOICE_ID= '||P_Invoice_Id  || 'P_Work_Orders_Id='||P_Work_Orders_Id ||' p_Sub_Tasks_Id='||p_Sub_Tasks_Id);
    OPEN Rec_Cursor 
    FOR 
    SELECT Invoice_Detail_Id, Id.Invoice_Id, Id.Work_Orders_Id, Work_Order_Number, Id.Sub_Tasks_Id, Sub_Task_Number, Id.Clin_Id, Clin_Number ,Clin_Title, Id.Sub_Clin_Id,
    Sub_Clin_Number, 
    DECODE(Clin_Sub_Clin, 'Y', Clin_Number ||Sub_Clin_Number,Clin_Number ) As Sub_Clin_Number_Disp,
    Id.Clin_Type, Labor_Category, Contract_Clin_Cost_Type,CONTRACTOR_ID, Contractor_Employee_Name, Invoice_Hours_Qty, Invoice_Rate, Id.Invoice_Amount, 
    I.INVOICE_DUE_DATE, Travel_Auth, id.Description, odc_auth
    FROM Invoice_Detail Id 
    INNER JOIN INVOICE I ON I.Invoice_Id = Id.Invoice_Id
    left outer join Work_Orders Wc ON Id.Work_Orders_Id = Wc.Work_Orders_Id 
    LEFT OUTER JOIN Sub_Tasks St ON Id.Sub_Tasks_Id = St.Sub_Tasks_Id 
    Inner Join Pop_Clin Pc ON Id.Clin_Id = Pc.Clin_Id 
    LEFT OUTER Join Sub_Clin Sc ON Id.Sub_Clin_Id = Sc.Sub_Clin_Id 
    WHERE (Id.Invoice_Id = P_Invoice_Id )--OR P_Invoice_Id= 0) 
      AND (Invoice_Detail_Id = P_Invoice_Detail_Id OR P_Invoice_Detail_Id= 0)
      AND (wc.Work_Orders_Id = 0)-- OR P_Work_Orders_Id= 0)
     -- AND (st.Sub_Tasks_Id = p_Sub_Tasks_Id)-- OR p_Sub_Tasks_Id= 0)
      Order By 1;
  EXCEPTION
  WHEN OTHERS THEN
    OPEN Rec_Cursor FOR SELECT 1 FROM Invoice_Detail ;
  END Sp_Get_Invoice_Detail;
/