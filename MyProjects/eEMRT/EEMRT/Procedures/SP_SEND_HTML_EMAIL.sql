CREATE OR REPLACE procedure eemrt.sp_send_html_email(
    p_to            in varchar2,
    p_from          in varchar2,
    p_subject       in varchar2,
   -- p_text          in varchar2 default null,
    p_html          in varchar2 default null,
    p_smtp_hostname in varchar2 default 'relay.faa.gov',
    p_smtp_portnum  in varchar2 default '25')
is
    l_boundary      varchar2(255) default 'a1b2c3d4e3f2g1';
    l_connection    utl_smtp.connection;
    l_body_html     clob := empty_clob;  --This LOB will be the email message
    l_offset        number;
    l_ammount       number;
    l_temp          varchar2(32767) default null;
begin
    l_connection := utl_smtp.open_connection( p_smtp_hostname, p_smtp_portnum );
    utl_smtp.helo( l_connection, p_smtp_hostname );
    utl_smtp.mail( l_connection, p_from );
    utl_smtp.rcpt( l_connection, p_to );

    l_temp := l_temp || 'MIME-Version: 1.0' ||  chr(13) || chr(10);
    l_temp := l_temp || 'To: ' || p_to || chr(13) || chr(10);
    l_temp := l_temp || 'From:  eEMRT System(' || p_from ||')'|| chr(13) || chr(10);
    l_temp := l_temp || 'Subject: ' || p_subject || chr(13) || chr(10);
    l_temp := l_temp || 'Reply-To: ' || p_from ||  chr(13) || chr(10);
    l_temp := l_temp || 'Content-Type: multipart/alternative; boundary=' || 
                         chr(34) || l_boundary ||  chr(34) || chr(13) || 
                         chr(10);

    ----------------------------------------------------
    -- Write the headers
    dbms_lob.createtemporary( l_body_html, false, 10 );
    dbms_lob.write(l_body_html,length(l_temp),1,l_temp);


    ----------------------------------------------------
    -- Write the text boundary
    l_offset := dbms_lob.getlength(l_body_html) + 1;
    l_temp   := '--' || l_boundary || chr(13)||chr(10);
    l_temp   := l_temp || 'content-type: text/plain; charset=us-ascii' || 
                  chr(13) || chr(10) || chr(13) || chr(10);
    dbms_lob.write(l_body_html,length(l_temp),l_offset,l_temp);

    ----------------------------------------------------
    -- Write the plain text portion of the email
    l_offset := dbms_lob.getlength(l_body_html) + 1;
   -- dbms_lob.write(l_body_html,length(p_text),l_offset,p_text);

    ----------------------------------------------------
    -- Write the HTML boundary
    l_temp   := chr(13)||chr(10)||chr(13)||chr(10)||'--' || l_boundary || 
                    chr(13) || chr(10);
    l_temp   := l_temp || 'content-type: text/html;' || 
                   chr(13) || chr(10) || chr(13) || chr(10);
    l_offset := dbms_lob.getlength(l_body_html) + 1;
    dbms_lob.write(l_body_html,length(l_temp),l_offset,l_temp);

    ----------------------------------------------------
    -- Write the HTML portion of the message
    l_offset := dbms_lob.getlength(l_body_html) + 1;
    dbms_lob.write(l_body_html,length(p_html),l_offset,p_html);

    ----------------------------------------------------
    -- Write the final html boundary
    l_temp   := chr(13) || chr(10) || '--' ||  l_boundary || '--' || chr(13);
    l_offset := dbms_lob.getlength(l_body_html) + 1;
    dbms_lob.write(l_body_html,length(l_temp),l_offset,l_temp);


    ----------------------------------------------------
    -- Send the email in 1900 byte chunks to UTL_SMTP
    l_offset  := 1;
    l_ammount := 1900;
    utl_smtp.open_data(l_connection);
    while l_offset < dbms_lob.getlength(l_body_html) loop
        utl_smtp.write_data(l_connection,
                            dbms_lob.substr(l_body_html,l_ammount,l_offset));
        l_offset  := l_offset + l_ammount ;
        l_ammount := least(1900,dbms_lob.getlength(l_body_html) - l_ammount);
    end loop;
    utl_smtp.close_data(l_connection);
    utl_smtp.quit( l_connection );
    dbms_lob.freetemporary(l_body_html);
end sp_send_html_email;
/