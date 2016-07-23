CREATE OR REPLACE PACKAGE eemrt."PKG_INVOICE" 
AS
  /*
  Procedure : PKG_INVOICE
  Author: Sridhar Kommana
  Date Created : 11/24/2015
  Purpose:  All procedures and functions related to Invoice.
  Update history:
  sridhar kommana :
  1) 11/24/2015 : created
  */
  PROCEDURE sp_get_invoice(
      p_userid     VARCHAR2 ,
      p_invoice_id NUMBER DEFAULT 0 ,
      p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,
      p_contract_number invoice.contract_number%type DEFAULT NULL,
      rec_cursor OUT sys_refcursor);
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
      p_invoice_received_date    IN invoice.invoice_received_date%TYPE,
      p_invoice_due_date         IN INVOICE.INVOICE_DUE_DATE%TYPE,
      p_Temp_Entity_id         IN INVOICE.Temp_Entity_id%TYPE DEFAULT NULL ,      
      
      p_id OUT invoice.Invoice_Id%type,
      p_pstatus OUT VARCHAR2 ) ;
  PROCEDURE sp_update_invoice(
      p_userid VARCHAR2 ,      
      p_Invoice_Id          IN invoice.Invoice_Id%TYPE,
      p_invoice_number           IN invoice.invoice_number%TYPE,
      p_invoice_date             IN invoice.invoice_date%TYPE,
      p_invoice_period_from      IN invoice.invoice_period_from%TYPE,
      p_invoice_period_to        IN invoice.invoice_period_to%TYPE,
      p_invoice_amount           IN invoice.invoice_amount%TYPE,
      p_status IN invoice.status%TYPE,      
      p_invoice_received_date    IN invoice.invoice_received_date%TYPE,      
      p_invoice_due_date         IN INVOICE.INVOICE_DUE_DATE%TYPE,
      p_pstatus OUT VARCHAR2 ) ;
  PROCEDURE sp_get_invoice_detail(
      p_userid            VARCHAR2 DEFAULT NULL ,
      p_invoice_id        NUMBER ,
      p_invoice_detail_id NUMBER DEFAULT 0 ,
      P_Work_Orders_Id NUMBER DEFAULT 0,
      p_Sub_Tasks_Id NUMBER DEFAULT 0,      
      rec_cursor OUT sys_refcursor);
  PROCEDURE sp_get_invoice_detail_Item(
      p_userid            VARCHAR2 ,
      p_invoice_id        NUMBER ,
      p_invoice_detail_id NUMBER ,
      rec_cursor OUT sys_refcursor);      
   PROCEDURE sp_get_invoice_View_detail(
      p_userid            VARCHAR2 DEFAULT NULL ,
      p_invoice_id        NUMBER ,
      p_invoice_detail_id NUMBER DEFAULT 0 ,
      P_Work_Orders_Id NUMBER DEFAULT 0,
      p_Sub_Tasks_Id NUMBER DEFAULT 0,      
      rec_cursor OUT sys_refcursor); 
  PROCEDURE Sp_Get_Invoice_Charge_Totals(
      P_Userid       VARCHAR2 DEFAULT NULL ,
      P_Invoice_Id   NUMBER ,
      P_Cost_Type    VARCHAR2 DEFAULT NULL ,
      Rec_Cursor OUT Sys_Refcursor);
      
  PROCEDURE sp_get_invoice_detail_session(
      p_userid            VARCHAR2 ,
      p_invoice_id        NUMBER ,
      p_invoice_detail_id NUMBER DEFAULT 0 ,
      rec_cursor OUT sys_refcursor);
  PROCEDURE sp_insert_inv_detail_session(
      p_userid VARCHAR2 ,
      p_invoice_id               IN invoice_detail_session.invoice_id%type DEFAULT NULL,
      p_work_orders_id           IN invoice_detail_session.work_orders_id%type DEFAULT NULL,
      p_sub_tasks_id             IN invoice_detail_session.sub_tasks_id%type DEFAULT NULL,
      p_clin_id                  IN invoice_detail_session.clin_id%type DEFAULT NULL,
      p_sub_clin_id              IN invoice_detail_session.sub_clin_id%type DEFAULT NULL,
      p_clin_type                IN invoice_detail_session.clin_type%type DEFAULT NULL,
      p_labor_category           IN invoice_detail_session.labor_category%type DEFAULT NULL,
      p_contract_clin_cost_type  IN invoice_detail_session.contract_clin_cost_type%type DEFAULT NULL,
      p_CONTRACTOR_ID IN invoice_detail_session.CONTRACTOR_ID%Type DEFAULT NULL,
      p_contractor_employee_name IN invoice_detail_session.contractor_employee_name%type DEFAULT NULL,
      p_invoice_hours_qty        IN invoice_detail_session.invoice_hours_qty%type DEFAULT NULL,
      p_invoice_rate             IN invoice_detail_session.invoice_rate%type DEFAULT NULL,
      p_invoice_amount           IN invoice_detail_session.invoice_amount%type DEFAULT NULL,
      p_id OUT invoice_detail_session.Invoice_Detail_Id%type,
      p_pstatus OUT VARCHAR2 );
  PROCEDURE Move_invoice_SESSION
    (
      p_invoice_id           IN invoice_detail_session.invoice_id%TYPE DEFAULT NULL,
      p_CREATED_BY           IN invoice_detail_session.CREATED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    );   

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
   p_ODC_Auth                IN     invoice_detail.ODC_Auth%TYPE DEFAULT NULL,
   p_id                            OUT invoice_detail_session.Invoice_Detail_Id%TYPE,
   p_pstatus                       OUT VARCHAR2);
  PROCEDURE sp_update_inv_detail(
      p_userid VARCHAR2 ,
      p_Invoice_Detail_Id IN invoice_detail.Invoice_Detail_Id%type DEFAULT NULL,
      p_invoice_hours_qty IN invoice_detail.invoice_hours_qty%type DEFAULT NULL,
      p_invoice_rate      IN invoice_detail.invoice_rate%type DEFAULT NULL,
      p_invoice_amount    IN invoice_detail.invoice_amount%type DEFAULT NULL,
      p_pstatus OUT VARCHAR2 ) ;
  PROCEDURE sp_delete_inv_detail
    (
      p_userid VARCHAR2 ,
      p_Invoice_Detail_Id IN invoice_detail.Invoice_Detail_Id%type DEFAULT NULL,
      p_pstatus OUT VARCHAR2
    );      
