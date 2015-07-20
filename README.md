# rshk\_http

Package for making simpler HTTP REQUEST with PL/SQL.

Sample GET:

    select rshk_http.do_get('http://www.roshka.com') from dual;

Will return a BLOB containing URL's content.

Sample POST:

    declare
       p_names TStringArray;
       p_values TStringArray;
       r CLOB;
    begin
       p_names(1)  := 'access_token';
       p_values(1) := 'YAZEERR-AUYERJDSJJSYYEW72772898';
       r := rshk_http.do_post('http://www.roshka.com', p_names, p_values);
    end;


