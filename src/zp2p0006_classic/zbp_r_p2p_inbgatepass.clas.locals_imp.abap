CLASS lhc_inbgatepassitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR inbgatepassitem RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR inbgatepassitem RESULT result.

    METHODS printnote FOR MODIFY
      IMPORTING keys FOR ACTION inbgatepassitem~printnote RESULT result.

ENDCLASS.

CLASS lhc_inbgatepassitem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD printnote.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_inbgatepass\\inbgatepassitem~printnote.

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepassitem ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgpi).

    LOOP AT lt_inbgpi ASSIGNING FIELD-SYMBOL(<inbgpi>).
      TRY.

          DATA(lo_note) = NEW zcl_o2c0014_delnote_print( iv_delivery = <inbgpi>-deliverydocument ).
          DATA(ls_cont) = lo_note->get_pdf( ).

        CATCH cx_somu_error INTO DATA(lr_formerror).
      ENDTRY.

      DATA(ls_result) = VALUE ts_result(  ).

      ls_result-%tky            = <inbgpi>-%tky.
      ls_result-%param-mimetype = 'application/pdf'.
      ls_result-%param-filename = |{ <inbgpi>-deliverydocument }_Note.pdf'|.

      CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
        EXPORTING
          input  = ls_cont-pdf_content
        IMPORTING
          output = ls_result-%param-mimecont.

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_inbgatepass DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    INTERFACES zif_p2p_gp_const.

    CLASS-METHODS class_constructor.

  PRIVATE SECTION.
    CONSTANTS:
        mc_msg_class TYPE symsgid VALUE 'ZP2P_0006_CLASSIC'.

    TYPES:
      ts_permission TYPE STRUCTURE FOR PERMISSIONS REQUEST zr_p2p_inbgatepass,
      ts_response   TYPE STRUCTURE FOR REPORTED LATE zr_p2p_inbgatepass\\inbgatepass,

      BEGIN OF ts_transporter,
        db_schenker TYPE lifnr,
      END OF ts_transporter.

    CLASS-DATA:
      ms_transporter TYPE ts_transporter.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR inbgatepass RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR inbgatepass RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR inbgatepass RESULT result.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR inbgatepass RESULT result.

    METHODS getgpentry FOR MODIFY
      IMPORTING keys FOR ACTION inbgatepass~getgpentry.

    METHODS getgpexit FOR MODIFY
      IMPORTING keys FOR ACTION inbgatepass~getgpexit.

    METHODS getwbgrossweight FOR MODIFY
      IMPORTING keys FOR ACTION inbgatepass~getwbgrossweight.

    METHODS getwbtareweight FOR MODIFY
      IMPORTING keys FOR ACTION inbgatepass~getwbtareweight.

    METHODS calcwbnetweight FOR DETERMINE ON MODIFY
      IMPORTING keys FOR inbgatepass~calcwbnetweight.

    METHODS determinedefaultvaluesforhead FOR DETERMINE ON MODIFY
      IMPORTING keys FOR inbgatepass~determinedefaultvaluesforhead.

    METHODS postgr FOR MODIFY
      IMPORTING keys FOR ACTION inbgatepass~postgr.

    METHODS printgpentry FOR MODIFY
      IMPORTING keys   FOR ACTION inbgatepass~printgpentry
      RESULT    result.

    METHODS printgpexit FOR MODIFY
      IMPORTING keys   FOR ACTION inbgatepass~printgpexit
      RESULT    result.

    METHODS postgitocrusher FOR MODIFY
      IMPORTING keys FOR ACTION inbgatepass~postgitocrusher.

    METHODS calcplant FOR DETERMINE ON MODIFY
      IMPORTING keys FOR inbgatepass~calcplant.

    METHODS calcgatepasstype FOR DETERMINE ON MODIFY
      IMPORTING keys FOR inbgatepass~calcgatepasstype.

    METHODS checkobligfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR inbgatepass~checkobligfields.

*    METHODS calcordernumberitem FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR inbgatepass~calcordernumberitem.

    METHODS calcbulk FOR DETERMINE ON MODIFY
      IMPORTING keys FOR inbgatepass~calcbulk.

    METHODS checkbol FOR VALIDATE ON SAVE
      IMPORTING keys FOR inbgatepass~checkbol.

    METHODS is_manual_granted
      RETURNING VALUE(rv_granted) TYPE boole_d.

    METHODS is_activity_granted
      IMPORTING
                iv_activity       TYPE zp2p_wb_actvt
      RETURNING VALUE(rv_granted) TYPE boole_d.
ENDCLASS.

