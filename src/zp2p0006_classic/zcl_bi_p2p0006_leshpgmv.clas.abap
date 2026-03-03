class ZCL_BI_P2P0006_LESHPGMV definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_GOODSMOVEMENT .

  constants MC_FBSTA_COMPLETED type FBSTA value 'C' ##NO_TEXT.
  constants MC_GROUP_SHIPMENT type SHTYP value 'Z030' ##NO_TEXT.
protected section.
private section.
ENDCLASS.



CLASS ZCL_BI_P2P0006_LESHPGMV IMPLEMENTATION.


  METHOD if_ex_le_shp_goodsmovement~change_input_header_and_items.
    CHECK is_likp-vbtyp EQ if_sd_doc_category=>delivery_shipping_notif.

    DATA(lt_shipment_key) = VALUE edoc_tknum_tab(
      FOR <vbfa> IN it_xvbfa WHERE ( vbtyp_n EQ if_sd_doc_category=>shipment ) ( <vbfa>-vbeln ) ).

    CHECK lt_shipment_key IS NOT INITIAL.

    SELECT tknum
      FROM vttk
       FOR ALL ENTRIES IN @lt_shipment_key
     WHERE tknum EQ @lt_shipment_key-table_line
       AND frkrl EQ @abap_true
       AND fbsta NE @mc_fbsta_completed
       AND shtyp NE @mc_group_shipment
      INTO TABLE @DATA(lt_shipment).

    CASE lines( lt_shipment ).
      WHEN 0.
      WHEN 1.
        DATA(lv_shipment_key) = lt_shipment[ 1 ]-tknum.
        DATA(lt_return)       = VALUE bapiret2_tab( ).

        DATA(lt_shipment_cost_items) = VALUE zttp2p0021_shpcit( ).

        CALL FUNCTION 'Z_P2P_BAPI_SHIPMENTCOST' DESTINATION 'SELF'
          EXPORTING
            iv_tknum_int  = lv_shipment_key
          TABLES
            it_cost_items = lt_shipment_cost_items
            et_return     = lt_return.

        LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>)
          WHERE type CA 'AEX'.
          DATA(ls_log) = VALUE shp_badi_error_log(
            vbeln = is_likp-vbeln
            msgty = <return>-type
            msgid = <return>-id
            msgno = <return>-number
            msgv1 = <return>-message_v1
            msgv2 = <return>-message_v2
            msgv3 = <return>-message_v3
            msgv4 = <return>-message_v4 ).

          INSERT ls_log
            INTO TABLE ct_log.
        ENDLOOP.
      WHEN OTHERS.
        MESSAGE e005(zp2p_0006_classic) WITH is_likp-vbeln INTO DATA(lv_msg).
        ls_log = CORRESPONDING shp_badi_error_log( syst ).
        ls_log-vbeln = is_likp-vbeln.

        INSERT ls_log
          INTO TABLE ct_log.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
