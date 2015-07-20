# rshk\_http

Package for making simpler HTTP REQUEST with PL/SQL.

## Samples

### GET:

    select rshk_http.do_get('http://www.roshka.com') from dual;

Will return a BLOB containing URL's content.

### POST:

    declare
       p_names TStringArray;
       p_values TStringArray;
       r CLOB;
    begin
       p_names(1)  := 'access_token';
       p_values(1) := 'YAZEERR-AUYERJDSJJSYYEW72772898';
       r := rshk_http.do_post('http://www.roshka.com', p_names, p_values);
    end;

## Prerequisites

You need to have `utl_http` package installed. Here's how you'd do it on
a UNIX based server:

    $ cd $ORACLE_HOME
    $ cd rdbms/admin
    $ sqlplus sys as sysdba
    sql> @utlhttp.sql
    sql> @prvthttp.plb

This was tested on Oracle 11gR2 (XE).