PROCEDURE SP_GET_TASK_STCLINS(
    p_UserId         VARCHAR2,
    P_SubTaskID      NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0  ,    
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,    
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,         
    REC_CURSOR OUT SYS_REFCURSOR);    
    
  PROCEDURE delete_invoice_SESSION
    (
      p_CREATED_BY           IN invoice_detail_session.CREATED_BY%TYPE ,
      p_PStatus OUT VARCHAR2
    );
    
PROCEDURE SP_GET_INV_POP_CLINS(
    p_UserId         VARCHAR2,
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,   
    p_contract_number invoice.contract_number%type DEFAULT NULL,  
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,  
    REC_CURSOR OUT SYS_REFCURSOR);    
PROCEDURE SP_GET_INV_LTMO_CLINS(
    p_UserId         VARCHAR2,
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,   
    p_contract_number invoice.contract_number%type DEFAULT NULL,  
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,  
    REC_CURSOR OUT SYS_REFCURSOR);   
  PROCEDURE SP_GET_TASK_STCLINS_LIST(
    p_UserId         VARCHAR2,
    P_SubTaskID      NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0  ,    
    p_period_of_performance_id IN invoice.period_of_performance_id%TYPE,    
    p_clin_sub_type  invoice_detail.clin_type%type DEFAULT NULL,     
    REC_CURSOR OUT SYS_REFCURSOR);
  PROCEDURE sp_get_inv_Monthly_Sums(
      p_userid     VARCHAR2 ,
      p_period_of_performance_id IN invoice.period_of_performance_id%TYPE  DEFAULT 0,
      p_contract_number invoice.contract_number%type,
      rec_cursor OUT sys_refcursor);
  PROCEDURE sp_delete_Draft_invoice
    (
      p_userid VARCHAR2 ,
      p_Invoice_Id IN invoice.Invoice_Id%type DEFAULT NULL,
      p_pstatus OUT VARCHAR2
    );         
  PROCEDURE sp_get_Funding_Invoice_totals(
      p_userid     VARCHAR2 ,
      p_contract_number invoice.contract_number%type,
      rec_cursor OUT sys_refcursor);    
  PROCEDURE sp_get_Est_Fund_Depletion_Dt(
      p_userid     VARCHAR2 ,
      p_contract_number invoice.contract_number%type,
      rec_cursor OUT sys_refcursor);
  PROCEDURE sp_get_Task_CLIN_LC_TITLE (
                                   p_user                VARCHAR2 DEFAULT NULL ,
                                   p_CLIN_ID             VARCHAR2 DEFAULT NULL ,
                                   p_sub_task            VARCHAR2 DEFAULT 'N' ,
                                   LC_TITLE_cursor   OUT SYS_REFCURSOR);
END pkg_invoice;
/