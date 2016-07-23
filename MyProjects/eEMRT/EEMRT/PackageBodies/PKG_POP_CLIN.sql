CREATE OR REPLACE PACKAGE BODY eemrt."PKG_POP_CLIN" 
IS
   /*
   Package : PKG_POP_CLIN
   Author: Sridhar Kommana
   Date Created : 09/15/2015
   Purpose:  All procedures related to CLIN

   Update history:
    11/10/2015 : Sridhar Kommana : Added new duplicate_val_index check for pop_clin insert.
    11/19/2015 : Sridhar Kommana : Added POP_TYPE
    04/07/2016 : Sridhar Kommana : Added new paramters for Travel Material and ODC amounts
    04/09/2016 : Sridhar Kommana, SriHari Gokina: Added new paramters for Travel Material and ODC amounts added merge statements for insert and update  insert_POP_CLIN, update_POP_CLIN
    04/09/2016 : Sridhar Kommana : Changed sequence in insert_POP_CLIN
    04/10/2016 : Srihari Gokina  : Getting New Sequence (CLIN_TMO_SEQ.NEXTVAL;) value, Verify If Already Used current valuein Previous Insert
    04/11/2016 : Sridhar Kommana, SriHari Gokina Added New cols Travel_Amount, Material_Amount, ODC_Amount for RTM-ID = CLINCHANGE
    04/14/2016 : Sridhar Kommana Added new Procedure : sp_get_CLIN_LC_Breakouts for new RTMId C01
    04/14/2016 : Srihari Gokina  : Added New SP: SP_GET_CLIN_BREAKOUT_AMOUNTS
    04/21/2016 : Sridhar Kommana Addded new breakout amount type :Labor
    05/01/2016 : Srihari Gokina  : Added Exceptions to Insert and Update CLIN_TMO SPs
    06/08/2016 : Sridhar Kommana : Removed sub task rate type col from SP_GET_CLIN to fix duplicates issue
    07/19/2016 : Srihari Gokina  : Add PGM_NAME (Program Name) to SP get_Labor_categories....
   */


   PROCEDURE insert_POP_CLIN (
      p_PERIOD_OF_PERFORMANCE_ID   IN     POP_CLIN.PERIOD_OF_PERFORMANCE_ID%TYPE DEFAULT NULL ,
      p_CLIN_NUMBER                IN     POP_CLIN.CLIN_NUMBER%TYPE DEFAULT NULL,
      p_CLIN_TYPE                  IN     POP_CLIN.CLIN_TYPE%TYPE DEFAULT NULL,
      p_CLIN_SUB_CLIN              IN     POP_CLIN.CLIN_SUB_CLIN%TYPE DEFAULT NULL,
      p_CLIN_TITLE                 IN     POP_CLIN.CLIN_TITLE%TYPE DEFAULT NULL,
      p_CLIN_HOURS                 IN     POP_CLIN.CLIN_HOURS%TYPE DEFAULT NULL,
      p_CLIN_RATE                  IN     POP_CLIN.CLIN_RATE%TYPE DEFAULT NULL,
      p_CLIN_AMOUNT                IN     POP_CLIN.CLIN_AMOUNT%TYPE DEFAULT NULL,
      p_HOURS_COMMITED             IN     POP_CLIN.HOURS_COMMITED%TYPE DEFAULT NULL,
      p_LABOR_CATEGORY_ID          IN     SUB_CLIN.LABOR_CATEGORY_ID%TYPE DEFAULT NULL,
      p_HASLABORCATEGORIES         IN     POP_CLIN.HASLABORCATEGORIES%TYPE DEFAULT NULL,
      p_LABOR_RATE_TYPE            IN     POP_CLIN.LABOR_RATE_TYPE%TYPE DEFAULT NULL,
      p_RATE_TYPE                  IN     POP_CLIN.RATE_TYPE%TYPE DEFAULT NULL,
      p_CREATED_BY                 IN     POP_CLIN.CREATED_BY%TYPE DEFAULT NULL,
      p_Labor_Amount               IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL,
      p_Travel_Amount              IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL,
      p_Material_Amount            IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL,
      p_ODC_Amount                 IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL,
      p_ID                            OUT work_orders.WORK_ORDERS_ID%TYPE,
      p_PStatus                       OUT VARCHAR2
   )
   IS
      v_Temp_id   NUMBER := POP_CLIN_SEQ.NEXTVAL;
   BEGIN
      SP_INSERT_AUDIT (
         p_CREATED_BY,
         'PKG_POP_CLIN.insert_POP_CLIN p_CLIN_NUMBER=' || p_CLIN_NUMBER
      );

      BEGIN
         INSERT INTO POP_CLIN (CLIN_ID,
                               PERIOD_OF_PERFORMANCE_ID,
                               CLIN_NUMBER,
                               CLIN_TYPE,
                               CLIN_SUB_CLIN,
                               CLIN_TITLE,
                               CLIN_HOURS,
                               CLIN_RATE,
                               CLIN_AMOUNT,
                               HOURS_COMMITED,
                               LABOR_CATEGORY_ID,
                               HASLABORCATEGORIES,
                               LABOR_RATE_TYPE,
                               RATE_TYPE,
                               CREATED_BY,
                               CREATED_ON)
           VALUES   (v_Temp_id,                        --POP_CLIN_SEQ.NEXTVAL,
                     p_PERIOD_OF_PERFORMANCE_ID,
                     p_CLIN_NUMBER,
                     p_CLIN_TYPE,
                     p_CLIN_SUB_CLIN,
                     p_CLIN_TITLE,
                     p_CLIN_HOURS,
                     p_CLIN_RATE,
                     p_CLIN_AMOUNT,
                     p_HOURS_COMMITED,
                     p_LABOR_CATEGORY_ID,
                     p_HASLABORCATEGORIES,
                     p_LABOR_RATE_TYPE,
                     p_RATE_TYPE,
                     p_CREATED_BY,
                     SYSDATE ());

         p_ID := v_Temp_id;

         IF SQL%FOUND
         THEN
            p_PStatus := 'SUCCESS';
            COMMIT;
  SP_INSERT_AUDIT (
         p_CREATED_BY,
         'PKG_POP_CLIN.insert_POP_CLIN SUCCESS p_CLIN_ID=' || v_Temp_id
      );            
         END IF;
        EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            ROLLBACK;
            p_PStatus :=
               'The CLIN Number you have entered is already in use under this Period of Performance (POP).  Please enter a unique CLIN Number.';
               RETURN;
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_PStatus := SQLERRM || '  Error Inserting POP_CLIN';
            RETURN;
      END;

      BEGIN                   ---Start Adding other clin amounts for this clin
         SP_INSERT_AUDIT (
            p_CREATED_BY,
            'PKG_POP_CLIN.insert_POP_CLIN  Adding other clin amounts p_CLIN_NUMBER='
            || p_CLIN_NUMBER
         );

         IF  p_PStatus = 'SUCCESS' AND p_Labor_Amount IS NOT NULL
         THEN
         BEGIN
            SP_INSERT_AUDIT (
               p_CREATED_BY,
               'PKG_POP_CLIN.insert_POP_CLIN  Adding other clin  Labor_Amount amounts p_Labor_Amount='
               || p_Labor_Amount
            );

            INSERT INTO Clin_Tmo (CLIN_TMO_ID,
                                  CLIN_ID,
                                  CLIN_NUMBER,
                                  CLIN_Title,
                                  CLIN_Type,
                                  CLIN_AMOUNT,
                                  CREATED_BY,
                                  CREATED_ON)
              VALUES   (CLIN_TMO_SEQ.NEXTVAL,
                        v_Temp_id,
                        p_CLIN_NUMBER, -- || '-Labor',
                        p_CLIN_TITLE, -- || '-Labor',
                        'Labor',
                        p_Labor_Amount,
                        p_CREATED_BY,
                        SYSDATE ());

            IF SQL%FOUND
            THEN
               p_PStatus := 'SUCCESS';
               COMMIT;
            END IF;
            EXCEPTION
            WHEN OTHERS
            THEN
              ROLLBACK;
              p_PStatus := 'Error Updating Labor Amount to CLIN_TMO';
          END;
         END IF;
        
         IF  p_PStatus = 'SUCCESS' AND p_Travel_Amount IS NOT NULL
         THEN
         BEGIN
            SP_INSERT_AUDIT (
               p_CREATED_BY,
               'PKG_POP_CLIN.insert_POP_CLIN  Adding other clin  Travel_Amount amounts p_Travel_Amount='
               || p_Travel_Amount
            );

            INSERT INTO Clin_Tmo (CLIN_TMO_ID,
                                  CLIN_ID,
                                  CLIN_NUMBER,
                                  CLIN_Title,
                                  CLIN_Type,
                                  CLIN_AMOUNT,
                                  CREATED_BY,
                                  CREATED_ON)
              VALUES   (CLIN_TMO_SEQ.NEXTVAL,
                        v_Temp_id,
                        p_CLIN_NUMBER, -- || '-Travel',
                        p_CLIN_TITLE, -- || '-Travel',
                        'Travel',
                        p_Travel_Amount,
                        p_CREATED_BY,
                        SYSDATE ());

            IF SQL%FOUND
            THEN
               p_PStatus := 'SUCCESS';
               COMMIT;
            END IF;
            EXCEPTION
            WHEN OTHERS
            THEN
              ROLLBACK;
              p_PStatus := 'Error Updating Travel Amount to CLIN_TMO';
          END;
         END IF;

         IF  p_PStatus = 'SUCCESS' AND p_Material_Amount IS NOT NULL
         THEN
         BEGIN
            SP_INSERT_AUDIT (
               p_CREATED_BY,
               'PKG_POP_CLIN.insert_POP_CLIN  Adding other clin   Material_Amount amounts p_Material_Amount='
               || p_Material_Amount
            );

            INSERT INTO Clin_Tmo (CLIN_TMO_ID,
                                  CLIN_ID,
                                  CLIN_NUMBER,
                                  CLIN_Title,
                                  CLIN_Type,
                                  CLIN_AMOUNT,
                                  CREATED_BY,
                                  CREATED_ON)
              VALUES   (CLIN_TMO_SEQ.NEXTVAL,
                        v_Temp_id,
                        p_CLIN_Title, -- || '-Material',
                        p_CLIN_NUMBER, -- || '-Material',
                        'Material',
                        p_Material_Amount,
                        p_CREATED_BY,
                        SYSDATE ());

            IF SQL%FOUND
            THEN
               p_PStatus := 'SUCCESS';
               COMMIT;
            END IF;
            EXCEPTION
            WHEN OTHERS
            THEN
              ROLLBACK;
              p_PStatus := 'Error Updating Material Amount to CLIN_TMO';
          END;
         END IF;

         IF  p_PStatus = 'SUCCESS' AND p_ODC_Amount IS NOT NULL
         THEN
         BEGIN
            SP_INSERT_AUDIT (
               p_CREATED_BY,
               'PKG_POP_CLIN.insert_POP_CLIN  Adding other clin    ODC_Amount amounts p_ODC_Amount='
               || p_ODC_Amount
            );

            INSERT INTO Clin_Tmo (CLIN_TMO_ID,
                                  CLIN_ID,
                                  CLIN_NUMBER,
                                  CLIN_Title,
                                  CLIN_Type,
                                  CLIN_AMOUNT,
                                  CREATED_BY,
                                  CREATED_ON)
              VALUES   (CLIN_TMO_SEQ.NEXTVAL,
                        v_Temp_id,
                        p_CLIN_NUMBER, -- || '-ODC',
                        p_CLIN_TITLE, -- || '-ODC',
                        'ODC',
                        p_ODC_Amount,
                        p_CREATED_BY,
                        SYSDATE ());

            IF SQL%FOUND
            THEN
               p_PStatus := 'SUCCESS';
               COMMIT;
            END IF;
            EXCEPTION
            WHEN OTHERS
            THEN
              ROLLBACK;
              p_PStatus := 'Error Updating ODC Amount to CLIN_TMO';
          END;
         END IF;
      
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            ROLLBACK;
            p_PStatus :=
               'The CLIN Number you have entered is already in use under this Period of Performance (POP).  Please enter a unique CLIN Number.';
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_PStatus := SQLERRM || '  Error Inserting POP_CLIN';
      END;
   END insert_POP_CLIN;


   -- update_POP_CLINate
   PROCEDURE update_POP_CLIN (
      p_CLIN_ID              IN     POP_CLIN.CLIN_ID%TYPE DEFAULT NULL ,
      p_CLIN_NUMBER          IN     POP_CLIN.CLIN_NUMBER%TYPE DEFAULT NULL ,
      p_CLIN_TYPE            IN     POP_CLIN.CLIN_TYPE%TYPE DEFAULT NULL ,
      p_CLIN_SUB_CLIN        IN     POP_CLIN.CLIN_SUB_CLIN%TYPE DEFAULT NULL ,
      p_CLIN_TITLE           IN     POP_CLIN.CLIN_TITLE%TYPE DEFAULT NULL ,
      p_CLIN_HOURS           IN     POP_CLIN.CLIN_HOURS%TYPE DEFAULT NULL ,
      p_CLIN_RATE            IN     POP_CLIN.CLIN_RATE%TYPE DEFAULT NULL ,
      p_CLIN_AMOUNT          IN     POP_CLIN.CLIN_AMOUNT%TYPE DEFAULT NULL ,
      p_HOURS_COMMITED       IN     POP_CLIN.HOURS_COMMITED%TYPE DEFAULT NULL ,
      p_LABOR_CATEGORY_ID    IN     SUB_CLIN.LABOR_CATEGORY_ID%TYPE DEFAULT NULL ,
      p_HASLABORCATEGORIES   IN     POP_CLIN.HASLABORCATEGORIES%TYPE DEFAULT NULL ,
      p_LABOR_RATE_TYPE      IN     POP_CLIN.LABOR_RATE_TYPE%TYPE DEFAULT NULL  ,
      p_RATE_TYPE            IN     POP_CLIN.RATE_TYPE%TYPE DEFAULT NULL ,
      p_LAST_MODIFIED_BY     IN     POP_CLIN.LAST_MODIFIED_BY%TYPE DEFAULT NULL ,
      p_Labor_Amount         IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL,
      p_Travel_Amount        IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL ,
      p_Material_Amount      IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL ,
      p_ODC_Amount           IN     Clin_Tmo.Clin_Amount%TYPE DEFAULT NULL ,
      p_PStatus                 OUT VARCHAR2
   )
   IS
      v_LABOR_CATEGORY_ID   SUB_CLIN.LABOR_CATEGORY_ID%TYPE;
      v_Temp_id             NUMBER := CLIN_TMO_SEQ.NEXTVAL;
      v_IsPrevInsert        VARCHAR2 (1) := 'F';
   BEGIN
      v_LABOR_CATEGORY_ID := p_LABOR_CATEGORY_ID;
      --SP_INSERT_AUDIT('update_POP_CLIN', 'p_CLIN_NUMBER= '|| p_CLIN_NUMBER ||' '|| 'p_LABOR_CATEGORY_ID= '|| v_LABOR_CATEGORY_ID);
      SP_INSERT_AUDIT (p_LAST_MODIFIED_BY, 'PKG_POP_CLIN.update_POP_CLIN');

      /* if p_CLIN_TYPE <> 'Labor' then
         v_LABOR_CATEGORY_ID := 0;
       else
         v_LABOR_CATEGORY_ID := p_LABOR_CATEGORY_ID;
       end if;*/

      BEGIN                                        -- Start of POP_CLIN_Update
         UPDATE   POP_CLIN
            SET   CLIN_NUMBER = p_CLIN_NUMBER,
                  CLIN_TYPE = p_CLIN_TYPE,
                  CLIN_SUB_CLIN = p_CLIN_SUB_CLIN,
                  CLIN_TITLE = p_CLIN_TITLE,
                  CLIN_HOURS = p_CLIN_HOURS,
                  CLIN_RATE = p_CLIN_RATE,
                  CLIN_AMOUNT = p_CLIN_AMOUNT,
                  HOURS_COMMITED = p_HOURS_COMMITED,
                  LABOR_CATEGORY_ID = v_LABOR_CATEGORY_ID,
                  HASLABORCATEGORIES = p_HASLABORCATEGORIES,
                  LABOR_RATE_TYPE = p_LABOR_RATE_TYPE,
                  RATE_TYPE = p_RATE_TYPE,
                  LAST_MODIFIED_BY = p_LAST_MODIFIED_BY,
                  LAST_MODIFIED_ON = SYSDATE ()
          WHERE   CLIN_ID = p_CLIN_ID;

         IF SQL%FOUND
         THEN
            p_PStatus := 'SUCCESS';
            COMMIT;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_PStatus := 'Error Updating POP_CLIN';
      END;                                           -- END of POP_CLIN Update
    
      IF p_PStatus = 'SUCCESS' AND p_Labor_Amount IS NOT NULL
      THEN
      BEGIN
         MERGE INTO   Clin_Tmo CT
              USING   (SELECT   CLIN_ID, CLIN_TYPE
                         FROM   POP_CLIN
                        WHERE   CLIN_ID = p_CLIN_ID) tmp
                 ON   (CT.CLIN_ID = TMP.CLIN_ID AND CT.CLIN_TYPE = 'Labor')
         WHEN MATCHED
         THEN
            UPDATE SET
               CT.CLIN_AMOUNT = p_Labor_Amount,
               CT.UPDATED_BY = p_LAST_MODIFIED_BY,
               CT.UPDATED_ON = SYSDATE ()
         WHEN NOT MATCHED
         THEN
            INSERT              (CT.CLIN_TMO_ID,
                                 CT.CLIN_ID,
                                 CT.CLIN_NUMBER,
                                 CT.CLIN_Title,
                                 CT.CLIN_Type,
                                 CT.CLIN_AMOUNT,
                                 CT.CREATED_BY,
                                 CT.CREATED_ON)
                VALUES   (v_Temp_id,
                          p_CLIN_ID,
                          p_CLIN_NUMBER, -- || '-Labor',
                          p_CLIN_NUMBER , --|| '-Labor',
                          'Labor',
                          p_Labor_Amount,
                          p_LAST_MODIFIED_BY,
                          SYSDATE ());

         v_IsPrevInsert := 'T';

         IF SQL%FOUND
         THEN
            p_PStatus := 'SUCCESS';
            COMMIT;
         END IF;         
         EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_PStatus := 'Error Updating Labor Amount to CLIN_TMO';
      END;
      END IF;

      IF p_PStatus = 'SUCCESS' AND p_Travel_Amount IS NOT NULL
      THEN
      BEGIN
         MERGE INTO   Clin_Tmo CT
              USING   (SELECT   CLIN_ID, CLIN_TYPE
                         FROM   POP_CLIN
                        WHERE   CLIN_ID = p_CLIN_ID) tmp
                 ON   (CT.CLIN_ID = TMP.CLIN_ID AND CT.CLIN_TYPE = 'Travel')
         WHEN MATCHED
         THEN
            UPDATE SET
               CT.CLIN_AMOUNT = p_Travel_Amount,
               CT.UPDATED_BY = p_LAST_MODIFIED_BY,
               CT.UPDATED_ON = SYSDATE ()
         WHEN NOT MATCHED
         THEN
            INSERT              (CT.CLIN_TMO_ID,
                                 CT.CLIN_ID,
                                 CT.CLIN_NUMBER,
                                 CT.CLIN_Title,
                                 CT.CLIN_Type,
                                 CT.CLIN_AMOUNT,
                                 CT.CREATED_BY,
                                 CT.CREATED_ON)
                VALUES   (v_Temp_id,
                          p_CLIN_ID,
                          p_CLIN_NUMBER , --|| '-Travel',
                          p_CLIN_NUMBER , --|| '-Travel',
                          'Travel',
                          p_Travel_Amount,
                          p_LAST_MODIFIED_BY,
                          SYSDATE ());

         v_IsPrevInsert := 'T';

         IF SQL%FOUND
         THEN
            p_PStatus := 'SUCCESS';
            COMMIT;
         END IF;
         EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_PStatus := 'Error Updating Travel Amount to CLIN_TMO';
        END;
      END IF;

      IF p_PStatus = 'SUCCESS' AND p_ODC_Amount IS NOT NULL
      THEN
      BEGIN
         --IF p_Travel_Amount IS NOT NULL THEN
         IF v_IsPrevInsert = 'T'
         THEN
            v_Temp_id := CLIN_TMO_SEQ.NEXTVAL;
         END IF;

         MERGE INTO   Clin_Tmo CT
              USING   (SELECT   CLIN_ID, CLIN_TYPE
                         FROM   POP_CLIN
                        WHERE   CLIN_ID = p_CLIN_ID) tmp
                 ON   (CT.CLIN_ID = TMP.CLIN_ID AND CT.CLIN_TYPE = 'ODC')
         WHEN MATCHED
         THEN
            UPDATE SET
               CT.CLIN_AMOUNT = p_ODC_Amount,
               CT.UPDATED_BY = p_LAST_MODIFIED_BY,
               CT.UPDATED_ON = SYSDATE ()
         WHEN NOT MATCHED
         THEN
            INSERT              (CT.CLIN_TMO_ID,
                                 CT.CLIN_ID,
                                 CT.CLIN_NUMBER,
                                 CT.CLIN_Title,
                                 CT.CLIN_Type,
                                 CT.CLIN_AMOUNT,
                                 CT.CREATED_BY,
                                 CT.CREATED_ON)
                VALUES   (v_Temp_id,
                          p_CLIN_ID,
                          p_CLIN_NUMBER, -- || '-ODC',
                          p_CLIN_NUMBER, -- || '-ODC',
                          'ODC',
                          p_ODC_Amount,
                          p_LAST_MODIFIED_BY,
                          SYSDATE ());

         v_IsPrevInsert := 'T';

         IF SQL%FOUND
         THEN
            p_PStatus := 'SUCCESS';
            COMMIT;
         END IF;
         EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_PStatus := 'Error Updating ODC Amount to CLIN_TMO';
      END;
      END IF;

      IF p_PStatus = 'SUCCESS' AND p_Material_Amount IS NOT NULL
      THEN
      BEGIN
         --IF p_Travel_Amount IS NOT NULL OR p_ODC_Amount IS NOT NULL THEN
         IF v_IsPrevInsert = 'T'
         THEN
            v_Temp_id := CLIN_TMO_SEQ.NEXTVAL;
         END IF;

         MERGE INTO   Clin_Tmo CT
              USING   (SELECT   CLIN_ID, CLIN_TYPE
                         FROM   POP_CLIN
                        WHERE   CLIN_ID = p_CLIN_ID) tmp
                 ON   (CT.CLIN_ID = TMP.CLIN_ID AND CT.CLIN_TYPE = 'Material')
         WHEN MATCHED
         THEN
            UPDATE SET
               CT.CLIN_AMOUNT = p_Material_Amount,
               CT.UPDATED_BY = p_LAST_MODIFIED_BY,
               CT.UPDATED_ON = SYSDATE ()
         WHEN NOT MATCHED
         THEN
            INSERT              (CT.CLIN_TMO_ID,
                                 CT.CLIN_ID,
                                 CT.CLIN_NUMBER,
                                 CT.CLIN_Title,
                                 CT.CLIN_Type,
                                 CT.CLIN_AMOUNT,
                                 CT.CREATED_BY,
                                 CT.CREATED_ON)
                VALUES   (v_Temp_id,
                          p_CLIN_ID,
                          p_CLIN_NUMBER, --|| '-Material',
                          p_CLIN_NUMBER, -- || '-Material',
                          'Material',
                          p_Material_Amount,
                          p_LAST_MODIFIED_BY,
                          SYSDATE ());

         v_IsPrevInsert := 'T';

         IF SQL%FOUND
         THEN
            p_PStatus := 'SUCCESS';
            COMMIT;
         END IF;
         EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            p_PStatus := 'Error Updating Material Amount to CLIN_TMO';
      END;
      END IF;

   END UPDATE_POP_CLIN;

   -- delete_POP_CLIN
   PROCEDURE delete_POP_CLIN (p_CLIN_ID   IN     POP_CLIN.CLIN_ID%TYPE,
                              p_PStatus      OUT VARCHAR2)
   IS
   BEGIN
      DELETE FROM   POP_CLIN
            WHERE   CLIN_ID = p_CLIN_ID;

      IF SQL%FOUND
      THEN
         p_PStatus := 'SUCCESS';
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_PStatus := 'Error Deleting POP_CLIN :' || SQLERRM;
   END;

   /*begin CLIN_Labor_Category DMLS  --Sridhar Kommana 04/24/2015*/


   PROCEDURE insert_CLIN_Labor_Category (
      P_CLIN_ID                    IN     CLIN_LABOR_CATEGORY.CLIN_ID%TYPE DEFAULT NULL ,
      P_LABOR_CATEGORY_TITLE       IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_TITLE%TYPE DEFAULT NULL
                                                                                          ,
      P_STD_LABOR_CATEGORY_ID      IN     CLIN_LABOR_CATEGORY.STD_LABOR_CATEGORY_ID%TYPE DEFAULT NULL
                                                                                           ,
      P_LABOR_CATEGORY_HIGH_RATE   IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_HIGH_RATE%TYPE DEFAULT NULL
                                                                                              ,
      P_LABOR_CATEGORY_LOW_RATE    IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_LOW_RATE%TYPE DEFAULT NULL
                                                                                             ,
      P_APPROVAL_DATE              IN     CLIN_LABOR_CATEGORY.APPROVAL_DATE%TYPE DEFAULT NULL
                                                                                   ,
      P_COMMENTS                   IN     CLIN_LABOR_CATEGORY.COMMENTS%TYPE DEFAULT NULL
                                                                              ,
      P_LABOR_CATEGORY_RATE        IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_RATE%TYPE DEFAULT NULL
                                                                                         ,
      P_LC_RATE_TYPE               IN     CLIN_LABOR_CATEGORY.LC_RATE_TYPE%TYPE DEFAULT NULL
                                                                                  ,
      P_CONTRACTOR                 IN     CLIN_LABOR_CATEGORY.CONTRACTOR%TYPE DEFAULT NULL
                                                                                ,
      P_CONTRACTOR_ID              IN     CLIN_LABOR_CATEGORY.CONTRACTOR_ID%TYPE DEFAULT NULL
                                                                                   ,
      P_VENDOR                     IN     CLIN_LABOR_CATEGORY.VENDOR%TYPE DEFAULT NULL
                                                                            ,
      p_LABOR_RATE_TYPE            IN     CLIN_LABOR_CATEGORY.LABOR_RATE_TYPE%TYPE DEFAULT NULL
                                                                                     ,
      P_CREATED_BY                 IN     CLIN_LABOR_CATEGORY.CREATED_BY%TYPE DEFAULT NULL
                                                                                ,
      P_CREATED_ON                 IN     CLIN_LABOR_CATEGORY.CREATED_ON%TYPE DEFAULT NULL
                                                                                ,
      p_PStatus                       OUT VARCHAR2
   )
   IS
      v_Rate_Type   VARCHAR2 (20);
   BEGIN
      SP_INSERT_AUDIT (
         P_CREATED_BY,
         'PKG_POP_CLIN.insert_CLIN_Labor_Category P_CLIN_ID=' || P_CLIN_ID
      );

      INSERT INTO CLIN_LABOR_CATEGORY (LABOR_CATEGORY_ID,
                                       CLIN_ID,
                                       LABOR_CATEGORY_TITLE,
                                       STD_LABOR_CATEGORY_ID,
                                       LABOR_CATEGORY_HIGH_RATE,
                                       LABOR_CATEGORY_LOW_RATE,
                                       LC_RATE_TYPE,
                                       APPROVAL_DATE,
                                       COMMENTS,
                                       LABOR_CATEGORY_RATE,
                                       CONTRACTOR,
                                       CONTRACTOR_ID,
                                       VENDOR,
                                       LABOR_RATE_TYPE,
                                       CREATED_BY,
                                       CREATED_ON)
        VALUES   (Labor_CLIN_SEQ.NEXTVAL,
                  P_CLIN_ID,
                  P_LABOR_CATEGORY_TITLE,
                  P_STD_LABOR_CATEGORY_ID,
                  P_LABOR_CATEGORY_HIGH_RATE,
                  P_LABOR_CATEGORY_LOW_RATE,
                  P_LC_RATE_TYPE,
                  P_APPROVAL_DATE,
                  P_COMMENTS,
                  P_LABOR_CATEGORY_RATE,
                  P_CONTRACTOR,
                  P_CONTRACTOR_ID,
                  P_VENDOR,
                  p_LABOR_RATE_TYPE,
                  p_CREATED_BY,
                  SYSDATE ());

      IF SQL%FOUND
      THEN
         p_PStatus := 'SUCCESS';
         COMMIT;
      END IF;

      BEGIN
         SELECT   Rate_Type
           INTO   v_Rate_type
           FROM   Pop_Clin
          WHERE   CLIN_ID = P_CLIN_ID;

         IF v_Rate_type IS NULL OR v_Rate_type = ''
         THEN
            SP_INSERT_AUDIT (p_CREATED_BY,
                             'Updating update RATE_TYPE in POP_CLIN ');

            UPDATE   Pop_Clin
               SET   Labor_category_id = P_STD_LABOR_CATEGORY_ID, --- Added by Sridhar on 03/25/2016 RTM ID = CHRISTOPHE CALL
                     RATE_TYPE = P_LC_RATE_TYPE,
                     LAST_MODIFIED_BY = p_CREATED_BY,
                     LAST_MODIFIED_ON = SYSDATE ()
             WHERE   CLIN_ID = P_CLIN_ID;

            COMMIT;
         ELSE
            SP_INSERT_AUDIT (p_CREATED_BY,
                             'Skipped update RATE_TYPE in POP_CLIN ');
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
            SP_INSERT_AUDIT (
               p_CREATED_BY,
               'Error update_POP_CLIN from insert_CLIN_Labor_Category cannot find P_CLIN_ID '
               || P_CLIN_ID
               || ' Error:'
               || SQLERRM
            );
            p_PStatus := SQLERRM || '  Error Updating CLIN Rate Type';
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         SP_INSERT_AUDIT (p_CREATED_BY,
                          'Error insert_CLIN_Labor_Category' || SQLERRM);
         p_PStatus := SQLERRM || '  Error Inserting CLIN_LABOR_CATEGORY';
   END;

   PROCEDURE update_CLIN_Labor_Category (
      P_LABOR_CATEGORY_ID          IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_ID%TYPE DEFAULT NULL
                                                                                       ,
      P_LABOR_CATEGORY_TITLE       IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_TITLE%TYPE DEFAULT NULL
                                                                                          ,
      P_STD_LABOR_CATEGORY_ID      IN     CLIN_LABOR_CATEGORY.STD_LABOR_CATEGORY_ID%TYPE DEFAULT NULL
                                                                                           ,
      P_LABOR_CATEGORY_HIGH_RATE   IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_HIGH_RATE%TYPE DEFAULT NULL
                                                                                              ,
      P_LABOR_CATEGORY_LOW_RATE    IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_LOW_RATE%TYPE DEFAULT NULL
                                                                                             ,
      P_APPROVAL_DATE              IN     CLIN_LABOR_CATEGORY.APPROVAL_DATE%TYPE DEFAULT NULL
                                                                                   ,
      P_COMMENTS                   IN     CLIN_LABOR_CATEGORY.COMMENTS%TYPE DEFAULT NULL
                                                                              ,
      P_LABOR_CATEGORY_RATE        IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_RATE%TYPE DEFAULT NULL
                                                                                         ,
      P_LC_RATE_TYPE               IN     CLIN_LABOR_CATEGORY.LC_RATE_TYPE%TYPE DEFAULT NULL
                                                                                  ,
      P_CONTRACTOR                 IN     CLIN_LABOR_CATEGORY.CONTRACTOR%TYPE DEFAULT NULL
                                                                                ,
      P_CONTRACTOR_ID              IN     CLIN_LABOR_CATEGORY.CONTRACTOR_ID%TYPE DEFAULT NULL
                                                                                   ,
      P_VENDOR                     IN     CLIN_LABOR_CATEGORY.VENDOR%TYPE DEFAULT NULL
                                                                            ,
      p_LABOR_RATE_TYPE            IN     CLIN_LABOR_CATEGORY.LABOR_RATE_TYPE%TYPE DEFAULT NULL
                                                                                     ,
      P_LAST_MODIFIED_BY           IN     CLIN_LABOR_CATEGORY.LAST_MODIFIED_BY%TYPE DEFAULT NULL
                                                                                      ,
      P_LAST_MODIFIED_ON           IN     CLIN_LABOR_CATEGORY.LAST_MODIFIED_ON%TYPE DEFAULT NULL
                                                                                      ,
      p_PStatus                       OUT VARCHAR2
   )
   IS
   BEGIN
      SP_INSERT_AUDIT (p_LAST_MODIFIED_BY,
                       'PKG_POP_CLIN.update_CLIN_Labor_Category');

      UPDATE   CLIN_LABOR_CATEGORY
         SET   LABOR_CATEGORY_TITLE = P_LABOR_CATEGORY_TITLE,
               STD_LABOR_CATEGORY_ID = P_STD_LABOR_CATEGORY_ID,
               LABOR_CATEGORY_HIGH_RATE = P_LABOR_CATEGORY_HIGH_RATE,
               LABOR_CATEGORY_LOW_RATE = P_LABOR_CATEGORY_LOW_RATE,
               LC_RATE_TYPE = P_LC_RATE_TYPE,
               APPROVAL_DATE = P_APPROVAL_DATE,
               COMMENTS = P_COMMENTS,
               LABOR_CATEGORY_RATE = P_LABOR_CATEGORY_RATE,
               CONTRACTOR = P_CONTRACTOR,
               CONTRACTOR_ID = p_CONTRACTOR_ID,
               VENDOR = P_VENDOR,
               LABOR_RATE_TYPE = p_LABOR_RATE_TYPE,
               LAST_MODIFIED_BY = p_LAST_MODIFIED_BY,
               LAST_MODIFIED_ON = SYSDATE ()
       WHERE   LABOR_CATEGORY_ID = P_LABOR_CATEGORY_ID;

      IF SQL%FOUND
      THEN
         p_PStatus := 'SUCCESS';
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_PStatus := 'Error Updating CLIN_LABOR_CATEGORY';
   END;

   PROCEDURE update_LC_Rate (
      P_LABOR_CATEGORY_ID      IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_ID%TYPE DEFAULT NULL
                                                                                   ,
      P_LABOR_CATEGORY_RATE    IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_RATE%TYPE DEFAULT NULL
                                                                                     ,
      P_LABOR_CATEGORY_HOURS   IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_HOURS%TYPE DEFAULT NULL
                                                                                      ,
      P_LAST_MODIFIED_BY       IN     CLIN_LABOR_CATEGORY.LAST_MODIFIED_BY%TYPE DEFAULT NULL
                                                                                  ,
      P_LAST_MODIFIED_ON       IN     CLIN_LABOR_CATEGORY.LAST_MODIFIED_ON%TYPE DEFAULT NULL
                                                                                  ,
      p_PStatus                   OUT VARCHAR2
   )
   IS
   BEGIN
      SP_INSERT_AUDIT (p_LAST_MODIFIED_BY, 'PKG_POP_CLIN.update_LC_Rate');

      UPDATE   CLIN_LABOR_CATEGORY
         SET   LABOR_CATEGORY_RATE = P_LABOR_CATEGORY_RATE,
               LABOR_CATEGORY_HOURS = P_LABOR_CATEGORY_HOURS,
               LAST_MODIFIED_BY = p_LAST_MODIFIED_BY,
               LAST_MODIFIED_ON = SYSDATE ()
       WHERE   LABOR_CATEGORY_ID = P_LABOR_CATEGORY_ID;

      IF SQL%FOUND
      THEN
         p_PStatus := 'SUCCESS';
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_PStatus := 'Error Updating update_LC_Rate';
   END;

   PROCEDURE delete_CLIN_Labor_Category (
      P_LABOR_CATEGORY_ID   IN     CLIN_LABOR_CATEGORY.LABOR_CATEGORY_ID%TYPE DEFAULT NULL
                                                                                ,
      p_LAST_MODIFIED_BY    IN     CLIN_LABOR_CATEGORY.LAST_MODIFIED_BY%TYPE DEFAULT NULL
                                                                               ,
      p_PStatus                OUT VARCHAR2
   )
   IS
   BEGIN
      SP_INSERT_AUDIT (
         p_LAST_MODIFIED_BY,
         'delete_CLIN_Labor_Category P_LABOR_CATEGORY_ID= '
         || P_LABOR_CATEGORY_ID
      );

      DELETE FROM   CLIN_LABOR_CATEGORY
            WHERE   LABOR_CATEGORY_ID = P_LABOR_CATEGORY_ID;

      IF SQL%FOUND
      THEN
         p_PStatus := 'SUCCESS';
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_PStatus := 'Error Deleting LABOR_CATEGORY_ID';
   END delete_CLIN_Labor_Category;

   PROCEDURE SP_GET_CLIN (
      p_UserId                         VARCHAR2 DEFAULT NULL ,
      P_CONTRACT_NUMBER                VARCHAR2 DEFAULT NULL ,
      P_POP_TYPE                       VARCHAR2 DEFAULT NULL ,
      P_CLIN_ID                        NUMBER DEFAULT 0 ,
      P_PERIOD_OF_PERFORMANCE_ID       NUMBER DEFAULT NULL ,
      REC_CURSOR                   OUT SYS_REFCURSOR
   )
   AS
   /*
   Procedure : SP_GET_CLIN
   Author: Sridhar Kommana
   Date Created : 11/05/2014
   Purpose:  Get Clin and Subclin information on contracts grid page
   Update history:
   sridhar kommana :
   1) 04/24/2015 : Removed unessessary rows by changing the position of P_CONTRACT_NUMBER
   2) 05/06/2015 : Added P_clin_id as a parm
   3) 05/25/2015 : Added new cols LABOR_RATE_TYPE and RATE_TYPE
   4) 06/10/2015 : Removed (POP.STATUS = 'Active')
   5) 04/11/2016 : Added New cols Travel_Amount, Material_Amount, ODC_Amount for RTM-ID = CLINCHANGE
   */
   BEGIN
      SP_INSERT_AUDIT (
         p_UserId,
            'PKG_POP_CLIN.SP_GET_CLIN Get Clin details for contract '
         || p_Contract_NUMBER
         || ' POP_TYPE='
         || P_POP_TYPE
         || ' PERIOD_OF_PERFORMANCE_ID='
         || P_PERIOD_OF_PERFORMANCE_ID
         || ' P_CLIN_ID='
         || P_CLIN_ID
      );

      --SP_INSERT_AUDIT ( p_UserId, 'SP_GET_CLIN ' || p_Contract_NUMBER || ' POP_TYPE=' || P_POP_TYPE || ' P_CLIN_ID=' || P_PERIOD_OF_PERFORMANCE_ID || ' P_CLIN_ID=' || P_CLIN_ID);
      OPEN REC_CURSOR FOR
           SELECT   DISTINCT
                    CLIN_ID,
                    STATUS,
                    Contract_number,
                    PERIOD_OF_PERFORMANCE_ID,
                    pop_type,
                    CLIN_NUMBER,
                    CLIN_TYPE,
                    CLIN_SUB_CLIN,
                    CLIN_TITLE,
                    LABOR_CATEGORY_ID,
                    HASLABORCATEGORIES,
                    Standard_LABOR_CATEGORY,
                    CLIN_HOURS,
                    DECODE (CLIN_SUB_CLIN, 'N', CLIN_RATE, '') AS CLIN_RATE,
                    CLIN_AMOUNT,
                    --DECODE (CLIN_SUB_CLIN, 'N', CLIN_HOURS_COMMITED, SUB_CLIN_HOURS_COMMITED)
                    CLIN_HOURS_COMMITED AS HOURS_COMMITED,
                    --DECODE (CLIN_SUB_CLIN, 'N', BALANCE_CLIN_HRS, BALANCE_SUB_CLIN_HRS)
                    BALANCE_CLIN_HRS AS BALANCE_HRS,
                    --DECODE ( CLIN_SUB_CLIN, 'N', NVL (CLIN_AMOUNT, 0) - NVL (CLIN_AMOUNT_COMMITED, 0), GET_CLIN_BALANCE (clin_id)) AS BALANCE_AMOUNT,
                    BALANCE_AMOUNT,
                    LABOR_RATE_TYPE,
                   --SC_LABOR_RATE_TYPE,
                    RATE_TYPE,
                    Labor_Amount,
                    Travel_Amount,
                    Material_Amount,
                    ODC_Amount
             FROM   (SELECT   C.CLIN_ID,
                              sub_clin_id,
                              POP.STATUS,
                              POP.pop_type,
                              POP.Contract_number,
                              C.PERIOD_OF_PERFORMANCE_ID,
                              C.CLIN_NUMBER,
                              C.CLIN_TYPE,
                              C.CLIN_SUB_CLIN,
                              C.CLIN_TITLE,
                              C.LABOR_CATEGORY_ID,
                              C.HASLABORCATEGORIES,
                              L.CATEGORY_NAME AS Standard_LABOR_CATEGORY,
                              C.LABOR_RATE_TYPE,
                           --   SC.LABOR_RATE_TYPE AS SC_LABOR_RATE_TYPE,
                              RATE_TYPE,
                              (SELECT   NVL (SUM (CLIN_HOURS), 0)
                                        + NVL (SUM (SUB_CLIN_HOURS), 0)
                                 FROM      POP_CLIN PC
                                        LEFT OUTER JOIN
                                           SUB_CLIN S
                                        ON S.clin_id = PC.clin_id
                                WHERE   PC.CLIN_ID = C.CLIN_ID
                                        AND (PC.CLIN_ID = P_CLIN_ID
                                             OR P_CLIN_ID = 0))
                                 AS CLIN_HOURS,
                              C.CLIN_RATE AS CLIN_RATE,
                              (SELECT   NVL (SUM (CLIN_AMOUNT), 0)
                                        + NVL (SUM (SUB_CLIN_AMOUNT), 0)
                                 FROM      POP_CLIN PC
                                        LEFT OUTER JOIN
                                           SUB_CLIN S
                                        ON S.clin_id = PC.clin_id
                                WHERE   PC.CLIN_ID = C.CLIN_ID
                                        AND (PC.CLIN_ID = P_CLIN_ID
                                             OR P_CLIN_ID = 0))
                                 AS CLIN_AMOUNT,
                              ( (SELECT   NVL (SUM (CLIN_HOURS), 0)
                                   FROM   WORK_ORDERS_CLINS WOC
                                  WHERE   WOC.CLIN_ID = C.CLIN_ID
                                          AND WOC.CLIN_ID IN
                                                   (SELECT   C1.CLIN_ID
                                                      FROM   pop_clin C1
                                                     WHERE   C1.Clin_Type <>
                                                                'Contract'))
                               + (SELECT   NVL (SUM (WLC.LABOR_CATEGORY_HOURS),
                                                0)
                                    FROM   WO_LABOR_CATEGORY WLC
                                   WHERE   WLC.CLIN_ID = C.CLIN_ID)
                               + (SELECT   NVL (SUM (CLIN_HOURS), 0)
                                    FROM   SUB_TASKS_CLINS WOC
                                   WHERE   WOC.CLIN_ID = C.CLIN_ID
                                           AND WOC.CLIN_ID IN
                                                    (SELECT   C1.CLIN_ID
                                                       FROM   pop_clin C1
                                                      WHERE   C1.Clin_Type <>
                                                                 'Contract'))
                               + (SELECT   NVL (SUM (WLC.LABOR_CATEGORY_HOURS),
                                                0)
                                    FROM   ST_LABOR_CATEGORY WLC
                                   WHERE   WLC.CLIN_ID = C.CLIN_ID))
                                 AS CLIN_HOURS_COMMITED,
                              (SELECT   SUM (NVL (WOC.CLIN_AMOUNT, 0))
                                 FROM   WORK_ORDERS_CLINS WOC
                                WHERE   WOC.FK_period_of_performance_id =
                                           C.PERIOD_OF_PERFORMANCE_ID
                                        AND (C.clin_id = WOC.clin_id)
                                        AND (C.CLIN_ID = P_CLIN_ID
                                             OR P_CLIN_ID = 0))
                                 AS CLIN_AMOUNT_COMMITED,
                              ( (SELECT   NVL (SUM (CLIN_HOURS), 0)
                                          + NVL (SUM (SUB_CLIN_HOURS), 0)
                                   FROM      POP_CLIN PC
                                          LEFT OUTER JOIN
                                             SUB_CLIN S
                                          ON S.clin_id = PC.clin_id
                                  WHERE   PC.CLIN_ID = C.CLIN_ID
                                          AND (PC.CLIN_ID = P_CLIN_ID
                                               OR P_CLIN_ID = 0))
                               - ( (SELECT   NVL (SUM (CLIN_HOURS), 0)
                                      FROM   WORK_ORDERS_CLINS WOC
                                     WHERE   WOC.CLIN_ID = C.CLIN_ID
                                             AND WOC.CLIN_ID IN
                                                      (SELECT   C1.CLIN_ID
                                                         FROM   pop_clin C1
                                                        WHERE   C1.Clin_Type <>
                                                                   'Contract'))
                                  + (SELECT   NVL (
                                                 SUM (WLC.LABOR_CATEGORY_HOURS),
                                                 0
                                              )
                                       FROM   WO_LABOR_CATEGORY WLC
                                      WHERE   WLC.CLIN_ID = C.CLIN_ID)
                                  + (SELECT   NVL (SUM (CLIN_HOURS), 0)
                                       FROM   SUB_TASKS_CLINS WOC
                                      WHERE   WOC.CLIN_ID = C.CLIN_ID
                                              AND WOC.CLIN_ID IN
                                                       (SELECT   C1.CLIN_ID
                                                          FROM   pop_clin C1
                                                         WHERE   C1.Clin_Type <>
                                                                    'Contract'))
                                  + (SELECT   NVL (
                                                 SUM (WLC.LABOR_CATEGORY_HOURS),
                                                 0
                                              )
                                       FROM   ST_LABOR_CATEGORY WLC
                                      WHERE   WLC.CLIN_ID = C.CLIN_ID)))
                                 AS BALANCE_CLIN_HRS,
                              ( (SELECT   NVL (SUM (CLIN_AMOUNT), 0)
                                          + NVL (SUM (SUB_CLIN_AMOUNT), 0)
                                   FROM      POP_CLIN PC
                                          LEFT OUTER JOIN
                                             SUB_CLIN S
                                          ON S.clin_id = PC.clin_id
                                  WHERE   PC.CLIN_ID = C.CLIN_ID
                                          AND (PC.CLIN_ID = P_CLIN_ID
                                               OR P_CLIN_ID = 0))
                               - ( (SELECT   NVL (SUM (CLIN_AMOUNT), 0)
                                      FROM   WORK_ORDERS_CLINS WOC
                                     WHERE   WOC.CLIN_ID = C.CLIN_ID-- AND C.PERIOD_OF_PERFORMANCE_ID = WOC.FK_PERIOD_OF_PERFORMANCE_ID
                                                                    --    AND WO_Clin_Type              <> 'Contract'
                                  )
                                  + (SELECT   NVL (SUM (WLC.LC_AMOUNT), 0)
                                       FROM   WO_LABOR_CATEGORY WLC
                                      WHERE   WLC.CLIN_ID = C.CLIN_ID)
                                  + (SELECT   NVL (SUM (CLIN_Amount), 0)
                                       FROM   SUB_TASKS_CLINS WOC
                                      WHERE   WOC.FK_period_of_performance_id =
                                                 WOC.FK_PERIOD_OF_PERFORMANCE_ID
                                              AND WOC.CLIN_ID = C.CLIN_ID--        AND ST_Clin_Type  <> 'Contract'
                                    )
                                  + (SELECT   NVL (SUM (WLC.LC_AMOUNT), 0)
                                       FROM   ST_LABOR_CATEGORY WLC
                                      WHERE   WLC.CLIN_ID = C.CLIN_ID)))
                                 AS BALANCE_Amount,
                              (SELECT   NVL (SUM (WOC.CLIN_Amount), 0)
                                 FROM   WORK_ORDERS_CLINS WOC
                                WHERE   WOC.FK_period_of_performance_id =
                                           C.PERIOD_OF_PERFORMANCE_ID
                                        AND (C.clin_id = WOC.clin_id
                                             OR SC.sub_clin_id =
                                                  WOC.sub_clin_id)
                                        AND (C.CLIN_ID = P_CLIN_ID
                                             OR P_CLIN_ID = 0))
                                 AS AMOUNT_COMMITED,
                              --   CT.CLIN_AMOUNT  as Travel_Amount,
                              --   CM.CLIN_AMOUNT as Material_Amount,
                              --   CO.CLIN_AMOUNT as ODC_Amount ,
                              TMO_PIV.Labor_Amount,
                              TMO_PIV.Travel_Amount,
                              TMO_PIV.Material_Amount,
                              TMO_PIV.ODC_Amount
                       FROM     POP_CLIN C
                                       INNER JOIN
                                          PERIOD_OF_PERFORMANCE POP
                                       ON C.PERIOD_OF_PERFORMANCE_ID =
                                             POP.PERIOD_OF_PERFORMANCE_ID
                                          ----  AND (POP.STATUS = 'Active')
                                          AND (POP.POP_TYPE = P_POP_TYPE
                                               OR P_POP_TYPE IS NULL)
                                          AND (POP.CONTRACT_NUMBER =
                                                  P_CONTRACT_NUMBER
                                               OR P_CONTRACT_NUMBER IS NULL) --'DTFAWA-11-X-80007'
                                          AND (C.PERIOD_OF_PERFORMANCE_ID =
                                                  P_PERIOD_OF_PERFORMANCE_ID
                                               OR NVL (
                                                    P_PERIOD_OF_PERFORMANCE_ID,
                                                    0
                                                 ) = 0)
                                          AND (C.CLIN_ID = P_CLIN_ID
                                               OR P_CLIN_ID = 0)
                                    LEFT OUTER JOIN
                                       SUB_CLIN SC
                                    ON (SC.CLIN_ID = C.CLIN_ID)
                                 LEFT OUTER JOIN
                                    LABOR_CATEGORIES L
                                 ON L.CATEGORY_ID = C.LABOR_CATEGORY_ID
                              --    LEFT OUTER JOIN CLIN_TMO CT     ON (CT.CLIN_ID = C.CLIN_ID and CT.CLIN_TYPE='Travel')
                              --    LEFT OUTER JOIN CLIN_TMO CM     ON (CM.CLIN_ID = C.CLIN_ID and CM.CLIN_TYPE='Material')
                              --    LEFT OUTER JOIN CLIN_TMO CO     ON (CO.CLIN_ID = C.CLIN_ID and CO.CLIN_TYPE='ODC')
                              LEFT OUTER JOIN
                                 (  SELECT   CLIN_ID,
                                          SUM (Labor_CLIN_AMOUNT)
                                                AS Labor_Amount,
                                             SUM (Travel_CLIN_AMOUNT)
                                                AS Travel_Amount,
                                             SUM (Material_CLIN_AMOUNT)
                                                AS Material_Amount,
                                             SUM (ODC_CLIN_AMOUNT) AS ODC_Amount
                                      FROM   CLIN_TMO PIVOT ( SUM (
                                                      CLIN_AMOUNT) AS
                                                      CLIN_AMOUNT FOR ( CLIN_TYPE
                                                      ) IN ( 'Labor' AS
                                                      Labor ,'Travel' AS
                                                      Travel , 'Material' AS
                                                      Material , 'ODC' AS
                                                      ODC ) )
                                  GROUP BY   CLIN_ID) TMO_PIV
                              ON TMO_PIV.CLIN_ID = C.CLIN_ID) TBLCLINS
         ORDER BY   1;
   EXCEPTION
      WHEN OTHERS
      THEN
         OPEN REC_CURSOR FOR
            SELECT   1 AS CLIN_ID,
                     1 AS PERIOD_OF_PERFORMANCE_ID,
                     1 AS CLIN_NUMBER,
                     1 AS CLIN_TYPE,
                     1 AS CLIN_SUB_CLIN,
                     1 AS CLIN_TITLE,
                     1 AS LABOR_CATEGORY_ID,
                     1 AS HASLABORCATEGORIES,
                     1 AS Standard_LABOR_CATEGORY,
                     1 AS CLIN_HOURS,
                     1 AS CLIN_RATE,
                     1 AS CLIN_AMOUNT,
                     1 AS HOURS_COMMITED,
                     1 AS BALANCE_HRS,
                     1 AS BALANCE_AMOUNT,
                     1 AS LABOR_RATE_TYPE,
                     1 AS SC_LABOR_RATE_TYPE,
                     1 AS RATE_TYPE
              FROM   DUAL;
   END SP_GET_CLIN;

 PROCEDURE sp_get_LaborCategories (
            p_UserId      VARCHAR2,  
            p_PGMName     VARCHAR2,  
            LaborCategories_cursor   OUT SYS_REFCURSOR
   )
   IS
   /*
   Procedure : sp_get_LaborCategories   Author: Sridhar Kommana
   Date Created : 04/24/2015 
   Purpose:  Get standard labor category information.
   Update history:
   sridhar kommana : 1) 05/04/2015 : Added p_USER fro auditing/debugging
                     2) 05/04/2015 : Added sort by 1 so that 0 will come on top
   Srihari Gokina :  3. 07/19/2016 - Adding Program Name (PGM_Name) IN Parameter and Filter as per Contract Program. like SS/SE2025/MITRE.
   */
   BEGIN
      --SP_INSERT_AUDIT (p_UserId, ' PKG_POP_CLIN.sp_get_LaborCategories');
      SP_INSERT_AUDIT (p_UserId, ' PKG_POP_CLIN.sp_get_LaborCategories for Program : ' || p_PGMName);
      OPEN LaborCategories_cursor FOR
           SELECT   CATEGORY_ID, CATEGORY_NAME
           FROM   labor_categories
           WHERE (PGM_NAME = p_PGMName OR PGM_NAME IS NULL ) AND ISACTIVE = 1
         ORDER BY  1;
   EXCEPTION
      WHEN OTHERS
      THEN
         OPEN LaborCategories_cursor FOR
            SELECT   1 CATEGORY_ID, 1 CATEGORY_NAME FROM labor_categories;
   END sp_get_LaborCategories;
   
   PROCEDURE sp_get_CLIN_LABOR_CATEGORY (
      p_WORK_ORDERS_ID          VARCHAR2 DEFAULT NULL ,
      p_LABOR_CATEGORY_ID       VARCHAR2 DEFAULT 0 ,
      p_CLIN_ID                 VARCHAR2 DEFAULT NULL ,
      p_USER                    VARCHAR2 DEFAULT NULL ,
      REC_CURSOR            OUT SYS_REFCURSOR
   )
   AS
   /*
   Procedure : sp_get_CLIN_LABOR_CATEGORY
   Author: Sridhar Kommana
   Date Created : 04/24/2015
   Purpose:  Get clin labor category information.
   Update history:
   sridhar kommana :LABOR_RATE_TYPE
   1) 04/24/2015 : Added p_USER fro auditing/debugging
   2) 05/27/2015 : Added LABOR_CATEGORY_RATE
   3) 05/28/2015 : Added LC_RATE_TYPE  , APPROVAL_DATE,  COMMENTS, CONTRACTOR, VENDOR,
   4) 06/01/2015 : Added p_LABOR_CATEGORY_ID
   5) 06/04/2015 : Added p_WORK_ORDERS_ID  not using for now
   6) 06/08/2015 : added C.LABOR_RATE_TYPE as  LC_LABOR_RATE_TYPE,
   7) 05/03/2016 : Added RATE_DISPLAY to display rate based on rate or range
   */
   BEGIN
      SP_INSERT_AUDIT (
         p_USER,
         'PKG_POP_CLIN.sp_get_CLIN_LABOR_CATEGORY for p_CLIN_ID, p_LABOR_CATEGORY_ID '
         || p_CLIN_ID
         || ','
         || p_LABOR_CATEGORY_ID
      );

      OPEN REC_CURSOR FOR
           SELECT   0 AS WO_LABOR_CATEGORY_ID,
                    C.LABOR_CATEGORY_ID,
                    C.CLIN_ID,
                    C.LABOR_CATEGORY_TITLE,
                    C.STD_LABOR_CATEGORY_ID,
                    C.LABOR_CATEGORY_HIGH_RATE,
                    C.LABOR_CATEGORY_LOW_RATE,
                    C.APPROVAL_DATE,
                    C.COMMENTS,
                    L.CATEGORY_NAME AS Standard_LABOR_CATEGORY,
                    PC.LABOR_RATE_TYPE,
                    C.LABOR_RATE_TYPE AS LC_LABOR_RATE_TYPE,
                    RATE_TYPE,
                    C.LABOR_CATEGORY_RATE,
                    0 AS LABOR_CATEGORY_HOURS,
                    0 AS LC_Amount,
                    0 AS TOT_LABOR_CATEGORY_HOURS,
                    0 TOT_LC_Amount,
                    LC_RATE_TYPE,
                    C.CONTRACTOR,
                    C.CONTRACTOR_ID,
                    C.VENDOR
                    ,DECODE(RATE_TYPE,'Range',C.LABOR_CATEGORY_LOW_RATE||'-'||C.LABOR_CATEGORY_HIGH_RATE,C.LABOR_CATEGORY_RATE) as RATE_DISPLAY 
                    
             FROM         CLIN_LABOR_CATEGORY C
                       LEFT OUTER JOIN
                          LABOR_CATEGORIES L
                       ON L.CATEGORY_ID = C.STD_LABOR_CATEGORY_ID
                    --LEFT OUTER JOIN WO_LABOR_CATEGORY WOL ON WOL.CLIN_ID = C.CLIN_ID
                    INNER JOIN
                       POP_CLIN PC
                    ON PC.CLIN_ID = C.CLIN_ID
            WHERE   C.CLIN_ID = p_CLIN_ID
                    AND (C.LABOR_CATEGORY_ID = p_LABOR_CATEGORY_ID
                         OR p_LABOR_CATEGORY_ID = 0)
         ORDER BY   1;
   EXCEPTION
      WHEN OTHERS
      THEN
         OPEN REC_CURSOR FOR
            SELECT   1 AS WO_LABOR_CATEGORY_ID,
                     1 AS LABOR_CATEGORY_ID,
                     1 AS CLIN_ID,
                     1 AS LABOR_CATEGORY_TITLE,
                     1 AS STD_LABOR_CATEGORY_ID,
                     1 AS LABOR_CATEGORY_HIGH_RATE,
                     1 AS LABOR_CATEGORY_LOW_RATE,
                     1 AS APPROVAL_DATE,
                     1 AS COMMENTS,
                     1 AS Standard_LABOR_CATEGORY,
                     1 AS LABOR_RATE_TYPE,
                     1 AS LC_LABOR_RATE_TYPE,
                     1 AS RATE_TYPE,
                     1 AS LABOR_CATEGORY_RATE,
                     1 AS LABOR_CATEGORY_HOURS,
                     1 AS LC_Amount,
                     1 AS TOT_LABOR_CATEGORY_HOURS,
                     1 TOT_LC_Amount,
                     1 AS LC_RATE_TYPE,
                     1 AS CONTRACTOR,
                     1 AS CONTRACTOR_ID,
                     1 AS VENDOR,                     1 as RATE_DISPLAY 
              FROM   CLIN_LABOR_CATEGORY;
   END sp_get_CLIN_LABOR_CATEGORY;

   PROCEDURE sp_get_CLIN_LC_TITLE (p_user                VARCHAR2 DEFAULT NULL ,
                                   p_CLIN_ID             VARCHAR2 DEFAULT NULL ,
                                   LC_TITLE_cursor   OUT SYS_REFCURSOR)
   IS
   /*
   Procedure : sp_get_CLIN_LC_TITLE
   Author: Sridhar Kommana
   Date Created : 07/01/2015
   Purpose:  Get clin labor category Titles.
   Update history:
   */
   BEGIN
      SP_INSERT_AUDIT (
         p_USER,
         'PKG_POP_CLIN.sp_get_CLIN_LC_TITLE for p_CLIN_ID= ' || p_CLIN_ID
      );

      OPEN LC_TITLE_cursor FOR
           SELECT   LABOR_CATEGORY_ID,
                    LABOR_CATEGORY_TITLE,
                    LABOR_CATEGORY_RATE,
                    LABOR_CATEGORY_HIGH_RATE,
                    LABOR_CATEGORY_LOW_RATE,
                    LC_RATE_TYPE
             FROM   CLIN_LABOR_CATEGORY
            WHERE   clin_id = p_CLIN_ID
         ORDER BY   2;
   EXCEPTION
      WHEN OTHERS
      THEN
         OPEN LC_TITLE_cursor FOR
            SELECT   0 AS LABOR_CATEGORY_ID,
                     '' AS LABOR_CATEGORY_TITLE,
                     0 LABOR_CATEGORY_RATE,
                     0 LABOR_CATEGORY_HIGH_RATE,
                     0 LABOR_CATEGORY_LOW_RATE,
                     '' LC_RATE_TYPE
              FROM   CLIN_LABOR_CATEGORY;
   END sp_get_CLIN_LC_TITLE;

   PROCEDURE sp_get_CLIN_LC_Breakouts (p_USER           VARCHAR2,
                                    p_CLIN_ID        VARCHAR2 DEFAULT NULL ,
                                    LC_REC_CURSOR   OUT SYS_REFCURSOR,
                                    TMO_REC_CURSOR OUT SYS_REFCURSOR)
