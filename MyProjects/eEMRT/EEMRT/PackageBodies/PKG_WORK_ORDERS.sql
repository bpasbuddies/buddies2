CREATE OR REPLACE PACKAGE BODY eemrt.pkg_work_orders
IS
  /*
  Procedure : pkg_work_orders
  Author: Sridhar Kommana
  Date Created : 11/14/2014
  Purpose:  Insert Update Delete Work Order records for eCert
  Update history:
 
*/

  -- insert_work_orders insert
  PROCEDURE insert_work_orders( ---Inserting Both Work Order and  Clin and SubClin
      p_WORK_ORDER_NUMBER        IN work_orders.WORK_ORDER_NUMBER%TYPE DEFAULT NULL,
      p_WORK_ORDER_TITLE         IN work_orders.WORK_ORDER_TITLE%TYPE DEFAULT NULL,
      p_START_DATE               IN work_orders.START_DATE%TYPE DEFAULT NULL,
      p_END_DATE                 IN work_orders.END_DATE%TYPE DEFAULT NULL,
      p_DESCRIPTION              IN work_orders.DESCRIPTION%TYPE DEFAULT NULL,
      p_ORGANIZATION             IN work_orders.ORGANIZATION%TYPE DEFAULT NULL,
      p_FAA_POC                  IN work_orders.FAA_POC%TYPE DEFAULT NULL,
      p_PERIOD_OF_PERFORMANCE_ID IN work_orders.PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL,
      p_Status                   IN work_orders.Status%TYPE DEFAULT NULL,
      p_WO_FEE                   IN work_orders.WO_FEE%TYPE DEFAULT 0,
      p_Sub_Task                 IN work_orders.sub_task%TYPE DEFAULT NULL,
      p_CLINS                    IN VARCHAR2 DEFAULT NULL,
      p_SUB_CLINS                IN VARCHAR2 DEFAULT NULL,
      p_CLIN_HOURS               IN VARCHAR2 DEFAULT NULL, ---Added by Sridhar on 02062015
      p_CLIN_AMOUNT              IN VARCHAR2 DEFAULT NULL, ---Added by Sridhar on 02062015
      p_CREATED_BY               IN work_orders.CREATED_BY%TYPE DEFAULT NULL,
      p_ID OUT work_orders.WORK_ORDERS_ID%TYPE,
      p_PStatus OUT VARCHAR2 )
  IS
    v_array_clin_id apex_application_global.vc_arr2;
    v_array_subclin_id apex_application_global.vc_arr2;
    v_array_clin_hrs apex_application_global.vc_arr2;
    v_array_clin_amt apex_application_global.vc_arr2;
    v_Temp_id NUMBER := WORK_ORDER_SEQ.NEXTVAL;
  BEGIN
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.insert_work_orders*');
    INSERT
    INTO work_orders
      (
        WORK_ORDERS_ID,
        WORK_ORDER_NUMBER,
        WORK_ORDER_TITLE,
        START_DATE,
        END_DATE,
        DESCRIPTION,
        ORGANIZATION,
        FAA_POC,
        PERIOD_OF_PERFORMANCE_ID,
        Status,
        WO_FEE,
        sub_task,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        v_Temp_id,
        p_WORK_ORDER_NUMBER,
        p_WORK_ORDER_TITLE,
        p_START_DATE,
        p_END_DATE,
        p_DESCRIPTION,
        REPLACE(p_ORGANIZATION,';;'';'),
        p_FAA_POC,
        p_PERIOD_OF_PERFORMANCE_ID,
        p_Status,
        p_WO_FEE,
        p_sub_task,
        p_CREATED_BY,
        sysdate()
      );
    p_ID := v_Temp_id;
  /*  --  type t_clin_id is table of WORK_ORDERS_CLINS.CLIN_ID%type index by pls_integer;
    ---type t_sub_clin_id is table of WORK_ORDERS_CLINS.SUB_CLIN_ID%type index by pls_integer;
    v_array_clin_id    := apex_util.string_to_table(p_CLINS, ',');
    v_array_subclin_id := apex_util.string_to_table(p_SUB_CLINS, ',');
    v_array_clin_hrs   := apex_util.string_to_table(p_CLIN_HOURS, ',');
    v_array_clin_amt   := apex_util.string_to_table(p_CLIN_AMOUNT, ',');
    forall i IN 1..v_array_clin_id.count
    INSERT
    INTO WORK_ORDERS_CLINS
      (
        WOC_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        WORK_ORDERS_CLINS_SEQ.NEXTVAL,
        v_Temp_id,
        p_PERIOD_OF_PERFORMANCE_ID,
        v_array_clin_id(i),
        v_array_clin_hrs(i),
        v_array_clin_amt(i),
        p_CREATED_BY,
        sysdate()
      );
    forall i IN 1..v_array_subclin_id.count
    INSERT
    INTO WORK_ORDERS_CLINS
      (
        WOC_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        WORK_ORDERS_CLINS_SEQ.NEXTVAL,
        v_Temp_id,
        p_PERIOD_OF_PERFORMANCE_ID,
        v_array_subclin_id(i),
        v_array_clin_hrs(i),
        v_array_clin_amt(i),
        p_CREATED_BY,
        sysdate()
      );*/
    IF SQL%FOUND THEN
      SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.insert_work_orders'||' Created  work_orders with p_WORK_ORDER_NUMBER ='||p_WORK_ORDER_NUMBER);
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN 
   p_ID := 0;
    ROLLBACK;
    p_PStatus := 'Error adding Task order, Task order number ' ||P_WORK_ORDER_NUMBER ||'  is already used. ';
      SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.insert_work_orders'||' Attempt to create  work_orders with WORK_ORDER_NUMBER ='||p_WORK_ORDER_NUMBER);  
  WHEN OTHERS THEN
   p_ID := 0;
    ROLLBACK;
    p_PStatus := 'Error inserting work_orders '||SQLERRM ;
  END insert_work_orders;
  PROCEDURE insert_woc_clinS
    ( ---Inserting only Clin and SubClin
      p_FK_WORK_ORDERS_ID        IN work_orders_clins.FK_WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_PERIOD_OF_PERFORMANCE_ID IN work_orders.PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL,
      p_CLINS                    IN VARCHAR2 DEFAULT NULL,
      p_SUB_CLINS                IN VARCHAR2 DEFAULT NULL,
      p_CLIN_HOURS               IN VARCHAR2 DEFAULT NULL, ---Added by Sridhar on 02062015
      p_CLIN_AMOUNT              IN VARCHAR2 DEFAULT NULL, ---Added by Sridhar on 02062015
      p_CREATED_BY               IN work_orders.CREATED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
    v_array_clin_id apex_application_global.vc_arr2;
    v_array_subclin_id apex_application_global.vc_arr2;
    v_array_clin_hrs apex_application_global.vc_arr2;
    v_array_clin_amt apex_application_global.vc_arr2;
    v_Temp_id NUMBER := WORK_ORDER_SEQ.NEXTVAL;
  BEGIN
    v_array_clin_id    := apex_util.string_to_table(p_CLINS, ',');
    v_array_subclin_id := apex_util.string_to_table(p_SUB_CLINS, ',');
    v_array_clin_hrs   := apex_util.string_to_table(p_CLIN_HOURS, ',');
    v_array_clin_amt   := apex_util.string_to_table(p_CLIN_AMOUNT, ',');
    forall i IN 1..v_array_clin_id.count
    INSERT
    INTO WORK_ORDERS_CLINS
      (
        WOC_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        WORK_ORDERS_CLINS_SEQ.NEXTVAL,
        p_FK_WORK_ORDERS_ID,
        p_PERIOD_OF_PERFORMANCE_ID,
        v_array_clin_id(i),
        v_array_clin_hrs(i),
        v_array_clin_amt(i),
        p_CREATED_BY,
        sysdate()
      );
    forall i IN 1..v_array_subclin_id.count
    INSERT
    INTO WORK_ORDERS_CLINS
      (
        WOC_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        WORK_ORDERS_CLINS_SEQ.NEXTVAL,
        v_Temp_id,
        p_PERIOD_OF_PERFORMANCE_ID,
        v_array_subclin_id(i),
        v_array_clin_hrs(i),
        v_array_clin_amt(i),
        p_CREATED_BY,
        sysdate()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error inserting work_orders '||SQLERRM ;
  END insert_woc_clinS;
-- Update_work_order_clin
  PROCEDURE update_clin_amounts
    (
      p_WOC_ID           IN VARCHAR2 DEFAULT NULL,
      p_CLIN_HOURS       IN VARCHAR2 DEFAULT NULL,
      p_CLIN_AMOUNT      IN VARCHAR2 DEFAULT NULL,
      p_LAST_MODIFIED_BY IN WORK_ORDERS_CLINS.LAST_MODIFIED_BY%type DEFAULT 'SYS' ,
      p_PStatus OUT VARCHAR2
    )
  IS
    v_array_woc_id apex_application_global.vc_arr2;
    v_array_clin_hrs apex_application_global.vc_arr2;
    v_array_clin_amt apex_application_global.vc_arr2;
    
  BEGIN
  SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'pkg_work_orders.update_clin_amounts p_WOC_ID= '||p_WOC_ID||' p_CLIN_HOURS='||p_CLIN_HOURS||'  p_CLIN_AMOUNT='||p_CLIN_AMOUNT);    
    v_array_woc_id   := apex_util.string_to_table(p_WOC_ID, ',');
    v_array_clin_hrs := apex_util.string_to_table(p_CLIN_HOURS, ',');
    v_array_clin_amt := apex_util.string_to_table(p_CLIN_AMOUNT, ',');
    forall i IN 1..v_array_woc_id.count
    UPDATE WORK_ORDERS_CLINS
    SET CLIN_HOURS     = v_array_clin_hrs(i),
      CLIN_AMOUNT      = v_array_clin_amt(i),
      LAST_MODIFIED_BY = p_LAST_MODIFIED_BY,
      LAST_MODIFIED_ON = Sysdate()
    WHERE WOC_ID       = v_array_woc_id(i);
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    ROLLBACK;
    SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'pkg_work_orders.update_clin_amounts Error: '||SQLERRM||' p_WOC_ID= '||p_WOC_ID||' p_CLIN_HOURS='||p_CLIN_HOURS||'  p_CLIN_AMOUNT='||p_CLIN_AMOUNT);     
    p_PStatus := 'Error updating update_clin_amounts '||SQLERRM ;
  END update_clin_amounts;
-- Update_work_order_clin
  PROCEDURE update_clin_id_amounts(
      p_WOC_ID           IN VARCHAR2 DEFAULT NULL,
      p_CLINS            IN VARCHAR2 DEFAULT NULL, ---comma seperated clinid
      p_SUB_CLINS        IN VARCHAR2 DEFAULT NULL,
      p_CLIN_HOURS       IN VARCHAR2 DEFAULT NULL,
      p_CLIN_AMOUNT      IN VARCHAR2 DEFAULT NULL,
      p_LAST_MODIFIED_BY IN WORK_ORDERS_CLINS.LAST_MODIFIED_BY%type DEFAULT 'SYS' ,
      p_PStatus OUT VARCHAR2)
  IS
    v_array_woc_id apex_application_global.vc_arr2;
    v_array_clin_id apex_application_global.vc_arr2;
    v_array_sub_clin_id apex_application_global.vc_arr2;
    v_array_clin_hrs apex_application_global.vc_arr2;
    v_array_clin_amt apex_application_global.vc_arr2;
  BEGIN
    v_array_woc_id      := apex_util.string_to_table(p_WOC_ID, ',');
    v_array_clin_id     := apex_util.string_to_table(p_CLINS, ',');
    v_array_sub_clin_id := apex_util.string_to_table(p_SUB_CLINS, ',');
    v_array_clin_hrs    := apex_util.string_to_table(p_CLIN_HOURS, ',');
    v_array_clin_amt    := apex_util.string_to_table(p_CLIN_AMOUNT, ',');
    forall i IN 1..v_array_woc_id.count
    UPDATE WORK_ORDERS_CLINS
    SET CLIN_ID        = v_array_clin_id(i),
      SUB_CLIN_ID      = v_array_sub_clin_id(i),
      CLIN_HOURS       = v_array_clin_hrs(i),
      CLIN_AMOUNT      = v_array_clin_amt(i),
      LAST_MODIFIED_BY = p_LAST_MODIFIED_BY,
      LAST_MODIFIED_ON = Sysdate()
    WHERE WOC_ID       = v_array_woc_id(i);
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error updating work_orders '||SQLERRM ;
  END update_clin_id_amounts;
  PROCEDURE insert_WORK_ORDERS_CLINS(
      p_WORK_ORDERS_ID           IN WORK_ORDERS_CLINS.FK_WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_PERIOD_OF_PERFORMANCE_ID IN WORK_ORDERS_CLINS.FK_PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL,
      p_CLIN_ID                  IN WORK_ORDERS_CLINS.CLIN_ID%TYPE DEFAULT NULL,
      p_SUB_CLIN_ID              IN WORK_ORDERS_CLINS.SUB_CLIN_ID%TYPE DEFAULT NULL,
      p_CLIN_HOURS               IN WORK_ORDERS_CLINS.CLIN_HOURS%TYPE DEFAULT NULL,
      p_CLIN_AMOUNT              IN WORK_ORDERS_CLINS.CLIN_AMOUNT%TYPE DEFAULT NULL,
      P_WO_CLIN_TYPE             IN WORK_ORDERS_CLINS.WO_CLIN_TYPE%TYPE DEFAULT  NULL,
      P_WO_Rate                  IN WORK_ORDERS_CLINS.WO_Rate%TYPE DEFAULT  NULL,      
      p_CREATED_BY               IN WORK_ORDERS_CLINS.CREATED_BY%TYPE DEFAULT NULL,
      p_ID OUT WORK_ORDERS_CLINS.WOC_ID%TYPE, ---Added by Sridhar on 02062015
      p_PStatus OUT VARCHAR2 )
  IS
    v_WOC_ID NUMBER:=0;
  BEGIN
    IF( p_WORK_ORDERS_ID =0 OR p_WORK_ORDERS_ID IS NULL ) THEN
      p_PStatus         := 'Error inserting WORK_ORDERS_CLINS '||' Cannot insert 0 or Null' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.insert_WORK_ORDERS_CLINS p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID||' p_CLIN_HOURS='||p_CLIN_HOURS||'  p_CLIN_AMOUNT='||p_CLIN_AMOUNT);
    v_WOC_ID := WORK_ORDERS_CLINS_SEQ.NEXTVAL;
    INSERT
    INTO WORK_ORDERS_CLINS
      (
        WOC_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        WO_CLIN_TYPE,
        WO_Rate,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        v_WOC_ID ,
        p_WORK_ORDERS_ID,
        p_PERIOD_OF_PERFORMANCE_ID,
        p_CLIN_ID,
        p_SUB_CLIN_ID,
        p_CLIN_HOURS,
        p_CLIN_AMOUNT,
        P_WO_CLIN_TYPE,
        P_WO_Rate,
        p_CREATED_BY,
        sysdate()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      p_ID      := v_WOC_ID;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error inserting WORK_ORDERS_CLINS '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.insert_WORK_ORDERS_CLINS'||'||SQLERRM|| p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID||' p_CLIN_HOURS='||p_CLIN_HOURS||'  p_CLIN_AMOUNT='||p_CLIN_AMOUNT);
  END;
  PROCEDURE insert_WO_CLINS_SESSION
    (
      p_Sub_Tasks_ID             IN WORK_ORDERS_CLINS_SESSION.SUB_TASKS_ID%TYPE DEFAULT NULL,
      p_WORK_ORDERS_ID           IN WORK_ORDERS_CLINS_SESSION.FK_WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_PERIOD_OF_PERFORMANCE_ID IN WORK_ORDERS_CLINS_SESSION.FK_PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL,
      p_CLIN_ID                  IN WORK_ORDERS_CLINS_SESSION.CLIN_ID%TYPE DEFAULT NULL,
      p_SUB_CLIN_ID              IN WORK_ORDERS_CLINS_SESSION.SUB_CLIN_ID%TYPE DEFAULT NULL,
      p_CLIN_HOURS               IN WORK_ORDERS_CLINS_SESSION.CLIN_HOURS%TYPE DEFAULT NULL,
      p_CLIN_AMOUNT              IN WORK_ORDERS_CLINS_SESSION.CLIN_AMOUNT%TYPE DEFAULT NULL,
      P_WO_CLIN_TYPE             IN WORK_ORDERS_CLINS.WO_CLIN_TYPE%TYPE DEFAULT  NULL,
      P_WO_Rate                  IN WORK_ORDERS_CLINS.WO_Rate%TYPE DEFAULT  NULL,      
      p_CREATED_BY               IN WORK_ORDERS_CLINS_SESSION.CREATED_BY%TYPE DEFAULT NULL,
      p_ID OUT WORK_ORDERS_CLINS_SESSION.WOC_ID%TYPE, ---Added by Sridhar on 02062015
      p_PStatus OUT VARCHAR2
    )
  IS
    v_WOC_ID NUMBER:=0;
  BEGIN
    IF( p_WORK_ORDERS_ID =0 OR p_WORK_ORDERS_ID IS NULL ) THEN
      p_PStatus         := 'Error inserting WORK_ORDERS_CLINS_SESSION '||' Cannot insert 0 or Null' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.insert_WO_CLINS_SESSION p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID||' p_CLIN_HOURS='||p_CLIN_HOURS||'  p_CLIN_AMOUNT='||p_CLIN_AMOUNT);
    v_WOC_ID := WORK_ORDERS_CLINS_SEQ.NEXTVAL;
    INSERT
    INTO WORK_ORDERS_CLINS_SESSION
      (
        WOC_ID,
        Sub_Tasks_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        WO_CLIN_TYPE,
        WO_Rate,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        v_WOC_ID ,
        p_Sub_Tasks_ID,
        p_WORK_ORDERS_ID,
        p_PERIOD_OF_PERFORMANCE_ID,
        p_CLIN_ID,
        p_SUB_CLIN_ID,
        p_CLIN_HOURS,
        p_CLIN_AMOUNT,
        P_WO_CLIN_TYPE,
        P_WO_Rate,
        p_CREATED_BY,
        sysdate()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      p_ID      := v_WOC_ID;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error inserting WORK_ORDERS_CLINS_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.insert_WORK_ORDERS_CLINS_SESSION'||'||SQLERRM|| p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID||' p_CLIN_HOURS='||p_CLIN_HOURS||'  p_CLIN_AMOUNT='||p_CLIN_AMOUNT);
  END insert_WO_CLINS_SESSION;
  PROCEDURE Move_WO_CLINS_SESSION
    (
      p_WORK_ORDERS_ID           IN WORK_ORDERS_CLINS_SESSION.FK_WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_PERIOD_OF_PERFORMANCE_ID IN WORK_ORDERS_CLINS_SESSION.FK_PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL,
      p_CREATED_BY               IN WORK_ORDERS_CLINS_SESSION.CREATED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
    v_WOC_ID NUMBER:=0;
  BEGIN
    IF( p_WORK_ORDERS_ID =0 OR p_WORK_ORDERS_ID IS NULL ) THEN
      p_PStatus         := 'Error moving  WORK_ORDERS_CLINS_SESSION '||' Cannot move with no id' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.Move_WO_CLINS_SESSION p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID );
    INSERT
    INTO WORK_ORDERS_CLINS(        WOC_ID,
        --Sub_Tasks_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        WO_CLIN_TYPE,
        WO_Rate,
        CREATED_BY,
        CREATED_ON)
      SELECT         WOC_ID,
      --  Sub_Tasks_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        WO_CLIN_TYPE,
        WO_Rate,
        CREATED_BY,
        CREATED_ON
        FROM WORK_ORDERS_CLINS_SESSION
        WHERE CREATED_BY      = p_CREATED_BY
        AND FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID
      ;
    DELETE WORK_ORDERS_CLINS_SESSION
    WHERE CREATED_BY      = p_CREATED_BY
    AND FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID ;

    Move_WO_LC_SESSION(p_WORK_ORDERS_ID, p_CREATED_BY, p_PStatus);
    
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error moving WORK_ORDERS_CLINS_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.Move_WO_CLINS_SESSION'||'||SQLERRM|| p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID );
  END Move_WO_CLINS_SESSION;
