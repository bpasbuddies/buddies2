CREATE OR REPLACE FUNCTION eemrt.GET_USER_FULLNAME
(
  p_UserName VARCHAR2
)
  RETURN VARCHAR2 AS fullName VARCHAR(200);
  firstName VARCHAR2(50);
  middleName VARCHAR2(50);
  lastName VARCHAR2(50);
  
BEGIN
  SP_INSERT_AUDIT('p_Admin' , 'GET_USER_FULLNAME p_UserName='|| p_UserName);
  
  SELECT FIRSTNAME, MIDDLEINITIAL, LASTNAME INTO firstName, middleName, lastName
  FROM USERS 
  WHERE LOWER(USERNAME) = LOWER(p_UserName);
  
  IF firstName IS NOT NULL AND middleName IS NOT NULL AND lastName IS NOT NULL THEN
    fullName := firstName || ' ' || middleName || ' ' || lastName;
  ELSIF firstName IS NOT NULL AND middleName IS NOT NULL AND lastName IS NULL THEN
    fullName := firstName || ' ' || middleName;
  ELSIF firstName IS NOT NULL AND middleName IS NULL AND lastName IS NULL THEN
    fullName := firstName;
  ELSIF firstName IS NULL AND middleName IS NOT NULL AND lastName IS NOT NULL THEN
    fullName := middleName || ' ' || lastName;
  ELSIF firstName IS NULL AND middleName IS NOT NULL AND lastName IS NULL THEN
    fullName := middleName;
  ELSE
    fullName := firstName || ' ' || lastName; 
  END IF;
 
  RETURN fullName;
  
END GET_USER_FULLNAME;
/