AS
/*
Procedure : sp_get_CLIN_LC_Breakouts
Author: Sridhar Kommana
Date Created : 04/14/2016
Purpose:  Get clin labor category information breakout amounts.
Update history:
06/02/2016 : Sridhar Kommana Added sort order by clin_type
  */
BEGIN
   SP_INSERT_AUDIT (  
      p_USER,
      'PKG_POP_CLIN.sp_get_CLIN_LC_Breakouts for p_CLIN_ID, p_LABOR_CATEGORY_ID '
      || p_CLIN_ID

   );
  BEGIN
   OPEN LC_REC_CURSOR FOR
        SELECT   C.LABOR_CATEGORY_ID,
                 C.CLIN_ID,
                 C.LABOR_CATEGORY_TITLE,
                 C.STD_LABOR_CATEGORY_ID,
                 C.LABOR_CATEGORY_HIGH_RATE,
                 C.LABOR_CATEGORY_LOW_RATE,
                 C.APPROVAL_DATE,
                 C.COMMENTS,
                 L.CATEGORY_NAME AS Standard_LABOR_CATEGORY,
                 PC.LABOR_RATE_TYPE,
                 C.LABOR_RATE_TYPE AS LC_LABOR_RATE_TYPE,
                 RATE_TYPE,
                 C.LABOR_CATEGORY_RATE,
                 LC_RATE_TYPE,
                 C.CONTRACTOR,
                 C.CONTRACTOR_ID,
                 C.VENDOR
          FROM    CLIN_LABOR_CATEGORY C
                 LEFT OUTER JOIN
                 LABOR_CATEGORIES L
                 ON L.CATEGORY_ID = C.STD_LABOR_CATEGORY_ID
                 INNER JOIN POP_CLIN PC
                 ON PC.CLIN_ID = C.CLIN_ID
         WHERE   C.CLIN_ID = p_CLIN_ID
      ORDER BY   1;