--Delete_WO_CLINS_SESSION
  PROCEDURE Delete_WO_CLINS_SESSION(
      p_CREATED_BY IN WORK_ORDERS_CLINS_SESSION.CREATED_BY%TYPE ,
      p_PStatus OUT VARCHAR2 )
  IS
    v_WOC_ID NUMBER:=0;
  BEGIN
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.Delete_WO_CLINS_SESSION p_CREATED_BY= '||p_CREATED_BY );
    --Delete all temp wo clins
    DELETE WORK_ORDERS_CLINS_SESSION
    WHERE CREATED_BY = p_CREATED_BY ;
    Delete_WO_LC_SESSION(p_CREATED_BY, p_PStatus ) ;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error deleting WORK_ORDERS_CLINS_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.Delete_WO_CLINS_SESSION'||'||SQLERRM|| p_CREATED_BY= '||p_CREATED_BY );
  END Delete_WO_CLINS_SESSION;
-- update_work_ordersate
  PROCEDURE update_work_orders(
      p_work_orders_ID    IN work_orders.work_orders_ID%type ,
      p_WORK_ORDER_NUMBER IN work_orders.WORK_ORDER_NUMBER%TYPE DEFAULT NULL,
      p_WORK_ORDER_TITLE  IN work_orders.WORK_ORDER_TITLE%TYPE DEFAULT NULL,
      p_START_DATE        IN work_orders.START_DATE%TYPE DEFAULT NULL,
      p_END_DATE          IN work_orders.END_DATE%TYPE DEFAULT NULL,
      p_DESCRIPTION       IN work_orders.DESCRIPTION%TYPE DEFAULT NULL,
      p_ORGANIZATION      IN work_orders.ORGANIZATION%TYPE DEFAULT NULL,
      p_FAA_POC           IN work_orders.FAA_POC%TYPE DEFAULT NULL,
      p_Status            IN work_orders.Status%TYPE DEFAULT NULL,
      p_WO_FEE            IN work_orders.WO_FEE%TYPE DEFAULT 0,
      p_Sub_Task          IN work_orders.sub_task%TYPE DEFAULT NULL,
      p_LAST_MODIFIED_BY  IN work_orders.LAST_MODIFIED_BY%type DEFAULT NULL ,
      p_PStatus OUT VARCHAR2 )
  IS
  BEGIN
    SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'pkg_work_orders.update_work_orders p_ORGANIZATION='||p_ORGANIZATION);
    UPDATE work_orders
    SET WORK_ORDER_NUMBER = p_WORK_ORDER_NUMBER,
      WORK_ORDER_TITLE    = p_WORK_ORDER_TITLE,
      START_DATE          = p_START_DATE,
      END_DATE            = p_END_DATE,
      DESCRIPTION         = p_DESCRIPTION,
      ORGANIZATION        = REPLACE(p_ORGANIZATION,';;'';'),
      FAA_POC             = p_FAA_POC,
      Status              = p_Status,
      WO_FEE              = p_WO_FEE,
      Sub_task            = p_sub_task,
      LAST_MODIFIED_BY    = p_LAST_MODIFIED_BY,
      LAST_MODIFIED_ON    = Sysdate()
    WHERE work_orders_ID  = p_work_orders_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN 
   
    ROLLBACK;
    p_PStatus := 'Error updating Task order, Task order number ' ||P_WORK_ORDER_NUMBER ||'  is already used. ';
      SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'pkg_work_orders.update_work_orders'||' Attempt to create  work_orders with WORK_ORDER_NUMBER ='||p_WORK_ORDER_NUMBER);  
  
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error updating work_orders '||SQLERRM ;
  END;
-- update_work_ordersate
  PROCEDURE update_WORK_ORDERS_CLINS(
      p_WOC_ID           IN WORK_ORDERS_CLINS.WOC_ID%TYPE,
      p_CLIN_HOURS       IN WORK_ORDERS_CLINS.CLIN_HOURS%TYPE DEFAULT NULL,
      p_CLIN_AMOUNT      IN WORK_ORDERS_CLINS.CLIN_AMOUNT%TYPE DEFAULT NULL,
      p_LAST_MODIFIED_BY IN WORK_ORDERS_CLINS.LAST_MODIFIED_BY%type DEFAULT NULL ,
      p_PStatus OUT VARCHAR2 )
  IS
  BEGIN
    SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'pkg_work_orders.update_WORK_ORDERS_CLINS  p_WOC_ID='|| p_WOC_ID ||' p_CLIN_HOURS='||p_CLIN_HOURS||'  p_CLIN_AMOUNT='||p_CLIN_AMOUNT);
    UPDATE WORK_ORDERS_CLINS
    SET CLIN_HOURS     = p_CLIN_HOURS,
      CLIN_AMOUNT      = p_CLIN_AMOUNT,
      LAST_MODIFIED_BY = p_LAST_MODIFIED_BY,
      LAST_MODIFIED_ON = Sysdate()
    WHERE WOC_ID       = p_WOC_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SP_INSERT_AUDIT( p_LAST_MODIFIED_BY,'Error pkg_work_orders.update_WORK_ORDERS_CLINS'||SQLERRM);
    p_PStatus := 'Error updating WORK_ORDERS_CLINS '||SQLERRM ;
  END;
-- delete_work_orders
  PROCEDURE delete_work_orders(
      p_work_orders_ID IN work_orders.work_orders_ID%type,
      P_LAST_MODIFIED_BY         IN work_orders.LAST_MODIFIED_BY%TYPE ,  
      p_PStatus OUT VARCHAR2 )
  IS
    vStatus VARCHAR2(20);
    child_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(child_exists, -2292);
    /* raises ORA-02292 */
  BEGIN
   select status into  vStatus from work_orders           
            WHERE  work_orders_ID = p_work_orders_ID ;
    SP_INSERT_AUDIT( P_LAST_MODIFIED_BY,'pkg_work_orders.delete_work_orders p_work_orders_ID='||p_work_orders_ID ||'Status='||vStatus);

    IF vStatus = 'Active' THEN 
      p_PStatus := 'Cannot Delete Active Task Order' ;
      RETURN; 
    END IF;  
    DELETE FROM work_orders WHERE work_orders_ID = p_work_orders_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN child_exists THEN
    p_PStatus := 'Cannot delete this Task Order, one or more clins exists for this Task Order ';
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error deleting Task Order: Error: '||SQLERRM ;
  END;
-- delete_WORK_ORDERS_CLINS
  PROCEDURE delete_WORK_ORDERS_CLINS(
      p_WOC_ID IN WORK_ORDERS_CLINS.WOC_ID%TYPE,
      p_PStatus OUT VARCHAR2 )
  IS
  BEGIN
    DELETE FROM WORK_ORDERS_CLINS WHERE WOC_ID = p_WOC_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error deleting WORK_ORDERS_CLINS '||SQLERRM ;
  END;
  PROCEDURE UPDATE_WO_LABOR_CATEGORY(
      P_WO_LABOR_CATEGORY_ID  IN WO_LABOR_CATEGORY.WO_LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      P_LABOR_CATEGORY_ID     IN WO_LABOR_CATEGORY.LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      P_CLIN_ID               IN WO_LABOR_CATEGORY.CLIN_ID%TYPE DEFAULT NULL,
      P_WORK_ORDERS_ID        IN WO_LABOR_CATEGORY.WORK_ORDERS_ID%TYPE DEFAULT NULL,
      P_STD_LABOR_CATEGORY_ID IN WO_LABOR_CATEGORY.STD_LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      P_LABOR_CATEGORY_RATE   IN WO_LABOR_CATEGORY.LABOR_CATEGORY_RATE%TYPE DEFAULT NULL,
      P_LABOR_CATEGORY_HOURS  IN WO_LABOR_CATEGORY.LABOR_CATEGORY_HOURS%TYPE DEFAULT NULL,
      P_VENDOR                IN WO_LABOR_CATEGORY.VENDOR%TYPE DEFAULT NULL,
      P_LC_AMOUNT            IN WO_LABOR_CATEGORY.LC_AMOUNT%TYPE DEFAULT NULL,
      P_LAST_MODIFIED_BY      IN WO_LABOR_CATEGORY.LAST_MODIFIED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2)
  IS
  BEGIN
    SP_INSERT_AUDIT (p_LAST_MODIFIED_BY, 'UPDATE_WO_LABOR_CATEGORY');
    UPDATE WO_LABOR_CATEGORY
    SET 
      --LABOR_CATEGORY_ID      = P_LABOR_CATEGORY_ID,
      --CLIN_ID                  = P_CLIN_ID,
      --WORK_ORDERS_ID           = P_WORK_ORDERS_ID,
      --STD_LABOR_CATEGORY_ID    = P_STD_LABOR_CATEGORY_ID,
      LABOR_CATEGORY_RATE      = P_LABOR_CATEGORY_RATE,
      LABOR_CATEGORY_HOURS     = P_LABOR_CATEGORY_HOURS,
      LC_AMOUNT = P_LC_AMOUNT,
      --VENDOR                   = P_VENDOR,
      --CONTRACTOR               = P_CONTRACTOR,
      LAST_MODIFIED_BY         = p_LAST_MODIFIED_BY,
      LAST_MODIFIED_ON         = SYSDATE ()
    WHERE WO_LABOR_CATEGORY_ID = P_WO_LABOR_CATEGORY_ID;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS';
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error Updating UPDATE_WO_LABOR_CATEGORY';
  END UPDATE_WO_LABOR_CATEGORY;
  PROCEDURE Insert_WO_LABOR_CATEGORY(
      P_LABOR_CATEGORY_ID     IN WO_LABOR_CATEGORY.LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      P_CLIN_ID               IN WO_LABOR_CATEGORY.CLIN_ID%TYPE DEFAULT NULL,
      P_WORK_ORDERS_ID        IN WO_LABOR_CATEGORY.WORK_ORDERS_ID%TYPE DEFAULT NULL,
      P_STD_LABOR_CATEGORY_ID IN WO_LABOR_CATEGORY.STD_LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      P_LABOR_CATEGORY_RATE   IN WO_LABOR_CATEGORY.LABOR_CATEGORY_RATE%TYPE DEFAULT NULL,
      P_LABOR_CATEGORY_HOURS  IN WO_LABOR_CATEGORY.LABOR_CATEGORY_HOURS%TYPE DEFAULT NULL,
      P_VENDOR                IN WO_LABOR_CATEGORY.VENDOR%TYPE DEFAULT NULL,
      P_CONTRACTOR            IN WO_LABOR_CATEGORY.CONTRACTOR%TYPE DEFAULT NULL,
      p_CREATED_BY            IN WO_LABOR_CATEGORY.LAST_MODIFIED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2)
  IS
  BEGIN
    SP_INSERT_AUDIT (p_CREATED_BY, 'Insert_WO_LABOR_CATEGORY');
    INSERT
    INTO WO_LABOR_CATEGORY
      (
        WO_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_ID,
        CLIN_ID,
        WORK_ORDERS_ID,
        STD_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_RATE,
        LABOR_CATEGORY_HOURS,
        VENDOR,
        CONTRACTOR,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        WO_LABOR_CATEGORY_SEQ.NEXTVAL,
        P_LABOR_CATEGORY_ID,
        P_CLIN_ID,
        P_WORK_ORDERS_ID,
        P_STD_LABOR_CATEGORY_ID,
        P_LABOR_CATEGORY_RATE,
        P_LABOR_CATEGORY_HOURS,
        P_VENDOR,
        P_CONTRACTOR,
        P_CREATED_BY,
        SYSDATE()
      );
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      -- p_ID := v_WOC_ID;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error Inserting Insert_WO_LABOR_CATEGORY';
  END Insert_WO_LABOR_CATEGORY ;
  PROCEDURE Insert_WO_LC_SESSION
    (
      P_LABOR_CATEGORY_ID     IN WO_LABOR_CATEGORY.LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      P_CLIN_ID               IN WO_LABOR_CATEGORY.CLIN_ID%TYPE DEFAULT NULL,
      P_SUB_TASKS_ID             IN WORK_ORDERS_CLINS_SESSION.SUB_TASKS_ID%TYPE DEFAULT NULL,
      P_WORK_ORDERS_ID        IN WO_LABOR_CATEGORY.WORK_ORDERS_ID%TYPE DEFAULT NULL,
      P_STD_LABOR_CATEGORY_ID IN WO_LABOR_CATEGORY.STD_LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      P_LABOR_CATEGORY_RATE   IN WO_LABOR_CATEGORY.LABOR_CATEGORY_RATE%TYPE DEFAULT NULL,
      P_LABOR_CATEGORY_HOURS  IN WO_LABOR_CATEGORY.LABOR_CATEGORY_HOURS%TYPE DEFAULT NULL,
      P_LC_AMOUNT               IN WO_LABOR_CATEGORY.LC_AMOUNT%TYPE DEFAULT NULL,
      P_CONTRACTOR            IN WO_LABOR_CATEGORY.CONTRACTOR%TYPE DEFAULT NULL,
      p_CREATED_BY            IN WO_LABOR_CATEGORY.LAST_MODIFIED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
  BEGIN
    SP_INSERT_AUDIT (p_CREATED_BY, 'Insert_WO_LABOR_CATEGORY');
    INSERT
    INTO WO_LABOR_CATEGORY_SESSION
      (
        WO_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_ID,
        CLIN_ID,
        SUB_TASKS_ID,
        WORK_ORDERS_ID,
        STD_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_RATE,
        LABOR_CATEGORY_HOURS,
        LC_AMOUNT,
        CONTRACTOR,
        CREATED_BY,
        CREATED_ON
      )
      VALUES
      (
        WO_LABOR_CATEGORY_SEQ.NEXTVAL,
        P_LABOR_CATEGORY_ID,
        P_CLIN_ID,
        P_SUB_TASKS_ID,
        P_WORK_ORDERS_ID,
        P_STD_LABOR_CATEGORY_ID,
        P_LABOR_CATEGORY_RATE,
        P_LABOR_CATEGORY_HOURS,
        P_LC_AMOUNT,
        P_CONTRACTOR,
        P_CREATED_BY,
        SYSDATE()
      ) ;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      -- p_ID := v_WOC_ID;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error Inserting Insert_WO_LC_SESSION';
  END Insert_WO_LC_SESSION ;
  PROCEDURE Move_WO_LC_SESSION
    (
      p_WORK_ORDERS_ID IN WO_LABOR_CATEGORY.WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_CREATED_BY     IN WO_LABOR_CATEGORY.CREATED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
  BEGIN
    IF( p_WORK_ORDERS_ID =0 OR p_WORK_ORDERS_ID IS NULL ) THEN
      p_PStatus         := 'Error moving  WO_LABOR_CATEGORY_SESSION '||' Cannot move with no id' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.Move_WO_LC_SESSION p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID );
    INSERT
    INTO WO_LABOR_CATEGORY(WO_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_ID,
        CLIN_ID,
        --SUB_TASKS_ID,
        WORK_ORDERS_ID,
        STD_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_RATE,
        LABOR_CATEGORY_HOURS,
        LC_AMOUNT,
        CONTRACTOR,
        CREATED_BY,
        CREATED_ON) 
      SELECT         WO_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_ID,
        CLIN_ID,
        --SUB_TASKS_ID,
        WORK_ORDERS_ID,
        STD_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_RATE,
        LABOR_CATEGORY_HOURS,
        LC_AMOUNT,
        CONTRACTOR,
        CREATED_BY,
        CREATED_ON
        FROM WO_LABOR_CATEGORY_SESSION
        WHERE CREATED_BY   = p_CREATED_BY
        AND WORK_ORDERS_ID = p_WORK_ORDERS_ID
      ;
    DELETE WO_LABOR_CATEGORY_SESSION
    WHERE CREATED_BY   = p_CREATED_BY
    AND WORK_ORDERS_ID = p_WORK_ORDERS_ID ;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error moving WORK_ORDERS_CLINS_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.Move_WO_LC_SESSION'||'||SQLERRM|| p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID );
  END Move_WO_LC_SESSION;

  
  PROCEDURE Delete_WO_LC_SESSION(
      p_CREATED_BY IN WO_LABOR_CATEGORY.CREATED_BY%TYPE,
      p_PStatus OUT VARCHAR2 )
  IS
    v_WOC_ID NUMBER:=0;
  BEGIN
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.Delete_WO_LC_SESSION p_CREATED_BY= '||p_CREATED_BY );
    --Delete all temp wo clins
    DELETE WO_LABOR_CATEGORY_SESSION
    WHERE CREATED_BY = p_CREATED_BY ;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    
    ROLLBACK;
    p_PStatus := 'Error deleting WO_LABOR_CATEGORY_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.Delete_WO_LC_SESSION'||'||SQLERRM|| p_CREATED_BY= '||p_CREATED_BY );
  END Delete_WO_LC_SESSION;
  PROCEDURE Move_ST_CLINS_SESSION
    (
      p_Sub_Tasks_ID           IN WORK_ORDERS_CLINS_SESSION.Sub_Tasks_ID%TYPE DEFAULT NULL,
      p_WORK_ORDERS_ID           IN WORK_ORDERS_CLINS_SESSION.FK_WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_PERIOD_OF_PERFORMANCE_ID IN WORK_ORDERS_CLINS_SESSION.FK_PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL,
      p_CREATED_BY               IN WORK_ORDERS_CLINS_SESSION.CREATED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
    v_WOC_ID NUMBER:=0;
  BEGIN
    IF( p_WORK_ORDERS_ID =0 OR p_WORK_ORDERS_ID IS NULL ) THEN
      p_PStatus         := 'Error moving  WORK_ORDERS_CLINS_SESSION '||' Cannot move with no id' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.Move_ST_CLINS_SESSION p_Sub_Tasks_ID= '||p_Sub_Tasks_ID );
    INSERT
    INTO SUB_TASKS_CLINS( 
        STC_ID,
        FK_Sub_Tasks_ID,
        WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        ST_CLIN_TYPE,
        ST_Rate,
        CREATED_BY,
        CREATED_ON)
      SELECT         
        WOC_ID,
        Sub_Tasks_ID,
        FK_WORK_ORDERS_ID,
        FK_PERIOD_OF_PERFORMANCE_ID,
        CLIN_ID,
        SUB_CLIN_ID,
        CLIN_HOURS,
        CLIN_AMOUNT,
        WO_CLIN_TYPE,
        WO_Rate,
        CREATED_BY,
        CREATED_ON
        FROM WORK_ORDERS_CLINS_SESSION
        WHERE CREATED_BY      = p_CREATED_BY
        AND FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID
        AND Sub_Tasks_ID = p_Sub_Tasks_ID
      ;
    DELETE WORK_ORDERS_CLINS_SESSION
    WHERE CREATED_BY      = p_CREATED_BY
    AND FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID
    AND Sub_Tasks_ID = p_Sub_Tasks_ID;

    Move_ST_LC_SESSION(p_Sub_Tasks_ID, p_WORK_ORDERS_ID, p_CREATED_BY, p_PStatus);
    
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error moving WORK_ORDERS_CLINS_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.Move_ST_CLINS_SESSION'||'||SQLERRM|| p_Sub_Tasks_ID= '||p_Sub_Tasks_ID );
  END Move_ST_CLINS_SESSION;
  PROCEDURE Move_ST_LC_SESSION
    (
        p_Sub_Tasks_ID           IN WORK_ORDERS_CLINS_SESSION.Sub_Tasks_ID%TYPE DEFAULT NULL,
      p_WORK_ORDERS_ID IN WO_LABOR_CATEGORY.WORK_ORDERS_ID%TYPE DEFAULT NULL,
      p_CREATED_BY     IN WO_LABOR_CATEGORY.CREATED_BY%TYPE DEFAULT NULL,
      p_PStatus OUT VARCHAR2
    )
  IS
  BEGIN
    IF( p_WORK_ORDERS_ID =0 OR p_WORK_ORDERS_ID IS NULL ) THEN
      p_PStatus         := 'Error moving  WO_LABOR_CATEGORY_SESSION '||' Cannot move with no id' ;
      RETURN;
    END IF;
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.Move_ST_LC_SESSION p_Sub_Tasks_ID= '||p_Sub_Tasks_ID );
    INSERT
    INTO ST_LABOR_CATEGORY(ST_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_ID,
        CLIN_ID,
        SUB_TASKS_ID,
        WORK_ORDERS_ID,
        STD_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_RATE,
        LABOR_CATEGORY_HOURS,
        LC_AMOUNT,
        CONTRACTOR,
        CREATED_BY,
        CREATED_ON) 
      SELECT         WO_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_ID,
        CLIN_ID,
        SUB_TASKS_ID,
        WORK_ORDERS_ID,
        STD_LABOR_CATEGORY_ID,
        LABOR_CATEGORY_RATE,
        LABOR_CATEGORY_HOURS,
        LC_AMOUNT,
        CONTRACTOR,
        CREATED_BY,
        CREATED_ON
        FROM WO_LABOR_CATEGORY_SESSION
        WHERE CREATED_BY   = p_CREATED_BY
        AND WORK_ORDERS_ID = p_WORK_ORDERS_ID
        AND Sub_Tasks_ID = p_Sub_Tasks_ID
      ;
    DELETE WO_LABOR_CATEGORY_SESSION
    WHERE CREATED_BY   = p_CREATED_BY
    AND WORK_ORDERS_ID = p_WORK_ORDERS_ID   AND Sub_Tasks_ID = p_Sub_Tasks_ID ;
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error moving WORK_ORDERS_CLINS_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.Move_ST_LC_SESSION'||'||SQLERRM|| p_Sub_Tasks_ID= '||p_Sub_Tasks_ID );
  END Move_ST_LC_SESSION;  

PROCEDURE SP_GET_WOC(
    P_CONTRACT_NUMBER          VARCHAR2 DEFAULT NULL ,
    P_POP_TYPE                 VARCHAR2 DEFAULT NULL ,
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_WOC_ID                   NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID           NUMBER DEFAULT 0 ,
    p_UserId                   VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WOC
  Author: Sridhar Kommana
  Date Created : 11/14/2014
  Purpose:  Get Clin hours and type info for a work order
  Update history:
  05/12/2015 Sridhar Kommana Added following new fields
  ---Available Hours/Qty, Available Amount, Work Order Hours/Qty, Work Order Amount, Remaining Hours/Qty, Remaining Amount
  Available_Hours_Qty ,Available_Amount,Remaining_Hours_Qty,Remaining_Amount
  05/22/2015 Sridhar Kommana Added new field to show LC_Exists grid
  3) 05/25/2015 : Added new cols LABOR_RATE_TYPE and RATE_TYPE
  4) 06/03/2015 : Added additional logic to calculate WO_CLIN_AMOUNT, incase of LC_EXISTS, it should be sum of all lc amounts.
  5) 06/08/2015 : Added LABOR_RATE_TYPE for SubClin
  6) 06/10/2015 : Added WHERE Available_Hours_Qty >0 AND Available_Amount>0 to restict records which do not have any hours available
  7) 06/10/2015 : Added logic to calculate Available_Hours_Qty and Available_Amount
  8) 07/09/2015 : Added work order labor categories records as union
  9) 07/24/2015 : Removed unwanted cols
  10) 07/24/2015 : Added group by totals
  11) 12/04/2015  Added CLIN_ID,sub_clin_id,CLIN_TYPE_ORIG 
  */
  p_status VARCHAR2(100);
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_GET_WOC: Get work order CLIN details p_Contract_NUMBER='||p_Contract_NUMBER|| 'P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| 'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'P_WOC_ID='||P_WOC_ID);
  pkg_work_orders.Delete_WO_CLINS_SESSION(p_UserId,p_status);
  OPEN REC_CURSOR FOR
  SELECT DISTINCT
    --WOC_ID,
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_NUMBER_DISP,
    NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, LABOR_CATEGORY_TITLE, CLIN_TYPE_DISP, SUM(WO_CLIN_HOURS) WO_CLIN_HOURS , WO_CLIN_Rate,
    SUM(WO_CLIN_AMOUNT) WO_CLIN_AMOUNT
     ,CLIN_ID,sub_clin_id,CLIN_TYPE as CLIN_TYPE_ORIG, LABOR_CATEGORY_ID
    --end of cols display
    -- CONTRACT_NUMBER, PERIOD_OF_PERFORMANCE_ID, POP_TYPE, CLIN_ID,sub_clin_id,  nvl(SUB_CLIN_NUMBER, CLIN_NUMBER)  CLIN_NUMBER_DISP , SUB_CLIN_NUMBER, CLIN_NUMBER, LABOR_CATEGORY_ID, CLIN_TYPE , SUB_CLIN_TYPE,
    --CLIN_SUB_CLIN , CLIN_TITLE , SUB_CLIN_TITLE, CLIN_HOURS, CLIN_RATE,CLIN_AMOUNT, FK_WORK_ORDERS_ID as WORK_ORDERS_ID, WOC_ID,    0 AS WO_LABOR_CATEGORY_ID,   LABOR_RATE_TYPE, SC_LABOR_RATE_TYPE, Available_Hours_Qty ,Available_Amount, Remaining_Hours_Qty,Remaining_Amount, LC_Exists
  FROM
    (SELECT 
     --POP.CONTRACT_NUMBER,
     -- POP_TYPE,
      C.CLIN_ID,
      SC.sub_clin_id,
      --C.PERIOD_OF_PERFORMANCE_ID,
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
   -- AND (POP.POP_TYPE             = P_POP_TYPE
   -- OR P_POP_TYPE                IS NULL) --'B'
    INNER JOIN WORK_ORDERS_CLINS W
    ON ( (W.CLIN_ID                       = C.CLIN_ID
    AND W.SUB_CLIN_ID                     = SC.SUB_CLIN_ID)
    OR ( W.CLIN_ID                        = C.CLIN_ID
    AND (W.SUB_CLIN_ID                   IS NULL
    OR W.SUB_CLIN_ID                      =0) ) )
    AND (W.WOC_ID                         = P_WOC_ID
    OR P_WOC_ID                           = 0)
    AND (W.FK_WORK_ORDERS_ID              = p_WORK_ORDERS_ID )
  --  AND (POP.CONTRACT_NUMBER              = P_CONTRACT_NUMBER
  --  OR P_CONTRACT_NUMBER                 IS NULL)--'DTFAWA-11-X-80007'
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID
   OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
UNION
    SELECT 
      --POP.CONTRACT_NUMBER,
      --POP_TYPE,
      C.CLIN_ID,
      SC.sub_clin_id,
      --C.PERIOD_OF_PERFORMANCE_ID,
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
      --W.SUB_CLIN_ID = SC.SUB_CLIN_ID AND
      W.CLIN_ID = SC.CLIN_ID ))
    INNER JOIN CLIN_LABOR_CATEGORY CLC
    ON CLC.LABOR_CATEGORY_ID    = W.LABOR_CATEGORY_ID
    AND CLC.CLIN_ID             = W.CLIN_ID
    AND (W.WO_LABOR_CATEGORY_ID = P_WOC_ID
    OR P_WOC_ID                 = 0)
    AND (W.WORK_ORDERS_ID       = p_WORK_ORDERS_ID )
      --AND W.created_by=p_UserId
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID
    OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
    ) TBLCLINS 
  GROUP BY  CLIN_ID,sub_clin_id,CLIN_TYPE,LABOR_CATEGORY_ID,
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER
    ||SUB_CLIN_NUMBER,CLIN_NUMBER ) , NVL(SUB_CLIN_TITLE,CLIN_TITLE) , LABOR_CATEGORY_TITLE, CLIN_TYPE_DISP, WO_CLIN_Rate
  ORDER BY 1 ;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
  SELECT   0 SUB_CLIN_NUMBER_DISP, 0 CLIN_TITLE_DISP, 0 LABOR_CATEGORY_TITLE, 0 CLIN_TYPE_DISP, 0 WO_CLIN_HOURS , 0 WO_CLIN_Rate, 0 WO_CLIN_AMOUNT from dual;
