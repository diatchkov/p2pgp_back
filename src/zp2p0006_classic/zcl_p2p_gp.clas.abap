class ZCL_P2P_GP definition
  public
  abstract
  create public .

public section.

  interfaces ZIF_P2P_GP_CONST .
  interfaces ZIF_P2P_GP .

  aliases MC_BSART_ZSTO
    for ZIF_P2P_GP_CONST~MC_BSART_ZSTO .
  aliases MC_CHG_ADD
    for ZIF_P2P_GP_CONST~MC_CHG_ADD .
  aliases MC_CHG_CHANGE
    for ZIF_P2P_GP_CONST~MC_CHG_CHANGE .
  aliases MC_CHG_DELETE
    for ZIF_P2P_GP_CONST~MC_CHG_DELETE .
  aliases MC_CHG_NO
    for ZIF_P2P_GP_CONST~MC_CHG_NO .
  aliases MC_CHG_RECALC
    for ZIF_P2P_GP_CONST~MC_CHG_RECALC .
  aliases MC_DEFAULT_TDP
    for ZIF_P2P_GP_CONST~MC_DEFAULT_TDP .
  aliases MC_GATEPASSTYPE
    for ZIF_P2P_GP_CONST~MC_GATEPASSTYPE .
  aliases MC_GP_STATUS
    for ZIF_P2P_GP_CONST~MC_GP_STATUS .
  aliases MC_MSG_CLASS
    for ZIF_P2P_GP_CONST~MC_MSG_CLASS .
  aliases MC_PROCIND
    for ZIF_P2P_GP_CONST~MC_PROCIND .
  aliases CHANGE
    for ZIF_P2P_GP~CHANGE .
  aliases CREATE
    for ZIF_P2P_GP~CREATE .
  aliases SET_GROSS_WEIGHT
    for ZIF_P2P_GP~SET_GROSS_WEIGHT .
  aliases SET_TARE_WEIGHT
    for ZIF_P2P_GP~SET_TARE_WEIGHT .
  aliases TS_DELIVERY_INS
    for ZIF_P2P_GP_CONST~TS_DELIVERY_INS .
  aliases TS_DELIVERY_UPD
    for ZIF_P2P_GP_CONST~TS_DELIVERY_UPD .
  aliases TS_SHIPMENT
    for ZIF_P2P_GP_CONST~TS_SHIPMENT .
  aliases TT_DELIVERY_UPD
    for ZIF_P2P_GP_CONST~TT_DELIVERY_UPD .
  aliases TT_ITEMDATA
    for ZIF_P2P_GP_CONST~TT_ITEMDATA .
  aliases TT_ITEMDATAACTION
    for ZIF_P2P_GP_CONST~TT_ITEMDATAACTION .
  aliases TT_SHIPMENT
    for ZIF_P2P_GP_CONST~TT_SHIPMENT .
  aliases TT_SHIPMENTHEADERDEADLINE
    for ZIF_P2P_GP_CONST~TT_SHIPMENTHEADERDEADLINE .
  aliases TT_SHIPMENTHEADERDEADLINEACT
    for ZIF_P2P_GP_CONST~TT_SHIPMENTHEADERDEADLINEACT .

  methods CONSTRUCTOR
    importing
      !IV_TKNUM type TKNUM .
  class-methods FACTORY
    importing
      !IV_TKNUM type TKNUM
    returning
      value(RO_GP) type ref to ZIF_P2P_GP .
protected section.

  data MV_TKNUM type TKNUM .
  data MS_SHIPMENT type TS_SHIPMENT .
  data MS_DB type ZI_P2P_GATEPASS .

  methods READ_DB .
private section.
ENDCLASS.



CLASS ZCL_P2P_GP IMPLEMENTATION.


  METHOD constructor.
    mv_tknum = iv_tknum.

    read_db( ).
  ENDMETHOD.


  METHOD factory.
    SELECT SINGLE gatepassid, gatepassdirection
      FROM zi_p2p_gatepass
     WHERE gatepassid EQ @iv_tknum
      INTO @DATA(ls_gatepass).

    CASE ls_gatepass-gatepassdirection.
      WHEN 'Z2'.
        ro_gp = CAST zif_p2p_gp( NEW zcl_p2p_gp_inbound( iv_tknum = iv_tknum ) ).
      WHEN OTHERS.
        ro_gp = CAST zif_p2p_gp( NEW zcl_p2p_gp_outbound( iv_tknum = iv_tknum ) ).
    ENDCASE.
  ENDMETHOD.


  METHOD zif_p2p_gp~change.
    CHECK ms_shipment-headerx   IS NOT INITIAL
       OR ms_shipment-deadlinex IS NOT INITIAL
       OR ms_shipment-itemx     IS NOT INITIAL.

    CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
      EXPORTING
        headerdata           = ms_shipment-header
        headerdataaction     = ms_shipment-headerx
      TABLES
        headerdeadline       = ms_shipment-deadline
        headerdeadlineaction = ms_shipment-deadlinex
        itemdata             = ms_shipment-item
        itemdataaction       = ms_shipment-itemx
        return               = rt_return.
  ENDMETHOD.


  METHOD zif_p2p_gp~set_tare_weight.
  ENDMETHOD.


  METHOD read_db.
    SELECT SINGLE *
      FROM zi_p2p_gatepass
     WHERE gatepassid EQ @mv_tknum
      INTO @ms_db.
  ENDMETHOD.


  METHOD zif_p2p_gp~set_gross_weight.
  ENDMETHOD.
ENDCLASS.
