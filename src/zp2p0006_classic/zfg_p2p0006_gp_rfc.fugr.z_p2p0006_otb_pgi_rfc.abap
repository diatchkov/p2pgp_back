FUNCTION z_p2p0006_otb_pgi_rfc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DELIVERYDOCUMENT) TYPE  VBELN_VL
*"  EXPORTING
*"     VALUE(ES_ERROR_LOG) TYPE  VBFS
*"     VALUE(ET_PROTOCOL) TYPE  TAB_PROTT
*"----------------------------------------------------------------------
  TRY.
      DATA(lo_od_api) = cl_outbound_delivery_factory=>get_instance( ).

      lo_od_api->post_goods_issue(
        EXPORTING
          im_deliverydocument = iv_deliverydocument
        IMPORTING
          ex_error_log        = DATA(ls_error_log)
          ex_protocol         = DATA(lt_protocol) ).

    CATCH cx_od_api_exception INTO DATA(lo_ex).
      APPEND LINES OF lo_ex->protocol_fm TO lt_protocol.
  ENDTRY.

  APPEND CORRESPONDING #( ls_error_log ) TO lt_protocol.
  et_protocol  = lt_protocol.
ENDFUNCTION.