END SP_GET_WOC;


/* Formatted on 5/27/2016 12:54:45 PM (QP5 v5.256.13226.35510) */
PROCEDURE SP_GET_WO_CLINS (
   P_PERIOD_OF_PERFORMANCE_ID       NUMBER DEFAULT NULL,
   P_CLIN_ID                        VARCHAR2 DEFAULT NULL,
   P_WOC_ID                         NUMBER DEFAULT 0,
   p_WORK_ORDERS_ID                 NUMBER DEFAULT 0,
   p_UserId                         VARCHAR2 DEFAULT NULL,
   REC_CURSOR                   OUT SYS_REFCURSOR)
AS
   /*
   Procedure : SP_GET_WO_CLINS
   Author: Sridhar Kommana
   Date Created : 06/26/2015
   Purpose:  Get Clin details and type info for a work order
 --    DECODE(CLIN_SUB_CLIN, 'Y',  CLIN_ID|| ':' || sub_clin_id,CLIN_ID ) as SUB_CLIN_ID_DISP  input
   Update history:
   Sridhar Kommana 05302016 Added new columns Available_Labor_Breakout,  Available_Travel_Breakout, Available_Material_Breakout,  Available_ODC_Breakout
   Sridhar Kommana 06212016 Fixed issue with deducting hours from QTY break out amounts
    */
   v_SubClin_id   VARCHAR2 (12) := NULL;
   v_Clin_id      VARCHAR2 (12) := NULL;
