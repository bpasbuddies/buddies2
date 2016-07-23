CREATE OR REPLACE PACKAGE eemrt."PKG_PERIOD_OF_PERFORMANCE" 
IS
  PROCEDURE insert_period_of_performance(
      p_CONTRACT_NUMBER IN period_of_performance.CONTRACT_NUMBER%type DEFAULT NULL,
      p_START_DATE      IN period_of_performance.START_DATE%type DEFAULT NULL,
      p_END_DATE        IN period_of_performance.END_DATE%type DEFAULT NULL,
      p_STATUS          IN period_of_performance.STATUS%type DEFAULT NULL,
      p_POP_TYPE        IN period_of_performance.POP_TYPE%type DEFAULT NULL,
      -- p_CEILING_HOURS IN period_of_performance.CEILING_HOURS%type DEFAULT NULL,
      p_COMMITTED_HOURS IN period_of_performance.COMMITTED_HOURS%type DEFAULT NULL,
      p_USED_HOURS      IN period_of_performance.USED_HOURS%type DEFAULT NULL,
      -- p_CEILING_AMOUNT IN period_of_performance.CEILING_AMOUNT%type DEFAULT NULL,
      p_OBLIGATED_AMOUNT IN period_of_performance.OBLIGATED_AMOUNT%type DEFAULT NULL,
      p_EXPENDED_AMOUNT  IN period_of_performance.EXPENDED_AMOUNT%type DEFAULT NULL,
      p_CREATED_BY       IN period_of_performance.CREATED_BY%type DEFAULT NULL,
      p_PStatus OUT VARCHAR2);
  -- update_period_of_performanceate
  PROCEDURE update_period_of_performance(
      p_period_of_performance_ID IN period_of_performance.period_of_performance_ID%type ,
      --p_CONTRACT_NUMBER  IN period_of_performance.CONTRACT_NUMBER%type DEFAULT NULL,
      p_START_DATE IN period_of_performance.START_DATE%type DEFAULT NULL,
      p_END_DATE   IN period_of_performance.END_DATE%type DEFAULT NULL,
      p_STATUS     IN period_of_performance.STATUS%type DEFAULT NULL,
      p_POP_TYPE   IN period_of_performance.POP_TYPE%type DEFAULT NULL,
      --p_CEILING_HOURS    IN period_of_performance.CEILING_HOURS%type DEFAULT NULL,
      p_COMMITTED_HOURS IN period_of_performance.COMMITTED_HOURS%type DEFAULT NULL,
      p_USED_HOURS      IN period_of_performance.USED_HOURS%type DEFAULT NULL,
      --  p_CEILING_AMOUNT   IN period_of_performance.CEILING_AMOUNT%type DEFAULT NULL,
      p_OBLIGATED_AMOUNT IN period_of_performance.OBLIGATED_AMOUNT%type DEFAULT NULL,
      p_EXPENDED_AMOUNT  IN period_of_performance.EXPENDED_AMOUNT%type DEFAULT NULL,
      p_LAST_MODIFIED_BY IN period_of_performance.LAST_MODIFIED_BY%type DEFAULT NULL ,
      p_PStatus OUT VARCHAR2 );
  -- delete_period_of_performanceete
  PROCEDURE delete_period_of_performance(
      p_period_of_performance_ID IN period_of_performance.period_of_performance_ID%type,
      p_PStatus OUT VARCHAR2 );
  PROCEDURE sp_get_pop(
      p_UserId                   VARCHAR2 DEFAULT NULL,
      p_Contract_NUMBER          VARCHAR2 DEFAULT NULL ,
      P_PERIOD_OF_PERFORMANCE_ID VARCHAR2 DEFAULT NULL,
      sum_cursor OUT SYS_REFCURSOR);

PROCEDURE sp_get_pop_type(    p_UserId  varchar2 DEFAULT NULL,
  P_CONTRACT_NUMBER VARCHAR2, 
    pop_cursor OUT SYS_REFCURSOR)      ;
      
END pkg_period_of_performance;
/