CREATE OR REPLACE PROCEDURE eemrt.p_test
AS
BEGIN
   
   -- OPS FUND 4th and 5th charactors should be '01')
   UPDATE   delphi_contract_stage
      SET   FUND_TYPE = 'OPS'
    WHERE       SUBSTR (FUND, 4, 2) = ('01')
            AND SUBSTR (FUND, 6, 2) <> ('AS')
            AND SUBSTR (FUND, 3, 1) <> 'X';

   

   --F&E FUND 4th and 5th charactors should be '82')
   UPDATE   delphi_contract_stage
      SET   FUND_TYPE = 'F&E'
    WHERE       SUBSTR (FUND, 4, 2) = ('82')
            AND SUBSTR (FUND, 6, 2) <> ('AS')
            AND SUBSTR (FUND, 3, 1) <> 'X';
          --  AND SUBSTR (FUND, 6, 1) <> ('W');

   --F&E FUND 4th and 5th charactors should be '81')
   UPDATE   delphi_contract_stage
      SET   FUND_TYPE = 'F&E'
    WHERE       SUBSTR (FUND, 4, 2) = ('81')
            AND SUBSTR (FUND, 6, 2) <> ('AS')
            AND SUBSTR (FUND, 3, 1) <> 'X';
            

   --RE&D FUND 4th and 5th charactors should be '88')
   UPDATE   delphi_contract_stage
      SET   FUND_TYPE = 'RE&D'
    WHERE       SUBSTR (FUND, 4, 2) = ('88')
            AND SUBSTR (FUND, 6, 2) <> ('AS')
            AND SUBSTR (FUND, 3, 1) <> 'X';


   --No year funds
   UPDATE   delphi_contract_stage
      SET   FUND_TYPE = 'No Year Fund'
    WHERE     SUBSTR (FUND, 3, 1) = 'X';
    
    
    
 -- ARRA ( 6th and 7th charactors should be 'AS')
   UPDATE   delphi_contract_stage
      SET   FUND_TYPE = 'ARRA'
    WHERE   SUBSTR (FUND, 6, 2) = ('AS') AND SUBSTR (FUND, 3, 1) <> 'X';


   --------xxxxxxxxxxxxxxxxxxxxxx--UPDATE EXPENDITURE EXPIRATION DATE FIELD:

   -- expire 2013 ( 3rd charactor should be 8)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2013'
    WHERE   SUBSTR (FUND, 3, 1) = ('8');

   -- expire 2014 ( 3rd charactor should be 9)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2014'
    WHERE   SUBSTR (FUND, 3, 1) = ('9');

   -- expire 2015 ( 3rd charactor should be 0)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2015'
    WHERE   SUBSTR (FUND, 3, 1) = ('0');

   -- expire 2016 ( 3rd charactor should be 1)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2016'
    WHERE   SUBSTR (FUND, 3, 1) = ('1');

   -- expire 2017 ( 3rd charactor should be 2)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2017'
    WHERE   SUBSTR (FUND, 3, 1) = ('2');

   -- expire 2018 ( 3rd charactor should be 3)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2018'
    WHERE   SUBSTR (FUND, 3, 1) = ('3');

   -- expire 2019 ( 3rd charactor should be 4)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2019'
    WHERE   SUBSTR (FUND, 3, 1) = ('4');


   -- expire 2020 ( 3rd charactor should be 5)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2020'
    WHERE   SUBSTR (FUND, 3, 1) = ('5');



   -- expire 2020 ( 3rd charactor should be 6)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2021'
    WHERE   SUBSTR (FUND, 3, 1) = ('6');


   -- expire 2020 ( 3rd charactor should be 7)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2022'
    WHERE   SUBSTR (FUND, 3, 1) = ('7');


   -- expire 2099 ( 3rd charactor should not be 8,9,0,1)
   UPDATE   delphi_contract_stage
      SET   expenditure_expiration_date = '30-SEP-2099'
    WHERE   SUBSTR (FUND, 3, 1) IN ('N', 'X');

commit;
   --------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxobligation_expiration_date


   UPDATE   delphi_contract_stage
      SET   obligation_expiration_date =
               DECODE (SUBSTR (FUND, 3, 1),
                       '8', '30-SEP-2008',
                       '9', '30-SEP-2009',
                       '0', '30-SEP-2010',
                       '1', '30-SEP-2011',
                       '2', '30-SEP-2012',
                       '3', '30-SEP-2013',
                       '4', '30-SEP-2014',
                       '5', '30-SEP-2015',
                       '6', '30-SEP-2016',
                       '7', '30-SEP-2017',
                       '8', '30-SEP-2018',
                       '9', '30-SEP-2019',
                       '30-SEP-2099')
    WHERE   fund = fund;

  commit;
   --------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxfiscal year


   UPDATE   delphi_contract_stage
      SET   Fiscal_Year = 201 || SUBSTR (bpac, 1, 1)
    WHERE   SUBSTR (bpac, 1, 1) IN
                  ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0');

   COMMIT;



   UPDATE   delphi_contract_stage
      SET   Fiscal_Year = 2099
    WHERE   fiscal_year IS NULL;

   COMMIT;
END; 
/