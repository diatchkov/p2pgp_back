INTERFACE zif_p2p_gp_const
  PUBLIC .

  TYPES:
    tt_shipmentheaderdeadline    TYPE STANDARD TABLE OF bapishipmentheaderdeadline    WITH DEFAULT KEY,
    tt_shipmentheaderdeadlineact TYPE STANDARD TABLE OF bapishipmentheaderdeadlineact WITH DEFAULT KEY,
    tt_itemdata                  TYPE STANDARD TABLE OF bapishipmentitem              WITH DEFAULT KEY,
    tt_itemdataaction            TYPE STANDARD TABLE OF bapishipmentitemaction        WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ts_delivery_upd,
      delivery_num   TYPE vbeln_vl,
      shipment_num   TYPE bapishipmentheader-shipment_num,
      picking_update TYPE boole_d,
      header         TYPE vbkok,
      partners       TYPE shp_partner_update_t,
      items          TYPE vbpok_t,
      no_read        TYPE xfeld,
      no_init        TYPE xfeld,
    END OF ts_delivery_upd,

    tt_delivery_upd TYPE STANDARD TABLE OF ts_delivery_upd WITH KEY delivery_num,

    BEGIN OF ts_shipment,
      shipment_num TYPE bapishipmentheader-shipment_num,
      ref_shipment TYPE bapishipmentheader-shipment_num,
      header       TYPE bapishipmentheader,
      headerx      TYPE bapishipmentheaderaction,
      item         TYPE tt_itemdata,
      itemx        TYPE tt_itemdataaction,
      deadline     TYPE tt_shipmentheaderdeadline,
      deadlinex    TYPE tt_shipmentheaderdeadlineact,
      deliveries   TYPE tt_delivery_upd,
      attachment   TYPE zttp2p0006_rc,
      po           TYPE zttp2p0006_po,
    END OF ts_shipment,

    tt_shipment TYPE STANDARD TABLE OF ts_shipment WITH KEY shipment_num.

  TYPES:
    BEGIN OF ts_delivery_ins,
      header TYPE vbsk,
      pcntrl TYPE leshp_delivery_proc_control_in,
      items  TYPE shp_komdlgn_t,
    END OF ts_delivery_ins.

  CONSTANTS:
    BEGIN OF mc_opera,
      insert TYPE updkz VALUE 'I',
      update TYPE updkz VALUE 'U',
      delete TYPE updkz VALUE 'D',
    END OF mc_opera.

  CONSTANTS:
    mc_chg_no     TYPE c VALUE 'N',
    mc_chg_add    TYPE c VALUE 'A',
    mc_chg_delete TYPE c VALUE 'D',
    mc_chg_change TYPE c VALUE 'C',
    mc_chg_recalc TYPE c VALUE 'R'.

  CONSTANTS:
    mc_default_tdp TYPE paramid VALUE 'TDP',
    mc_bsart_zsto  TYPE bsart   VALUE 'ZSTO',

    BEGIN OF mc_procind,
      p0001 TYPE sdabw VALUE '0001',
      p0002 TYPE sdabw VALUE '0002',
      p0003 TYPE sdabw VALUE '0003',
    END OF mc_procind,

    BEGIN OF mc_gatepasstype,
      z001 TYPE shtyp VALUE 'Z001',
      z002 TYPE shtyp VALUE 'Z002',
      z003 TYPE shtyp VALUE 'Z003',
      z004 TYPE shtyp VALUE 'Z004',
      z010 TYPE shtyp VALUE 'Z010',
      z020 TYPE shtyp VALUE 'Z020',
      z030 TYPE shtyp VALUE 'Z030',
    END OF mc_gatepasstype,

    BEGIN OF mc_gp_status,
      planning  TYPE zp2p_gp_status VALUE '01',
      checkin   TYPE zp2p_gp_status VALUE '02',
      loadstart TYPE zp2p_gp_status VALUE '03',
      loadend   TYPE zp2p_gp_status VALUE '04',
      shipstart TYPE zp2p_gp_status VALUE '05',
      shipend   TYPE zp2p_gp_status VALUE '06',
      shipcompl TYPE zp2p_gp_status VALUE '07',
    END OF mc_gp_status,

    BEGIN OF mc_activity,
      create      TYPE zp2p_wb_actvt VALUE '01',
      change      TYPE zp2p_wb_actvt VALUE '02',
      display     TYPE zp2p_wb_actvt VALUE '03',
      print       TYPE zp2p_wb_actvt VALUE '04',
      lock        TYPE zp2p_wb_actvt VALUE '05',
      delete      TYPE zp2p_wb_actvt VALUE '06',
      post        TYPE zp2p_wb_actvt VALUE '10',
      checkin     TYPE zp2p_wb_actvt VALUE 'Z1',
      checkout    TYPE zp2p_wb_actvt VALUE 'Z2',
      tareweigt   TYPE zp2p_wb_actvt VALUE 'Z3',
      grossweight TYPE zp2p_wb_actvt VALUE 'Z4',
      tolcheck    TYPE zp2p_wb_actvt VALUE '39',
    END OF mc_activity,

    BEGIN OF mc_truck_type,
      bulk      TYPE zp2p_truck_type VALUE '06',
      container TYPE zp2p_truck_type VALUE '08',
    END OF mc_truck_type,

  mc_msg_class type symsgid value 'ZP2P_0006_CLASSIC'.

ENDINTERFACE.
