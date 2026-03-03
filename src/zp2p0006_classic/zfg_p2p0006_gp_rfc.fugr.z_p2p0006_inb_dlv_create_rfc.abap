FUNCTION z_p2p0006_inb_dlv_create_rfc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_ITEMS) TYPE  SHP_KOMDLGN_T
*"  EXPORTING
*"     VALUE(EV_DELIVERYDOCUMENT) TYPE  VBELN_VL
*"     VALUE(ET_RETURN) TYPE  BAPIRETTAB
*"----------------------------------------------------------------------

  DATA(lt_vbfs)   = VALUE vbfs_t( ).
  DATA(lt_vbls)   = VALUE vbls_t( ).
  DATA(lt_return) = VALUE bapiret2_t( ).

  DATA(ls_header) = VALUE vbsk(
    ernam = sy-uname
    erdat = sy-datum
    uzeit = sy-uzeit ).

  DATA(ls_pcntrl) = VALUE leshp_delivery_proc_control_in(
    privileged_mode = abap_true
    no_commit       = abap_true ).

  CALL FUNCTION 'GN_DELIVERY_CREATE'
    EXPORTING
      vbsk_i      = ls_header
      is_control  = ls_pcntrl
      no_commit   = abap_true
      if_no_deque = abap_true
    TABLES
      xkomdlgn    = it_items
      xvbfs       = lt_vbfs
      xvbls       = lt_vbls.

  LOOP AT lt_vbfs ASSIGNING FIELD-SYMBOL(<vbfs>).
    DATA(ls_return) = VALUE bapiret2(
        type       = <vbfs>-msgty
        id         = <vbfs>-msgid
        number     = <vbfs>-msgno
        message_v1 = <vbfs>-msgv1
        message_v2 = <vbfs>-msgv2
        message_v3 = <vbfs>-msgv3
        message_v4 = <vbfs>-msgv4 ).

    INSERT ls_return
      INTO TABLE et_return.
  ENDLOOP.

  ev_deliverydocument = VALUE #( lt_vbls[ 1 ]-vbeln_lif OPTIONAL ).
ENDFUNCTION.