BEGIN
   v_Clin_id := P_CLIN_ID;

   --SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_GET_WO_CLINS: Get work order details P_CLIN_ID='||P_CLIN_ID|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);
   IF INSTR (v_Clin_id, ':') > 1
   THEN
      v_SubClin_id := SUBSTR (v_Clin_id, INSTR (v_Clin_id, ':') + 1);
      v_Clin_id := SUBSTR (v_Clin_id, 1, INSTR (v_Clin_id, ':') - 1);
   ELSE
      v_Clin_id := P_CLIN_ID;
      v_SubClin_id := NULL;
   END IF;

   SP_INSERT_AUDIT (
      p_UserId,
         'pkg_work_orders.sp_GET_WO_CLINS: Get work order CLIN details P_CLIN_ID='
      || P_CLIN_ID
      || ' v_Clin_id='
      || v_Clin_id
      || ' ||  v_SubClin_id='
      || v_SubClin_id
      || ' P_PERIOD_OF_PERFORMANCE_ID='
      || P_PERIOD_OF_PERFORMANCE_ID
      || ' p_WORK_ORDERS_ID='
      || p_WORK_ORDERS_ID
      || ' P_WOC_ID='
      || P_WOC_ID);

   OPEN REC_CURSOR FOR
        SELECT DISTINCT
               CONTRACT_NUMBER,
               PERIOD_OF_PERFORMANCE_ID,
               POP_TYPE,
               NVL (CLIN_ID, 0) AS CLIN_ID,
               NVL (sub_clin_id, 0) AS sub_clin_id,
               NVL (SUB_CLIN_NUMBER, CLIN_NUMBER) CLIN_NUMBER_DISP,
               SUB_CLIN_NUMBER,
               CLIN_NUMBER,
               DECODE (CLIN_SUB_CLIN,
                       'Y', CLIN_NUMBER || SUB_CLIN_NUMBER,
                       CLIN_NUMBER)
                  AS SUB_CLIN_NUMBER_DISP,
               LABOR_CATEGORY_ID,
               (SELECT CATEGORY_NAME
                  FROM LABOR_CATEGORIES
                 WHERE LABOR_CATEGORIES.CATEGORY_ID = LABOR_CATEGORY_ID)
                  AS DESCRIPTION,
               CLIN_TYPE,
               SUB_CLIN_TYPE,
               CLIN_TYPE_DISP,
               CLIN_SUB_CLIN,
               CLIN_TITLE,
               SUB_CLIN_TITLE,
               NVL (SUB_CLIN_TITLE, CLIN_TITLE) CLIN_TITLE_DISP,
               CLIN_HOURS,
               CLIN_RATE,
               CLIN_AMOUNT,
               FK_WORK_ORDERS_ID AS WORK_ORDERS_ID,
               WOC_ID,
               WO_CLIN_HOURS,
               0 AS WO_LABOR_CATEGORY_ID,
               WO_CLIN_AMOUNT,
               LABOR_RATE_TYPE,
               SC_LABOR_RATE_TYPE,
               DECODE(sign(Available_Hours_Qty),-1,0,Available_Hours_Qty) Available_Hours_Qty,
               Available_Amount,
               LC_Exists, --,       Remaining_Hours_Qty,Remaining_Amount, LC_Exists
               Available_Labor_Breakout,
               Available_Travel_Breakout,
               Available_Material_Breakout,
               Available_ODC_Breakout
          FROM (SELECT POP.CONTRACT_NUMBER,
                       POP_TYPE,
                       C.CLIN_ID,
                       SC.sub_clin_id,
                       C.PERIOD_OF_PERFORMANCE_ID,
                       C.CLIN_NUMBER,
                       SC.SUB_CLIN_NUMBER,
                       SC.SUB_CLIN_TYPE,
                       C.CLIN_TYPE,
                       --NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP ,
                       NVL (WO_CLIN_TYPE, NVL (SC.SUB_CLIN_TYPE, C.CLIN_TYPE))
                          AS CLIN_TYPE_DISP,
                       C.CLIN_SUB_CLIN,
                       C.CLIN_TITLE,
                       SC.SUB_CLIN_TITLE,
                       C.LABOR_CATEGORY_ID,  --L.CATEGORY_NAME AS DESCRIPTION,
                       NVL (C.CLIN_HOURS, 0) + NVL (SC.SUB_CLIN_HOURS, 0)
                          AS CLIN_HOURS,
                       NVL (C.CLIN_RATE, 0) + NVL (SC.SUB_CLIN_RATE, 0)
                          AS CLIN_RATE,
                       NVL (C.CLIN_AMOUNT, 0) + NVL (SC.SUB_CLIN_AMOUNT, 0)
                          AS CLIN_AMOUNT,
                       W.WOC_ID,
                       FK_WORK_ORDERS_ID,
                       NVL (W.CLIN_HOURS, 0) WO_CLIN_HOURS,
                       NVL (W.CLIN_AMOUNT, 0) WO_CLIN_AMOUNT,

                         
                   
                       (  NVL (C.CLIN_HOURS, 0)
                        + NVL (SC.SUB_CLIN_HOURS, 0)
                        - NVL (
                             (SELECT NVL (SUM (W.CLIN_HOURS), 0)
                                FROM WORK_ORDERS_CLINS W
                               WHERE     (    W.CLIN_ID = C.CLIN_ID AND WO_CLIN_TYPE= 'Labor'
                                          AND (   W.SUB_CLIN_ID = v_SubClin_id
                                               OR v_SubClin_id IS NULL
                                               OR W.SUB_CLIN_ID = 0)
                                                )                                          
                             OR C.CLIN_ID   IN ( select ClIN_ID  from CLIN_TMO TMO WHERE TMO.CLIN_TYPE  NOT  IN ( 'Travel' , 'Material' , 'ODC') AND C.CLIN_ID = TMO.CLIN_ID )                                          
                                     AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                             C.PERIOD_OF_PERFORMANCE_ID)),
                             0)
                        - (SELECT NVL (SUM (NVL (WLC.LABOR_CATEGORY_HOURS, 0)),
                                       0)
                             FROM WO_LABOR_CATEGORY_SESSION WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (W.CLIN_HOURS), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND WO_CLIN_TYPE= 'Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id
                                            OR v_SubClin_id IS NULL
                                            OR W.SUB_CLIN_ID = 0))
                                  --AND C.Clin_Type <> 'Contract'
                                   --       AND C.CLIN_ID <> CTT.ClIN_ID
                                  --        AND C.CLIN_ID <> CTM.ClIN_ID
                                  --        AND C.CLIN_ID <> CTO.ClIN_ID     
                               OR C.CLIN_ID   IN ( select ClIN_ID  from CLIN_TMO TMO WHERE TMO.CLIN_TYPE  NOT  IN ( 'Travel' , 'Material' , 'ODC') AND C.CLIN_ID = TMO.CLIN_ID )                                                               
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (NVL (WLC.LABOR_CATEGORY_HOURS, 0)),
                                       0)
                             FROM WO_LABOR_CATEGORY WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID))
                            --)
                          AS Available_Hours_Qty,
                          
                       (  NVL (C.CLIN_AMOUNT, 0)
                        + NVL (SC.SUB_CLIN_AMOUNT, 0)
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (NVL (WLC.LC_AMOUNT, 0)), 0)
                             FROM WO_LABOR_CATEGORY WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS WOC
                            WHERE WOC.CLIN_ID = C.CLIN_ID AND WOC.ST_CLIN_TYPE='Labor' )
                        - (SELECT NVL (SUM (NVL (WLC.LC_AMOUNT, 0)), 0)
                             FROM WO_LABOR_CATEGORY_SESSION WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (SLC.LC_AMOUNT), 0)
                             FROM ST_LABOR_CATEGORY SLC
                            WHERE SLC.CLIN_ID = C.CLIN_ID))
                          AS Available_Amount,
                          
                       (  NVL (CTL.CLIN_AMOUNT, 0)
                        - (SELECT NVL (SUM (NVL (WLC.LC_AMOUNT, 0)), 0)
                             FROM WO_LABOR_CATEGORY WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (NVL (WLC.LC_AMOUNT, 0)), 0)
                             FROM WO_LABOR_CATEGORY_SESSION WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)                            
                        - (SELECT NVL (SUM (SLC.LC_AMOUNT), 0)
                             FROM ST_LABOR_CATEGORY SLC
                            WHERE SLC.CLIN_ID = C.CLIN_ID))
                          AS Available_Labor_Breakout,

                          

                       (NVL (CTM.CLIN_AMOUNT, 0)
                        
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Material' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id 
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Material' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))                                          
                                          
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS STC
                            WHERE STC.CLIN_ID = C.CLIN_ID AND STC.ST_CLIN_TYPE='Material' AND C.CLIN_TYPE='Labor'))
                          AS Available_Material_Breakout,
                      
                       (NVL (CTO.CLIN_AMOUNT, 0)
                        
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='ODC' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id 
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='ODC' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))                                          
                                          
                                          
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS STC
                            WHERE STC.CLIN_ID = C.CLIN_ID AND STC.ST_CLIN_TYPE='ODC' AND C.CLIN_TYPE='Labor'))
                          AS Available_ODC_Breakout,  
                          

    
                       (NVL (CTT.CLIN_AMOUNT, 0)                        

                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Travel' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id 
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                   
                                          C.PERIOD_OF_PERFORMANCE_ID))
                   
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Travel' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                            --AND   CREATED_BY      = p_UserId
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))                                          
                                          
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS STC
                            WHERE STC.CLIN_ID = C.CLIN_ID AND STC.ST_CLIN_TYPE='Travel' AND C.CLIN_TYPE='Labor')
                    
                  /*  
                      - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))      */                       --Commented by Sridhar on 06/16/2016
                            )
                           AS Available_Travel_Breakout,
                                                                           
                          
                                                    
                       (SELECT DECODE (COUNT (CLC.clin_id), 0, 'N', 'Y')
                          FROM clin_labor_category clc
                         WHERE clc.clin_id = C.CLIN_ID)
                          AS LC_Exists,
                       C.LABOR_RATE_TYPE,
                       SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
                       RATE_TYPE
                  FROM POP_CLIN C
                       LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID)
                       LEFT OUTER JOIN CLIN_TMO CTL ON (CTL.CLIN_ID = C.CLIN_ID AND CTL.CLIN_TYPE='Labor')
                       LEFT OUTER JOIN CLIN_TMO CTT ON (CTT.CLIN_ID = C.CLIN_ID AND CTT.CLIN_TYPE='Travel')                       
                       LEFT OUTER JOIN CLIN_TMO CTM ON (CTM.CLIN_ID = C.CLIN_ID AND CTM.CLIN_TYPE='Material')
                       LEFT OUTER JOIN CLIN_TMO CTO ON (CTO.CLIN_ID = C.CLIN_ID AND CTO.CLIN_TYPE='ODC')
                       INNER JOIN PERIOD_OF_PERFORMANCE POP
                          ON C.PERIOD_OF_PERFORMANCE_ID =
                                POP.PERIOD_OF_PERFORMANCE_ID
                       --INNER JOIN WORK_ORDERS_CLINS W ON (W.CLIN_ID = C.CLIN_ID OR  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )
                       INNER JOIN WORK_ORDERS_CLINS W
                          ON     (   (    W.CLIN_ID = C.CLIN_ID
                                      AND W.SUB_CLIN_ID = SC.SUB_CLIN_ID)
                                  OR (    W.CLIN_ID = C.CLIN_ID
                                      AND (   W.SUB_CLIN_ID IS NULL
                                           OR W.SUB_CLIN_ID = 0)))
                             AND (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
                             AND (W.FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID )
                             AND (C.CLIN_ID = v_Clin_id OR v_Clin_id IS NULL)
                             --v_SubClin_id
                             AND (   SC.SUB_CLIN_ID = v_SubClin_id
                                  OR v_SubClin_id IS NULL)
                             AND (   C.PERIOD_OF_PERFORMANCE_ID =
                                        P_PERIOD_OF_PERFORMANCE_ID
                                  OR NVL (P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
                UNION  --- Also get  clins which are not in current work order
                SELECT POP.CONTRACT_NUMBER,
                       POP_TYPE,
                       C.CLIN_ID,
                       SC.sub_clin_id,
                       C.PERIOD_OF_PERFORMANCE_ID,
                       C.CLIN_NUMBER,
                       SC.SUB_CLIN_NUMBER,
                       SC.SUB_CLIN_TYPE,
                       C.CLIN_TYPE,
                       --NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP ,
                       'Labor' AS CLIN_TYPE_DISP,
                       C.CLIN_SUB_CLIN,
                       C.CLIN_TITLE,
                       SC.SUB_CLIN_TITLE,
                       C.LABOR_CATEGORY_ID,
                       -- L.CATEGORY_NAME AS DESCRIPTION,
                       NVL (C.CLIN_HOURS, 0) + NVL (SC.SUB_CLIN_HOURS, 0)
                          AS CLIN_HOURS,
                       NVL (C.CLIN_RATE, 0) + NVL (SC.SUB_CLIN_RATE, 0)
                          AS CLIN_RATE,
                       NVL (C.CLIN_AMOUNT, 0) + NVL (SC.SUB_CLIN_AMOUNT, 0)
                          AS CLIN_AMOUNT,
                       NULL AS WOC_ID,
                       NULL AS FK_WORK_ORDERS_ID,
                       0 AS WO_CLIN_HOURS,
                       0 AS WO_CLIN_AMOUNT,
                      
                  (  NVL (C.CLIN_HOURS, 0)
                        + NVL (SC.SUB_CLIN_HOURS, 0)
                        - (SELECT NVL (SUM (W.CLIN_HOURS), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND WO_CLIN_TYPE= 'Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id
                                            OR v_SubClin_id IS NULL
                                            OR W.SUB_CLIN_ID = 0)
                                       OR  C.CLIN_ID   IN ( select ClIN_ID  from CLIN_TMO TMO WHERE TMO.CLIN_TYPE  NOT  IN ( 'Travel' , 'Material' , 'ODC') AND C.CLIN_ID = TMO.CLIN_ID )
                                      --AND C.Clin_Type <> 'Contract'
                                   --       AND C.CLIN_ID <> CTT.ClIN_ID
                                   --       AND C.CLIN_ID <> CTM.ClIN_ID
                                  --        AND C.CLIN_ID <> CTO.ClIN_ID                                      
                                       )
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_HOURS), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND WO_CLIN_TYPE= 'Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id
                                            OR v_SubClin_id IS NULL
                                            OR W.SUB_CLIN_ID = 0))
                                      OR  C.CLIN_ID   IN ( select ClIN_ID  from CLIN_TMO TMO WHERE TMO.CLIN_TYPE  NOT  IN ( 'Travel' , 'Material' , 'ODC') AND C.CLIN_ID = TMO.CLIN_ID )                                            
                                 -- AND C.Clin_Type <> 'Contract'
                                   --       AND C.CLIN_ID <> CTT.ClIN_ID
                                   --       AND C.CLIN_ID <> CTM.ClIN_ID
                                   --       AND C.CLIN_ID <> CTO.ClIN_ID                                 
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (NVL (WLC.LABOR_CATEGORY_HOURS, 0)),
                                       0)
                             FROM WO_LABOR_CATEGORY WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (NVL (WLC.LABOR_CATEGORY_HOURS, 0)),
                                       0)
                             FROM WO_LABOR_CATEGORY_SESSION WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (CLIN_Hours), 0)
                             FROM SUB_TASKS_CLINS WOC
                            WHERE WOC.CLIN_ID = C.CLIN_ID AND WOC.ST_CLIN_TYPE='Labor' )
                        - (SELECT NVL (SUM (SLC.LABOR_CATEGORY_HOURS), 0)
                             FROM ST_LABOR_CATEGORY SLC
                            WHERE SLC.CLIN_ID = C.CLIN_ID))
                            
                               
                        
                       
                          AS Available_Hours_Qty,
                          
                       (  NVL (C.CLIN_AMOUNT, 0)
                        + NVL (SC.SUB_CLIN_AMOUNT, 0)
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id
                                            OR v_SubClin_id IS NULL
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (WLC.LC_AMOUNT), 0)
                             FROM WO_LABOR_CATEGORY WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (NVL (WLC.LC_AMOUNT, 0)), 0)
                             FROM WO_LABOR_CATEGORY_SESSION WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS WOC
                            WHERE WOC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (SLC.LC_AMOUNT), 0)
                             FROM ST_LABOR_CATEGORY SLC
                            WHERE SLC.CLIN_ID = C.CLIN_ID))
                          AS Available_Amount,
                          
                       (  NVL (CTL.CLIN_AMOUNT, 0)
                        - (SELECT NVL (SUM (NVL (WLC.LC_AMOUNT, 0)), 0)
                             FROM WO_LABOR_CATEGORY WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)
                        - (SELECT NVL (SUM (NVL (WLC.LC_AMOUNT, 0)), 0)
                             FROM WO_LABOR_CATEGORY_SESSION WLC
                            WHERE WLC.CLIN_ID = C.CLIN_ID)                            
                        - (SELECT NVL (SUM (SLC.LC_AMOUNT), 0)
                             FROM ST_LABOR_CATEGORY SLC
                            WHERE SLC.CLIN_ID = C.CLIN_ID))
                          AS Available_Labor_Breakout,

                          

                       (NVL (CTM.CLIN_AMOUNT, 0)
                        
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Material' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id 
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Material' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))                                          
                                          
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS STC
                            WHERE STC.CLIN_ID = C.CLIN_ID AND STC.ST_CLIN_TYPE='Material' AND C.CLIN_TYPE='Labor'))
                          AS Available_Material_Breakout,

                          
                       (NVL (CTO.CLIN_AMOUNT, 0)
                        
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='ODC' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id 
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='ODC' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))                                          
                                          
                                          
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS STC
                            WHERE STC.CLIN_ID = C.CLIN_ID AND STC.ST_CLIN_TYPE='ODC' AND C.CLIN_TYPE='Labor'))
                          AS Available_ODC_Breakout,  
                          

                       (NVL (CTT.CLIN_AMOUNT, 0)
                        
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Travel' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = v_SubClin_id 
                                            OR v_SubClin_id IS NULL))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))
                        - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID AND W.WO_CLIN_TYPE='Travel' AND C.CLIN_TYPE='Labor'
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                         --AND   CREATED_BY      = p_UserId
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))                                          
                                          
                        - (SELECT NVL (SUM (CLIN_Amount), 0)
                             FROM SUB_TASKS_CLINS STC
                            WHERE STC.CLIN_ID = C.CLIN_ID AND STC.ST_CLIN_TYPE='Travel' AND C.CLIN_TYPE='Labor')

         /*               - (SELECT NVL (SUM (W.CLIN_AMOUNT), 0)
                             FROM WORK_ORDERS_CLINS_SESSION W
                            WHERE     (    W.CLIN_ID = C.CLIN_ID
                                       AND (   W.SUB_CLIN_ID = SC.SUB_CLIN_ID
                                            OR W.SUB_CLIN_ID = 0))
                                  AND (W.FK_PERIOD_OF_PERFORMANCE_ID =
                                          C.PERIOD_OF_PERFORMANCE_ID))

           */                 
                            )
                          AS Available_Travel_Breakout,
                                                                           
                          
                                                                  
                                                   
                       (SELECT DECODE (COUNT (CLC.clin_id), 0, 'N', 'Y')
                          FROM clin_labor_category clc
                         WHERE clc.clin_id = C.CLIN_ID)
                          LC_Exists,
                       C.LABOR_RATE_TYPE,
                       SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
                       RATE_TYPE
                  FROM POP_CLIN C
                       LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID)
                       LEFT OUTER JOIN CLIN_TMO CTL ON (CTL.CLIN_ID = C.CLIN_ID AND CTL.CLIN_TYPE='Labor')
                       LEFT OUTER JOIN CLIN_TMO CTT ON (CTT.CLIN_ID = C.CLIN_ID AND CTT.CLIN_TYPE='Travel')                       
                       LEFT OUTER JOIN CLIN_TMO CTM ON (CTM.CLIN_ID = C.CLIN_ID AND CTM.CLIN_TYPE='Material')
                       LEFT OUTER JOIN CLIN_TMO CTO ON (CTO.CLIN_ID = C.CLIN_ID AND CTO.CLIN_TYPE='ODC')
                       INNER JOIN PERIOD_OF_PERFORMANCE POP
                          ON     C.PERIOD_OF_PERFORMANCE_ID =
                                    POP.PERIOD_OF_PERFORMANCE_ID
                             AND (C.CLIN_ID = v_Clin_id OR v_Clin_id IS NULL)
                             --v_SubClin_id
                             AND (   SC.SUB_CLIN_ID = v_SubClin_id
                                  OR v_SubClin_id IS NULL)
                             AND (   C.PERIOD_OF_PERFORMANCE_ID =
                                        P_PERIOD_OF_PERFORMANCE_ID
                                  OR NVL (P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
                             AND NOT EXISTS
                                        (SELECT 1
                                           FROM WORK_ORDERS_CLINS WOC
                                          WHERE     (       WOC.FK_PERIOD_OF_PERFORMANCE_ID =
                                                               P_PERIOD_OF_PERFORMANCE_ID
                                                        AND SC.SUB_CLIN_ID =
                                                               WOC.SUB_CLIN_ID
                                                     OR     WOC.FK_PERIOD_OF_PERFORMANCE_ID =
                                                               P_PERIOD_OF_PERFORMANCE_ID
                                                        AND C.CLIN_ID =
                                                               WOC.CLIN_ID)
                                                AND WOC.FK_WORK_ORDERS_ID =
                                                       p_WORK_ORDERS_ID))
               TBLCLINS
      --  WHERE Available_Hours_Qty >0   or Available_Amount>0
      ORDER BY WOC_ID, clin_id;
EXCEPTION
   WHEN OTHERS
   THEN
      OPEN REC_CURSOR FOR
         SELECT 1 AS CONTRACT_NUMBER,
                1 AS PERIOD_OF_PERFORMANCE_ID,
                1 AS POP_TYPE,
                1 AS CLIN_ID,
                1 AS sub_clin_id,
                1 AS CLIN_NUMBER_DISP,
                1 AS SUB_CLIN_NUMBER,
                1 AS CLIN_NUMBER,
                1 AS LABOR_CATEGORY_ID,
                1 AS DESCRIPTION,
                1 AS CLIN_TYPE,
                1 AS SUB_CLIN_TYPE,
                1 AS CLIN_TYPE_DISP,
                1 AS CLIN_SUB_CLIN,
                1 AS CLIN_TITLE,
                1 AS SUB_CLIN_TITLE,
                1 AS CLIN_TITLE_DISP,
                1 AS CLIN_HOURS,
                1 AS CLIN_RATE,
                1 AS CLIN_AMOUNT,
                1 AS LABOR_RATE_TYPE,
                1 AS SC_LABOR_RATE_TYPE,
                1 AS WOC_ID,
                1 AS FK_WORK_ORDERS_ID,
                1 AS WO_CLIN_HOURS,
                1 AS WO_CLIN_AMOUNT,
                1 AS Available_Hours_Qty,
                1 AS Available_Amount,   --1 as  WO_Hours_Qty, 1 as WO_Amount,
                1 AS Remaining_Hours_Qty,
                1 AS Remaining_Amount,
                1 AS LC_Exists,
                1 AS LABOR_RATE_TYPE,
                1 AS RATE_TYPE
           FROM DUAL;
END SP_GET_WO_CLINS;

PROCEDURE SP_GET_CLINS_List(
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_CLIN_ID                  NUMBER DEFAULT NULL ,
    P_CLIN_TYPE                VARCHAR2 DEFAULT NULL,
 --   P_WOC_ID                   NUMBER DEFAULT 0 ,
  --  p_WORK_ORDERS_ID           NUMBER DEFAULT 0 ,
    p_UserId                   VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_CLINS_List
  Author: Sridhar Kommana
  Date Created : 06/26/2015
  Purpose:  Get Clin list info for a Contract POP
  Update history:
           04/25/2016 :Srihari Gokina : Added Parameter CLIN_TYPE and CLIN_TMO to SP.
           05/20/2016 : Sridhar Kommana : Modified Null in place of 0 for clin_tmo
           05/20/2016 : Sridhar Kommana : Modified clin_tmo record output to get the parent clin rather than child itself
           05/20/2016 : Sridhar Kommana : Added two new scenarios for labor categories and sub-clins
           05/31/2016 : Sridhar Kommana : Modified CLin title to show "Number: Title"
  */
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_GET_CLINS_List: Get CLINS list P_CLIN_ID='||P_CLIN_ID|| ' P_CLIN_TYPE='||P_CLIN_TYPE || ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID);--||' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);
  OPEN REC_CURSOR FOR
  SELECT DISTINCT   DECODE(CLIN_SUB_CLIN, 'Y', CLIN_ID
    || ':'
    || sub_clin_id,CLIN_ID ) AS SUB_CLIN_ID_DISP, CLIN_ID, sub_clin_id, NVL(SUB_CLIN_NUMBER, CLIN_NUMBER) CLIN_NUMBER_DISP , SUB_CLIN_NUMBER, CLIN_NUMBER, 

    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER
    ||'-'
    ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_NUMBER_DISP, CLIN_SUB_CLIN , CLIN_TITLE , SUB_CLIN_TITLE, 
    NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP
  FROM 
   (
 
   SELECT C.CLIN_ID, SC.sub_clin_id, CLIN_NUMBER, SUB_CLIN_NUMBER, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP, C.CLIN_SUB_CLIN ,
    CLIN_NUMBER ||': '||C.CLIN_TITLE as CLIN_TITLE,
    --SUB_CLIN_NUMBER||': '|| SC.SUB_CLIN_TITLE as SUB_CLIN_TITLE
    SC.SUB_CLIN_TITLE
    --  CLIN_NUMBER ||SUB_CLIN_NUMBER||': '||SC.SUB_CLIN_TITLE as SUB_CLIN_TITLE
    FROM POP_CLIN C 
    LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) 
    INNER JOIN PERIOD_OF_PERFORMANCE POP  ON C.PERIOD_OF_PERFORMANCE_ID   = POP.PERIOD_OF_PERFORMANCE_ID AND
     (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID) 
    WHERE (C.CLIN_TYPE = P_CLIN_TYPE OR C.CLIN_TYPE = 'Labor') AND C.haslaborcategories = 'N' AND C.CLIN_SUB_CLIN = 'N'
   UNION 
    SELECT C.CLIN_ID, null as sub_clin_id, CLIN_NUMBER, null as SUB_CLIN_NUMBER,  C.CLIN_TYPE  CLIN_TYPE_DISP, C.CLIN_SUB_CLIN ,
    CLIN_NUMBER ||': '||C.CLIN_TITLE as CLIN_TITLE , NULL as SUB_CLIN_TITLE
    FROM POP_CLIN C 
    INNER JOIN PERIOD_OF_PERFORMANCE POP  ON C.PERIOD_OF_PERFORMANCE_ID   = POP.PERIOD_OF_PERFORMANCE_ID AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID) 
    WHERE C.CLIN_TYPE = 'Labor' AND C.haslaborcategories = 'Y' AND C.CLIN_SUB_CLIN = 'N'
    AND ( select sum(tmo.clin_amount) from Clin_Tmo tmo where TMO.CLIN_ID = C.CLIN_ID) > 0  
  UNION
    SELECT C.CLIN_ID, null as sub_clin_id, CLIN_NUMBER, null as SUB_CLIN_NUMBER,  C.CLIN_TYPE  CLIN_TYPE_DISP, C.CLIN_SUB_CLIN ,
    CLIN_NUMBER ||': '||C.CLIN_TITLE as CLIN_TITLE , NULL as SUB_CLIN_TITLE
    FROM POP_CLIN C 
    INNER JOIN PERIOD_OF_PERFORMANCE POP  ON C.PERIOD_OF_PERFORMANCE_ID   = POP.PERIOD_OF_PERFORMANCE_ID AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID) 
    WHERE C.CLIN_TYPE = 'Labor' AND C.haslaborcategories = 'Y' AND C.CLIN_SUB_CLIN = 'N'
    --AND ( select sum(NVL(tmo.clin_amount,0)) from Clin_Tmo tmo where TMO.CLIN_ID = C.CLIN_ID) = 0  
  UNION
    SELECT C.CLIN_ID, null as sub_clin_id, CLIN_NUMBER, null as SUB_CLIN_NUMBER,  C.CLIN_TYPE  CLIN_TYPE_DISP, C.CLIN_SUB_CLIN ,
    --C.CLIN_TITLE ,
    CLIN_NUMBER ||': '||C.CLIN_TITLE as CLIN_TITLE , 
    NULL as SUB_CLIN_TITLE
    FROM POP_CLIN C 
    INNER JOIN PERIOD_OF_PERFORMANCE POP  ON C.PERIOD_OF_PERFORMANCE_ID   = POP.PERIOD_OF_PERFORMANCE_ID AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID) 
    WHERE C.CLIN_TYPE = 'Labor' AND C.haslaborcategories = 'Y' AND C.CLIN_SUB_CLIN = 'N'
    AND ( select sum(NVL(tmo.clin_amount,0)) from Clin_Tmo tmo where TMO.CLIN_ID = C.CLIN_ID) = 0  
  UNION     
    SELECT C.CLIN_ID, SC.sub_clin_id, CLIN_NUMBER, SUB_CLIN_NUMBER, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP, C.CLIN_SUB_CLIN ,
    --C.CLIN_TITLE 
    --CLIN_NUMBER ||': '||C.CLIN_TITLE as CLIN_TITLE ,
        CLIN_NUMBER ||SUB_CLIN_NUMBER||': '||SC.SUB_CLIN_TITLE as CLIN_TITLE ,  CLIN_NUMBER ||SUB_CLIN_NUMBER||': '||SC.SUB_CLIN_TITLE as SUB_CLIN_TITLE
     --SUB_CLIN_NUMBER||': '||SC.SUB_CLIN_TITLE as SUB_CLIN_TITLE
    FROM POP_CLIN C 
    LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) 
    INNER JOIN PERIOD_OF_PERFORMANCE POP  ON C.PERIOD_OF_PERFORMANCE_ID   = POP.PERIOD_OF_PERFORMANCE_ID AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID) 
    WHERE C.CLIN_TYPE = 'Labor' AND C.haslaborcategories = 'N' AND (SC.SUB_CLIN_TYPE =P_CLIN_TYPE OR SC.SUB_CLIN_TYPE = 'Labor' )
/*
    SELECT 0        AS CLIN_ID,
      0             AS sub_clin_id,
      'Select Clin' AS CLIN_NUMBER,
      'Select Clin' AS SUB_CLIN_NUMBER ,
      '0'           AS CLIN_TYPE_DISP ,
      '0'           AS CLIN_SUB_CLIN ,
      '0'           AS CLIN_TITLE ,
      '0'           AS SUB_CLIN_TITLE
    FROM DUAL*/
    ) TBLCLINS
  ORDER BY 1 ;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT NULL AS  CLIN_ID, NULL AS sub_clin_id, NULL AS  CLIN_NUMBER, NULL AS  SUB_CLIN_NUMBER , NULL AS  CLIN_TYPE_DISP, NULL as CLIN_SUB_CLIN , 
  NULL AS   CLIN_TITLE , NULL AS  SUB_CLIN_TITLE FROM DUAL;
END SP_GET_CLINS_List;

PROCEDURE sp_get_Work_Orders(
    p_UserId  varchar2 DEFAULT NULL,
    P_WORK_ORDERS_ID NUMBER DEFAULT 0 ,   
    P_POP_ID NUMBER DEFAULT 0 , 
    p_contract_number  varchar2 DEFAULT NULL,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_Work_Orders
  Author: Sridhar Kommana
  Date Created : 04/24/2015
  Purpose:  Get work orders for each contract or get details when work_order_id is passed.
  Update history: 
  sridhar kommana :
  1) 05/04/2015 : Added p_USER fro auditing/debugging
  2) 05/04/2015 : Added sort by 1 so that 0 will come on top
  3) 05/04/2015 : Removed where clause WHERE POP.STATUS = 'Active' because User selects POP type on the form. 
  4) 05/04/2015 : Added vendor feild.
  5) 05/14/2015 : Added Org title.  
  6) 06/15/2015 : Added LEFT outer JOIN (select distinct org_cd, ORG_TITLE from organizations) O on WO.organization = O.org_cd, to avoid duplicates
  */
    p_status Varchar2(100) :=NULL;