CLASS lhc_inbgatepass IMPLEMENTATION.

  METHOD is_manual_granted.
    AUTHORITY-CHECK OBJECT 'ZP2P_WBMAN'
      ID 'ACTVT' FIELD if_dmc_authority_constants=>gc_actvt_change.

    rv_granted = COND #( WHEN sy-subrc EQ 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.

  METHOD is_activity_granted.
    AUTHORITY-CHECK OBJECT 'ZP2P_WBACT'
      ID 'WB_ACTVT' FIELD iv_activity.

    rv_granted = COND #( WHEN sy-subrc EQ 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_features.
    result-%create = COND #(
      WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-create )
      THEN if_abap_behv=>fc-f-unrestricted
      ELSE if_abap_behv=>fc-f-read_only ).
  ENDMETHOD.

  METHOD get_instance_features.
    TYPES:
      ts_result TYPE STRUCTURE FOR INSTANCE FEATURES RESULT zr_p2p_inbgatepass\\inbgatepass.

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
       ENTITY inbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_inbgp).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      DATA(ls_result) = VALUE ts_result(
        %tky                = <inbgp>-%tky

        %action-edit = COND #(
          WHEN NOT is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-change )
            OR <inbgp>-islogicallydeleted EQ abap_true
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %delete = COND #(
          WHEN NOT is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-delete )
            OR <inbgp>-islogicallydeleted EQ abap_true
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-wbmanual = COND #(
          WHEN is_manual_granted( ) = abap_false
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-containerid = COND #(
          WHEN <inbgp>-trucktype = zif_p2p_gp_const=>mc_truck_type-container
          THEN if_abap_behv=>fc-f-mandatory
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-sealnumber = COND #(
          WHEN <inbgp>-trucktype = zif_p2p_gp_const=>mc_truck_type-container
          THEN if_abap_behv=>fc-f-mandatory
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-ordernumber = COND #(
          WHEN <inbgp>-isbulk = abap_true
          THEN if_abap_behv=>fc-f-mandatory
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-ordernumberitem = COND #(
          WHEN <inbgp>-isbulk = abap_true
          THEN if_abap_behv=>fc-f-mandatory
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-storagelocation = COND #(
          WHEN <inbgp>-isbulk = abap_true
          THEN if_abap_behv=>fc-f-mandatory
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-wbsafetycheck = if_abap_behv=>fc-f-mandatory

        %field-wbmanualreason = COND #(
          WHEN <inbgp>-wbmanual = abap_false
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-mandatory )

        %field-wbdeviceid = COND #(
          WHEN <inbgp>-wbmanual = abap_true
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-wbtareweight = COND #(
          WHEN <inbgp>-wbmanual = abap_false
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-wbgrossweight = COND #(
          WHEN <inbgp>-wbmanual = abap_false
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-wbunit = COND #(
          WHEN <inbgp>-wbmanual = abap_false
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-billoflanding = COND #(
          WHEN <inbgp>-transporter EQ ms_transporter-db_schenker
          THEN if_abap_behv=>fc-f-mandatory
          ELSE if_abap_behv=>fc-f-unrestricted )

        %field-radiationcertificatebody = COND #(
          WHEN <inbgp>-isscrap EQ abap_true
          THEN if_abap_behv=>fc-f-mandatory
          ELSE if_abap_behv=>fc-f-unrestricted )

        %action-getgpentry = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-checkin )
           AND <inbgp>-%is_draft = if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )

        %action-getwbgrossweight = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-grossweight )
           AND <inbgp>-wbmanual = abap_false
           AND <inbgp>-%is_draft = if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )

        %action-getwbtareweight = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-tareweigt )
           AND <inbgp>-wbmanual = abap_false
           AND <inbgp>-%is_draft = if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )

        %action-getgpexit = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-checkout )
           AND ( <inbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
            OR ( <inbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadstart AND
                 <inbgp>-wbnotrelevant  EQ abap_true ) )
           AND <inbgp>-%is_draft EQ if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )

        %action-printgpentry = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-print )
           AND <inbgp>-%is_draft = if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )

        %action-printgpexit = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-print )
           AND <inbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
           AND <inbgp>-%is_draft      EQ if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )

        %action-postgr = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-post )
           AND <inbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
           AND <inbgp>-%is_draft      EQ if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )

        %action-postgitocrusher = COND #(
          WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-post )
           AND <inbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
           AND <inbgp>-%is_draft      EQ if_abap_behv=>mk-off
          THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only ) ).

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD getgpentry.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
        ENTITY inbgatepass ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_inbgp).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      <inbgp>-entrydate = sy-datum.
      <inbgp>-entrytime = sy-uzeit.
      <inbgp>-entryuser = sy-uname.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
       ENTITY inbgatepass
       UPDATE FIELDS ( entrydate entrytime entryuser )
       WITH VALUE #( FOR inbgp IN lt_inbgp
                     ( %tky      = inbgp-%tky
                       entrydate = inbgp-entrydate
                       entrytime = inbgp-entrytime
                       entryuser = inbgp-entryuser ) )
       FAILED failed MAPPED mapped REPORTED reported.
  ENDMETHOD.

  METHOD getgpexit.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
        ENTITY inbgatepass ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_inbgp).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      <inbgp>-exitdate = sy-datum.
      <inbgp>-exittime = sy-uzeit.
      <inbgp>-exituser = sy-uname.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
       ENTITY inbgatepass
       UPDATE FIELDS ( exitdate exittime exituser )
       WITH VALUE #( FOR inbgp IN lt_inbgp
                     ( %tky     = inbgp-%tky
                       exitdate = inbgp-exitdate
                       exittime = inbgp-exittime
                       exituser = inbgp-exituser ) )
       FAILED failed MAPPED mapped REPORTED reported.
  ENDMETHOD.

  METHOD getwbgrossweight.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
       ENTITY inbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_inbgp).

    DATA(lv_error) = abap_false.

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      TRY.
          DATA(ls_params)  = VALUE zsp2p_wb_weight_capture(
            device_id = <inbgp>-wbdeviceid
            rf_id     = <inbgp>-rfid
            tknum     = <inbgp>-gatepassid ).

          DATA(lo_capture) = NEW zcl_p2p_wb_weight_capture( is_params = ls_params ).

          DATA(ls_weight) = lo_capture->capture_weight( ).

          GET TIME STAMP FIELD DATA(lv_crtmp).

          DATA(ls_weight_status) = VALUE ztp2p_wb_weight(
            guid          = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( )
            trans_id      = ls_weight-trans_id
            device_id     = ls_weight-device_id
            rf_id         = ls_weight-rf_id
            location      = ls_weight-location
            weight        = ls_weight-weight
            tknum         = <inbgp>-gatepassid
            weight_id     = zcl_p2p_wb_weight_capture=>mc_weight_id-gross
            crtmp         = lv_crtmp
            crnam         = sy-uname
            weight_status = zcl_p2p_wb_weight_capture=>mc_weight_status-grosscaptured
            sttmp         = lv_crtmp
            stnam         = sy-uname ).

          lo_capture->set_weight_status(
            is_weight_status = ls_weight_status ).

          <inbgp>-wbgrossweight = ls_weight-weight.

        CATCH zcx_p2p_wb_weight_capture INTO DATA(lo_ex).
          INSERT VALUE #( %tky                     = <inbgp>-%tky
                          %msg                     = new_message_with_text(
                            text     = lo_ex->get_text( )
                            severity = if_abap_behv_message=>severity-error ) ) INTO TABLE reported-inbgatepass.

          INSERT VALUE #( %tky                     = <inbgp>-%tky
                          %action-getwbgrossweight = if_abap_behv=>mk-on
                          %fail-cause              = if_abap_behv=>cause-unspecific ) INTO TABLE failed-inbgatepass.

          lv_error = abap_true.
      ENDTRY.
    ENDLOOP.

    IF lv_error EQ abap_false.
      MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
         ENTITY inbgatepass
         UPDATE FIELDS ( wbgrossweight wbunit )
         WITH VALUE #( FOR inbgp IN lt_inbgp
                       ( %tky        = inbgp-%tky
                         wbgrossweight = inbgp-wbgrossweight
                         wbunit        = inbgp-wbunit ) ).
    ENDIF.
  ENDMETHOD.

  METHOD getwbtareweight.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
       ENTITY inbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_inbgp).

    DATA(lv_error) = abap_false.

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).

      TRY.
          DATA(ls_params)  = VALUE zsp2p_wb_weight_capture(
              device_id = <inbgp>-wbdeviceid
              rf_id     = <inbgp>-rfid
              tknum     = <inbgp>-gatepassid ).

          DATA(lo_capture) = NEW zcl_p2p_wb_weight_capture( is_params = ls_params ).

          DATA(ls_weight) = lo_capture->capture_weight( ).

          GET TIME STAMP FIELD DATA(lv_crtmp).

          DATA(ls_weight_status) = VALUE ztp2p_wb_weight(
            guid          = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( )
            trans_id      = ls_weight-trans_id
            device_id     = ls_weight-device_id
            rf_id         = ls_weight-rf_id
            location      = ls_weight-location
            weight        = ls_weight-weight
            tknum         = <inbgp>-gatepassid
            weight_id     = zcl_p2p_wb_weight_capture=>mc_weight_id-tare
            crtmp         = lv_crtmp
            crnam         = sy-uname
            weight_status = zcl_p2p_wb_weight_capture=>mc_weight_status-tarecaptured
            sttmp         = lv_crtmp
            stnam         = sy-uname ).

          lo_capture->set_weight_status(
            is_weight_status = ls_weight_status ).

          <inbgp>-wbtareweight = ls_weight-weight.
        CATCH zcx_p2p_wb_weight_capture INTO DATA(lo_ex).
          INSERT VALUE #( %tky                     = <inbgp>-%tky
                          %msg                     = new_message_with_text(
                            text     = lo_ex->get_text( )
                            severity = if_abap_behv_message=>severity-error ) ) INTO TABLE reported-inbgatepass.

          INSERT VALUE #( %tky                     = <inbgp>-%tky
                          %action-getwbgrossweight = if_abap_behv=>mk-on
                          %fail-cause              = if_abap_behv=>cause-unspecific ) INTO TABLE failed-inbgatepass.

          lv_error = abap_true.
      ENDTRY.
    ENDLOOP.

    IF lv_error EQ abap_false.
      MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
         ENTITY inbgatepass
         UPDATE FIELDS ( wbtareweight wbunit )
         WITH VALUE #( FOR inbgp IN lt_inbgp
                       ( %tky        = inbgp-%tky
                         wbtareweight = inbgp-wbtareweight
                         wbunit       = inbgp-wbunit ) ).
    ENDIF.
  ENDMETHOD.

  METHOD calcwbnetweight.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
       ENTITY inbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_inbgp).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      IF <inbgp>-wbgrossweight EQ 0 OR <inbgp>-wbtareweight EQ 0.
        <inbgp>-wbnetweight = 0.
      ELSE.
        <inbgp>-wbnetweight = <inbgp>-wbgrossweight - <inbgp>-wbtareweight.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
       ENTITY inbgatepass
       UPDATE FIELDS (  wbnetweight )
       WITH VALUE #( FOR inbgp IN lt_inbgp
                     ( %tky        = inbgp-%tky
                       wbnetweight = inbgp-wbnetweight ) ).
  ENDMETHOD.

  METHOD determinedefaultvaluesforhead.
    TYPES:
      ts_itemupdate TYPE STRUCTURE FOR UPDATE zr_p2p_inbgatepass\\inbgatepass,
      tt_itemupdate TYPE TABLE FOR UPDATE zr_p2p_inbgatepass\\inbgatepass.

    DATA(lt_itemupdate) = VALUE tt_itemupdate( ).

    SELECT SINGLE userparametervalue
      FROM p_userparameter
     WHERE userparameter EQ @zcl_p2p_wb_weight_capture=>mc_device_pid
      INTO @DATA(lv_default_device).

    SELECT SINGLE userparametervalue
      FROM p_userparameter
     WHERE userparameter EQ @zif_p2p_gp_const~mc_default_tdp
      INTO @DATA(lv_default_tdp).

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass
      FIELDS ( transpplanpoint wbdeviceid wbunit truckcapacityunit )
      WITH CORRESPONDING #( keys )
      RESULT DATA(inbgp).

    LOOP AT inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      IF <inbgp>-wbunit IS INITIAL.
        APPEND VALUE ts_itemupdate(
          %tky              = <inbgp>-%tky
          transpplanpoint   = lv_default_tdp
          wbdeviceid        = lv_default_device
          wbunit            = zcl_p2p_wb_weight_capture=>mc_default_unit
          truckcapacityunit = zcl_p2p_wb_weight_capture=>mc_default_unit ) TO lt_itemupdate.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
        ENTITY inbgatepass
        UPDATE FIELDS ( transpplanpoint wbdeviceid wbunit truckcapacityunit )
        WITH lt_itemupdate.
  ENDMETHOD.

  METHOD postgr.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass BY \_item ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgpi).

    DATA(lt_shipment) = VALUE zif_p2p_gp_const~tt_shipment(  ).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      READ TABLE lt_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
          shipment_num = <inbgp>-%key-gatepassid.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          shipment_num        = <inbgp>-%key-gatepassid
          ref_shipment        = <inbgp>-%key-gatepassid
          header-shipment_num = <inbgp>-%key-gatepassid )
          INTO TABLE lt_shipment ASSIGNING <shipment>.
      ENDIF.

      CONVERT DATE sy-datum TIME sy-uzeit INTO TIME STAMP DATA(lv_completion) TIME ZONE sy-zonlo.

      DATA(ls_deadline) = VALUE bapishipmentheaderdeadline(
        time_type      = 'HDRSTCADT'
        time_stamp_utc = lv_completion
        time_zone      = sy-zonlo ).

      INSERT ls_deadline
        INTO TABLE <shipment>-deadline.

      DATA(ls_deadlinex) = VALUE bapishipmentheaderdeadlineact(
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ).

      INSERT ls_deadlinex
        INTO TABLE <shipment>-deadlinex.

      <shipment>-header-status_compl  = abap_true.
      <shipment>-headerx-status_compl = zif_p2p_gp_const~mc_chg_change.
    ENDLOOP.

    DATA(lv_error) = abap_false.

    LOOP AT lt_shipment ASSIGNING <shipment>.
      DATA(lt_return) = VALUE bapiret2_tab( ).

      CALL FUNCTION 'BAPI_SHIPMENT_CHANGE' DESTINATION 'NONE'
        EXPORTING
          headerdata           = <shipment>-header
          headerdataaction     = <shipment>-headerx
        TABLES
          headerdeadline       = <shipment>-deadline
          headerdeadlineaction = <shipment>-deadlinex
          return               = lt_return.

      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>)
        WHERE type CA 'AEX'.

        lv_error = abap_true.

        APPEND VALUE #(
          %key           = <inbgp>-%key
          %state_area    = 'INBGATEPASS'
          %action-postgr = if_abap_behv=>mk-on
          %msg           = me->new_message(
            id       = <return>-id
            number   = <return>-number
            severity = if_abap_behv_message=>severity-error
            v1       = <return>-message_v1
            v2       = <return>-message_v2
            v3       = <return>-message_v3
            v4       = <return>-message_v4 ) ) TO reported-inbgatepass.
      ENDLOOP.

      IF lv_error EQ abap_true.
        INSERT VALUE #(
          %key           = <inbgp>-%key
          %fail-cause    = if_abap_behv=>cause-unspecific
          %action-postgr = if_abap_behv=>mk-on )
          INTO TABLE failed-inbgatepass.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
      ELSE.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'.
      ENDIF.

      CALL FUNCTION 'RFC_CONNECTION_CLOSE'
        EXPORTING
          destination = 'NONE'
        EXCEPTIONS
          OTHERS      = 0.
    ENDLOOP.

    CHECK lv_error EQ abap_false.

    MODIFY ENTITIES OF i_inbounddeliverytp
      ENTITY inbounddelivery
      EXECUTE postgoodsmovement
      FROM VALUE #( FOR <inbkey> IN lt_inbgpi
        ( inbounddelivery = <inbkey>-deliverydocument ) )
      MAPPED DATA(gm_mapped)
      REPORTED DATA(gm_reported)
      FAILED DATA(gm_failed).

    LOOP AT lt_inbgpi ASSIGNING FIELD-SYMBOL(<inbgpi>).
      LOOP AT gm_failed-inbounddelivery ASSIGNING FIELD-SYMBOL(<failed>) USING KEY entity
        WHERE %key-inbounddelivery = <inbgpi>-deliverydocument.
        INSERT VALUE #(
          %key           = <inbgp>-%key
          %fail-cause    = if_abap_behv=>cause-unspecific
          %action-postgr = if_abap_behv=>mk-on )
          INTO TABLE failed-inbgatepass.
      ENDLOOP.

      LOOP AT gm_reported-inbounddelivery ASSIGNING FIELD-SYMBOL(<reported>) USING KEY entity
        WHERE %key-inbounddelivery = <inbgpi>-deliverydocument.
        APPEND VALUE #(
          %key           = <inbgp>-%key
          %state_area    = 'INBGATEPASS'
          %action-postgr = if_abap_behv=>mk-on
          %msg           = <reported>-%msg ) TO reported-inbgatepass.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD printgpentry.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_inbgatepass\\inbgatepass~printgpentry.

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      TRY.
          DATA(lt_keys) = VALUE cl_somu_form_services=>ty_gt_key(
            ( name = 'ShipmentNum'    value = <inbgp>-%key-gatepassid )
            ( name = 'Language'       value = sy-langu )
            ( name = 'OutputType'     value = 'ENTRY' )
            ( name = 'OutputPreview'  value = 'DoPreview' ) ) ##NO_TEXT.

          cl_somu_form_services=>get_instance( )->get_pdf(
            EXPORTING
              iv_form_name                 = 'ZZO2C0013_GATEPASS_V1'
              it_key                       = lt_keys
            IMPORTING
              ev_pdf                       = DATA(lv_mimecont) ).
        CATCH cx_somu_error INTO DATA(lr_formerror).
      ENDTRY.

      DATA(ls_result) = VALUE ts_result(  ).

      ls_result-%key            = <inbgp>-%key.
      ls_result-%param-mimetype = 'application/pdf'.
      ls_result-%param-filename = |{ <inbgp>-%key-gatepassid }_Entry.pdf'|.

      CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
        EXPORTING
          input  = lv_mimecont
        IMPORTING
          output = ls_result-%param-mimecont.

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD printgpexit.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_inbgatepass\\inbgatepass~printgpexit.

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      TRY.
          DATA(lt_keys) = VALUE cl_somu_form_services=>ty_gt_key(
            ( name = 'ShipmentNum'    value = <inbgp>-%key-gatepassid )
            ( name = 'Language'       value = sy-langu )
            ( name = 'OutputType'     value = 'EXIT' )
            ( name = 'OutputPreview'  value = 'DoPreview' ) ) ##NO_TEXT.

          cl_somu_form_services=>get_instance( )->get_pdf(
            EXPORTING
              iv_form_name                 = 'ZZO2C0013_GATEPASS_V1'
              it_key                       = lt_keys
            IMPORTING
              ev_pdf                       = DATA(lv_mimecont) ).
        CATCH cx_somu_error INTO DATA(lr_formerror).
      ENDTRY.

      DATA(ls_result) = VALUE ts_result(  ).

      ls_result-%key            = <inbgp>-%key.
      ls_result-%param-mimetype = 'application/pdf'.
      ls_result-%param-filename = |{ <inbgp>-%key-gatepassid }_Exit.pdf'|.

      CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
        EXPORTING
          input  = lv_mimecont
        IMPORTING
          output = ls_result-%param-mimecont.

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD postgitocrusher.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass BY \_item ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgpi).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      READ TABLE lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>) WITH KEY entity COMPONENTS
        %key = <key>-%key.
      CHECK sy-subrc EQ 0.

      DATA(lt_deliveries) = VALUE zttp2p_bapishipmentitem(
        FOR <item> IN lt_inbgpi WHERE ( %pidparent = <inbgp>-%pid ) ( delivery = <item>-deliverydocument ) ).

      LOOP AT lt_deliveries ASSIGNING FIELD-SYMBOL(<delivery>).
        SELECT *
          FROM lips
         WHERE vbeln EQ @<delivery>-delivery
          INTO TABLE @DATA(lt_lips).

        DATA(ls_header) = VALUE bapi2017_gm_head_01(
          pstng_date          = sy-datum
          doc_date            = sy-datum
          bill_of_lading      = <inbgp>-billoflanding
          header_txt          = |{ <delivery>-delivery }| ).

        DATA(ls_code) = VALUE bapi2017_gm_code(
          gm_code = '03' ).

        DATA(lt_item) = VALUE bapi2017_gm_item_create_t( ).

        LOOP AT lt_lips ASSIGNING FIELD-SYMBOL(<lips>).
          DATA(ls_item) = VALUE bapi2017_gm_item_create(
            move_type            = '261'
            material             = <lips>-matnr
            plant                = <lips>-werks
            val_type             = <lips>-bwtar
            stge_loc             = <lips>-lgort
            entry_qnt            = <lips>-lfimg
            entry_uom            = <lips>-meins
            deliv_numb_to_search = <lips>-vbeln
            deliv_item_to_search = <lips>-posnr
            orderid              = <key>-%param-orderid ).

          INSERT ls_item
            INTO TABLE lt_item.
        ENDLOOP.

        DATA(lt_return) = VALUE bapiret2_t( ).
        DATA(ls_gmhead) = VALUE bapi2017_gm_head_ret( ).

        CALL FUNCTION 'BAPI_GOODSMVT_CREATE' DESTINATION 'NONE'
          EXPORTING
            goodsmvt_header  = ls_header
            goodsmvt_code    = ls_code
            testrun          = abap_false
          IMPORTING
            goodsmvt_headret = ls_gmhead
          TABLES
            goodsmvt_item    = lt_item
            return           = lt_return.

        LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>)
          WHERE type CA 'AEX'.

          DATA(lv_error) = abap_true.

          APPEND VALUE #(
              %key           = <inbgp>-%key
              %state_area    = 'INBGATEPASS'
              %action-postgr = if_abap_behv=>mk-on
              %msg           = me->new_message(
                  id       = <return>-id
                  number   = <return>-number
                  severity = if_abap_behv_message=>severity-error
                  v1       = <return>-message_v1
                  v2       = <return>-message_v2
                  v3       = <return>-message_v3
                  v4       = <return>-message_v4 ) ) TO reported-inbgatepass.
        ENDLOOP.

        IF lv_error EQ abap_true.
          INSERT VALUE #(
            %key           = <inbgp>-%key
            %fail-cause    = if_abap_behv=>cause-unspecific
            %action-postgr = if_abap_behv=>mk-on )
            INTO TABLE failed-inbgatepass.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.

          CONTINUE.
        ELSE.
          APPEND VALUE #(
            %msg = me->new_message(
              id       = mc_msg_class
              number   = '002'
              severity = if_abap_behv_message=>severity-success
              v1       = ls_gmhead-mat_doc
              v2       = ls_gmhead-doc_year ) ) TO reported-inbgatepass.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'.
        ENDIF.

        CALL FUNCTION 'RFC_CONNECTION_CLOSE'
          EXPORTING
            destination = 'NONE'
          EXCEPTIONS
            OTHERS      = 0.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD calcplant.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass FIELDS ( ordernumber plant storagelocation )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    SELECT *
      FROM zc_p2p_first_poi
       FOR ALL ENTRIES IN @lt_inbgp
     WHERE purchaseorder EQ @lt_inbgp-ordernumber
      INTO TABLE @DATA(lt_first_poi).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      DATA(ls_first_poi) = VALUE #(  lt_first_poi[ purchaseorder = <inbgp>-ordernumber ] OPTIONAL ).
      <inbgp>-plant           = ls_first_poi-plant.
      <inbgp>-storagelocation = ls_first_poi-storagelocation.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass
      UPDATE FIELDS ( plant storagelocation )
      WITH VALUE #(
        FOR inbgp IN lt_inbgp (
          %tky            = inbgp-%tky
          plant           = inbgp-plant
          storagelocation = inbgp-storagelocation ) ).
  ENDMETHOD.

  METHOD calcgatepasstype.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH VALUE #( FOR key IN keys (
        %key      = key-%key
        %is_draft = if_abap_behv=>mk-off ) )
      RESULT DATA(lt_active).

    CHECK lt_active IS INITIAL.

    DATA(lv_one_time) = CONV tdlnr( zcl_asas_tvarv_constant=>get_value( iv_name = 'ZP2P0006_CLASSIC_SUPPLIER' ) ).

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass FIELDS ( transpplanpoint gatepasstype )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    SELECT *
      FROM ztp2p_a_inbstdef
       FOR ALL ENTRIES IN @lt_inbgp
     WHERE tplst EQ @lt_inbgp-transpplanpoint
      INTO TABLE @DATA(lt_inbstdef).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      DATA(ls_inbstdef) = VALUE #(  lt_inbstdef[ tplst = <inbgp>-transpplanpoint ] OPTIONAL ).
      <inbgp>-gatepasstype = ls_inbstdef-shtyp.

      IF <inbgp>-transporter EQ lv_one_time.
        <inbgp>-gatepasstype = zif_p2p_gp_const~mc_gatepasstype-z020.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass
      UPDATE FIELDS ( gatepasstype )
      WITH VALUE #(
        FOR inbgp IN lt_inbgp (
          %tky         = inbgp-%tky
          gatepasstype = inbgp-gatepasstype ) ).
  ENDMETHOD.

  METHOD checkobligfields.
    DATA(ls_permission_request) = VALUE ts_permission( ).

    DATA(lo_struct) = CAST cl_abap_structdescr(
      cl_abap_structdescr=>describe_by_data_ref( REF #(  ls_permission_request-%field  ) ) ).

    DATA(lt_components) = lo_struct->get_components( ).

    LOOP AT lt_components ASSIGNING FIELD-SYMBOL(<field>).
      ls_permission_request-%field-(<field>-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      GET PERMISSIONS ONLY INSTANCE FEATURES OF zr_p2p_inbgatepass
        ENTITY inbgatepass
        FROM VALUE #( ( %tky = <inbgp>-%tky ) )
        REQUEST ls_permission_request
        RESULT DATA(ls_permission_result).

      LOOP AT lt_components ASSIGNING <field>.

        CHECK ls_permission_result-instances[ %tky = <inbgp>-%tky ]-%field-(<field>-name) EQ if_abap_behv=>fc-f-mandatory
           OR ls_permission_result-global-%field-(<field>-name) EQ if_abap_behv=>fc-f-mandatory.

        CHECK <inbgp>-(<field>-name) IS INITIAL.

        APPEND VALUE #(  %tky = <inbgp>-%tky ) TO failed-inbgatepass.

        cl_dd_ddl_annotation_service=>get_annos_4_element(
          EXPORTING
            entityname  = 'ZC_P2P_INBGATEPASS'
            elementname = CONV #( <field>-name )
          IMPORTING
            annos       = DATA(lt_annotations) ).

        DATA(lv_label) = VALUE #(  lt_annotations[ annoname = 'ENDUSERTEXT.LABEL' ]-value OPTIONAL ).

        DATA(ls_reported) = VALUE ts_response(
          %tky        = <inbgp>-%tky
          %state_area = 'INBGATEPASS'
          %msg        = me->new_message(
            id       = mc_msg_class
            number   = '006'
            severity = if_abap_behv_message=>severity-error
            v1       = lv_label ) ).

        ls_reported-%element-(<field>-name) = if_abap_behv=>mk-on.

        APPEND ls_reported TO reported-inbgatepass.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

*  METHOD calcordernumberitem.
*    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
*      ENTITY inbgatepass FIELDS ( ordernumber ordernumberitem )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_inbgp).
*
***    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
***      <inbgp>-ordernumberitem = VALUE #( lt_items[ purchaseorder = <inbgp>-ordernumber ]-purchaseorderitem OPTIONAL ).
***    ENDLOOP.
**
**    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
**      ENTITY inbgatepass
**      UPDATE FIELDS ( ordernumberitem )
**      WITH VALUE #(
**        FOR inbgp IN lt_inbgp (
**          %tky            = inbgp-%tky
**          ordernumberitem = inbgp-ordernumberitem ) ).
*  ENDMETHOD.

  METHOD calcbulk.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass FIELDS ( transpplanpoint trucktype isbulk )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    IF lt_inbgp IS NOT INITIAL.
      SELECT tplst, fillbulk
        FROM zc_p2p_definbshiptype AS dft
        JOIN @lt_inbgp AS inb
          ON inb~transpplanpoint EQ dft~tplst
        INTO TABLE @DATA(lt_defaults).
    ENDIF.

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).
      DATA(lv_bulk_allowed) = xsdbool(
        <inbgp>-trucktype EQ zif_p2p_gp_const=>mc_truck_type-bulk AND
        line_exists( lt_defaults[
          tplst    = <inbgp>-transpplanpoint
          fillbulk = abap_true ] ) ).

      IF <inbgp>-isscrap EQ abap_true OR lv_bulk_allowed EQ abap_true.
        <inbgp>-isbulk = abap_true.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass
      UPDATE FIELDS ( isbulk )
      WITH VALUE #(
        FOR inbgp IN lt_inbgp (
          %tky   = inbgp-%tky
          isbulk = inbgp-isbulk ) ).
  ENDMETHOD.

  METHOD class_constructor.
    SELECT SINGLE low
      FROM zi_asas_utilities_tvarvc( p_type = 'P', p_name = 'ZP2P0006_DB_SCHENKER' )
      INTO @ms_transporter-db_schenker.
  ENDMETHOD.

  METHOD checkbol.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_inbgp).

    SELECT bol~billoflanding, bol~gatepassid
      FROM zc_p2p_inb_bolvh AS bol
      JOIN @lt_inbgp AS inb
        ON inb~billoflanding EQ bol~billoflanding
      INTO TABLE @DATA(lt_bol).

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>)
      WHERE transporter   EQ ms_transporter-db_schenker
        AND billoflanding IS NOT INITIAL.
      IF NOT line_exists( lt_bol[ billoflanding = <inbgp>-billoflanding ] ).
        APPEND VALUE #(
          %tky        = <inbgp>-%tky
          %element-billoflanding = if_abap_behv=>mk-on
          %state_area = 'INBGATEPASS'
          %msg        = me->new_message(
            id       = mc_msg_class
            number   = '013'
            severity = if_abap_behv_message=>severity-error
            v1       = <inbgp>-gatepassid
            v2       = <inbgp>-billoflanding ) ) TO reported-inbgatepass.

        INSERT VALUE #(
          %tky = <inbgp>-%tky )
          INTO TABLE failed-inbgatepass.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_p2p_inbgatepass DEFINITION INHERITING FROM cl_abap_behavior_saver_failed.
  PUBLIC SECTION.
    INTERFACES zif_p2p_gp_const.

  PROTECTED SECTION.
    TYPES:
      ts_inbgp_chg     TYPE STRUCTURE FOR CHANGE zr_p2p_inbgatepass\\inbgatepass,
      ts_inbgp_del     TYPE STRUCTURE FOR KEY OF zr_p2p_inbgatepass\\inbgatepass,

      ts_inbgp_itm_chg TYPE STRUCTURE FOR CHANGE zr_p2p_inbgatepass\\inbgatepassitem,
      ts_inbgp_itm_del TYPE STRUCTURE FOR KEY OF zr_p2p_inbgatepass\\inbgatepassitem,
      tt_inbgp_itm_chg TYPE TABLE FOR CHANGE zr_p2p_inbgatepass\\inbgatepassitem,
      tt_inbgp_itm_del TYPE TABLE FOR KEY OF zr_p2p_inbgatepass\\inbgatepassitem,

      ts_reported      TYPE RESPONSE FOR REPORTED LATE zr_p2p_inbgatepass,
      ts_failed        TYPE RESPONSE FOR FAILED LATE zr_p2p_inbgatepass.

    METHODS map_control
      IMPORTING is_data    TYPE any
      CHANGING  cs_control TYPE any.

    METHODS adjust_numbers REDEFINITION.

    METHODS save_modified REDEFINITION.

    METHODS map_messages REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

  PRIVATE SECTION.
    METHODS insert_shipment
      IMPORTING
        is_inbgp_ins TYPE ts_inbgp_chg
      CHANGING
        ct_shipment  TYPE zif_p2p_gp_const~tt_shipment
        cs_reported  TYPE ts_reported
        cs_failed    TYPE ts_failed.

    METHODS update_shipment
      IMPORTING
        is_inbgp_chg TYPE ts_inbgp_chg
      CHANGING
        ct_shipment  TYPE zif_p2p_gp_const~tt_shipment
        cs_reported  TYPE ts_reported
        cs_failed    TYPE ts_failed.

    METHODS delete_shipment
      IMPORTING
        is_inbgp_del TYPE ts_inbgp_del
      CHANGING
        ct_shipment  TYPE zif_p2p_gp_const~tt_shipment.

    METHODS update_delivery
      IMPORTING
        is_inbgp_chg TYPE ts_inbgp_chg
      CHANGING
        ct_delivery  TYPE zif_p2p_gp_const~tt_delivery_upd.

    METHODS insert_shipment_item
      IMPORTING
        it_inbgp_itm_ins TYPE tt_inbgp_itm_chg
      CHANGING
        ct_shipment      TYPE zif_p2p_gp_const~tt_shipment
        ct_delivery      TYPE zif_p2p_gp_const~tt_delivery_upd.

    METHODS update_shipment_item
      IMPORTING
        it_inbgp_itm_chg TYPE tt_inbgp_itm_chg
      CHANGING
        ct_shipment      TYPE zif_p2p_gp_const~tt_shipment.

    METHODS delete_shipment_item
      IMPORTING
        it_inbgp_itm_del TYPE tt_inbgp_itm_del
      CHANGING
        ct_shipment      TYPE zif_p2p_gp_const~tt_shipment.

    METHODS create_bulk_delivery
      IMPORTING
        is_inbgp_ins TYPE ts_inbgp_chg
      EXPORTING
        ev_delivery  TYPE vbeln_va
      CHANGING
        cs_reported  TYPE ts_reported
        cs_failed    TYPE ts_failed.

    METHODS fill_bulk_delivery
      IMPORTING
        VALUE(is_inbgp_ins) TYPE ts_inbgp_chg
      EXPORTING
        VALUE(es_delivery)  TYPE zif_p2p_gp_const~ts_delivery_ins.

    METHODS update_weight
      IMPORTING
        is_inbgp_chg TYPE ts_inbgp_chg
      RAISING
        zcx_p2p_wb_weight_capture.

    METHODS update_attachment
      IMPORTING
        it_shipment TYPE zif_p2p_gp_const~tt_shipment
      CHANGING
        cs_reported TYPE ts_reported
        cs_failed   TYPE ts_failed.

    METHODS update_group_shipment
      CHANGING
        ct_shipment TYPE zif_p2p_gp_const~tt_shipment.
