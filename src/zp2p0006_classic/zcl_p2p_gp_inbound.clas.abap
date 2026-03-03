class ZCL_P2P_GP_INBOUND definition
  public
  inheriting from ZCL_P2P_GP
  final
  create public .

public section.
  methods ZIF_P2P_GP~SET_TARE_WEIGHT
    redefinition .
  methods ZIF_P2P_GP~SET_GROSS_WEIGHT
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_P2P_GP_INBOUND IMPLEMENTATION.


  METHOD zif_p2p_gp~set_gross_weight.
    ms_shipment-header-shipment_num     = mv_tknum.

    ms_shipment-header-status_plan        = abap_true.
    ms_shipment-header-status_checkin     = abap_true.
    ms_shipment-header-status_load_start  = abap_true.
    ms_shipment-header-zzwb_tare_weight   = ms_db-wbtareweight.
    ms_shipment-header-zzwb_gross_weight  = is_weight-weight.
    ms_shipment-header-zzwb_net_weight    = ms_shipment-header-zzwb_gross_weight - ms_shipment-header-zzwb_tare_weight.
    ms_shipment-header-zzwb_unit          = is_weight-meins.

    ms_shipment-headerx-status_plan       = mc_chg_change.
    ms_shipment-headerx-status_checkin    = mc_chg_change.
    ms_shipment-headerx-status_load_start = mc_chg_change.
    ms_shipment-headerx-zzwb_gross_weight = mc_chg_change.
    ms_shipment-headerx-zzwb_net_weight   = mc_chg_change.
    ms_shipment-headerx-zzwb_unit         = mc_chg_change.

    SELECT SINGLE dpreg, upreg
      FROM vttk
     WHERE tknum EQ @mv_tknum
      INTO @DATA(ls_entry).

    CONVERT DATE ls_entry-dpreg TIME ls_entry-upreg
       INTO TIME STAMP DATA(lv_entry) TIME ZONE sy-zonlo.

    CONVERT DATE sy-datum TIME sy-uzeit
       INTO TIME STAMP DATA(lv_wb_gross_entry) TIME ZONE sy-zonlo.

    ms_shipment-deadline = VALUE #( (
      time_type      = 'HDRSTPLDT'
      time_stamp_utc = lv_entry
      time_zone      = sy-zonlo ) (
      time_type      = 'HDRSTCIADT'
      time_stamp_utc = lv_entry
      time_zone      = sy-zonlo ) (
      time_type      = 'HDRSTLSADT'
      time_stamp_utc = lv_wb_gross_entry
      time_zone      = sy-zonlo ) ).

    ms_shipment-deadlinex = VALUE #( (
      time_type      = zif_p2p_gp_const~mc_chg_change
      time_stamp_utc = zif_p2p_gp_const~mc_chg_change
      time_zone      = zif_p2p_gp_const~mc_chg_change ) (
      time_type      = zif_p2p_gp_const~mc_chg_change
      time_stamp_utc = zif_p2p_gp_const~mc_chg_change
      time_zone      = zif_p2p_gp_const~mc_chg_change ) (
      time_type      = zif_p2p_gp_const~mc_chg_change
      time_stamp_utc = zif_p2p_gp_const~mc_chg_change
      time_zone      = zif_p2p_gp_const~mc_chg_change ) ).
  ENDMETHOD.


  METHOD zif_p2p_gp~set_tare_weight.
    ms_shipment-header-shipment_num      = mv_tknum.
    ms_shipment-header-status_load_end   = abap_true.
    ms_shipment-header-zzwb_tare_weight  = is_weight-weight.
    ms_shipment-header-zzwb_gross_weight = ms_db-wbgrossweight.
    ms_shipment-header-zzwb_net_weight   = ms_shipment-header-zzwb_gross_weight - ms_shipment-header-zzwb_tare_weight.
    ms_shipment-header-zzwb_unit         = is_weight-meins.

    ms_shipment-headerx-status_load_end  = mc_chg_change.
    ms_shipment-headerx-zzwb_tare_weight = mc_chg_change.
    ms_shipment-headerx-zzwb_net_weight  = mc_chg_change.
    ms_shipment-headerx-zzwb_unit        = mc_chg_change.

    CONVERT DATE sy-datum TIME sy-uzeit
       INTO TIME STAMP DATA(lv_wb_tare_entry) TIME ZONE sy-zonlo.

    ms_shipment-deadline = VALUE #( (
      time_type      = 'HDRSTLEADT'
      time_stamp_utc = lv_wb_tare_entry
      time_zone      = sy-zonlo ) ).

    ms_shipment-deadlinex = VALUE #( (
      time_type      = zif_p2p_gp_const~mc_chg_change
      time_stamp_utc = zif_p2p_gp_const~mc_chg_change
      time_zone      = zif_p2p_gp_const~mc_chg_change ) ).
  ENDMETHOD.
ENDCLASS.