BEGIN
 IF p_contract_number is NOT NULL THEN 
   SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_Work_Orders-Get Work Orders List for a contract '||p_Contract_NUMBER ||' P_POP_ID='||P_POP_ID );
   --- Delete Work order clin Sessions
   pkg_work_orders.Delete_WO_CLINS_SESSION(p_UserId,p_status);
   
      OPEN REC_CURSOR
      FOR
              SELECT WO.WORK_ORDERS_ID,
                WO.WORK_ORDER_NUMBER,
                WO.WORK_ORDER_TITLE,
                WO.WORK_ORDER_NUMBER
                ||'................'
                ||WO.WORK_ORDER_TITLE AS WORK_ORDER_DESC,
                WO.START_DATE,
                WO.END_DATE,
                WO.DESCRIPTION,
                WO.ORGANIZATION,
                ORG_TITLE,
                WO.FAA_POC,
                WO.PERIOD_OF_PERFORMANCE_ID,
                 (
                    (SELECT SUM(NVL(CLIN_HOURS,0))
                    FROM WORK_ORDERS_CLINS WOC
                    WHERE FK_WORK_ORDERS_ID = WORK_ORDERS_ID
                    AND WO_CLIN_TYPE= 'Labor'  
                     ) +
                        (SELECT NVL(SUM(NVL(WLC.LABOR_CATEGORY_HOURS,0)),0)
                        FROM WO_LABOR_CATEGORY WLC
                        WHERE WLC.WORK_ORDERS_ID = WO.WORK_ORDERS_ID 
                        )
                           +(
                            select nvl(sum(W.CLIN_HOURS),0)  from SUB_TASKS_CLINS W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID
                             AND ST_CLIN_TYPE= 'Labor'
                            )
                            + (
                             select nvl(sum(nvl(W.LABOR_CATEGORY_Hours,0))  ,0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID
                             )                        
                ) AS WORK_ORDER_HOURS,
                (
                  (SELECT NVL(SUM(NVL(W.CLIN_AMOUNT,0)) ,0) FROM WORK_ORDERS_CLINS W  WHERE FK_WORK_ORDERS_ID = WORK_ORDERS_ID
                  ) +
                    ( SELECT NVL(SUM(NVL(W.LC_AMOUNT,0)) ,0) FROM WO_LABOR_CATEGORY W  WHERE W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID 
                    ) + 
                      (select nvl(sum(W.CLIN_AMOUNT),0)  from SUB_TASKS_CLINS W WHERE   W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID
                      ) 
                        + (select nvl(sum(nvl(W.LC_AMOUNT,0))  ,0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID
                          )
                
                )AS WORK_ORDER_AMOUNT,
                0 AS TOTAL_AMOUNT, --0 is   for Fee TODO
                (SELECT TO_CHAR( NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' )
                FROM LSD_WO_FUNDS LWF
                WHERE POP.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER
                AND LWF.WORK_ORDERS_ID    =WO.WORK_ORDERS_ID
                ) AS ALLOCATED,
                WO_FEE,
                WO.Status,
                WO.sub_task,
                POP.CONTRACT_NUMBER,
                POP.POP_TYPE -- ,
              FROM Work_Orders WO
              LEFT JOIN
                (SELECT DISTINCT org_cd, ORG_TITLE FROM organizations WHERE rownum=1
                ) O
              ON WO.organization = O.org_cd
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
                --WHERE POP.STATUS = 'Active'
              AND POP.contract_number = p_contract_number
                --inner join  contract c       on C.CONTRACT_NUMBER = POP.contract_number
              ORDER BY PERIOD_OF_PERFORMANCE_ID ;
 ELSE
    SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_Work_Orders - Get Work Orders details for WORK_ORDERS_ID '||P_WORK_ORDERS_ID ||' P_POP_ID='||P_POP_ID);
  --  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_Work_Orders P_WORK_ORDERS_ID '||P_WORK_ORDERS_ID ||' P_POP_ID='||P_POP_ID);
       OPEN REC_CURSOR
      FOR
          SELECT    
            WO.WORK_ORDERS_ID,  
            WO.WORK_ORDER_NUMBER,
            WO.WORK_ORDER_TITLE,
            WO.WORK_ORDER_NUMBER ||'................' ||WO.WORK_ORDER_TITLE as WORK_ORDER_DESC,
            WO.START_DATE,
            WO.END_DATE,
            WO.DESCRIPTION,
            WO.ORGANIZATION, FN_GET_ORG_TITLE_FROM_SP(WO.ORGANIZATION) ORG_TITLE,
            WO.FAA_POC,
            WO.PERIOD_OF_PERFORMANCE_ID,
  /*          (select sum(nvl(W.CLIN_HOURS,0))  from WORK_ORDERS_CLINS W WHERE  FK_WORK_ORDERS_ID = WORK_ORDERS_ID) as WORK_ORDER_HOURS,
            (select sum(nvl(W.CLIN_AMOUNT,0))  from WORK_ORDERS_CLINS W WHERE  FK_WORK_ORDERS_ID = WORK_ORDERS_ID)  as WORK_ORDER_AMOUNT  , 
*/
                 (
                    (SELECT SUM(NVL(CLIN_HOURS,0))
                    FROM WORK_ORDERS_CLINS WOC
                    WHERE FK_WORK_ORDERS_ID = WORK_ORDERS_ID
                      AND WO_CLIN_TYPE= 'Labor'
                     ) +
                        (SELECT NVL(SUM(NVL(WLC.LABOR_CATEGORY_HOURS,0)),0)
                        FROM WO_LABOR_CATEGORY WLC
                        WHERE WLC.WORK_ORDERS_ID = WO.WORK_ORDERS_ID 
                        )
                           +(
                            select sum(nvl(W.CLIN_HOURS,0))  from SUB_TASKS_CLINS W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID 
                              AND ST_CLIN_TYPE= 'Labor'
                            )
                            + (
                             select nvl(sum(nvl(W.LABOR_CATEGORY_Hours,0))  ,0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID
                             )                        
                ) AS WORK_ORDER_HOURS,
                (
                  (SELECT NVL(SUM(NVL(W.CLIN_AMOUNT,0)) ,0) FROM WORK_ORDERS_CLINS W  WHERE FK_WORK_ORDERS_ID = WORK_ORDERS_ID
                  ) +
                    ( SELECT NVL(SUM(NVL(W.LC_AMOUNT,0)) ,0) FROM WO_LABOR_CATEGORY W  WHERE W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID 
                    ) + 
                      (select sum(nvl(W.CLIN_AMOUNT,0))  from SUB_TASKS_CLINS W WHERE   W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID
                      ) 
                        + (select nvl(sum(nvl(W.LC_AMOUNT,0))  ,0) from ST_LABOR_CATEGORY W WHERE  W.WORK_ORDERS_ID = WO.WORK_ORDERS_ID
                          )
                
                )AS WORK_ORDER_AMOUNT,
            0  as TOTAL_AMOUNT, 
            (select to_char( NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' )  from LSD_WO_FUNDS LWF WHERE POP.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER
             AND LWF.WORK_ORDERS_ID=P_WORK_ORDERS_ID)  as ALLOCATED, 
             WO_FEE,
            WO.Status, 
            POP.CONTRACT_NUMBER, 
            POP.POP_TYPE --, C.VENDOR
      FROM Work_Orders  WO 
            LEFT outer JOIN (select distinct org_cd, ORG_TITLE from organizations) O on WO.organization = O.org_cd
            inner join PERIOD_OF_PERFORMANCE POP 
      ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID    

      --WHERE POP.STATUS = 'Active'       
      AND (WORK_ORDERS_ID = P_WORK_ORDERS_ID OR P_WORK_ORDERS_ID= 0)  
      AND (WO.PERIOD_OF_PERFORMANCE_ID = P_POP_ID OR P_POP_ID= 0)  
    -- inner join  contract c  on C.CONTRACT_NUMBER = POP.contract_number        
      
      ORDER BY 1;
 END IF;
 
  
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
            SELECT 1 as WORK_ORDERS_ID,
            1 as WORK_ORDER_NUMBER,
            1 as  WORK_ORDER_TITLE,
            1 as WORK_ORDER_DESC,            
            1 as  START_DATE,
            1 as   END_DATE,
            1 as   DESCRIPTION,
            1 as  ORGANIZATION, 1 as ORG_TITLE,
            1 as   FAA_POC,
            1 as  PERIOD_OF_PERFORMANCE_ID,
            1 as  WORK_ORDER_HOURS,
            1 as  WORK_ORDER_AMOUNT,1 as TOTAL_AMOUNT,
            1 as ALLOCATED, 
             1 as WO_FEE,
            1 as Status, 
            1 as sub_task, 
            1 as CONTRACT_NUMBER, 
            1 as POP_TYPE from dual;
        
END sp_get_Work_Orders;


PROCEDURE sp_get_TO_DETAILS(
    p_UserId         VARCHAR2,
    P_WORK_ORDERS_ID NUMBER DEFAULT 0,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_TO_DETAILS
  Author: Sridhar Kommana
  Date Created : 08/28/2015
  Purpose:  Get Task orders for each contract.
  Update history:
  */
  p_status VARCHAR2(100) :=NULL;
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_TO_DETAILS - Get Task Orders List for a contract P_WORK_ORDERS_ID= '||P_WORK_ORDERS_ID );
        OPEN REC_CURSOR FOR 
        SELECT WO.WORK_ORDERS_ID, WO.WORK_ORDER_NUMBER, WO.WORK_ORDER_Title, WO.ORGANIZATION ORGANIZATION, WO.FAA_POC FAA_POC, WO.START_DATE,
            WO.END_DATE,
        (
        (SELECT NVL(SUM(NVL(W.CLIN_AMOUNT,0)) ,0)
        FROM WORK_ORDERS_CLINS W
        WHERE FK_WORK_ORDERS_ID = P_WORK_ORDERS_ID
        ) +
        (SELECT NVL(SUM(NVL(W.LC_AMOUNT,0)) ,0)
        FROM WO_LABOR_CATEGORY W
        WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
        )+
(SELECT NVL(SUM(W.CLIN_AMOUNT),0)
            FROM SUB_TASKS_CLINS W
            WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
            ) +
            (SELECT NVL(SUM(NVL(W.LC_AMOUNT,0)) ,0)
            FROM ST_LABOR_CATEGORY W
            WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
            )        
        )
      AS
        WORK_ORDER_AMOUNT ,
        (SELECT TO_CHAR( NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' )
        FROM LSD_WO_FUNDS LWF
        WHERE -- POP.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND
          LWF.WORK_ORDERS_ID =P_WORK_ORDERS_ID
        )
      AS
        ALLOCATED , 
        
        ( 
                (SELECT NVL(SUM(NVL(W.CLIN_AMOUNT,0)) ,0)
        FROM WORK_ORDERS_CLINS W
        WHERE FK_WORK_ORDERS_ID = P_WORK_ORDERS_ID
        ) +
        (SELECT NVL(SUM(NVL(W.LC_AMOUNT,0)) ,0)
        FROM WO_LABOR_CATEGORY W
        WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
        )+
(SELECT NVL(SUM(W.CLIN_AMOUNT),0)
            FROM SUB_TASKS_CLINS W
            WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
            ) +
            (SELECT NVL(SUM(NVL(W.LC_AMOUNT,0)) ,0)
            FROM ST_LABOR_CATEGORY W
            WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
            )  
        )AS TOTAL_AMOUNT
        
        
        FROM Work_Orders WO WHERE (WORK_ORDERS_ID = P_WORK_ORDERS_ID )
      UNION
          SELECT ST.SUB_TASKS_ID WORK_ORDERS_ID,
            ST.SUB_TASK_NUMBER WORK_ORDER_NUMBER,
            ST.SUB_TASK_TITLE WORK_ORDER_Title ,
            ST.ORGANIZATION ORGANIZATION,
            ST.FAA_POC FAA_POC,            ST.START_DATE,
            ST.END_DATE,
            (
            (SELECT NVL(SUM(W.CLIN_AMOUNT),0)
            FROM SUB_TASKS_CLINS W
            WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
            ) +
            (SELECT NVL(SUM(NVL(W.LC_AMOUNT,0)) ,0)
            FROM ST_LABOR_CATEGORY W
            WHERE W.WORK_ORDERS_ID = P_WORK_ORDERS_ID
            ) )AS WORK_ORDER_AMOUNT ,
            (SELECT TO_CHAR( NVL( SUM(LWF.AMOUNT), 0 ), '999,999,999,999,999.99' )
            FROM LSD_WO_FUNDS LWF
            WHERE --POP.CONTRACT_NUMBER = LWF.CONTRACT_NUMBER AND
              LWF.WORK_ORDERS_ID =P_WORK_ORDERS_ID
            ) AS ALLOCATED ,0 AS TOTAL_AMOUNT
          FROM SUB_TASKS ST
          WHERE (SUB_TASKS_ID = P_WORK_ORDERS_ID)
          ORDER BY WORK_ORDER_NUMBER ;
END sp_get_TO_DETAILS;

PROCEDURE sp_get_TOs(
    p_UserId  varchar2,
    P_POP_ID varchar2 default NULL,
    p_contract_number  varchar2 ,
  --  P_WORK_ORDERS_ID number default 0,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_TOs
  Author: Sridhar Kommana
  Date Created : 08/28/2015
  Purpose:  Get Task orders for each contract.
  Update history: 
  07/05/2016 : changed order by clause to workorder id RTM ID; E002
  */
    p_status Varchar2(100) :=NULL;
BEGIN
    SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_TOs - Get Task Orders List for a contract '||p_Contract_NUMBER  || 'P_POP_ID='||P_POP_ID);
   
      OPEN REC_CURSOR
      FOR  
              SELECT WO.WORK_ORDERS_ID,  WO.WORK_ORDER_NUMBER, WO.WORK_ORDER_Title, WO.WORK_ORDER_NUMBER || ' - ' || WO.WORK_ORDER_Title as WO_TEXT,  WO.ORGANIZATION ORGANIZATION, WO.FAA_POC  FAA_POC
              FROM Work_Orders WO
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)
           --   AND (WORK_ORDERS_ID = P_WORK_ORDERS_ID OR P_WORK_ORDERS_ID= 0) 
       /*       UNION  
              SELECT ST.SUB_TASKS_ID WORK_ORDERS_ID,
              ST.SUB_TASK_NUMBER WORK_ORDER_NUMBER, ST.SUB_TASK_TITLE WORK_ORDER_Title ,   ST.ORGANIZATION ORGANIZATION, ST.FAA_POC  FAA_POC
              FROM SUB_TASKS ST
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = ST.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number
              AND  (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)*/
       --       AND (SUB_TASKS_ID = P_WORK_ORDERS_ID OR P_WORK_ORDERS_ID= 0) 
              ORDER BY WO.WORK_ORDERS_ID asc ; 
 
END sp_get_TOs;


PROCEDURE SP_GET_WO_CLIN_DETAILS(
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_CLIN_ID VARCHAR2 DEFAULT NULL ,
    P_WOC_ID NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0 ,
    p_UserId VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WO_CLIN_DETAILS
  Author: Sridhar Kommana
  Date Created : 06/26/2015
  Purpose:  Get Clin details and type info for a work order
  Update history:
   */
BEGIN
   SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_GET_WO_CLIN_DETAILS: Get work order details P_CLIN_ID='||P_CLIN_ID|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);
 
   
  OPEN REC_CURSOR FOR 
  select  distinct
    CONTRACT_NUMBER, PERIOD_OF_PERFORMANCE_ID, POP_TYPE, CLIN_ID, sub_clin_id,  
    nvl(SUB_CLIN_NUMBER, CLIN_NUMBER)  CLIN_NUMBER_DISP , SUB_CLIN_NUMBER, CLIN_NUMBER,  DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) as SUB_CLIN_NUMBER_DISP,  LABOR_CATEGORY_ID, 
    (select CATEGORY_NAME from LABOR_CATEGORIES where LABOR_CATEGORIES.CATEGORY_ID = LABOR_CATEGORY_ID ) as  DESCRIPTION,   
    CLIN_TYPE , SUB_CLIN_TYPE, CLIN_TYPE_DISP,
    CLIN_SUB_CLIN , CLIN_TITLE , SUB_CLIN_TITLE, nvl(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP,
    CLIN_HOURS, CLIN_RATE,CLIN_AMOUNT, FK_WORK_ORDERS_ID as WORK_ORDERS_ID, WOC_ID,  WO_CLIN_HOURS, 0 AS WO_LABOR_CATEGORY_ID,    
     WO_CLIN_AMOUNT, LABOR_RATE_TYPE, SC_LABOR_RATE_TYPE,     
      Available_Hours_Qty ,Available_Amount,  
      Remaining_Hours_Qty,Remaining_Amount, LC_Exists
  from (   
  SELECT POP.CONTRACT_NUMBER, POP_TYPE, C.CLIN_ID, SC.sub_clin_id, C.PERIOD_OF_PERFORMANCE_ID, C.CLIN_NUMBER, SC.SUB_CLIN_NUMBER, SC.SUB_CLIN_TYPE ,C.CLIN_TYPE , 
  NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP , 
  C.CLIN_SUB_CLIN , C.CLIN_TITLE , SC.SUB_CLIN_TITLE ,  C.LABOR_CATEGORY_ID,   --L.CATEGORY_NAME AS DESCRIPTION,  
  NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) AS  CLIN_HOURS, 
  NVL(C.CLIN_RATE,0)+ NVL(SC.SUB_CLIN_RATE,0) AS  CLIN_RATE,
  NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS  CLIN_AMOUNT,
  W.WOC_ID,FK_WORK_ORDERS_ID, nvl(W.CLIN_HOURS,0)   WO_CLIN_HOURS, 
  nvl(W.CLIN_AMOUNT,0)   WO_CLIN_AMOUNT ,  
  ---( DECODE((select DECODE(count(CLC.clin_id),0,'N','Y')  from  clin_labor_category clc where clc.clin_id= C.CLIN_ID) ,'Y',(select sum(wlc.LABOR_CATEGORY_RATE*wlc.LABOR_CATEGORY_HOURS) from WO_LABOR_CATEGORY wlc Where wlc.WORK_ORDERS_ID = w.FK_WORK_ORDERS_ID AND wlc.clin_id=c.clin_id ), W.CLIN_AMOUNT ))   as  WO_CLIN_AMOUNT ,  
  
 (NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) - nvl(W.CLIN_HOURS,0)) as  Available_Hours_Qty ,
 ( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) - nvl(W.CLIN_AMOUNT,0) ) as  Available_Amount,
  -- 1 as  WO_Hours_Qty, 1 as WO_Amount,
 (NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) - nvl(W.CLIN_HOURS,0)) as  Remaining_Hours_Qty, 
 ( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) - nvl(W.CLIN_AMOUNT,0) ) as  Remaining_Amount,
 (select DECODE(count(CLC.clin_id),0,'N','Y')  from  clin_labor_category clc where clc.clin_id= C.CLIN_ID) as  LC_Exists,       
  C.LABOR_RATE_TYPE, SC.LABOR_RATE_TYPE as SC_LABOR_RATE_TYPE, RATE_TYPE
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) 
  INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID  
  INNER JOIN WORK_ORDERS_CLINS W ON (W.CLIN_ID = C.CLIN_ID OR  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )
  AND (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID )
  AND (C.CLIN_ID = P_CLIN_ID OR P_CLIN_ID is NULL) 
  AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0) 
  ) TBLCLINS 
--  WHERE Available_Hours_Qty >0   or Available_Amount>0
  order by WOC_ID, clin_id ;
  EXCEPTION
  WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
          SELECT   1 as   CONTRACT_NUMBER,  1 as   PERIOD_OF_PERFORMANCE_ID, 1 as POP_TYPE, 1 as   CLIN_ID, 1 as   sub_clin_id,  
                   1 as   CLIN_NUMBER_DISP , 1 as   SUB_CLIN_NUMBER, 1 as    CLIN_NUMBER,  1 as   LABOR_CATEGORY_ID,  1 as   DESCRIPTION,   
                   1 as   CLIN_TYPE ,  1 as   SUB_CLIN_TYPE,  1 as   CLIN_TYPE_DISP,
                   1 as   CLIN_SUB_CLIN ,  1 as   CLIN_TITLE ,  1 as   SUB_CLIN_TITLE,  1 as    CLIN_TITLE_DISP,
                   1 as   CLIN_HOURS,  1 as   CLIN_RATE,  1 as   CLIN_AMOUNT, 1 as LABOR_RATE_TYPE, 1 as SC_LABOR_RATE_TYPE,   1 as   WOC_ID, 1 as FK_WORK_ORDERS_ID,   1 as   WO_CLIN_HOURS,    1 as   WO_CLIN_AMOUNT
                   , 1 as  Available_Hours_Qty ,1 as  Available_Amount, --1 as  WO_Hours_Qty, 1 as WO_Amount,
                   1 as  Remaining_Hours_Qty,1 as  Remaining_Amount,
                   1 as LC_Exists ,1 AS LABOR_RATE_TYPE,
                1 AS RATE_TYPE FROM dual;
END SP_GET_WO_CLIN_DETAILS;

PROCEDURE  sp_get_WO_LABOR_CATEGORY(   
    p_WO_LABOR_CATEGORY_ID VARCHAR2 DEFAULT 0,
    p_WORK_ORDERS_ID VARCHAR2 DEFAULT NULL,
    p_LABOR_CATEGORY_ID VARCHAR2 DEFAULT 0,
    p_CLIN_ID VARCHAR2 DEFAULT NULL,
    p_USER VARCHAR2 DEFAULT NULL,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_WO_LABOR_CATEGORY
  Author: Sridhar Kommana
  Date Created : 04/24/2015
  Purpose:  Get clin labor category information.
  Update history:
  sridhar kommana :LABOR_RATE_TYPE
  1) 04/24/2015 : Added p_USER fro auditing/debugging
  2) 05/27/2015 : Added LABOR_CATEGORY_RATE
  3) 05/28/2015 : Added LC_RATE_TYPE  , APPROVAL_DATE,  COMMENTS, CONTRACTOR, VENDOR,
  4) 06/01/2015 : Added p_LABOR_CATEGORY_ID  
  5) 06/04/2015 : Added p_WORK_ORDERS_ID  
  6) 06/08/2015 : added C.LABOR_RATE_TYPE as  LC_LABOR_RATE_TYPE,
  */