EXCEPTION
   WHEN OTHERS
   THEN
      OPEN LC_REC_CURSOR FOR
         SELECT   NULL AS LABOR_CATEGORY_ID,
                  NULL AS CLIN_ID,
                  NULL AS LABOR_CATEGORY_TITLE,
                  NULL AS STD_LABOR_CATEGORY_ID,
                  NULL AS LABOR_CATEGORY_HIGH_RATE,
                  NULL AS LABOR_CATEGORY_LOW_RATE,
                  NULL AS APPROVAL_DATE,
                  NULL AS COMMENTS,
                  NULL AS Standard_LABOR_CATEGORY,
                  NULL AS LABOR_RATE_TYPE,
                  NULL AS LC_LABOR_RATE_TYPE,
                  NULL AS RATE_TYPE,
                  NULL AS LABOR_CATEGORY_RATE,
                  NULL AS LC_RATE_TYPE,
                  NULL AS CONTRACTOR,
                  NULL AS CONTRACTOR_ID,
                  NULL AS VENDOR
           FROM   DUAL;
  END;
  BEGIN
        OPEN TMO_REC_CURSOR FOR
         SELECT   CLIN_TMO_ID,
                  CLIN_ID,
                  CLIN_TITLE,
                  CLIN_TYPE,
                  CLIN_AMOUNT,
                  CLIN_NUMBER,
                  DECODE(CLIN_TYPE, 'Labor', 1, 'Travel', 2, 'Material',3 , 'ODC', 4,5 ) as CTORDER
          from    clin_tmo
        where clin_id=p_CLIN_ID order by CTORDER;
        
        EXCEPTION
   WHEN OTHERS
   THEN
      OPEN TMO_REC_CURSOR FOR
         SELECT   NULL AS  CLIN_TMO_ID,
                  NULL AS  CLIN_ID,
                  NULL AS  CLIN_TITLE,
                  NULL AS  CLIN_TYPE,
                  NULL AS  CLIN_AMOUNT,
                  NULL AS  CLIN_NUMBER
           FROM   DUAL;          
  END;
          
