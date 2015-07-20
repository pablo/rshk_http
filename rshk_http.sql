create type TStringArray as table of varchar2(32767);
/

create or replace package RSHK_HTTP is

  -- Author  : RSHK
  -- Created : 02/11/2010 9:30:10 AM
  -- Purpose : Funciones de red para llamados REST

  MY_USER_AGENT constant varchar2(32) := 'RshkPLSQL_HTTP_CLI/6.7';


  -- Public function and procedure declarations
  function  do_post(p_url varchar2, p_names TStringArray, p_values TStringArray, transfer_timeout in pls_integer default 45) return clob;
  function  do_get(p_url varchar2, transfer_timeout in pls_integer default 45) return clob;
  function  do_get(p_url varchar2, p_names TStringArray, p_values TStringArray, transfer_timeout in pls_integer default 45) return clob;


end RSHK_HTTP;

/

create or replace package body RSHK_HTTP is

  FUNCTION read_response(resp in out utl_http.resp) RETURN CLOB is
    v_msg CLOB;
    v_ret CLOB;
  BEGIN
    v_ret := '';
    begin
      LOOP
         utl_http.read_text(r => resp, data => v_msg);
         v_ret := v_ret || v_msg;
      end loop;
    exception
      when utl_http.end_of_body then
         utl_http.end_response(r => resp);
    end;

    -- consider converting response to UTF-8
    RETURN v_ret;
  end read_response;

  function do_post(p_url varchar2, p_names TStringArray, p_values TStringArray, transfer_timeout in pls_integer default 45) return clob is
    v_post clob;
    req utl_http.req;
    resp utl_http.resp;
    old_timeout pls_integer;
  begin
    utl_http.get_transfer_timeout(old_timeout);
    utl_http.set_transfer_timeout(transfer_timeout);

    -- parameters processing
    v_post := '';
    if p_names.count > 0 then
      for i in p_names.first .. p_names.last loop
        v_post := v_post || utl_url.escape(p_names(i)) || '=' || utl_url.escape(url => p_values(i), escape_reserved_chars => TRUE) || '&';
      end loop;
    end if;
    if p_names.count > 0 then
      v_post := substr(v_post, 1, length(v_post) - 1);
    end if;

    -- HTTP POST
    req := utl_http.begin_request(url => p_url, method => 'POST');
    utl_http.set_header(req, 'Content-Type', 'application/x-www-form-urlencoded');
    utl_http.set_header(req, 'Content-Length', length(v_post));
    utl_http.set_header(req, 'User-Agent', MY_USER_AGENT);

    utl_http.write_text(req, v_post);

    -- leer respuesta HTTP
    resp := utl_http.get_response(r => req);
    utl_http.set_transfer_timeout(old_timeout);
    RETURN read_response(resp);
  end do_post;

  function do_get(p_url varchar2, transfer_timeout in pls_integer default 45) return clob is
    req utl_http.req;
    resp utl_http.resp;
    old_timeout pls_integer;
  begin
    utl_http.get_transfer_timeout(old_timeout);
    utl_http.set_transfer_timeout(transfer_timeout);
    req := utl_http.begin_request(url => p_url, method => 'GET');
    utl_http.set_header(req, 'User-Agent', MY_USER_AGENT);
    resp := utl_http.get_response(r => req);
    utl_http.set_transfer_timeout(old_timeout);
    RETURN read_response(resp);
  end do_get;

  function do_get(p_url varchar2, p_names TStringArray, p_values TStringArray, transfer_timeout in pls_integer default 45) return clob is
    query_string varchar2(2048);
  begin
    query_string := '';
    for i in p_names.first .. p_names.last loop
      query_string := query_string || utl_url.escape(p_names(i)) || '=' || utl_url.escape(url => p_values(i), escape_reserved_chars => TRUE) || '&';
    end loop;
    return do_get(p_url || '?' || query_string, transfer_timeout);
  end do_get;


begin
  -- Initialization
  utl_http.set_response_error_check(enable => false);
end RSHK_HTTP;

