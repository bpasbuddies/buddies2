CREATE OR REPLACE PROCEDURE eemrt.SP_SEND_EMAIL (
                                       sender     IN VARCHAR2,
                                       receiver   IN   VARCHAR2,
                                       subject    IN   VARCHAR2,
                                       MESSAGE    IN   VARCHAR2 )
IS

conn   UTL_SMTP.connection;
crlf   VARCHAR2 (2)        := CHR (13) || CHR (10);
mesg   VARCHAR2 (32000);

BEGIN
 SP_INSERT_AUDIT('send email', subject|| 'Email sent to '  ||receiver );
   -- Open connection
   conn := UTL_SMTP.open_connection ('relay.faa.gov', 25);
   -- Hand Shake
   UTL_SMTP.helo (conn, 'relay.faa.gov');

   -- Configure sender and recipient to UTL_SMTP
   UTL_SMTP.mail (conn, sender);
   UTL_SMTP.rcpt (conn, receiver);

   mesg :=
         'Date: '
      || TO_CHAR (SYSDATE, 'dd Mon yy hh24:mi:ss')
      || crlf
      || 'From:  eEMRT System'
      || crlf
      || 'Subject: '
      || subject
      || crlf
      || 'To: '
      || receiver
      || crlf
     -- || 'THIS MESSAGE IS FOR NOTIFICATION PURPOSES ONLY.  PLEASE DO NOT REPLY TO THIS MESSAGE'
      || crlf
      || crlf
      || crlf
      || MESSAGE
      || crlf
      || crlf
      || crlf;

  --- Configure sending message
   UTL_SMTP.DATA (conn, mesg);

  --- closing connection
   UTL_SMTP.quit (conn);


END SP_SEND_EMAIL;
/