END sp_get_CLIN_LC_Breakouts;



   PROCEDURE SP_GET_CLIN_BREAKOUT_AMOUNTS(
              p_USER  VARCHAR2  ,
              p_CLIN_ID VARCHAR2 ,
              P_CLIN_TYPE VARCHAR2 DEFAULT NULL,
              TMO_AMOUNTS_CURSOR OUT SYS_REFCURSOR)
  /* Procedure : SP_GET_CLIN_BREAKOUT_AMOUNTS
     Author: Srihari Gokina
     Date Created : 04/14/2016
     Purpose:  Get CLIN Breakout Amounts in task order clin page.
     Update history: 
     sridhar kommana 04/15/2016 Added New parameter P_CLIN_TYPE
     Sridhar Kommana 06/02/2016 Added sort order by clin_type     
     */    
   IS
   BEGIN
      SP_INSERT_AUDIT ( p_USER, 'PKG_POP_CLIN.SP_GET_CLIN_BREAKOUT_AMOUNTS for p_CLIN_ID= ' || p_CLIN_ID );

      OPEN TMO_AMOUNTS_CURSOR FOR
           SELECT   CLIN_TMO_ID,
                    CLIN_ID,
                    CLIN_TYPE,
                    CLIN_AMOUNT,
                    CLIN_NUMBER,
                    CLIN_TITLE,
                    DECODE(CLIN_TYPE, 'Labor', 1, 'Travel', 2, 'Material',3 , 'ODC', 4,5 ) as CTORDER
            FROM    CLIN_TMO        
            WHERE CLIN_ID = p_CLIN_ID
             AND (CLIN_TYPE = P_CLIN_TYPE  OR P_CLIN_TYPE IS NULL)
         ORDER BY  CTORDER;
   EXCEPTION
      WHEN OTHERS
      THEN
         OPEN TMO_AMOUNTS_CURSOR FOR
           SELECT   0 AS CLIN_TMO_ID,
                    0 AS CLIN_ID,
                    '' AS CLIN_TITLE,
                    '' AS CLIN_TYPE,
                    0 AS CLIN_AMOUNT,
                    '' AS CLIN_NUMBER
            FROM CLIN_TMO;
   END SP_GET_CLIN_BREAKOUT_AMOUNTS;

END PKG_POP_CLIN;
/