BEGIN
 SP_INSERT_AUDIT( p_USER,'pkg_work_orders.sp_get_WO_LABOR_CATEGORY for p_WO_LABOR_CATEGORY_ID, p_WORK_ORDERS_ID, p_LABOR_CATEGORY_ID, p_CLIN_ID '||p_WO_LABOR_CATEGORY_ID||','|| p_WORK_ORDERS_ID || ',' ||p_LABOR_CATEGORY_ID ||','||p_CLIN_ID);   
  OPEN REC_CURSOR FOR   
      SELECT  WOL.WO_LABOR_CATEGORY_ID, C.LABOR_CATEGORY_ID, C.CLIN_ID, C.LABOR_CATEGORY_TITLE, 
              C.STD_LABOR_CATEGORY_ID, C.LABOR_CATEGORY_HIGH_RATE, C.LABOR_CATEGORY_LOW_RATE, C.APPROVAL_DATE , C.COMMENTS, 
              L.CATEGORY_NAME AS Standard_LABOR_CATEGORY ,C.LABOR_RATE_TYPE as  LC_LABOR_RATE_TYPE,  PC.LABOR_RATE_TYPE,
              RATE_TYPE, 
              DECODE(WOL.WO_LABOR_CATEGORY_ID, NULL ,C.LABOR_CATEGORY_RATE, WOL.LABOR_CATEGORY_RATE) LABOR_CATEGORY_RATE,  
              WOL.WORK_ORDERS_ID,  
              WOL.LABOR_CATEGORY_HOURS,
              WOL.LABOR_CATEGORY_RATE*WOL.LABOR_CATEGORY_HOURS LC_Amount,  
              (select sum(LABOR_CATEGORY_HOURS) from WO_LABOR_CATEGORY Where WO_LABOR_CATEGORY_ID= WOL.WO_LABOR_CATEGORY_ID) as TOT_LABOR_CATEGORY_HOURS,    
              (select sum(LABOR_CATEGORY_RATE*LABOR_CATEGORY_HOURS) from WO_LABOR_CATEGORY Where WO_LABOR_CATEGORY_ID= WOL.WO_LABOR_CATEGORY_ID)  TOT_LC_Amount,  
              LC_RATE_TYPE, C.CONTRACTOR, C.VENDOR
  FROM CLIN_LABOR_CATEGORY C   
  LEFT OUTER JOIN LABOR_CATEGORIES L ON L.CATEGORY_ID = C.STD_LABOR_CATEGORY_ID 
  LEFT OUTER JOIN WO_LABOR_CATEGORY WOL ON WOL.CLIN_ID = C.CLIN_ID
          AND WOL.LABOR_CATEGORY_ID = C.LABOR_CATEGORY_ID
  INNER JOIN POP_CLIN PC ON PC.CLIN_ID = C.CLIN_ID
  WHERE C.CLIN_ID  = p_CLIN_ID
  --  AND ( C.LABOR_CATEGORY_ID  = p_LABOR_CATEGORY_ID OR p_LABOR_CATEGORY_ID = 0)
    AND ( WOL.WO_LABOR_CATEGORY_ID  = p_WO_LABOR_CATEGORY_ID OR p_WO_LABOR_CATEGORY_ID = 0)
    AND ( WOL.WORK_ORDERS_ID  = p_WORK_ORDERS_ID OR p_WORK_ORDERS_ID = 0)
/*UNION
  SELECT
        WC.WO_LABOR_CATEGORY_ID, WC.LABOR_CATEGORY_ID, WC.CLIN_ID , LABOR_CATEGORY_TITLE,
        WC.STD_LABOR_CATEGORY_ID , LABOR_CATEGORY_HIGH_RATE , LABOR_CATEGORY_LOW_RATE, APPROVAL_DATE,WC.COMMENTS,L.CATEGORY_NAME AS Standard_LABOR_CATEGORY ,
        LABOR_RATE_TYPE,RATE_TYPE,  WC.LABOR_CATEGORY_RATE, WC.WORK_ORDERS_ID,  WC.LABOR_CATEGORY_HOURS,
        WC.LABOR_CATEGORY_RATE*WC.LABOR_CATEGORY_HOURS LC_Amount,   (select sum(LABOR_CATEGORY_HOURS) from WO_LABOR_CATEGORY Where WORK_ORDERS_ID= WC.WORK_ORDERS_ID) TOT_LABOR_CATEGORY_HOURS,
        (select sum(LABOR_CATEGORY_RATE*LABOR_CATEGORY_HOURS) from WO_LABOR_CATEGORY Where WORK_ORDERS_ID= WC.WORK_ORDERS_ID) TOT_LC_Amount,
        LC_RATE_TYPE , WC.CONTRACTOR,WC.VENDOR
  --C.LABOR_CATEGORY_ID, C.CLIN_ID, C.LABOR_CATEGORY_TITLE, C.STD_LABOR_CATEGORY_ID, C.LABOR_CATEGORY_HIGH_RATE, C.LABOR_CATEGORY_LOW_RATE, C.APPROVAL_DATE , C.COMMENTS, L.CATEGORY_NAME AS Standard_LABOR_CATEGORY ,  LABOR_RATE_TYPE, RATE_TYPE, C.LABOR_CATEGORY_RATE, WOL.LABOR_CATEGORY_HOURS, LC_RATE_TYPE, C.CONTRACTOR, C.VENDOR
  FROM WO_LABOR_CATEGORY WC   
  LEFT OUTER JOIN LABOR_CATEGORIES L ON L.CATEGORY_ID = WC.STD_LABOR_CATEGORY_ID
  INNER JOIN CLIN_LABOR_CATEGORY CL ON  CL.LABOR_CATEGORY_ID = WC.LABOR_CATEGORY_ID
  INNER JOIN POP_CLIN PC ON PC.CLIN_ID = WC.CLIN_ID  
  --INNER JOIN POP_CLIN PC ON PC.CLIN_ID = C.CLIN_ID
  WHERE WC.WORK_ORDERS_ID  = p_WORK_ORDERS_ID
  AND (WC.CLIN_ID  = p_CLIN_ID OR p_CLIN_ID =0)  */
  
  order by 1 ;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT 1 AS WO_LABOR_CATEGORY_ID, 1 AS   LABOR_CATEGORY_ID, 1 AS   CLIN_ID, 1 AS   LABOR_CATEGORY_TITLE, 1 AS   STD_LABOR_CATEGORY_ID,
  1 as LABOR_CATEGORY_HIGH_RATE, 1 as LABOR_CATEGORY_LOW_RATE, 1 AS   APPROVAL_DATE , 1 AS   COMMENTS, 1 AS   Standard_LABOR_CATEGORY
  ,1 as LABOR_CATEGORY_RATE, 1 as LABOR_CATEGORY_HOURS ,         1 as  LC_Amount,
        1 as TOT_LABOR_CATEGORY_HOURS,
       1  TOT_LC_Amount,  1 as LC_LABOR_RATE_TYPE,  1 as  LC_RATE_TYPE, 1 as CONTRACTOR, 1 as    VENDOR
  FROM CLIN_LABOR_CATEGORY ;
END sp_get_WO_LABOR_CATEGORY;

PROCEDURE  SP_GET_WOC_TYPE_COUNTS(
    p_UserId  varchar2 DEFAULT NULL,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WOC_TYPE_COUNTS
  Author: Sridhar Kommana
  Date Created : 11/05/2014
  Purpose:  group counts for different types of clin
  Update history:
  sridhar kommana :   
  1) 05/11/2015 : Added WO_FEE , AMOUNT_FUNDED to the data set
  2) 07/16/2015 : Modified query to fetch counts from WORK_ORDERS_CLINS and WO_LABOR_CATEGORY
  3) 08/15/2015 : Modified query to fetch totals from Sub-Task tables
  */
vCount NUMBER:=0;
BEGIN
 select count(WORK_ORDERS_ID) 
 into vCount
 from WORK_ORDERS 
 WHERE  WORK_ORDERS_ID = p_WORK_ORDERS_ID;
 if vCount > 0 then     
 BEGIN 
    OPEN REC_CURSOR FOR 
   select
          NVL(SUM(LaborHours),0)  as  LaborHours, 
          NVL(SUM(LaborAmt),0)  as  LaborAmt, 
          NVL(SUM(MaterialCount),0)  as  MaterialCount, 
          NVL(SUM(MaterialAmt),0)  as  MaterialAmt, 
          NVL(SUM(TravelAmt),0)  as  TravelAmt, 
          NVL(SUM(ODCAmt),0)  as  ODCAmt, 
          NVL(sum(WO_FEE),0)  as  WO_FEE, 
          NVL(SUM(AMOUNT_FUNDED),0) as  AMOUNT_FUNDED 
   FROM
   (   select
        nvl(SUM(DECODE(clin_type,'Labor', Hours)),0) as  LaborHours, 
        nvl(SUM(DECODE(clin_type,'Labor', Amt)),0)  as  LaborAmt, 
        nvl(SUM(DECODE(clin_type,'Material', Hours)),0) as  MaterialCount,       
        nvl(SUM(DECODE(clin_type,'Material', Amt)),0) as  MaterialAmt, 
        nvl(SUM(DECODE(clin_type,'Travel', Amt)),0) as  TravelAmt ,
        nvl(SUM(DECODE(clin_type,'ODC', Amt)),0) as  ODCAmt,
         NVL(WO_FEE,0) WO_FEE,
          (select   
        nvl(SUM(AMOUNT),0)  from LSD_WO_FUNDS LWF
      WHERE LWF.WORK_ORDERS_ID   = p_WORK_ORDERS_ID ) as AMOUNT_FUNDED
  
      from 
      ( 
 
       -- TASK ORDER CLINS 
     (           SELECT WOC.WO_CLIN_TYPE AS clin_type ,
                  FK_WORK_ORDERS_ID,
                  NVL(SUM(WOC.clin_hours),0)  AS Hours,
                  NVL(SUM(WOC.clin_Amount),0) AS Amt,
                   NVL(WO_FEE,0) as WO_FEE   
                FROM 
                WORK_ORDERS_CLINS WOC
                INNER JOIN WORK_ORDERS WO 
                ON WORK_ORDERS_ID = FK_WORK_ORDERS_ID
                AND (FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID)
                WHERE (WOC.WO_CLIN_TYPE   IN ( 'Labor', 'Material','Travel','ODC')
                )
                GROUP BY WOC.WO_CLIN_TYPE,
                  FK_WORK_ORDERS_ID ,
                  WO_FEE                 
       UNION   ALL -- Labor category portion for Work Orders
                SELECT 'Labor' AS clin_type ,
                  WLC.WORK_ORDERS_ID FK_WORK_ORDERS_ID,
                  NVL(SUM(WLC.LABOR_CATEGORY_hours),0) AS Hours,
                  NVL(SUM(WLC.LC_Amount),0)            AS Amt,
                    
                  NVL(WO_FEE,0) as WO_FEE 
 
                FROM WO_LABOR_CATEGORY WLC
                INNER JOIN WORK_ORDERS WO
                ON WO.WORK_ORDERS_ID = WLC.WORK_ORDERS_ID
                AND WLC.WORK_ORDERS_ID = p_WORK_ORDERS_ID 
                GROUP BY 'Labor' ,   WLC.WORK_ORDERS_ID,   WO_FEE)
       UNION ALL -- SUB-TASK CLINS 
                 ( SELECT  STC.ST_CLIN_TYPE AS clin_type ,
                          FK_SUB_TASKS_ID,
                          NVL(SUM(STC.clin_hours),0)  AS Hours,
                          NVL(SUM(STC.clin_Amount),0) AS Amt,
                           NVL(ST_FEE,0) as WO_FEE    
                  FROM SUB_TASKS_CLINS STC
                  INNER JOIN SUB_TASKS WO  ON SUB_TASKS_ID      = FK_SUB_TASKS_ID
                  AND (STC.WORK_ORDERS_ID = p_WORK_ORDERS_ID)
                        WHERE (STC.ST_CLIN_TYPE IN ( 'Labor', 'Material','Travel','ODC'))
                        GROUP BY STC.ST_CLIN_TYPE,
                          FK_SUB_TASKS_ID ,
                          ST_FEE )
                        --LWF.SUB_TASKS_ID
      UNION ALL -- Labor category portion for SUB-TASK Orders
              SELECT 'Labor' AS clin_type ,
                WLC.SUB_TASKS_ID FK_SUB_TASKS_ID,
                NVL(SUM(WLC.LABOR_CATEGORY_hours),0) AS Hours,
                NVL(SUM(WLC.LC_Amount),0)            AS Amt,
                NVL(ST_FEE,0) as WO_FEE   
              FROM ST_LABOR_CATEGORY WLC
              INNER JOIN SUB_TASKS WO
              ON WO.SUB_TASKS_ID   = WLC.SUB_TASKS_ID
              AND WLC.WORK_ORDERS_ID = p_WORK_ORDERS_ID
              GROUP BY 'Labor' ,
                WLC.SUB_TASKS_ID,
                ST_FEE   
      )  tblCounts
     GROUP BY WO_FEE
) TotalsTable  
 ;
    END;
 else
 OPEN REC_CURSOR FOR 
   SELECT    0 as LaborHours,  0 as LaborAmt, 0 as MaterialCount, 0 as MaterialAmt,  0 as TravelAmt,  0 as ODCAmt , 0 as  WO_FEE , 0 as AMOUNT_FUNDED from dual;
 end if;
    SP_INSERT_AUDIT(p_UserId,  'pkg_work_orders.sp_GET_WOC_TYPE_COUNTS-Get group counts of Labor, ODC, Travel, Material  for WORK_ORDERS_ID='|| p_WORK_ORDERS_ID);     
    --SP_INSERT_AUDIT(p_UserId,  'pkg_work_orders.sp_GET_WOC_TYPE_COUNTS p_WORK_ORDERS_ID='|| p_WORK_ORDERS_ID); 
    
   EXCEPTION  WHEN NO_DATA_FOUND THEN 
   OPEN REC_CURSOR FOR 
       
  SELECT    0 as LaborHours,  0 as LaborAmt, 0 as MaterialCount, 0 as MaterialAmt,  0 as TravelAmt,  0 as ODCAmt  , 0 as  WO_FEE , 0 as AMOUNT_FUNDED from dual;

    
 
  WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
       
   SELECT  0 as LaborHours,  0 as LaborAmt, 0 as MaterialCount, 0 as MaterialAmt,  0 as TravelAmt,  0 as ODCAmt  , 0 as  WO_FEE , 0 as AMOUNT_FUNDED from dual;

          
END SP_GET_WOC_TYPE_COUNTS;