ENDCLASS.

CLASS lsc_zr_p2p_inbgatepass IMPLEMENTATION.

  METHOD adjust_numbers.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass ALL FIELDS
      WITH VALUE #( FOR inbgp IN mapped-inbgatepass ( %pky = inbgp-%pre ) )
      RESULT DATA(lt_inbgp).

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepassitem ALL FIELDS
      WITH VALUE #( FOR inbgpi IN mapped-inbgatepassitem ( %pky = inbgpi-%pre ) )
      RESULT DATA(lt_inbgpi).

    DATA(lv_count) = 1.

    LOOP AT mapped-inbgatepassitem ASSIGNING FIELD-SYMBOL(<inbgp_itm>).
      <inbgp_itm>-%key-gatepassid     = <inbgp_itm>-%tmp-gatepassid.
      <inbgp_itm>-%key-gatepassitemid = lv_count.
      lv_count = lv_count + 1.
    ENDLOOP.

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass BY \_po ALL FIELDS
      WITH VALUE #( FOR inbgpo IN mapped-inbgatepasspo ( %key-gatepassid = inbgpo-%tmp-gatepassid ) )
      RESULT DATA(lt_inbgpo).

    SELECT po~gatepassid AS gatepassid, MAX( po~gatepassitemid ) AS gatepassitemid
      FROM zc_p2p_gpc_po AS po
      JOIN @lt_inbgpo AS keys
        ON keys~gatepassid = po~gatepassid
     GROUP BY po~gatepassid
      INTO TABLE @DATA(lt_max_position).

    LOOP AT mapped-inbgatepasspo ASSIGNING FIELD-SYMBOL(<inbgp_po_group>)
      GROUP BY ( gatepassid = <inbgp_po_group>-%tmp-gatepassid ) ASSIGNING FIELD-SYMBOL(<lt_inbgp_po>).

      DATA(lv_gatepassitemid) = VALUE #(  lt_max_position[ gatepassid = <lt_inbgp_po>-gatepassid ]-gatepassitemid OPTIONAL ).

      LOOP AT GROUP <lt_inbgp_po> ASSIGNING FIELD-SYMBOL(<inbgp_po>).
        lv_gatepassitemid = lv_gatepassitemid + 10.
        <inbgp_po>-%key-gatepassid     = <inbgp_po>-%tmp-gatepassid.
        <inbgp_po>-%key-gatepassitemid = lv_gatepassitemid.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_inbgp ASSIGNING FIELD-SYMBOL(<inbgp>).

      DATA(ls_header) = CORRESPONDING bapishipmentheader( <inbgp>-%data MAPPING FROM ENTITY ).

      DATA(lt_deliveries) = VALUE zttp2p_bapishipmentitem(
        FOR <item> IN lt_inbgpi WHERE ( %pidparent = <inbgp>-%pid ) ( delivery = <item>-deliverydocument ) ).

      DATA(lt_return) = VALUE bapiret2_t( ).

      CALL FUNCTION 'BAPI_SHIPMENT_CREATE' DESTINATION 'NONE'
        EXPORTING
          headerdata = ls_header
        IMPORTING
          transport  = ls_header-shipment_num
        TABLES
          itemdata   = lt_deliveries
          return     = lt_return.

      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>)
        WHERE type CA 'AEX'.

        DATA(lv_error) = abap_true.

        APPEND VALUE #(
            %state_area = 'INBGATEPASS'
            %op-%create = if_abap_behv=>mk-on
            %msg        = me->new_message(
                id       = <return>-id
                number   = <return>-number
                severity = if_abap_behv_message=>severity-error
                v1       = <return>-message_v1
                v2       = <return>-message_v2
                v3       = <return>-message_v3
                v4       = <return>-message_v4 ) ) TO reported-inbgatepass.
      ENDLOOP.

      IF lv_error EQ abap_true.
        INSERT VALUE #(
            %fail-cause = if_abap_behv=>cause-conflict
            %op-%create = if_abap_behv=>mk-on )
          INTO TABLE failed-inbgatepass.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
      ELSE.
        APPEND VALUE #(
            %pre-%pid       = <inbgp>-%pid
            %key-gatepassid = ls_header-shipment_num ) TO mapped-inbgatepass.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD save_modified.
    DATA(lt_shipment) = VALUE zif_p2p_gp_const~tt_shipment(  ).
    DATA(lt_delivery) = VALUE zif_p2p_gp_const~tt_delivery_upd( ).

    LOOP AT create-inbgatepass ASSIGNING FIELD-SYMBOL(<inbgp_ins>).
      insert_shipment(
        EXPORTING
          is_inbgp_ins = <inbgp_ins>
        CHANGING
          ct_shipment  = lt_shipment
          cs_reported  = reported
          cs_failed    = failed ).
    ENDLOOP.

    LOOP AT update-inbgatepass ASSIGNING FIELD-SYMBOL(<inbgp_upd>).
      update_shipment(
        EXPORTING
          is_inbgp_chg = <inbgp_upd>
        CHANGING
          ct_shipment  = lt_shipment
          cs_reported  = reported
          cs_failed    = failed ).

      update_delivery(
        EXPORTING
          is_inbgp_chg = <inbgp_upd>
        CHANGING
          ct_delivery  = lt_delivery ).
    ENDLOOP.

    LOOP AT delete-inbgatepass ASSIGNING FIELD-SYMBOL(<inbgp_del>).
      delete_shipment(
        EXPORTING
          is_inbgp_del = <inbgp_del>
        CHANGING
          ct_shipment = lt_shipment ).
    ENDLOOP.

    insert_shipment_item(
      EXPORTING
        it_inbgp_itm_ins = create-inbgatepassitem
      CHANGING
        ct_shipment      = lt_shipment
        ct_delivery      = lt_delivery ).

    update_shipment_item(
      EXPORTING
        it_inbgp_itm_chg = update-inbgatepassitem
      CHANGING
        ct_shipment      = lt_shipment ).

    delete_shipment_item(
      EXPORTING
        it_inbgp_itm_del = delete-inbgatepassitem
      CHANGING
        ct_shipment      = lt_shipment ).

    update_group_shipment(
      CHANGING
        ct_shipment = lt_shipment ).

    DATA(lv_sys_msg) = VALUE text255( ).

    LOOP AT lt_shipment ASSIGNING FIELD-SYMBOL(<shipment>)
      WHERE headerx   IS NOT INITIAL
         OR deadlinex IS NOT INITIAL
         OR itemx     IS NOT INITIAL.
      DATA(lt_return)     = VALUE bapiret2_tab( ).

      CALL FUNCTION 'BAPI_SHIPMENT_CHANGE' DESTINATION 'NONE'
        EXPORTING
          headerdata           = <shipment>-header
          headerdataaction     = <shipment>-headerx
        TABLES
          headerdeadline       = <shipment>-deadline
          headerdeadlineaction = <shipment>-deadlinex
          itemdata             = <shipment>-item
          itemdataaction       = <shipment>-itemx
          return               = lt_return
        EXCEPTIONS
          system_failure       = 1 MESSAGE lv_sys_msg.

      IF lv_sys_msg IS NOT INITIAL.
        INSERT VALUE #(
          id         = sy-msgid
          number     = sy-msgno
          type       = sy-msgty
          message_v1 = sy-msgv1
          message_v2 = sy-msgv2
          message_v3 = sy-msgv3
          message_v4 = sy-msgv4 ) INTO TABLE lt_return.
      ENDIF.

      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>)
        WHERE type CA 'AEX'.

        DATA(lv_error) = abap_true.

        APPEND VALUE #(
            gatepassid  = <shipment>-ref_shipment
            %state_area = 'INBGATEPASS'
            %op-%update = if_abap_behv=>mk-on
            %msg        = me->new_message(
                id       = <return>-id
                number   = <return>-number
                severity = if_abap_behv_message=>severity-error
                v1       = <return>-message_v1
                v2       = <return>-message_v2
                v3       = <return>-message_v3
                v4       = <return>-message_v4 ) ) TO reported-inbgatepass.
      ENDLOOP.

      IF lv_error EQ abap_true.
        INSERT VALUE #(
            gatepassid  = <shipment>-ref_shipment
            %fail-cause = if_abap_behv=>cause-conflict
            %op-%update = if_abap_behv=>mk-on )
          INTO TABLE failed-inbgatepass.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
        RETURN.
      ENDIF.
    ENDLOOP.

    update_attachment(
      EXPORTING
        it_shipment = lt_shipment
      CHANGING
        cs_reported = reported
        cs_failed   = failed ).

    LOOP AT lt_delivery ASSIGNING FIELD-SYMBOL(<delivery>).
      DATA(lt_protocol) = VALUE tab_prott( ).

      CALL FUNCTION 'WS_DELIVERY_UPDATE' DESTINATION 'NONE'
        EXPORTING
          vbkok_wa                 = <delivery>-header
          if_error_messages_send_0 = abap_false
          synchron                 = abap_true
          update_picking           = abap_false
          commit                   = abap_false
          delivery                 = <delivery>-header-vbeln_vl
          nicht_sperren            = abap_false
        TABLES
          vbpok_tab                = <delivery>-items
          prot                     = lt_protocol
        EXCEPTIONS
          system_failure           = 1 MESSAGE lv_sys_msg.

      IF lv_sys_msg IS NOT INITIAL.
        INSERT CORRESPONDING #( syst ) INTO TABLE lt_protocol.
      ENDIF.

      LOOP AT lt_protocol ASSIGNING FIELD-SYMBOL(<protocol>)
        WHERE msgty CA 'AEX'.

        lv_error = abap_true.

        APPEND VALUE #(
            gatepassid  = <delivery>-shipment_num
            %state_area = 'INBGATEPASS'
            %op-%update = if_abap_behv=>mk-on
            %msg        = me->new_message(
                id       = <protocol>-msgid
                number   = CONV #( <protocol>-msgno )
                severity = if_abap_behv_message=>severity-error
                v1       = <protocol>-msgv1
                v2       = <protocol>-msgv2
                v3       = <protocol>-msgv3
                v4       = <protocol>-msgv4 ) ) TO reported-inbgatepass.
      ENDLOOP.

      IF lv_error EQ abap_true.
        INSERT VALUE #(
            gatepassid  = <shipment>-ref_shipment
            %fail-cause = if_abap_behv=>cause-conflict
            %op-%update = if_abap_behv=>mk-on )
          INTO TABLE failed-inbgatepass.
      ENDIF.
    ENDLOOP.

    IF lv_error EQ abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
      RETURN.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
        EXPORTING
          wait = abap_true.
    ENDIF.

    LOOP AT update-inbgatepass ASSIGNING <inbgp_upd>.
      TRY.
          update_weight( is_inbgp_chg = <inbgp_upd> ).

        CATCH zcx_p2p_wb_weight_capture INTO DATA(lo_ex).
          INSERT VALUE #(
            %key     = <inbgp_upd>-%key
            %msg     = new_message_with_text(
            text     = lo_ex->get_text( )
            severity = if_abap_behv_message=>severity-error ) ) INTO TABLE reported-inbgatepass.

          INSERT VALUE #(
            %key     = <inbgp_upd>-%key
            %action-getwbgrossweight = if_abap_behv=>mk-on
            %fail-cause              = if_abap_behv=>cause-unspecific ) INTO TABLE failed-inbgatepass.
      ENDTRY.
    ENDLOOP.

    IF lv_error EQ abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
      RETURN.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
        EXPORTING
          wait = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD map_control.
    DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = cs_control ) ).

    DATA(lt_fields) = lo_struct->get_ddic_field_list( ).

    LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<field>).
      ASSIGN COMPONENT <field>-fieldname OF STRUCTURE is_data TO FIELD-SYMBOL(<data>).
      ASSIGN COMPONENT <field>-fieldname OF STRUCTURE cs_control TO FIELD-SYMBOL(<control>).

      CHECK sy-subrc EQ 0
        AND <control>  EQ abap_true.

      IF <data> IS INITIAL.
        <control> = zif_p2p_gp_const~mc_chg_delete.
      ELSE.
        <control> = zif_p2p_gp_const~mc_chg_change.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD update_shipment.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass
      ALL FIELDS
      WITH VALUE #( ( %key = is_inbgp_chg-%key ) )
      RESULT DATA(lt_inbgp).

    DATA(inbgp) = lt_inbgp[ KEY entity COMPONENTS %key = is_inbgp_chg-%key ].

    READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
        shipment_num = is_inbgp_chg-%key-gatepassid.
    IF sy-subrc NE 0.
      INSERT VALUE #(
        shipment_num        = is_inbgp_chg-%key-gatepassid
        ref_shipment        = is_inbgp_chg-%key-gatepassid
        header-shipment_num = is_inbgp_chg-%key-gatepassid )
        INTO TABLE ct_shipment ASSIGNING <shipment>.
    ENDIF.

    <shipment>-header  = CORRESPONDING bapishipmentheader( is_inbgp_chg MAPPING FROM ENTITY ).
    <shipment>-headerx = CORRESPONDING bapishipmentheaderaction( is_inbgp_chg MAPPING FROM ENTITY ).

    map_control(
      EXPORTING
        is_data    = <shipment>-header
      CHANGING
        cs_control = <shipment>-headerx ).

    IF is_inbgp_chg-%control-entrydate EQ if_abap_behv=>mk-on.

      CONVERT DATE is_inbgp_chg-entrydate TIME is_inbgp_chg-entrytime
         INTO TIME STAMP DATA(lv_entry) TIME ZONE sy-zonlo.

      <shipment>-deadline = VALUE #( (
        time_type      = 'HDRSTCIPDT'
        time_stamp_utc = lv_entry
        time_zone      = sy-zonlo ) ).

      <shipment>-deadlinex = VALUE #( (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

      IF inbgp-wbnotrelevant EQ abap_true.
        <shipment>-deadline = VALUE #( (
          time_type      = 'HDRSTCIPDT'
          time_stamp_utc = lv_entry
          time_zone      = sy-zonlo ) (
          time_type      = 'HDRSTPLDT'
          time_stamp_utc = lv_entry
          time_zone      = sy-zonlo ) (
          time_type      = 'HDRSTCIADT'
          time_stamp_utc = lv_entry
          time_zone      = sy-zonlo ) (
          time_type      = 'HDRSTLSADT'
          time_stamp_utc = lv_entry
          time_zone      = sy-zonlo ) ).

        <shipment>-deadlinex = VALUE #( (
          time_type      = zif_p2p_gp_const~mc_chg_change
          time_stamp_utc = zif_p2p_gp_const~mc_chg_change
          time_zone      = zif_p2p_gp_const~mc_chg_change ) (
          time_type      = zif_p2p_gp_const~mc_chg_change
          time_stamp_utc = zif_p2p_gp_const~mc_chg_change
          time_zone      = zif_p2p_gp_const~mc_chg_change ) (
          time_type      = zif_p2p_gp_const~mc_chg_change
          time_stamp_utc = zif_p2p_gp_const~mc_chg_change
          time_zone      = zif_p2p_gp_const~mc_chg_change ) (
          time_type      = zif_p2p_gp_const~mc_chg_change
          time_stamp_utc = zif_p2p_gp_const~mc_chg_change
          time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

        <shipment>-header-status_plan        = abap_true.
        <shipment>-headerx-status_plan       = zif_p2p_gp_const~mc_chg_change.

        <shipment>-header-status_checkin     = abap_true.
        <shipment>-headerx-status_checkin    = zif_p2p_gp_const~mc_chg_change.

        <shipment>-header-status_load_start  = abap_true.
        <shipment>-headerx-status_load_start = zif_p2p_gp_const~mc_chg_change.
      ENDIF.

    ENDIF.

    IF is_inbgp_chg-%control-exitdate EQ if_abap_behv=>mk-on.
      CONVERT DATE is_inbgp_chg-exitdate TIME is_inbgp_chg-exittime
         INTO TIME STAMP DATA(lv_exit) TIME ZONE sy-zonlo.

      <shipment>-deadline = VALUE #( (
        time_type      = 'HDRSTSSADT'
        time_stamp_utc = lv_exit
        time_zone      = sy-zonlo ) (
        time_type      = 'HDRSTSEADT'
        time_stamp_utc = lv_exit
        time_zone      = sy-zonlo ) ).

      <shipment>-deadlinex = VALUE #( (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

      <shipment>-header-status_shpmnt_start  = abap_true.
      <shipment>-headerx-status_shpmnt_start = zif_p2p_gp_const~mc_chg_change.

      <shipment>-header-status_shpmnt_end  = abap_true.
      <shipment>-headerx-status_shpmnt_end = zif_p2p_gp_const~mc_chg_change.
    ENDIF.

    IF is_inbgp_chg-%control-wbtareweight EQ if_abap_behv=>mk-on.
      CONVERT DATE sy-datum TIME sy-uzeit
         INTO TIME STAMP DATA(lv_wb_tare_entry) TIME ZONE sy-zonlo.

      <shipment>-deadline = VALUE #( (
        time_type      = 'HDRSTLEADT'
        time_stamp_utc = lv_wb_tare_entry
        time_zone      = sy-zonlo ) ).

      <shipment>-deadlinex = VALUE #( (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

      <shipment>-header-status_load_end  = abap_true.
      <shipment>-headerx-status_load_end = zif_p2p_gp_const~mc_chg_change.
    ENDIF.

    IF is_inbgp_chg-%control-wbgrossweight EQ if_abap_behv=>mk-on.
      SELECT SINGLE dpreg, upreg
        FROM vttk
       WHERE tknum EQ @is_inbgp_chg-%key-gatepassid
        INTO @DATA(ls_entry).

      CONVERT DATE ls_entry-dpreg TIME ls_entry-upreg
         INTO TIME STAMP lv_entry TIME ZONE sy-zonlo.

      CONVERT DATE sy-datum TIME sy-uzeit
         INTO TIME STAMP DATA(lv_wb_gross_entry) TIME ZONE sy-zonlo.

      <shipment>-deadline = VALUE #( (
        time_type      = 'HDRSTPLDT'
        time_stamp_utc = lv_entry
        time_zone      = sy-zonlo ) (
        time_type      = 'HDRSTCIADT'
        time_stamp_utc = lv_entry
        time_zone      = sy-zonlo ) (
        time_type      = 'HDRSTLSADT'
        time_stamp_utc = lv_wb_gross_entry
        time_zone      = sy-zonlo ) ).

      <shipment>-deadlinex = VALUE #( (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

      <shipment>-header-status_plan        = abap_true.
      <shipment>-headerx-status_plan       = zif_p2p_gp_const~mc_chg_change.

      <shipment>-header-status_checkin     = abap_true.
      <shipment>-headerx-status_checkin    = zif_p2p_gp_const~mc_chg_change.

      <shipment>-header-status_load_start  = abap_true.
      <shipment>-headerx-status_load_start = zif_p2p_gp_const~mc_chg_change.
    ENDIF.

    IF is_inbgp_chg-%control-radiationcertificatefile EQ if_abap_behv=>mk-on.
      INSERT VALUE zsp2p0006_rc(
        tknum  = is_inbgp_chg-%key-gatepassid
        fname  = is_inbgp_chg-%data-radiationcertificatefile
        mtype  = is_inbgp_chg-%data-radiationcertificatetype
        rcert  = is_inbgp_chg-%data-radiationcertificatebody
        updkz  = 'U' ) INTO TABLE <shipment>-attachment.
    ENDIF.

    IF inbgp-isbulk EQ abap_true.
      READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
        ENTITY inbgatepass BY \_item ALL FIELDS
        WITH VALUE #( ( %key-gatepassid = is_inbgp_chg-%key-gatepassid ) )
        RESULT DATA(inbgpi).

      IF inbgpi IS INITIAL.
        create_bulk_delivery(
          EXPORTING
            is_inbgp_ins = is_inbgp_chg
          IMPORTING
            ev_delivery  = DATA(lv_delivery)
          CHANGING
            cs_reported  = cs_reported
            cs_failed    = cs_failed ).

        IF lv_delivery IS NOT INITIAL.
          DATA(ls_item) = VALUE bapishipmentitem(
            delivery  = lv_delivery
            itenerary = 1 ).

          INSERT ls_item
            INTO TABLE <shipment>-item.

          DATA(ls_itemx) = VALUE bapishipmentitemaction(
              delivery  = zif_p2p_gp_const~mc_chg_add
              itenerary = zif_p2p_gp_const~mc_chg_add ).

          INSERT ls_itemx
            INTO TABLE <shipment>-itemx.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD insert_shipment_item.
    CHECK it_inbgp_itm_ins IS NOT INITIAL.

    DATA(lv_itenerary) = 1.

    LOOP AT it_inbgp_itm_ins ASSIGNING FIELD-SYMBOL(<inbgp_itm_ins_group>)
      GROUP BY ( gatepassid = <inbgp_itm_ins_group>-gatepassid ) ASSIGNING FIELD-SYMBOL(<lt_inbgp_itm_ins>).

      READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
         shipment_num = <lt_inbgp_itm_ins>-gatepassid.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          shipment_num        = <lt_inbgp_itm_ins>-gatepassid
          ref_shipment        = <lt_inbgp_itm_ins>-gatepassid
          header-shipment_num = <lt_inbgp_itm_ins>-gatepassid )
          INTO TABLE ct_shipment ASSIGNING <shipment>.
      ENDIF.

      LOOP AT GROUP <lt_inbgp_itm_ins> ASSIGNING FIELD-SYMBOL(<inbgp_itm_ins>).
        DATA(ls_item) = VALUE bapishipmentitem(
          delivery  = <inbgp_itm_ins>-deliverydocument
          itenerary = lv_itenerary ).

        lv_itenerary = lv_itenerary + 1.

        INSERT ls_item
          INTO TABLE <shipment>-item.

        DATA(ls_itemx) = VALUE bapishipmentitemaction(
          delivery  = zif_p2p_gp_const~mc_chg_add
          itenerary = zif_p2p_gp_const~mc_chg_add ).

        INSERT ls_itemx
          INTO TABLE <shipment>-itemx.

        IF <shipment>-header-shipment_route IS INITIAL.
          SELECT SINGLE route
            FROM likp
           WHERE vbeln EQ @<inbgp_itm_ins>-deliverydocument
            INTO @<shipment>-header-shipment_route.
          IF sy-subrc EQ 0.
            <shipment>-headerx-shipment_route = zif_p2p_gp_const~mc_chg_change.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_shipment_item.
  ENDMETHOD.

  METHOD delete_shipment_item.
    CHECK it_inbgp_itm_del IS NOT INITIAL.

    SELECT *
      FROM vttp
       FOR ALL ENTRIES IN @it_inbgp_itm_del
     WHERE tknum EQ @it_inbgp_itm_del-gatepassid
       AND tpnum EQ @it_inbgp_itm_del-gatepassitemid
      INTO TABLE @DATA(lt_deliveries).

    LOOP AT lt_deliveries ASSIGNING FIELD-SYMBOL(<delivery>).
      READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
          shipment_num = <delivery>-tknum.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          shipment_num        = <delivery>-tknum
          ref_shipment        = <delivery>-tknum
          header-shipment_num = <delivery>-tknum )
          INTO TABLE ct_shipment ASSIGNING <shipment>.
      ENDIF.

      DATA(ls_item) = VALUE bapishipmentitem(
        delivery  = <delivery>-vbeln
        itenerary = <delivery>-tprfo ).

      INSERT ls_item
        INTO TABLE <shipment>-item.

      DATA(ls_itemx) = VALUE bapishipmentitemaction(
        delivery  = zif_p2p_gp_const~mc_chg_delete
        itenerary = zif_p2p_gp_const~mc_chg_delete ).

      INSERT ls_itemx
        INTO TABLE <shipment>-itemx.
    ENDLOOP.
  ENDMETHOD.

  METHOD insert_shipment.
    READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
        shipment_num = is_inbgp_ins-%key-gatepassid.
    IF sy-subrc NE 0.
      INSERT VALUE #(
        shipment_num        = is_inbgp_ins-%key-gatepassid
        ref_shipment        = is_inbgp_ins-%key-gatepassid
        header-shipment_num = is_inbgp_ins-%key-gatepassid )
        INTO TABLE ct_shipment ASSIGNING <shipment>.
    ENDIF.

    IF is_inbgp_ins-%data-isbulk EQ abap_true.
      create_bulk_delivery(
        EXPORTING
          is_inbgp_ins = is_inbgp_ins
        IMPORTING
          ev_delivery  = DATA(lv_delivery)
        CHANGING
          cs_reported  = cs_reported
          cs_failed    = cs_failed ).

      IF lv_delivery IS NOT INITIAL.
        DATA(ls_item) = VALUE bapishipmentitem(
          delivery  = lv_delivery
          itenerary = 1 ).

        INSERT ls_item
          INTO TABLE <shipment>-item.

        DATA(ls_itemx) = VALUE bapishipmentitemaction(
            delivery  = zif_p2p_gp_const~mc_chg_add
            itenerary = zif_p2p_gp_const~mc_chg_add ).

        INSERT ls_itemx
          INTO TABLE <shipment>-itemx.
      ENDIF.
    ENDIF.

    IF is_inbgp_ins-%control-radiationcertificatefile EQ if_abap_behv=>mk-on.
      INSERT VALUE zsp2p0006_rc(
        tknum  = is_inbgp_ins-%key-gatepassid
        fname  = is_inbgp_ins-%data-radiationcertificatefile
        mtype  = is_inbgp_ins-%data-radiationcertificatetype
        rcert  = is_inbgp_ins-%data-radiationcertificatebody
        updkz  = 'I' ) INTO TABLE <shipment>-attachment.
    ENDIF.
  ENDMETHOD.

  METHOD create_bulk_delivery.
    DATA(ls_delivery) = VALUE zif_p2p_gp_const~ts_delivery_ins( ).

    fill_bulk_delivery(
        EXPORTING
          is_inbgp_ins = is_inbgp_ins
        IMPORTING
          es_delivery  = ls_delivery ).

    DATA(lt_return)  = VALUE bapiret2_t( ).
    DATA(lv_sys_msg) = VALUE text255( ).

    CALL FUNCTION 'Z_P2P0006_INB_DLV_CREATE_RFC' DESTINATION 'NONE'
      EXPORTING
        it_items            = ls_delivery-items
      IMPORTING
        ev_deliverydocument = ev_delivery
      CHANGING
        ct_return           = lt_return
      EXCEPTIONS
        system_failure      = 1 MESSAGE lv_sys_msg.

    IF lv_sys_msg IS NOT INITIAL.
      INSERT VALUE #(
        id         = sy-msgid
        number     = sy-msgno
        type       = sy-msgty
        message_v1 = sy-msgv1
        message_v2 = sy-msgv2
        message_v3 = sy-msgv3
        message_v4 = sy-msgv4 ) INTO TABLE lt_return.
    ENDIF.

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>)
      WHERE type CA 'AEX'.

      DATA(lv_error) = abap_true.

      APPEND VALUE #(
          %state_area = 'INBGATEPASS'
          %key        = is_inbgp_ins-%key
          %op-%create = if_abap_behv=>mk-on
          %msg        = me->new_message(
              id       = <return>-id
              number   = <return>-number
              severity = if_abap_behv_message=>severity-error
              v1       = <return>-message_v1
              v2       = <return>-message_v2
              v3       = <return>-message_v3
              v4       = <return>-message_v4 ) ) TO cs_reported-inbgatepass.
    ENDLOOP.

    IF lv_error EQ abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.

      INSERT VALUE #(
          %key        = is_inbgp_ins-%key
          %fail-cause = if_abap_behv=>cause-unspecific
          %op-%create = if_abap_behv=>mk-on )
        INTO TABLE cs_failed-inbgatepass.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'.
    ENDIF.
  ENDMETHOD.

  METHOD fill_bulk_delivery.
    es_delivery-pcntrl-privileged_mode = abap_true.
    es_delivery-pcntrl-no_commit       = abap_true.

    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass
      ALL FIELDS
      WITH VALUE #( ( %key = is_inbgp_ins-%key ) )
      RESULT DATA(lt_inbgp).

    DATA(inbgp) = lt_inbgp[ KEY entity COMPONENTS %key = is_inbgp_ins-%key ].

    CHECK inbgp-ordernumber IS NOT INITIAL.

    SELECT SINGLE ebeln, lifnr
      FROM ekko
     WHERE ebeln EQ @inbgp-ordernumber
      INTO @DATA(ls_po_header).

    SELECT ekpo~ebeln, ebelp, werks, matnr, bwtar, meins, lmein,
           ekko~inco1, ekko~inco2, ekko~inco2_l, ekko~inco3_l, ekko~inco2_key, ekko~inco3_key, ekko~inco4_key
      FROM ekpo
      JOIN ekko
        ON ekko~ebeln EQ ekpo~ebeln
     WHERE ekpo~ebeln EQ @inbgp-ordernumber
       AND ekpo~ebelp EQ @inbgp-ordernumberitem
      INTO TABLE @DATA(lt_po_items).

    es_delivery-header-ernam = sy-uname.
    es_delivery-header-erdat = sy-datum.
    es_delivery-header-uzeit = sy-uzeit.

    LOOP AT lt_po_items ASSIGNING FIELD-SYMBOL(<po_item>).

      DATA(ls_item) = VALUE komdlgn(
        lfart     = 'EL'
        vgtyp     = 'V'
        pstyv     = 'ELN'
        kzazu     = abap_true
        lifnr     = ls_po_header-lifnr
        werks     = <po_item>-werks
        lgort     = inbgp-storagelocation
        matnr     = <po_item>-matnr
        bwtar     = <po_item>-bwtar
        inco1     = <po_item>-inco1
        inco2     = <po_item>-inco2
        inco2_l   = <po_item>-inco2_l
        inco3_l   = <po_item>-inco3_l
        inco2_key = <po_item>-inco2_key
        inco3_key = <po_item>-inco3_key
        inco4_key = <po_item>-inco4_key
        lfimg     = inbgp-truckcapacity
        lifex     = inbgp-billoflanding
        vrkme     = <po_item>-meins
        meins     = <po_item>-lmein
        vgbel     = <po_item>-ebeln
        vgpos     = <po_item>-ebelp
        lfdat     = sy-datum
        lfuhr     = sy-uzeit ).

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input    = inbgp-truckcapacity
          unit_in  = inbgp-truckcapacityunit
          unit_out = <po_item>-meins
        IMPORTING
          output   = ls_item-lfimg
        EXCEPTIONS
          OTHERS   = 0.

      INSERT ls_item
        INTO TABLE es_delivery-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_delivery.
    CHECK is_inbgp_chg-%key-gatepassid IS NOT INITIAL.

    DATA(ls_head_changed) = CORRESPONDING zsp2p0006_likp( is_inbgp_chg MAPPING FROM ENTITY ).
    DATA(ls_head_control) = CORRESPONDING zsp2p0006_likp_control( is_inbgp_chg MAPPING FROM ENTITY ).

    DATA(ls_item_changed) = CORRESPONDING zsp2p0006_lips( is_inbgp_chg MAPPING FROM ENTITY ).
    DATA(ls_item_control) = CORRESPONDING zsp2p0006_lips_control( is_inbgp_chg MAPPING FROM ENTITY ).

    CHECK ls_head_control IS NOT INITIAL
       OR ls_item_control IS NOT INITIAL.

    DATA(ls_shipment)   = VALUE vttk( ).
    DATA(lt_ship_items) = VALUE vttp_tab( ).
    DATA(lt_ship_seg)   = VALUE vtts_tab( ).
    DATA(lt_ship_segi)  = VALUE vtsp_tab( ).

    DATA(lt_delivery)       = VALUE vtrlk_tab( ).
    DATA(lt_delivery_items) = VALUE vtrlp_tab( ).

    CALL FUNCTION 'RV_SHIPMENT_READ'
      EXPORTING
        shipment_number       = is_inbgp_chg-%key-gatepassid
        option_items          = abap_true
      IMPORTING
        shipment_header       = ls_shipment
      TABLES
        shipment_items        = lt_ship_items
        shipment_segments     = lt_ship_seg
        shipment_segment_item = lt_ship_segi
        delivery_items        = lt_delivery_items
        delivery_headers      = lt_delivery
      EXCEPTIONS
        OTHERS                = 0.

    CHECK lines( lt_delivery ) EQ 1.

    DATA(lo_head_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_head_control ) ).
    DATA(lt_head_fields) = lo_head_struct->get_ddic_field_list( ).

    DATA(lo_item_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_item_control ) ).
    DATA(lt_item_fields) = lo_item_struct->get_ddic_field_list( ).

    LOOP AT lt_delivery ASSIGNING FIELD-SYMBOL(<delivery>).
      DATA(ls_header) = CORRESPONDING vbkok( <delivery>-ext ).

      LOOP AT lt_head_fields ASSIGNING FIELD-SYMBOL(<field>).
        ASSIGN COMPONENT <field>-fieldname OF STRUCTURE ls_header  TO FIELD-SYMBOL(<header>).
        ASSIGN COMPONENT <field>-fieldname OF STRUCTURE ls_head_changed TO FIELD-SYMBOL(<head_changed>).
        ASSIGN COMPONENT <field>-fieldname OF STRUCTURE ls_head_control TO FIELD-SYMBOL(<head_control>).

        CHECK sy-subrc EQ 0
          AND <head_control> EQ abap_true.

        <header> = <head_changed>.
      ENDLOOP.

      ls_header-vbeln_vl                = <delivery>-vbeln.
      ls_header-komue                   = abap_true.
      ls_header-update_extension_fields = abap_true.

      IF ls_head_control-lifex EQ abap_true.
        ls_header-kzlifex = abap_true.
      ENDIF.

      DATA(ls_delivery_upd) = VALUE zif_p2p_gp_const~ts_delivery_upd(
        delivery_num = <delivery>-vbeln
        shipment_num = is_inbgp_chg-%key-gatepassid
        header       = ls_header ).

      IF ( ls_shipment-zzbulk EQ abap_true AND ls_header-zznet_weight NE 0 ) OR ls_item_control IS NOT INITIAL.
        LOOP AT lt_delivery_items ASSIGNING FIELD-SYMBOL(<delivery_item>)
          WHERE vbeln EQ <delivery>-vbeln.

          DATA(ls_item) = VALUE vbpok( ).

          ls_item-vbeln_vl = <delivery_item>-vbeln.
          ls_item-posnr_vl = <delivery_item>-posnr.

          ls_item-vbeln    = <delivery_item>-vbeln.
          ls_item-posnn    = <delivery_item>-posnr.

          IF ls_shipment-zzbulk EQ abap_true AND ls_header-zznet_weight NE 0.
            CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
              EXPORTING
                input    = ls_header-zznet_weight
                unit_in  = zcl_p2p_wb_weight_capture=>mc_default_unit
                unit_out = <delivery_item>-vrkme
              IMPORTING
                output   = ls_item-lfimg
              EXCEPTIONS
                OTHERS   = 0.

            ls_item-pikmg = ls_item-lfimg.
            ls_item-lianp = abap_true.
          ENDIF.

          IF ls_item_control IS NOT INITIAL.
            ls_item-zzpiececount_dli = ls_item_changed-zzpiececount_dli.
            ls_item-update_extension_fields = abap_true.
          ENDIF.

          INSERT ls_item
            INTO TABLE ls_delivery_upd-items.
        ENDLOOP.
      ENDIF.

      INSERT ls_delivery_upd
        INTO TABLE ct_delivery.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_weight.
    IF is_inbgp_chg-%control-wbgrossweight EQ if_abap_behv=>mk-on OR
       is_inbgp_chg-%control-wbtareweight  EQ if_abap_behv=>mk-on.

      READ ENTITY IN LOCAL MODE zr_p2p_inbgatepass
        FIELDS ( wbdeviceid )
        WITH VALUE #( ( %key = is_inbgp_chg-%key ) )
        RESULT DATA(lt_inbgp).

      DATA(inbgp) = lt_inbgp[ %key = is_inbgp_chg-%key ].

      GET TIME STAMP FIELD DATA(lv_crtmp).

      DATA(ls_params)  = VALUE zsp2p_wb_weight_capture(
        device_id = inbgp-wbdeviceid ).

      DATA(lo_capture) = NEW zcl_p2p_wb_weight_capture( is_params = ls_params ).

      IF is_inbgp_chg-%control-wbgrossweight EQ if_abap_behv=>mk-on.
        DATA(ls_weight_status) = VALUE ztp2p_wb_weight(
          guid          = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( )
          device_id     = inbgp-wbdeviceid
          weight        = is_inbgp_chg-wbgrossweight
          meins         = zcl_p2p_wb_weight_capture=>mc_default_unit
          tknum         = inbgp-gatepassid
          weight_id     = zcl_p2p_wb_weight_capture=>mc_weight_id-gross
          crtmp         = lv_crtmp
          crnam         = sy-uname
          weight_status = zcl_p2p_wb_weight_capture=>mc_weight_status-grosscaptured
          sttmp         = lv_crtmp
          stnam         = sy-uname ).

        lo_capture->set_weight_status( is_weight_status = ls_weight_status ).
      ENDIF.

      IF is_inbgp_chg-%control-wbtareweight EQ if_abap_behv=>mk-on.
        ls_weight_status = VALUE ztp2p_wb_weight(
          guid          = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( )
          device_id     = inbgp-wbdeviceid
          weight        = is_inbgp_chg-wbtareweight
          meins         = zcl_p2p_wb_weight_capture=>mc_default_unit
          tknum         = inbgp-gatepassid
          weight_id     = zcl_p2p_wb_weight_capture=>mc_weight_id-tare
          crtmp         = lv_crtmp
          crnam         = sy-uname
          weight_status = zcl_p2p_wb_weight_capture=>mc_weight_status-tarecaptured
          sttmp         = lv_crtmp
          stnam         = sy-uname ).

        lo_capture->set_weight_status( is_weight_status = ls_weight_status ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD update_group_shipment.
    READ ENTITIES OF zr_p2p_inbgatepass IN LOCAL MODE
      ENTITY inbgatepass
      FIELDS ( billoflanding )
      WITH VALUE #( FOR shipment IN ct_shipment ( gatepassid = shipment-shipment_num ) )
      RESULT DATA(lt_inbgp).

    SELECT *
      FROM zc_p2p_inb_bolvh
       FOR ALL ENTRIES IN @lt_inbgp
     WHERE billoflanding EQ @lt_inbgp-billoflanding
      INTO TABLE @DATA(lt_group_shipment).

    LOOP AT ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>)
      WHERE item IS NOT INITIAL.

      TRY.
          DATA(ls_inbgp) = lt_inbgp[ KEY entity COMPONENTS gatepassid = <shipment>-shipment_num ].
          DATA(ls_group_shipment) = lt_group_shipment[ billoflanding = ls_inbgp-billoflanding ].

          READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<group_shipment>) WITH TABLE KEY
            shipment_num = ls_group_shipment-gatepassid.
          IF sy-subrc NE 0.
            INSERT VALUE #(
              shipment_num        = ls_group_shipment-gatepassid
              ref_shipment        = ls_inbgp-%key-gatepassid
              header-shipment_num = ls_group_shipment-gatepassid )
              INTO TABLE ct_shipment ASSIGNING <group_shipment>.
          ENDIF.

          <group_shipment>-item  = <shipment>-item.
          <group_shipment>-itemx = <shipment>-itemx.

        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_messages.

  ENDMETHOD.

  METHOD delete_shipment.
    READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
        shipment_num = is_inbgp_del-gatepassid.
    IF sy-subrc NE 0.
      INSERT VALUE #(
        shipment_num        = is_inbgp_del-gatepassid
        ref_shipment        = is_inbgp_del-gatepassid
        header-shipment_num = is_inbgp_del-gatepassid )
        INTO TABLE ct_shipment ASSIGNING <shipment>.
    ENDIF.

    <shipment>-header-zzdeleted  = abap_true.
    <shipment>-headerx-zzdeleted = zif_p2p_gp_const~mc_chg_change.
  ENDMETHOD.

  METHOD update_attachment.
    LOOP AT it_shipment ASSIGNING FIELD-SYMBOL(<shipment>)
      WHERE attachment IS NOT INITIAL.

      DATA(lt_insert) = VALUE zttp2p_a_rc(
        FOR <attachment> IN <shipment>-attachment
          WHERE ( updkz = zif_p2p_gp_const~mc_opera-insert )
          ( CORRESPONDING #( <attachment> )  ) ).

      DATA(lt_update) = VALUE zttp2p_a_rc(
        FOR <attachment> IN <shipment>-attachment
          WHERE ( updkz = zif_p2p_gp_const~mc_opera-update )
          ( CORRESPONDING #( <attachment> )  ) ).

      DATA(lt_delete) = VALUE zttp2p_a_rc(
        FOR <attachment> IN <shipment>-attachment
          WHERE ( updkz = zif_p2p_gp_const~mc_opera-delete )
          ( CORRESPONDING #( <attachment> )  ) ).
    ENDLOOP.

    IF lt_insert IS NOT INITIAL.
      INSERT ztp2p_a_rc FROM TABLE lt_insert.
    ENDIF.

    IF lt_delete IS NOT INITIAL.
      DELETE ztp2p_a_rc FROM TABLE lt_delete.
    ENDIF.

    IF lt_update IS NOT INITIAL.
      MODIFY ztp2p_a_rc FROM TABLE lt_update.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