PROCEDURE SP_GET_TO_ST_CLINS(
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_CLIN_ID VARCHAR2 DEFAULT NULL ,
    P_WOC_ID NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0 ,
    p_UserId VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_TO_ST_CLINS
  Author: Sridhar Kommana
  Date Created : 08/30/2015
  Purpose:  Get Clin details and type info for a Task order and Sub-Task order
   */
   v_SubClin_id VARCHAR2(12) := NULL;
   v_Clin_id VARCHAR2(12) := NULL;
BEGIN

 
   v_Clin_id := P_CLIN_ID; 
   --SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_GET_TO_ST_CLINS: Get work order details P_CLIN_ID='||P_CLIN_ID|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);
  if instr(v_Clin_id,':') > 1 then 
    v_SubClin_id := substr(v_Clin_id, instr(v_Clin_id,':')+1);
    v_Clin_id := substr(v_Clin_id,1,instr(v_Clin_id,':')-1);
   else
    v_Clin_id := P_CLIN_ID; 
    v_SubClin_id := NULL;
  end if;
  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_GET_TO_ST_CLINS: Get work order CLIN details P_CLIN_ID='||P_CLIN_ID|| ' v_Clin_id='||v_Clin_id|| ' ||  v_SubClin_id='||v_SubClin_id|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);   
  OPEN REC_CURSOR FOR 
  select  distinct
    CONTRACT_NUMBER, PERIOD_OF_PERFORMANCE_ID, POP_TYPE, NVL(CLIN_ID,0) as CLIN_ID , NVL(sub_clin_id,0) as sub_clin_id ,  
    nvl(SUB_CLIN_NUMBER, CLIN_NUMBER)  CLIN_NUMBER_DISP , SUB_CLIN_NUMBER, CLIN_NUMBER,  DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) as SUB_CLIN_NUMBER_DISP,  LABOR_CATEGORY_ID, 
    (select CATEGORY_NAME from LABOR_CATEGORIES where LABOR_CATEGORIES.CATEGORY_ID = LABOR_CATEGORY_ID ) as  DESCRIPTION,   
    CLIN_TYPE , SUB_CLIN_TYPE, CLIN_TYPE_DISP,
    CLIN_SUB_CLIN , CLIN_TITLE , SUB_CLIN_TITLE, nvl(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP,
    CLIN_HOURS, CLIN_RATE,CLIN_AMOUNT, FK_WORK_ORDERS_ID as WORK_ORDERS_ID, WOC_ID,  WO_CLIN_HOURS, 0 AS WO_LABOR_CATEGORY_ID,    
     WO_CLIN_AMOUNT, LABOR_RATE_TYPE, SC_LABOR_RATE_TYPE,     
      Available_Hours_Qty ,Available_Amount,  LC_Exists --,       Remaining_Hours_Qty,Remaining_Amount, LC_Exists
  from (   
  
  SELECT POP.CONTRACT_NUMBER, POP_TYPE, C.CLIN_ID, SC.sub_clin_id, C.PERIOD_OF_PERFORMANCE_ID, C.CLIN_NUMBER, SC.SUB_CLIN_NUMBER, SC.SUB_CLIN_TYPE ,C.CLIN_TYPE , 
  --NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP , 
    NVL(WO_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) as CLIN_TYPE_DISP,
  C.CLIN_SUB_CLIN , C.CLIN_TITLE , SC.SUB_CLIN_TITLE ,  C.LABOR_CATEGORY_ID,   --L.CATEGORY_NAME AS DESCRIPTION,  
  NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) AS  CLIN_HOURS, 
  NVL(C.CLIN_RATE,0)+ NVL(SC.SUB_CLIN_RATE,0) AS  CLIN_RATE,
  NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS  CLIN_AMOUNT,
  W.WOC_ID,FK_WORK_ORDERS_ID, nvl(W.CLIN_HOURS,0)   WO_CLIN_HOURS, 
  nvl(W.CLIN_AMOUNT,0)   WO_CLIN_AMOUNT ,  
 
  (NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) 
    -  NVL(( 
    select nvl(SUM(W.CLIN_HOURS),0) from WORK_ORDERS_CLINS W WHERE 
    (W.CLIN_ID = C.CLIN_ID AND     ( W.SUB_CLIN_ID = v_SubClin_id or v_SubClin_id is NULL OR  W.SUB_CLIN_ID  = 0 )
    AND C.Clin_Type <> 'Contract')
    AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
 - (select nvl(sum(nvl(WLC.LABOR_CATEGORY_HOURS,0)),0) from WO_LABOR_CATEGORY_SESSION WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
- ( select nvl(SUM(W.CLIN_HOURS),0) from WORK_ORDERS_CLINS_SESSION W WHERE (W.CLIN_ID = C.CLIN_ID AND ( W.SUB_CLIN_ID = v_SubClin_id or v_SubClin_id is NULL OR W.SUB_CLIN_ID = 0 )   ) AND C.Clin_Type <> 'Contract'  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID))     
 -  (select nvl(sum(nvl(WLC.LABOR_CATEGORY_HOURS,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )     )
 
 as  Available_Hours_Qty ,
 
 ( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0)
  - ( select nvl(SUM(W.CLIN_AMOUNT),0) from WORK_ORDERS_CLINS W WHERE 
  (W.CLIN_ID = C.CLIN_ID AND ( W.SUB_CLIN_ID = v_SubClin_id or v_SubClin_id is NULL) )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID))
  - ( select nvl(SUM(W.CLIN_AMOUNT),0) from WORK_ORDERS_CLINS_SESSION W WHERE (W.CLIN_ID = C.CLIN_ID AND ( W.SUB_CLIN_ID = SC.SUB_CLIN_ID OR W.SUB_CLIN_ID =0 ) )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID))  
  -  (select nvl(sum(nvl(WLC.LC_AMOUNT,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID ) 
  - (SELECT NVL(SUM(CLIN_Amount),0)   FROM SUB_TASKS_CLINS WOC    WHERE WOC.CLIN_ID = C.CLIN_ID ) 
  -  (select nvl(sum(nvl(WLC.LC_AMOUNT,0)),0) from WO_LABOR_CATEGORY_SESSION WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
  - (SELECT NVL(SUM(SLC.LC_AMOUNT),0) FROM ST_LABOR_CATEGORY SLC   WHERE SLC.CLIN_ID = C.CLIN_ID )    
 ) as  Available_Amount,  
  (select DECODE(count(CLC.clin_id),0,'N','Y')  from  clin_labor_category clc where clc.clin_id= C.CLIN_ID) as  LC_Exists,     
  C.LABOR_RATE_TYPE, SC.LABOR_RATE_TYPE as SC_LABOR_RATE_TYPE, RATE_TYPE
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) 
  INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID  
  --INNER JOIN WORK_ORDERS_CLINS W ON (W.CLIN_ID = C.CLIN_ID OR  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )
INNER JOIN WORK_ORDERS_CLINS W ON
  ( (W.CLIN_ID = C.CLIN_ID AND  W.SUB_CLIN_ID = SC.SUB_CLIN_ID) OR ( W.CLIN_ID = C.CLIN_ID AND  (W.SUB_CLIN_ID Is NULL OR W.SUB_CLIN_ID =0) ) )     
  AND (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID )
  AND (C.CLIN_ID = v_Clin_id  OR v_Clin_id  is NULL)
  --v_SubClin_id
  AND (SC.SUB_CLIN_ID = v_SubClin_id OR  v_SubClin_id is NULL)
  AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0) 
  ) TBLCLINS 
  order by WOC_ID, clin_id ;
  EXCEPTION
  WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
          SELECT   1 as   CONTRACT_NUMBER,  1 as   PERIOD_OF_PERFORMANCE_ID, 1 as POP_TYPE, 1 as   CLIN_ID, 1 as   sub_clin_id,  
                   1 as   CLIN_NUMBER_DISP , 1 as   SUB_CLIN_NUMBER, 1 as    CLIN_NUMBER,  1 as   LABOR_CATEGORY_ID,  1 as   DESCRIPTION,   
                   1 as   CLIN_TYPE ,  1 as   SUB_CLIN_TYPE,  1 as   CLIN_TYPE_DISP,
                   1 as   CLIN_SUB_CLIN ,  1 as   CLIN_TITLE ,  1 as   SUB_CLIN_TITLE,  1 as    CLIN_TITLE_DISP,
                   1 as   CLIN_HOURS,  1 as   CLIN_RATE,  1 as   CLIN_AMOUNT, 1 as LABOR_RATE_TYPE, 1 as SC_LABOR_RATE_TYPE,   1 as   WOC_ID, 1 as FK_WORK_ORDERS_ID,   1 as   WO_CLIN_HOURS,    1 as   WO_CLIN_AMOUNT
                   , 1 as  Available_Hours_Qty ,1 as  Available_Amount, --1 as  WO_Hours_Qty, 1 as WO_Amount,
                   1 as  Remaining_Hours_Qty,1 as  Remaining_Amount,
                   1 as LC_Exists ,1 AS LABOR_RATE_TYPE,
                1 AS RATE_TYPE FROM dual;
END SP_GET_TO_ST_CLINS;
PROCEDURE SP_GET_ORG_TITLE 
(
  P_ORG_CODE IN VARCHAR2 ,
  p_org_title OUT VARCHAR2
) AS 
 
v_array_ORGCD apex_application_global.vc_arr2;
v_Org_title varchar2(200);
v_Org_title_all varchar2(20000);
begin
--v_array_ORGCD := apex_util.string_to_table('AFO300;AMK335;AML1080;',';');
v_array_ORGCD := apex_util.string_to_table(P_ORG_CODE,';');
v_Org_title := NULL;
--v_Org_title_all := NULL;
for i in 1..v_array_ORGCD.count
Loop--DBMS_OUTPUT.PUT_LINE(v_array_ORGCD(i));
 SELECT  distinct org_title into v_Org_title from organizations where org_cd = v_array_ORGCD(i);
 if v_Org_title is not null and i =1 then 
      v_Org_title_all := v_Org_title  ;
 else
      v_Org_title_all := v_Org_title_all ||';'||v_Org_title;
 end if;
 p_org_title := v_Org_title_all;
 --DBMS_OUTPUT.PUT_LINE('inside ' || i || ' ' ||v_Org_title_all);
 
end loop;
 --- DBMS_OUTPUT.PUT_LINE('outside==' ||v_Org_title_all);
Exception when no_data_found then
Null;
END SP_GET_ORG_TITLE;
FUNCTION FN_GET_ORG_TITLE_FROM_SP(
    p_OrgCode VARCHAR2)
  RETURN VARCHAR2
AS
  v_Title VARCHAR2(20000);
BEGIN
  SP_GET_ORG_TITLE ( REPLACE(p_OrgCode,';;',';') , v_Title ) ;
  RETURN v_Title;
END FN_GET_ORG_TITLE_FROM_SP;


PROCEDURE sp_get_TO_STs(
    p_UserId  varchar2,
    P_POP_ID varchar2 default NULL,
    p_contract_number  varchar2 ,
    TO_REC_CURSOR OUT SYS_REFCURSOR )
AS
  /*
  Procedure : sp_get_TO_STs
  Author: Sridhar Kommana
  Date Created : 01/15/2016
  Purpose:  Get Task orders an sub-tasks for each contract.
  Update history: 
  
  */
    p_status Varchar2(100) :=NULL;
BEGIN
    SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_TO_STs - Get Task Orders and sub-tasks List for a contract '||p_Contract_NUMBER  || 'P_POP_ID='||P_POP_ID);
   
      OPEN TO_REC_CURSOR
      FOR  
              SELECT WO.WORK_ORDERS_ID as ID,   null as ParentID,  WO.WORK_ORDER_Title as Title
              FROM Work_Orders WO
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)

              --LEFT OUTER JOIN SUB_TASKS  ST 
              --ON ST.WORK_ORDERS_ID = WO.WORK_ORDERS_ID                 
           
              
      UNION ALL 
              SELECT   ST.SUB_TASKS_ID as id, WO.WORK_ORDERS_ID as ParentID, ST.SUB_TASK_TITLE AS TITLE 
              FROM  SUB_TASKS  ST
              inner join WORK_ORDERS WO 
              ON WO.WORK_ORDERS_ID = ST.WORK_ORDERS_ID
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number              
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)
           
              ORDER BY parentid, title ; 
 
END sp_get_TO_STs;

PROCEDURE sp_get_TO_STsX(
    p_UserId  varchar2,
    P_POP_ID varchar2 default NULL,
    p_contract_number  varchar2 ,
    TO_REC_CURSOR OUT SYS_REFCURSOR,
    ST_REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_TO_STs
  Author: Sridhar Kommana
  Date Created : 01/15/2016
  Purpose:  Get Task orders an sub-tasks for each contract.
  Update history: 
  
  */
    p_status Varchar2(100) :=NULL;
BEGIN
    SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_TO_STs - Get Task Orders and sub-tasks List for a contract '||p_Contract_NUMBER  || 'P_POP_ID='||P_POP_ID);
   
      OPEN TO_REC_CURSOR
      FOR  
              SELECT WO.WORK_ORDERS_ID,   WO.WORK_ORDER_Title --,   ST.SUB_TASKS_ID, ST.SUB_TASK_TITLE
              FROM Work_Orders WO
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)

              --LEFT OUTER JOIN SUB_TASKS  ST 
              --ON ST.WORK_ORDERS_ID = WO.WORK_ORDERS_ID                 
           
              ORDER BY WORK_ORDER_Title desc; 
       OPEN ST_REC_CURSOR
        FOR  
              SELECT    --WO.WORK_ORDERS_ID,   WO.WORK_ORDER_Title ,  
                      ST.SUB_TASKS_ID, ST.SUB_TASK_TITLE
              FROM  SUB_TASKS  ST
              inner join WORK_ORDERS WO 
              ON WO.WORK_ORDERS_ID = ST.WORK_ORDERS_ID
              INNER JOIN PERIOD_OF_PERFORMANCE POP
              ON POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID
              AND POP.contract_number = p_contract_number              
              AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID  OR P_POP_ID IS NULL)
           
              ORDER BY SUB_TASK_TITLE desc; 
 
END sp_get_TO_STsX;


PROCEDURE SP_GET_TASKCLIN_BREAKOUTS(
    P_CONTRACT_NUMBER          VARCHAR2 DEFAULT NULL ,
    P_POP_TYPE                 VARCHAR2 DEFAULT NULL ,
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_WOC_ID                   NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID           NUMBER DEFAULT 0 ,
    p_UserId                   VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_TASKCLIN_BREAKOUTS
  Author: Sridhar Kommana
  Date Created : 04/25/2016
  Purpose:  Get Clin hours and type info for a task order order seperated by Labor travel material odc
  */
  p_status VARCHAR2(100);
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.SP_GET_TASKCLIN_BREAKOUTS: Get work order CLIN details p_Contract_NUMBER='||p_Contract_NUMBER|| 'P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| 'p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| 'P_WOC_ID='||P_WOC_ID);
  pkg_work_orders.Delete_WO_CLINS_SESSION(p_UserId,p_status);
  OPEN REC_CURSOR FOR
  SELECT DISTINCT
    --WOC_ID,
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER ||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_NUMBER_DISP,
    NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP, LABOR_CATEGORY_TITLE, CLIN_TYPE_DISP, SUM(WO_CLIN_HOURS) WO_CLIN_HOURS , WO_CLIN_Rate,
    SUM(WO_CLIN_AMOUNT) WO_CLIN_AMOUNT
     ,CLIN_ID,sub_clin_id,CLIN_TYPE as CLIN_TYPE_ORIG, LABOR_CATEGORY_ID
  FROM
    (SELECT 
     --POP.CONTRACT_NUMBER,
     -- POP_TYPE,
      C.CLIN_ID,
      SC.sub_clin_id,
      --C.PERIOD_OF_PERFORMANCE_ID,
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
   -- AND (POP.POP_TYPE             = P_POP_TYPE
   -- OR P_POP_TYPE                IS NULL) --'B'
    INNER JOIN WORK_ORDERS_CLINS W
    ON ( (W.CLIN_ID                       = C.CLIN_ID
    AND W.SUB_CLIN_ID                     = SC.SUB_CLIN_ID)
    OR ( W.CLIN_ID                        = C.CLIN_ID
    AND (W.SUB_CLIN_ID                   IS NULL
    OR W.SUB_CLIN_ID                      =0) ) )
    AND (W.WOC_ID                         = P_WOC_ID
    OR P_WOC_ID                           = 0)
    AND (W.FK_WORK_ORDERS_ID              = p_WORK_ORDERS_ID )
  --  AND (POP.CONTRACT_NUMBER              = P_CONTRACT_NUMBER
  --  OR P_CONTRACT_NUMBER                 IS NULL)--'DTFAWA-11-X-80007'
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID
   OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
UNION
    SELECT 
      --POP.CONTRACT_NUMBER,
      --POP_TYPE,
      C.CLIN_ID,
      SC.sub_clin_id,
      --C.PERIOD_OF_PERFORMANCE_ID,
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
      --W.SUB_CLIN_ID = SC.SUB_CLIN_ID AND
      W.CLIN_ID = SC.CLIN_ID ))
    INNER JOIN CLIN_LABOR_CATEGORY CLC
    ON CLC.LABOR_CATEGORY_ID    = W.LABOR_CATEGORY_ID
    AND CLC.CLIN_ID             = W.CLIN_ID
    AND (W.WO_LABOR_CATEGORY_ID = P_WOC_ID
    OR P_WOC_ID                 = 0)
    AND (W.WORK_ORDERS_ID       = p_WORK_ORDERS_ID )
      --AND W.created_by=p_UserId
    AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID
    OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
    ) TBLCLINS 
  GROUP BY  CLIN_ID,sub_clin_id,CLIN_TYPE,LABOR_CATEGORY_ID,
    DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER
    ||SUB_CLIN_NUMBER,CLIN_NUMBER ) , NVL(SUB_CLIN_TITLE,CLIN_TITLE) , LABOR_CATEGORY_TITLE, CLIN_TYPE_DISP, WO_CLIN_Rate
  ORDER BY 1 ;
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
  SELECT   0 SUB_CLIN_NUMBER_DISP, 0 CLIN_TITLE_DISP, 0 LABOR_CATEGORY_TITLE, 0 CLIN_TYPE_DISP, 0 WO_CLIN_HOURS , 0 WO_CLIN_Rate, 0 WO_CLIN_AMOUNT from dual;
END SP_GET_TASKCLIN_BREAKOUTS;

PROCEDURE sp_get_Contract_TOs(
    p_UserId  varchar2,
    P_POP_ID varchar2, 
    p_contract_number  varchar2 ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : sp_get_Contract_TOs
  Author: Sridhar Kommana
  Date Created : 05/23/2016
  Purpose:  Get Task/Sub-Task orders for each contract.
  Update history: 
  05/24/2016 Sridhar Kommana Modified columns  to match the dropdown on front-end
  05/31/2016 :Sridhar kommana Added clinumber to title
  06/13/2016 : SRidhar Kommana Removed outer join to sub-tasks
  07/05/2016 : Sridhar Kommana Added ContractNumber as top row in union RTM ID :: DBREQ07052016
  07/14/206  : Sridhar Kommana Added decode statement to WORK_ORDER_NUMBER_DISP RTM ID :  I01-15
  07/14/206  : Sridhar Kommana  concatinated  Work_order_id to sub-taskid  statement to fix same ids for work order and sub-task-order:  I01-17
  
  
  */
    
BEGIN
      SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.sp_get_Contract_TOs - Get Task/Sub-Task orders for each contract.p_Contract_NUMBER= '||p_Contract_NUMBER  || 'P_POP_ID='||P_POP_ID);
   
      OPEN REC_CURSOR
      FOR
            
      select 
        C.Contract_Number, C.Cor_Name ,
            Pop.Pop_Type, Pop.Period_Of_Performance_Id,  
            C.Contract_Number as WORK_ORDERS_ID,  C.Contract_Number as WORK_ORDER_NUMBER, NULL as WORK_ORDER_Title, NULL as   FAA_POC, 
            NULL as Parent_Id , NULL   as SUB_TASKS_ID, NULL as  SUB_TASK_NUMBER , 
             NULL as SUB_TASK_TITLE, NULL as  ST_FAA_POC,  C.Contract_Number  as  WORK_ORDER_NUMBER_DISP, 1 as SortOrder
      FROM Contract C, Period_Of_Performance POP--, Work_orders WO --, SUB_TASKS ST
      Where C.Contract_Number=POP.Contract_Number 
      AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID)--  OR P_POP_ID = 0 )
     -- AND POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID(+)
     -- AND WO.Work_Orders_Id = ST.Work_Orders_Id(+) 
      AND C.Contract_Number=p_contract_number 
       UNION  
      select 
        C.Contract_Number, C.Cor_Name ,
            Pop.Pop_Type, Pop.Period_Of_Performance_Id,  
            to_char(WO.WORK_ORDERS_ID) as WORK_ORDERS_ID,  WO.WORK_ORDER_NUMBER, WO.WORK_ORDER_Title, WO.FAA_POC  FAA_POC, 
            NULL as Parent_Id , WO.WORK_ORDERS_ID as SUB_TASKS_ID, WO.WORK_ORDER_NUMBER SUB_TASK_NUMBER , 
             WO.WORK_ORDER_Title SUB_TASK_TITLE, WO.FAA_POC ST_FAA_POC, DECODE(WO.WORK_ORDER_NUMBER, NULL,'',  WO.WORK_ORDER_NUMBER||': '||WO.WORK_ORDER_Title) as WORK_ORDER_NUMBER_DISP ,2 as SortOrder
      FROM Contract C, Period_Of_Performance POP, Work_orders WO --, SUB_TASKS ST
      Where C.Contract_Number=POP.Contract_Number 
      AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID)--  OR P_POP_ID = 0 )
      AND POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID(+)
     -- AND WO.Work_Orders_Id = ST.Work_Orders_Id(+) 
      AND C.Contract_Number=p_contract_number 
      UNION      
      select 
       C.Contract_Number, C.Cor_Name ,
            Pop.Pop_Type, Pop.Period_Of_Performance_Id,  
            to_char(St.Work_Orders_Id||':'||ST.SUB_TASKS_ID) as WORK_ORDERS_ID,  ST.SUB_TASK_NUMBER  WORK_ORDER_NUMBER, WO.WORK_ORDER_Title, WO.FAA_POC  FAA_POC, 
            to_char(St.Work_Orders_Id) as Parent_Id , ST.SUB_TASKS_ID , ST.SUB_TASK_NUMBER ,  ST.SUB_TASK_TITLE, ST.FAA_POC ST_FAA_POC
            ,  DECODE(ST.SUB_TASK_NUMBER, NULL,'', ST.SUB_TASK_NUMBER||': '||ST.SUB_TASK_TITLE) as WORK_ORDER_NUMBER_DISP, 3 as SortOrder
      FROM Contract C, Period_Of_Performance POP, Work_orders WO, SUB_TASKS ST
      Where C.Contract_Number=POP.Contract_Number 
      AND (POP.PERIOD_OF_PERFORMANCE_ID = P_POP_ID)--  OR P_POP_ID = 0 )
      AND POP.PERIOD_OF_PERFORMANCE_ID = WO.PERIOD_OF_PERFORMANCE_ID(+)
      AND WO.Work_Orders_Id = ST.Work_Orders_Id--  (+) //Commented by Sridhar on 06/13/2016
      AND C.Contract_Number=p_contract_number

       ORDER BY SortOrder asc, Parent_Id desc,SUB_TASKS_ID asc    ;
      --ORDER BY Parent_Id desc,SUB_TASKS_ID asc;      

      
EXCEPTION WHEN OTHERS
THEN 
      OPEN REC_CURSOR
      FOR  
      select NULL as Contract_Number,  NULL as Cor_Name ,
             NULL as Pop_Type,  NULL as Period_Of_Performance_Id,  
             NULL as WORK_ORDERS_ID,   NULL as WORK_ORDER_NUMBER,  NULL as WORK_ORDER_Title,  NULL as  FAA_POC, 
             NULL as Parent_Id ,  NULL as SUB_TASKS_ID,  NULL as SUB_TASK_NUMBER ,   NULL as SUB_TASK_TITLE,  NULL as ST_FAA_POC
      FROM DUAL;
 
END sp_get_Contract_TOs;

  PROCEDURE Delete_WO_ID_CLINS_SESSION(
      p_CREATED_BY IN WORK_ORDERS_CLINS_SESSION.CREATED_BY%TYPE ,
      p_WORK_ORDERS_ID IN WORK_ORDERS_CLINS_SESSION.CREATED_BY%TYPE ,
      p_PStatus OUT VARCHAR2 )
  /*
  Procedure : Delete_WO_ID_CLINS_SESSION
  Author: Sridhar Kommana
  Date Created : 06/13/2016
  Purpose:  delete session record based on work order id and user.
  Update history: 
  */      
  IS
 
  BEGIN
    SP_INSERT_AUDIT( p_CREATED_BY,'pkg_work_orders.Delete_WO_ID_CLINS_SESSION p_CREATED_BY= '||p_CREATED_BY||'p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID  );
    --Delete all temp wo clins
    DELETE WORK_ORDERS_CLINS_SESSION
    WHERE CREATED_BY = p_CREATED_BY
    AND FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID ;    
    
    DELETE WO_LABOR_CATEGORY_SESSION
    WHERE CREATED_BY = p_CREATED_BY 
    AND WORK_ORDERS_ID = p_WORK_ORDERS_ID ;  
    
    IF SQL%FOUND THEN
      p_PStatus := 'SUCCESS' ;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_PStatus := 'Error deleting Delete_WO_ID_CLINS_SESSION '||SQLERRM ;
    SP_INSERT_AUDIT( p_CREATED_BY,'Error pkg_work_orders.Delete_WO_ID_CLINS_SESSION'||'||SQLERRM|| p_CREATED_BY= '||p_CREATED_BY||'p_WORK_ORDERS_ID= '||p_WORK_ORDERS_ID  );
  END Delete_WO_ID_CLINS_SESSION;

PROCEDURE SP_GET_WO_CLINS_SESS (
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_CLIN_ID NUMBER DEFAULT NULL ,
    P_WOC_ID NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID NUMBER DEFAULT 0 ,
    p_UserId VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WO_CLINS_SESS 
  Author: Sridhar Kommana
  Date Created : 06/26/2015
  Purpose:  Get Clin details and type info for a work order session while creating a work order.
  Update history:
   */
   
BEGIN
   SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.SP_GET_WO_CLINS_SESS : Get work order details P_CLIN_ID='||P_CLIN_ID|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);

  OPEN REC_CURSOR FOR 
  select  distinct
   CONTRACT_NUMBER, PERIOD_OF_PERFORMANCE_ID, POP_TYPE, CLIN_ID, sub_clin_id,  
    nvl(SUB_CLIN_NUMBER, CLIN_NUMBER)  CLIN_NUMBER_DISP , SUB_CLIN_NUMBER, CLIN_NUMBER,  DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) as SUB_CLIN_NUMBER_DISP,  LABOR_CATEGORY_ID, 
      LABOR_CATEGORY_TITLE,  
    CLIN_TYPE , SUB_CLIN_TYPE, CLIN_TYPE_DISP,
    CLIN_SUB_CLIN , CLIN_TITLE , SUB_CLIN_TITLE, nvl(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP,
    CLIN_HOURS, CLIN_RATE,CLIN_AMOUNT, FK_WORK_ORDERS_ID as WORK_ORDERS_ID, WOC_ID,  WO_CLIN_HOURS, WO_CLIN_RATE, 0 AS WO_LABOR_CATEGORY_ID,    
     WO_CLIN_AMOUNT, LABOR_RATE_TYPE, SC_LABOR_RATE_TYPE,     
    --  Available_Hours_Qty ,Available_Amount,  
     0 as Remaining_Hours_Qty, 0 as Remaining_Amount --, LC_Exists*/
       
  from (   
  SELECT POP.CONTRACT_NUMBER, POP_TYPE, C.CLIN_ID, SC.sub_clin_id, C.PERIOD_OF_PERFORMANCE_ID, C.CLIN_NUMBER, SC.SUB_CLIN_NUMBER, SC.SUB_CLIN_TYPE ,C.CLIN_TYPE , 
  --NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP , 
  NVL(WO_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) as CLIN_TYPE_DISP,  
  C.CLIN_SUB_CLIN , C.CLIN_TITLE , SC.SUB_CLIN_TITLE ,  C.LABOR_CATEGORY_ID, '' as LABOR_CATEGORY_TITLE ,  --L.CATEGORY_NAME AS DESCRIPTION,  
  NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) AS  CLIN_HOURS, 
  NVL(C.CLIN_RATE,0)+ NVL(SC.SUB_CLIN_RATE,0) AS  CLIN_RATE,
  NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS  CLIN_AMOUNT,
  W.WOC_ID,FK_WORK_ORDERS_ID, nvl(W.CLIN_HOURS,0)   WO_CLIN_HOURS,  WO_RATE as   WO_CLIN_RATE, 
  nvl(W.CLIN_AMOUNT,0)   WO_CLIN_AMOUNT ,  
/*
(   
    NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0)
  - NVL((select nvl(SUM(W.CLIN_HOURS),0) from WORK_ORDERS_CLINS W WHERE (W.CLIN_ID = C.CLIN_ID and  (W.SUB_CLIN_ID = SC.SUB_CLIN_ID OR W.SUB_CLIN_ID =0 )   AND C.Clin_Type <> 'Contract' )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
  - NVL((select nvl(SUM(W.CLIN_HOURS),0) from WORK_ORDERS_CLINS_SESSION W WHERE (W.CLIN_ID = C.CLIN_ID and   (W.SUB_CLIN_ID = SC.SUB_CLIN_ID OR W.SUB_CLIN_ID =0 )  AND C.Clin_Type <> 'Contract' )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
  - (select nvl(sum(nvl(WLC.LABOR_CATEGORY_HOURS,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
  - (select nvl(sum(nvl(WLC.LABOR_CATEGORY_HOURS,0)),0) from WO_LABOR_CATEGORY_SESSION WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
  - (SELECT NVL(SUM(CLIN_Hours),0)   FROM SUB_TASKS_CLINS WOC    WHERE WOC.CLIN_ID = C.CLIN_ID ) 
  - (SELECT NVL(SUM(SLC.LABOR_CATEGORY_HOURS),0) FROM ST_LABOR_CATEGORY SLC WHERE SLC.CLIN_ID = C.CLIN_ID )    
 )
 */ 
 0 as  Remaining_Hours_Qty, 
 /*
 ( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0)  - 
   NVL(( select nvl(SUM(W.CLIN_AMOUNT),0) from WORK_ORDERS_CLINS W WHERE (W.CLIN_ID = C.CLIN_ID and   (W.SUB_CLIN_ID = SC.SUB_CLIN_ID OR W.SUB_CLIN_ID =0 )  )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
   -( select nvl(SUM(W.CLIN_AMOUNT),0) from WORK_ORDERS_CLINS_SESSION W WHERE (W.CLIN_ID = C.CLIN_ID and 
   (W.SUB_CLIN_ID = SC.SUB_CLIN_ID OR W.SUB_CLIN_ID =0 )  )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)  AND w.created_by=p_UserId ) 
 - (select nvl(sum(nvl(WLC.LC_AMOUNT,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
  -  (select nvl(sum(nvl(WLC.LC_AMOUNT,0)),0) from WO_LABOR_CATEGORY_SESSION WLC   WHERE WLC.CLIN_ID = C.CLIN_ID AND WLC.created_by=p_UserId )
  - (SELECT NVL(SUM(CLIN_Amount),0)   FROM SUB_TASKS_CLINS WOC    WHERE WOC.CLIN_ID = C.CLIN_ID ) 
  - (SELECT NVL(SUM(SLC.LC_AMOUNT),0) FROM ST_LABOR_CATEGORY SLC   WHERE SLC.CLIN_ID = C.CLIN_ID )   

) */ 0  as  Remaining_Amount,
 
 --(select DECODE(count(CLC.clin_id),0,'N','Y')  from  clin_labor_category clc where clc.clin_id= C.CLIN_ID) as  LC_Exists,       
  C.LABOR_RATE_TYPE, SC.LABOR_RATE_TYPE as SC_LABOR_RATE_TYPE, RATE_TYPE
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) 
  INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID  
INNER JOIN WORK_ORDERS_CLINS_SESSION W ON
  ( (W.CLIN_ID = C.CLIN_ID AND  W.SUB_CLIN_ID = SC.SUB_CLIN_ID) OR ( W.CLIN_ID = C.CLIN_ID AND  (W.SUB_CLIN_ID Is NULL OR W.SUB_CLIN_ID =0) ) )
  AND (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID )
  AND W.created_by=p_UserId
  AND (C.CLIN_ID = P_CLIN_ID OR P_CLIN_ID is NULL) 
  AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0) 




UNION ---Also include labor categories sessions
   


  SELECT POP.CONTRACT_NUMBER, POP_TYPE, C.CLIN_ID, SC.sub_clin_id, C.PERIOD_OF_PERFORMANCE_ID, C.CLIN_NUMBER, SC.SUB_CLIN_NUMBER, SC.SUB_CLIN_TYPE ,C.CLIN_TYPE , 
  --NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE) CLIN_TYPE_DISP , 
  'Labor' as CLIN_TYPE_DISP,
  C.CLIN_SUB_CLIN , C.CLIN_TITLE , SC.SUB_CLIN_TITLE ,  C.LABOR_CATEGORY_ID, CLC.LABOR_CATEGORY_TITLE ,
  NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) AS  CLIN_HOURS, 
  NVL(C.CLIN_RATE,0)+ NVL(SC.SUB_CLIN_RATE,0) AS  CLIN_RATE,
  NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0) AS  CLIN_AMOUNT,
  W.WO_LABOR_CATEGORY_ID WOC_ID,WORK_ORDERS_ID, nvl(W.LABOR_CATEGORY_HOURS,0)   WO_CLIN_HOURS,  nvl(W.LABOR_CATEGORY_Rate,0)   WO_CLIN_RATE, 
  --nvl(W.CLIN_AMOUNT,0)   WO_CLIN_AMOUNT ,  
 LC_AMOUNT as  WO_CLIN_AMOUNT ,  

/*    (NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) 
    -  NVL(( 
    select nvl(SUM(W.CLIN_HOURS),0) from WORK_ORDERS_CLINS W WHERE 
    (W.CLIN_ID = C.CLIN_ID OR  W.SUB_CLIN_ID = SC.SUB_CLIN_ID   
    AND C.Clin_Type <> 'Contract')
    AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
 -  (select nvl(sum(nvl(WLC.LABOR_CATEGORY_HOURS,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )     ) as  Available_Hours_Qty ,
 
 ( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0)
  - NVL(( select nvl(SUM(W.CLIN_AMOUNT),0) from WORK_ORDERS_CLINS W WHERE (W.CLIN_ID = C.CLIN_ID OR  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
  -  (select nvl(sum(nvl(WLC.LC_AMOUNT,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
   ) as  Available_Amount, */   
 /*(NVL(C.CLIN_HOURS,0)+ NVL(SC.SUB_CLIN_HOURS,0) 
  -  NVL(( select nvl(SUM(W.CLIN_HOURS),0) from WORK_ORDERS_CLINS W WHERE (W.CLIN_ID = C.CLIN_ID AND  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
 - (select nvl(sum(nvl(WLC.LABOR_CATEGORY_HOURS,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
 - ( select nvl(SUM(W.CLIN_HOURS),0) from WORK_ORDERS_CLINS_SESSION W WHERE (W.CLIN_ID = C.CLIN_ID and  W.SUB_CLIN_ID = SC.SUB_CLIN_ID AND C.Clin_Type <> 'Contract' ) 
 AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)  AND W.created_by=p_UserId)
 - (select nvl(sum(nvl(WLC.LABOR_CATEGORY_HOURS,0)),0) from WO_LABOR_CATEGORY_SESSION WLC   WHERE WLC.CLIN_ID = C.CLIN_ID AND WLC.created_by=p_UserId)
 - (SELECT NVL(SUM(CLIN_Hours),0)   FROM SUB_TASKS_CLINS WOC    WHERE WOC.CLIN_ID = C.CLIN_ID ) 
 - (SELECT NVL(SUM(SLC.LABOR_CATEGORY_HOURS),0) FROM ST_LABOR_CATEGORY SLC   WHERE SLC.CLIN_ID = C.CLIN_ID )    
 ) */
 0 as  Remaining_Hours_Qty, 
 
 /*( NVL(C.CLIN_AMOUNT,0)+ NVL(SC.SUB_CLIN_AMOUNT,0)  - 
   NVL(( select nvl(SUM(W.CLIN_AMOUNT),0) from WORK_ORDERS_CLINS W WHERE (W.CLIN_ID = C.CLIN_ID AND  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)
-NVL(( select nvl(SUM(W.CLIN_AMOUNT),0) from WORK_ORDERS_CLINS_SESSION W WHERE (W.CLIN_ID = C.CLIN_ID AND  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = C.PERIOD_OF_PERFORMANCE_ID)),0)   
 - (select nvl(sum(nvl(WLC.LC_AMOUNT,0)),0) from WO_LABOR_CATEGORY WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
  -  (select nvl(sum(nvl(WLC.LC_AMOUNT,0)),0) from WO_LABOR_CATEGORY_SESSION WLC   WHERE WLC.CLIN_ID = C.CLIN_ID )
  - (SELECT NVL(SUM(CLIN_Amount),0)   FROM SUB_TASKS_CLINS WOC    WHERE WOC.CLIN_ID = C.CLIN_ID ) 
  - (SELECT NVL(SUM(SLC.LC_AMOUNT),0) FROM ST_LABOR_CATEGORY SLC   WHERE SLC.CLIN_ID = C.CLIN_ID )     
 )
  */
 0 as  Remaining_Amount,
 
 
 --(select DECODE(count(CLC.clin_id),0,'N','Y')  from  clin_labor_category clc where clc.clin_id= C.CLIN_ID) as  LC_Exists,       
  C.LABOR_RATE_TYPE, SC.LABOR_RATE_TYPE as SC_LABOR_RATE_TYPE, RATE_TYPE
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID) 
  INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID  
  INNER JOIN WO_LABOR_CATEGORY_SESSION W ON (W.CLIN_ID = C.CLIN_ID ) --OR  W.SUB_CLIN_ID = SC.SUB_CLIN_ID )
  INNER JOIN CLIN_LABOR_CATEGORY CLC ON CLC.LABOR_CATEGORY_ID = W.LABOR_CATEGORY_ID 
  AND CLC.CLIN_ID = W.CLIN_ID 
  AND (W.WO_LABOR_CATEGORY_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.WORK_ORDERS_ID = p_WORK_ORDERS_ID )
  AND W.created_by=p_UserId
  AND (C.CLIN_ID = P_CLIN_ID OR P_CLIN_ID is NULL) 
  AND (C.PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0) 
  
  ) TBLCLINS 
--  WHERE Available_Hours_Qty >0   or Available_Amount>0
  order by WOC_ID, clin_id ;
  EXCEPTION
  WHEN OTHERS THEN
  OPEN REC_CURSOR FOR 
          SELECT   1 as   CONTRACT_NUMBER,  1 as   PERIOD_OF_PERFORMANCE_ID, 1 as POP_TYPE, 1 as   CLIN_ID, 1 as   sub_clin_id,  
                   1 as   CLIN_NUMBER_DISP , 1 as   SUB_CLIN_NUMBER, 1 as    CLIN_NUMBER,  1 as   LABOR_CATEGORY_ID,  1 as   DESCRIPTION,   
                   1 as   CLIN_TYPE ,  1 as   SUB_CLIN_TYPE,  1 as   CLIN_TYPE_DISP,
                   1 as   CLIN_SUB_CLIN ,  1 as   CLIN_TITLE ,  1 as   SUB_CLIN_TITLE,  1 as    CLIN_TITLE_DISP,
                   1 as   CLIN_HOURS,  1 as   CLIN_RATE,  1 as   CLIN_AMOUNT, 1 as LABOR_RATE_TYPE, 1 as SC_LABOR_RATE_TYPE,   1 as   WOC_ID, 1 as FK_WORK_ORDERS_ID,   1 as   WO_CLIN_HOURS,    1 as   WO_CLIN_AMOUNT
                   , 1 as  Available_Hours_Qty ,1 as  Available_Amount, --1 as  WO_Hours_Qty, 1 as WO_Amount,
                   1 as  Remaining_Hours_Qty,1 as  Remaining_Amount,
                   1 as LC_Exists ,1 AS LABOR_RATE_TYPE,
                1 AS RATE_TYPE FROM dual;
END SP_GET_WO_CLINS_SESS ;


PROCEDURE SP_GET_WO_CLINS_SESS_NEW(
    P_PERIOD_OF_PERFORMANCE_ID NUMBER DEFAULT NULL ,
    P_CLIN_ID                  NUMBER DEFAULT NULL ,
    P_WOC_ID                   NUMBER DEFAULT 0 ,
    p_WORK_ORDERS_ID           NUMBER DEFAULT 0 ,
    p_UserId                   VARCHAR2 DEFAULT NULL ,
    REC_CURSOR OUT SYS_REFCURSOR)
AS
  /*
  Procedure : SP_GET_WO_CLINS_SESS_NEW
  Author: Sridhar Kommana
  Date Created : 06/26/2015
  Purpose:  Get Clin details and type info for a work order session while creating a work order.
  Update history:
  */
BEGIN
  SP_INSERT_AUDIT(p_UserId, 'pkg_work_orders.SP_GET_WO_CLINS_SESS_NEW*: Get work order details P_CLIN_ID='||P_CLIN_ID|| ' P_PERIOD_OF_PERFORMANCE_ID='||P_PERIOD_OF_PERFORMANCE_ID|| ' p_WORK_ORDERS_ID='||p_WORK_ORDERS_ID|| ' P_WOC_ID='||P_WOC_ID);
  OPEN REC_CURSOR FOR 
  SELECT DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) AS SUB_CLIN_NUMBER_DISP, 
  NVL(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP,
  NULL AS   LABOR_CATEGORY_TITLE,
  NVL(WO_CLIN_TYPE, NVL(SC.SUB_CLIN_TYPE ,C.CLIN_TYPE)) AS   CLIN_TYPE_DISP,
  W.CLIN_HOURS as WO_CLIN_HOURS, WO_Rate WO_CLIN_Rate, 
  W.CLIN_AMOUNT WO_CLIN_AMOUNT, 
  0 Remaining_Hours_Qty, 
  0 Remaining_Amount 
  FROM POP_CLIN C LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID)

  INNER JOIN WORK_ORDERS_CLINS_SESSION W ON W.Clin_ID = C.CLIN_ID WHERE ( (W.CLIN_ID = C.CLIN_ID AND W.SUB_CLIN_ID = SC.SUB_CLIN_ID) 
  OR ( W.CLIN_ID = C.CLIN_ID AND (W.SUB_CLIN_ID IS NULL OR W.SUB_CLIN_ID =0) ) )
  --AND   (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.FK_WORK_ORDERS_ID = p_WORK_ORDERS_ID ) AND W.created_by=p_UserId AND (W.CLIN_ID = P_CLIN_ID OR P_CLIN_ID IS NULL) 
  AND (W.FK_PERIOD_OF_PERFORMANCE_ID = P_PERIOD_OF_PERFORMANCE_ID OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0)
  UNION ---Also include labor categories sessions
  SELECT
    --  DECODE(CLIN_SUB_CLIN, 'Y', CLIN_NUMBER||SUB_CLIN_NUMBER,CLIN_NUMBER ) as SUB_CLIN_NUMBER_DISP,
    -- nvl(SUB_CLIN_TITLE,CLIN_TITLE) CLIN_TITLE_DISP,
    CLIN_NUMBER AS SUB_CLIN_NUMBER_DISP,
    CLIN_TITLE CLIN_TITLE_DISP,
    CLC.LABOR_CATEGORY_TITLE,
    'Labor' AS CLIN_TYPE_DISP,
    NVL(W.LABOR_CATEGORY_HOURS,0) WO_CLIN_HOURS,
    NVL(W.LABOR_CATEGORY_Rate,0) WO_CLIN_RATE,
    LC_AMOUNT AS WO_CLIN_AMOUNT,
    0 Remaining_Hours_Qty,
    0 Remaining_Amount
  FROM POP_CLIN C --LEFT OUTER JOIN SUB_CLIN SC ON (SC.CLIN_ID = C.CLIN_ID)
    --INNER JOIN PERIOD_OF_PERFORMANCE POP ON C.PERIOD_OF_PERFORMANCE_ID = POP.PERIOD_OF_PERFORMANCE_ID
  INNER JOIN WO_LABOR_CATEGORY_SESSION W
  ON W.Clin_ID = C.CLIN_ID
  INNER JOIN CLIN_LABOR_CATEGORY CLC
  ON CLC.LABOR_CATEGORY_ID = W.LABOR_CATEGORY_ID
  AND CLC.CLIN_ID          = W.CLIN_ID
  WHERE W.CLIN_ID          = C.CLIN_ID
    --  ( (W.CLIN_ID = C.CLIN_ID AND  W.SUB_CLIN_ID = SC.SUB_CLIN_ID) OR ( W.CLIN_ID = C.CLIN_ID AND  (W.SUB_CLIN_ID Is NULL OR W.SUB_CLIN_ID =0) ) )
    ---AND (W.WOC_ID = P_WOC_ID OR P_WOC_ID = 0)
  AND (W.WORK_ORDERS_ID                 = p_WORK_ORDERS_ID )
  AND W.created_by                      =p_UserId
  AND (W.CLIN_ID                        = P_CLIN_ID
  OR P_CLIN_ID                         IS NULL)
  AND (C.PERIOD_OF_PERFORMANCE_ID       = P_PERIOD_OF_PERFORMANCE_ID  
  OR NVL(P_PERIOD_OF_PERFORMANCE_ID, 0) = 0);
EXCEPTION
WHEN OTHERS THEN
  OPEN REC_CURSOR FOR SELECT NULL AS  CLIN_NUMBER_DISP FROM dual;
END SP_GET_WO_CLINS_SESS_NEW;
END pkg_work_orders;
/