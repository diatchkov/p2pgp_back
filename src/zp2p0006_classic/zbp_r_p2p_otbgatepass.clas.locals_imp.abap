CLASS lhc_otbgatepassdlvitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR otbgatepassdlvitem RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR otbgatepassdlvitem RESULT result.

    METHODS batchsplit FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepassdlvitem~batchsplit.

    METHODS calcquantity FOR DETERMINE ON MODIFY
      IMPORTING keys FOR otbgatepassdlvitem~calcquantity.

    METHODS calcbatch FOR DETERMINE ON MODIFY
      IMPORTING keys FOR otbgatepassdlvitem~calcbatch.

ENDCLASS.

CLASS lhc_otbgatepassdlvitem IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    TYPES:
      ts_result TYPE STRUCTURE FOR INSTANCE FEATURES RESULT zr_p2p_otbgatepass\\otbgatepassdlvitem.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepassdlvitem ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_otbgpdi).

    LOOP AT lt_otbgpdi ASSIGNING FIELD-SYMBOL(<otbgpdi>).
      DATA(ls_result) = VALUE ts_result(
        %tky = <otbgpdi>-%tky

      %field-batch = COND #(
        WHEN <otbgpdi>-mainitem IS NOT INITIAL
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %field-billets = COND #(
        WHEN <otbgpdi>-mainitem IS NOT INITIAL
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %delete = COND #(
        WHEN <otbgpdi>-mainitem IS NOT INITIAL
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-batchsplit = COND #(
        WHEN <otbgpdi>-%is_draft = if_abap_behv=>mk-on
         AND <otbgpdi>-mainitem IS INITIAL
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only ) ).

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD batchsplit.
    TYPES:
      ts_batch TYPE STRUCTURE FOR CREATE zr_p2p_otbgatepass\\otbgatepassitem\_otbgatepassdlvitem,
      tt_batch TYPE TABLE FOR CREATE zr_p2p_otbgatepass\\otbgatepassitem\_otbgatepassdlvitem.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassitem ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpi)
      ENTITY otbgatepassdlvitem ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpdi)
      ENTITY otbgatepassitem BY \_otbgatepassdlvitem ALL FIELDS
        WITH VALUE #( FOR <key> IN keys (
          %is_draft        = <key>-%is_draft
          gatepassid       = <key>-gatepassid
          gatepassitemid   = <key>-gatepassitemid ) )
      RESULT DATA(lt_batches).

    DELETE lt_batches WHERE mainitem IS INITIAL.
    SORT lt_batches BY deliverydocumentitem DESCENDING.

    TRY.
        DATA(lv_item) = lt_batches[ 1 ]-deliverydocumentitem.
      CATCH cx_sy_itab_line_not_found.
        lv_item = 900000.
    ENDTRY.

    DATA(batches) = VALUE tt_batch(  ).

    LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>).
      APPEND INITIAL LINE TO batches ASSIGNING FIELD-SYMBOL(<batch>).
      <batch>-%tky = <otbgpi>-%tky.

      LOOP AT lt_otbgpdi ASSIGNING FIELD-SYMBOL(<otbgpdi>).
        lv_item = lv_item + 1.

        APPEND VALUE #(
          %is_draft                = <otbgpdi>-%is_draft
          gatepassid               = <otbgpdi>-%key-gatepassid
          gatepassitemid           = <otbgpdi>-%key-gatepassitemid
          deliverydocument         = <otbgpdi>-%key-deliverydocument
          deliverydocumentitem     = lv_item
          mainitem                 = <otbgpdi>-deliverydocumentitem
          referencesddocument      = <otbgpdi>-referencesddocument
          referencesddocumentitem  = <otbgpdi>-referencesddocumentitem
          plant                    = <otbgpdi>-plant
          storagelocation          = <otbgpdi>-storagelocation
          material                 = <otbgpdi>-material
          deliveryquantityunit     = <otbgpdi>-deliveryquantityunit
        ) TO <batch>-%target.
      ENDLOOP.
    ENDLOOP.

*   Create Items
    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassitem
      CREATE BY \_otbgatepassdlvitem
      AUTO FILL CID
        FIELDS ( gatepassid gatepassitemid deliverydocument deliverydocumentitem mainitem
                 referencesddocument referencesddocumentitem plant storagelocation material deliveryquantityunit )
        WITH batches
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed)
      MAPPED DATA(lt_mapped).
  ENDMETHOD.

  METHOD calcquantity.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH VALUE #( FOR <key> IN keys (
        %is_draft  = <key>-%is_draft
        gatepassid = <key>-gatepassid ) )
      RESULT DATA(lt_otbgp)

      ENTITY otbgatepassitem ALL FIELDS
      WITH VALUE #( FOR <key> IN keys (
        %is_draft      = <key>-%is_draft
        gatepassid     = <key>-gatepassid
        gatepassitemid = <key>-gatepassitemid ) )
      RESULT DATA(lt_otbgpi)

      ENTITY otbgatepassitem BY \_otbgatepassdlvitem ALL FIELDS
        WITH VALUE #( FOR <key> IN keys (
          %is_draft      = <key>-%is_draft
          gatepassid     = <key>-gatepassid
          gatepassitemid = <key>-gatepassitemid ) )
      RESULT DATA(lt_otbgpdi).

    DELETE lt_otbgpdi
     WHERE mainitem IS INITIAL.

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      DATA(lv_wbnetweight) = <otbgp>-wbnetweight.

      LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>) USING KEY entity
        WHERE gatepassid EQ <otbgp>-%key-gatepassid.

        LOOP AT lt_otbgpdi ASSIGNING FIELD-SYMBOL(<otbgpdi>) USING KEY entity
          WHERE gatepassid     EQ <otbgpi>-gatepassid
            AND gatepassitemid EQ <otbgpi>-gatepassitemid.

          <otbgpdi>-actualdeliveryquantity = <otbgpdi>-billets * <otbgpdi>-batchweight.

          DATA(ls_mara) = VALUE mara( ).

          CALL FUNCTION 'MARA_SINGLE_READ'
            EXPORTING
              matnr = <otbgpdi>-material
            IMPORTING
              wmara = ls_mara.

          CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
            EXPORTING
              input    = <otbgpdi>-actualdeliveryquantity
              unit_in  = ls_mara-meins
              unit_out = <otbgpdi>-deliveryquantityunit
            IMPORTING
              output   = <otbgpdi>-actualdeliveryquantity.

          lv_wbnetweight = lv_wbnetweight - <otbgpdi>-actualdeliveryquantity.

          IF lv_wbnetweight LT 0.
            lv_wbnetweight = 0.
          ENDIF.
        ENDLOOP.

        IF sy-subrc EQ 0.
          <otbgpdi>-actualdeliveryquantity = <otbgpdi>-actualdeliveryquantity + lv_wbnetweight.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassdlvitem
      UPDATE FIELDS ( actualdeliveryquantity )
      WITH VALUE #(
        FOR otbgpdi IN lt_otbgpdi
          ( %tky                   = otbgpdi-%tky
            actualdeliveryquantity = otbgpdi-actualdeliveryquantity ) ).

  ENDMETHOD.

  METHOD calcbatch.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassdlvitem ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpdi).

    CHECK lt_otbgpdi IS NOT INITIAL.

    DATA(lv_atinn) = CONV atinn_no_conv( zcl_asas_tvarv_constant=>get_value( iv_name = 'ZP2P0006_BATCH_WEIGHT' ) ).

    SELECT bclas~plant, bclas~material, bclas~batch, fromdecimalvalue AS batchweight, uom AS batchuom
      FROM zi_o2c_batchclassification AS bclas
      JOIN @lt_otbgpdi AS items
        ON items~plant    EQ bclas~plant
       AND items~material EQ bclas~material
       AND items~batch    EQ bclas~batch
     WHERE bclas~charcinternalid EQ @lv_atinn
      INTO TABLE @DATA(lt_classification).

    LOOP AT lt_otbgpdi ASSIGNING FIELD-SYMBOL(<otbgpdi>).
      TRY.
          DATA(ls_classification) = lt_classification[
            plant    = <otbgpdi>-plant
            material = <otbgpdi>-material
            batch    = <otbgpdi>-batch ].

          <otbgpdi>-batchweight = ls_classification-batchweight.
          <otbgpdi>-batchuom    = ls_classification-batchuom.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassdlvitem
      UPDATE FIELDS ( batchweight batchuom )
      WITH VALUE #(
        FOR otbgpdi IN lt_otbgpdi
          ( %tky        = otbgpdi-%tky
            batchweight = otbgpdi-batchweight
            batchuom    = otbgpdi-batchuom  ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_otbgatepassitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    CONSTANTS:
      mc_msg_class TYPE symsgid VALUE 'ZP2P_0006_CLASSIC'.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR otbgatepassitem RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR otbgatepassitem RESULT result.

    METHODS printnote FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepassitem~printnote RESULT result.

    METHODS printtaxinvoice FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepassitem~printtaxinvoice RESULT result.

    METHODS printadvinvoice FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepassitem~printadvinvoice RESULT result.

    METHODS printqualcert FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepassitem~printqualcert RESULT result.

    METHODS printplannote FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepassitem~printplannote RESULT result.

    METHODS get_invoice
      IMPORTING
                iv_delivery       TYPE vbeln_va
                iv_type           TYPE fkart
      RETURNING VALUE(rv_invoice) TYPE vbeln_vl
      RAISING   cx_sy_itab_line_not_found.

ENDCLASS.

CLASS lhc_otbgatepassitem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD printnote.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_otbgatepass\\otbgatepassitem~printnote.

    DATA(ls_result) = VALUE ts_result(  ).

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassitem ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpi).

    LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>).
      TRY.

          DATA(lo_note) = NEW zcl_o2c0014_delnote_print( iv_delivery = <otbgpi>-deliverydocument ).
          DATA(ls_cont) = lo_note->get_pdf( ).

          ls_result-%tky            = <otbgpi>-%tky.
          ls_result-%param-mimetype = 'application/pdf'.
          ls_result-%param-filename = |{ <otbgpi>-deliverydocument }_Note.pdf'|.

          CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
            EXPORTING
              input  = ls_cont-pdf_content
            IMPORTING
              output = ls_result-%param-mimecont.

          INSERT ls_result
            INTO TABLE result.

        CATCH cx_somu_error INTO DATA(lr_formerror).
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.

  METHOD printqualcert.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_otbgatepass\\otbgatepassitem~printqualcert.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassitem ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpi).

    LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>).
      TRY.

          DATA(lo_cert) = NEW zcl_mnf_qm_cert_dms_ctr_dlv(
            iv_vbeln = <otbgpi>-deliverydocument ).

          DATA(lv_cont) = lo_cert->get_data( ).

          IF lv_cont IS INITIAL.
            RAISE EXCEPTION TYPE zcx_mnf_qm_certificate.
          ENDIF.

          DATA(ls_result) = VALUE ts_result(  ).

          ls_result-%tky            = <otbgpi>-%tky.
          ls_result-%param-mimetype = 'application/pdf'.
          ls_result-%param-filename = |{ <otbgpi>-deliverydocument }_Cert.pdf'|.

          CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
            EXPORTING
              input  = lv_cont
            IMPORTING
              output = ls_result-%param-mimecont.

          INSERT ls_result
            INTO TABLE result.

        CATCH zcx_mnf_qm_certificate cx_somu_error.
          INSERT VALUE #(
            %tky = <otbgpi>-%tky
            %msg = new_message(
              id       = mc_msg_class
              number   = '011'
              severity = if_abap_behv_message=>severity-success
              v1       = <otbgpi>-deliverydocument ) ) INTO TABLE reported-otbgatepassitem.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD printadvinvoice.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_otbgatepass\\otbgatepassitem~printadvinvoice.

    DATA(ls_result) = VALUE ts_result(  ).

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassitem ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpi).

    LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>).
      TRY.
          DATA(lv_advinv) = get_invoice(
            iv_delivery = <otbgpi>-deliverydocument
            iv_type     = 'ZPID' ).

          DATA(lo_advinv) = NEW zcl_o2c0021_tax_invoice_print(
            iv_invoice  = lv_advinv ).

          DATA(ls_cont) = lo_advinv->get_pdf( ).

          ls_result-%tky            = <otbgpi>-%tky.
          ls_result-%param-mimetype = 'application/pdf'.
          ls_result-%param-filename = |{ <otbgpi>-deliverydocument }_TaxInvoice.pdf'|.

          CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
            EXPORTING
              input  = ls_cont-pdf_content
            IMPORTING
              output = ls_result-%param-mimecont.

          INSERT ls_result
            INTO TABLE result.

        CATCH cx_sy_itab_line_not_found cx_somu_error.
          INSERT VALUE #(
            %tky = <otbgpi>-%tky
            %msg = new_message(
              id       = mc_msg_class
              number   = '010'
              severity = if_abap_behv_message=>severity-success
              v1       = <otbgpi>-deliverydocument ) ) INTO TABLE reported-otbgatepassitem.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD printtaxinvoice.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_otbgatepass\\otbgatepassitem~printtaxinvoice.

    DATA(ls_result) = VALUE ts_result(  ).

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassitem ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpi).

    LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>).
      TRY.
          DATA(lv_taxinv) = get_invoice(
            iv_delivery = <otbgpi>-deliverydocument
            iv_type     = 'ZDOM' ).

          DATA(lo_taxinv) = NEW zcl_o2c0021_tax_invoice_print(
            iv_invoice  = lv_taxinv ).

          DATA(ls_cont) = lo_taxinv->get_pdf( ).

          ls_result-%tky            = <otbgpi>-%tky.
          ls_result-%param-mimetype = 'application/pdf'.
          ls_result-%param-filename = |{ <otbgpi>-deliverydocument }_TaxInvoice.pdf'|.

          CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
            EXPORTING
              input  = ls_cont-pdf_content
            IMPORTING
              output = ls_result-%param-mimecont.

          INSERT ls_result
            INTO TABLE result.

        CATCH cx_sy_itab_line_not_found cx_somu_error.
          INSERT VALUE #(
            %tky = <otbgpi>-%tky
            %msg = new_message(
              id       = mc_msg_class
              number   = '009'
              severity = if_abap_behv_message=>severity-success
              v1       = <otbgpi>-deliverydocument ) ) INTO TABLE reported-otbgatepassitem.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_invoice.
    TYPES bapivbrkout_tab TYPE STANDARD TABLE OF bapivbrkout WITH EMPTY KEY.

    DATA(ls_range) = VALUE bapi_ref_doc_range(
      sign         = if_salv_bs_c_filter=>sign_including
      option       = if_salv_bs_c_filter=>operator_eq
      ref_doc_low  = iv_delivery ).

    DATA(lt_billing) = VALUE bapivbrkout_tab( ).
    DATA(lt_success) = VALUE bapivbrksuccess_t( ).

    CALL FUNCTION 'BAPI_BILLINGDOC_GETLIST'
      EXPORTING
        refdocrange           = ls_range
      TABLES
        success               = lt_success
        billingdocumentdetail = lt_billing.

    LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<billing>)
      WHERE bill_type EQ iv_type
        AND cancelled EQ abap_false.
      rv_invoice = <billing>-billingdoc.
      EXIT.
    ENDLOOP.

    IF rv_invoice IS INITIAL.
      RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
    ENDIF.
  ENDMETHOD.

  METHOD printplannote.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_otbgatepass\\otbgatepassitem~printplannote.

    DATA(ls_result) = VALUE ts_result(  ).

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepassitem ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgpi).

    LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>).
      DATA(lo_note) = NEW zcl_sdenh039_planned_dlv_dp( i_delivery_doc = <otbgpi>-deliverydocument ).
      DATA(ls_cont) = lo_note->get_pdf( ).

      ls_result-%tky            = <otbgpi>-%tky.
      ls_result-%param-mimetype = 'application/pdf'.
      ls_result-%param-filename = |{ <otbgpi>-deliverydocument }_PlannedNote.pdf'|.

      CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
        EXPORTING
          input  = ls_cont-pdf
        IMPORTING
          output = ls_result-%param-mimecont.

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_otbgatepass DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    INTERFACES zif_p2p_gp_const.

  PRIVATE SECTION.
    CONSTANTS:
      mc_msg_class TYPE symsgid VALUE 'ZP2P_0006_CLASSIC'.

    TYPES:
      ts_permission TYPE STRUCTURE FOR PERMISSIONS REQUEST zr_p2p_otbgatepass,
      ts_response   TYPE STRUCTURE FOR REPORTED LATE zr_p2p_otbgatepass\\otbgatepass,
      ts_otbgp      TYPE STRUCTURE FOR READ RESULT zr_p2p_otbgatepass\\otbgatepass,
      ts_failed     TYPE RESPONSE FOR FAILED EARLY zr_p2p_otbgatepass,
      ts_reported   TYPE RESPONSE FOR REPORTED EARLY zr_p2p_otbgatepass.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR otbgatepass RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR otbgatepass RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR otbgatepass RESULT result.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR otbgatepass RESULT result.

    METHODS getgpentry FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepass~getgpentry.

    METHODS getgpexit FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepass~getgpexit.

    METHODS getwbgrossweight FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepass~getwbgrossweight.

    METHODS getwbtareweight FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepass~getwbtareweight.
    METHODS calcwbnetweight FOR DETERMINE ON MODIFY
      IMPORTING keys FOR otbgatepass~calcwbnetweight.

    METHODS determinedefaultvaluesforhead FOR DETERMINE ON MODIFY
      IMPORTING keys FOR otbgatepass~determinedefaultvaluesforhead.

    METHODS postgi FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepass~postgi.

    METHODS printgpentry FOR MODIFY
      IMPORTING keys   FOR ACTION otbgatepass~printgpentry
      RESULT    result.

    METHODS printgpexit FOR MODIFY
      IMPORTING keys   FOR ACTION otbgatepass~printgpexit
      RESULT    result.

    METHODS calcgatepasstype FOR DETERMINE ON MODIFY
      IMPORTING keys FOR otbgatepass~calcgatepasstype.

    METHODS checkobligfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR otbgatepass~checkobligfields.

    METHODS checkgrossweight FOR VALIDATE ON SAVE
      IMPORTING keys FOR otbgatepass~checkgrossweight.

    METHODS calcbulk FOR DETERMINE ON MODIFY
      IMPORTING keys FOR otbgatepass~calcbulk.

    METHODS postgiwithtolerance FOR MODIFY
      IMPORTING keys FOR ACTION otbgatepass~postgiwithtolerance.

    METHODS check_tolerance
      IMPORTING
        is_otbgp    TYPE ts_otbgp
        is_reason   TYPE zso2c_chtol_s_reason_info OPTIONAL
      CHANGING
        cs_reported TYPE ts_reported
        cs_failed   TYPE ts_failed
      RAISING
        cx_bapi_custom_ex.

    METHODS complete_shipment
      IMPORTING
        is_otbgp    TYPE ts_otbgp
      CHANGING
        cs_reported TYPE ts_reported
        cs_failed   TYPE ts_failed
      RAISING
        cx_bapi_custom_ex.

    METHODS post_delivery
      IMPORTING
        is_otbgp    TYPE ts_otbgp
      CHANGING
        cs_reported TYPE ts_reported
        cs_failed   TYPE ts_failed
      RAISING
        cx_bapi_custom_ex.

    METHODS is_manual_granted
      RETURNING VALUE(rv_granted) TYPE boole_d.

    METHODS is_activity_granted
      IMPORTING iv_activity       TYPE zp2p_wb_actvt
      RETURNING VALUE(rv_granted) TYPE boole_d.

    METHODS is_tolerance_granted
      RETURNING VALUE(rv_granted) TYPE boole_d.

ENDCLASS.

CLASS lhc_otbgatepass IMPLEMENTATION.

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

  METHOD is_tolerance_granted.
    AUTHORITY-CHECK OBJECT 'ZO2C_CHTOL'
    ID 'ACTVT' FIELD zif_p2p_gp_const=>mc_activity-tolcheck.

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
      ts_result TYPE STRUCTURE FOR INSTANCE FEATURES RESULT zr_p2p_otbgatepass\\otbgatepass.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      DATA(ls_result) = VALUE ts_result(
        %tky                = <otbgp>-%tky

        %action-edit = COND #(
          WHEN NOT is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-change )
            OR <otbgp>-islogicallydeleted EQ abap_true
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

        %delete = COND #(
          WHEN NOT is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-delete )
            OR <otbgp>-islogicallydeleted EQ abap_true
          THEN if_abap_behv=>fc-f-read_only
          ELSE if_abap_behv=>fc-f-unrestricted )

      %field-containerid = COND #(
        WHEN <otbgp>-trucktype = zif_p2p_gp_const=>mc_truck_type-container
        THEN if_abap_behv=>fc-f-mandatory
        ELSE if_abap_behv=>fc-f-unrestricted )

      %field-sealnumber = COND #(
        WHEN <otbgp>-trucktype = zif_p2p_gp_const=>mc_truck_type-container
        THEN if_abap_behv=>fc-f-mandatory
        ELSE if_abap_behv=>fc-f-unrestricted )

      %field-containerweight = COND #(
        WHEN <otbgp>-trucktype = zif_p2p_gp_const=>mc_truck_type-container
        THEN if_abap_behv=>fc-f-mandatory
        ELSE if_abap_behv=>fc-f-unrestricted )

      %field-containerunit = if_abap_behv=>fc-f-read_only

      %field-wbsafetycheck = if_abap_behv=>fc-f-mandatory

      %field-wbmanual = COND #(
        WHEN is_manual_granted( ) = abap_false
        THEN if_abap_behv=>fc-f-read_only
        ELSE if_abap_behv=>fc-f-unrestricted )

      %field-wbmanualreason = COND #(
        WHEN <otbgp>-wbmanual = abap_false
        THEN if_abap_behv=>fc-f-read_only
        ELSE if_abap_behv=>fc-f-mandatory )

      %field-wbdeviceid = COND #(
        WHEN <otbgp>-wbmanual = abap_true
        THEN if_abap_behv=>fc-f-read_only
        ELSE if_abap_behv=>fc-f-unrestricted )

      %field-wbtareweight = COND #(
        WHEN <otbgp>-wbmanual = abap_false
        THEN if_abap_behv=>fc-f-read_only
        ELSE if_abap_behv=>fc-f-unrestricted )

      %field-wbgrossweight = COND #(
        WHEN <otbgp>-wbmanual = abap_false
        THEN if_abap_behv=>fc-f-read_only
        ELSE if_abap_behv=>fc-f-unrestricted )

      %field-wbunit = COND #(
        WHEN <otbgp>-wbmanual = abap_false
        THEN if_abap_behv=>fc-f-read_only
        ELSE if_abap_behv=>fc-f-unrestricted )

      %action-getgpentry = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-checkin )
         AND <otbgp>-%is_draft = if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-getwbgrossweight = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-grossweight )
         AND <otbgp>-wbmanual = abap_false
         AND <otbgp>-%is_draft = if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-getwbtareweight = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-tareweigt )
         AND <otbgp>-wbmanual = abap_false
         AND <otbgp>-%is_draft = if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-getgpexit = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-checkout )
         AND ( <otbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
          OR ( <otbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadstart AND
               <otbgp>-wbnotrelevant  EQ abap_true ) )
         AND <otbgp>-%is_draft      EQ if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-printgpentry = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-print )
         AND <otbgp>-%is_draft = if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-printgpexit = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-print )
         AND <otbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
         AND <otbgp>-%is_draft      EQ if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-postgi = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-post )
         AND <otbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
         AND <otbgp>-%is_draft      EQ if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only )

      %action-postgiwithtolerance = COND #(
        WHEN is_activity_granted( iv_activity = zif_p2p_gp_const=>mc_activity-post )
         AND is_tolerance_granted( )
         AND <otbgp>-shipmentstatus GE zif_p2p_gp_const~mc_gp_status-loadend
         AND <otbgp>-%is_draft      EQ if_abap_behv=>mk-off
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only ) ).

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD getgpentry.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
        ENTITY otbgatepass ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      <otbgp>-entrydate = sy-datum.
      <otbgp>-entrytime = sy-uzeit.
      <otbgp>-entryuser = sy-uname.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepass
       UPDATE FIELDS ( entrydate entrytime entryuser )
       WITH VALUE #( FOR otbgp IN lt_otbgp
                     ( %tky      = otbgp-%tky
                       entrydate = otbgp-entrydate
                       entrytime = otbgp-entrytime
                       entryuser = otbgp-entryuser ) )
       FAILED failed MAPPED mapped REPORTED reported.
  ENDMETHOD.

  METHOD getgpexit.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
        ENTITY otbgatepass ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      <otbgp>-exitdate = sy-datum.
      <otbgp>-exittime = sy-uzeit.
      <otbgp>-exituser = sy-uname.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepass
       UPDATE FIELDS ( exitdate exittime exituser )
       WITH VALUE #( FOR otbgp IN lt_otbgp
                     ( %tky     = otbgp-%tky
                       exitdate = otbgp-exitdate
                       exittime = otbgp-exittime
                       exituser = otbgp-exituser ) )
       FAILED failed MAPPED mapped REPORTED reported.
  ENDMETHOD.

  METHOD getwbgrossweight.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_otbgp).

    DATA(lv_error) = abap_false.

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      TRY.
          DATA(ls_params)  = VALUE zsp2p_wb_weight_capture(
              device_id = <otbgp>-wbdeviceid
              rf_id     = <otbgp>-rfid ).

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
             meins         = zcl_p2p_wb_weight_capture=>mc_default_unit
             tknum         = <otbgp>-gatepassid
             weight_id     = 'GROSSWEIGHT'
             crtmp         = lv_crtmp
             crnam         = sy-uname
             weight_status = 'GROSSWEIGHTCAPTURED'
             sttmp         = lv_crtmp
             stnam         = sy-uname ).

          lo_capture->set_weight_status(
            is_weight_status = ls_weight_status ).

          <otbgp>-wbgrossweight = ls_weight-weight.
        CATCH zcx_p2p_wb_weight_capture INTO DATA(lo_ex).
          INSERT VALUE #( %tky                     = <otbgp>-%tky
                          %msg                     = new_message_with_text(
                            text     = lo_ex->get_text( )
                            severity = if_abap_behv_message=>severity-error ) ) INTO TABLE reported-otbgatepass.

          INSERT VALUE #( %tky                     = <otbgp>-%tky
                          %action-getwbgrossweight = if_abap_behv=>mk-on
                          %fail-cause              = if_abap_behv=>cause-unspecific ) INTO TABLE failed-otbgatepass.

          lv_error = abap_true.
      ENDTRY.
    ENDLOOP.

    IF lv_error EQ abap_false.
      MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
         ENTITY otbgatepass
         UPDATE FIELDS (  wbgrossweight wbunit )
         WITH VALUE #( FOR otbgp IN lt_otbgp
                       ( %tky        = otbgp-%tky
                         wbgrossweight = otbgp-wbgrossweight
                         wbunit        = otbgp-wbunit ) ).
    ENDIF.
  ENDMETHOD.

  METHOD getwbtareweight.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_otbgp).

    DATA(lv_error) = abap_false.

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      TRY.
          DATA(ls_params)  = VALUE zsp2p_wb_weight_capture(
              device_id = <otbgp>-wbdeviceid
              rf_id     = <otbgp>-rfid ).

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
            meins         = zcl_p2p_wb_weight_capture=>mc_default_unit
            tknum         = <otbgp>-gatepassid
            weight_id     = 'TAREWEIGHT'
            crtmp         = lv_crtmp
            crnam         = sy-uname
            weight_status = 'TAREWEIGHTCAPTURED'
            sttmp         = lv_crtmp
            stnam         = sy-uname ).

          lo_capture->set_weight_status(
            is_weight_status = ls_weight_status ).

          <otbgp>-wbtareweight = ls_weight-weight.
        CATCH zcx_p2p_wb_weight_capture INTO DATA(lo_ex).
          INSERT VALUE #( %tky                     = <otbgp>-%tky
                          %msg                     = new_message_with_text(
                            text     = lo_ex->get_text( )
                            severity = if_abap_behv_message=>severity-error ) ) INTO TABLE reported-otbgatepass.

          INSERT VALUE #( %tky                     = <otbgp>-%tky
                          %action-getwbgrossweight = if_abap_behv=>mk-on
                          %fail-cause              = if_abap_behv=>cause-unspecific ) INTO TABLE failed-otbgatepass.

          lv_error = abap_true.
      ENDTRY.
    ENDLOOP.

    IF lv_error EQ abap_false.
      MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
         ENTITY otbgatepass
         UPDATE FIELDS ( wbtareweight wbunit )
         WITH VALUE #( FOR otbgp IN lt_otbgp
                       ( %tky        = otbgp-%tky
                         wbtareweight = otbgp-wbtareweight
                         wbunit       = otbgp-wbunit ) ).
    ENDIF.
  ENDMETHOD.

  METHOD calcwbnetweight.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepass ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      IF <otbgp>-wbgrossweight EQ 0 OR <otbgp>-wbtareweight EQ 0.
        <otbgp>-wbnetweight = 0.
      ELSE.
        <otbgp>-wbnetweight = <otbgp>-wbgrossweight - <otbgp>-wbtareweight.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
       ENTITY otbgatepass
       UPDATE FIELDS (  wbnetweight )
       WITH VALUE #( FOR otbgp IN lt_otbgp
                     ( %tky        = otbgp-%tky
                       wbnetweight = otbgp-wbnetweight ) ).
  ENDMETHOD.

  METHOD determinedefaultvaluesforhead.
    TYPES:
      ts_itemupdate TYPE STRUCTURE FOR UPDATE zr_p2p_otbgatepass\\otbgatepass,
      tt_itemupdate TYPE TABLE FOR UPDATE zr_p2p_otbgatepass\\otbgatepass.

    DATA(lt_itemupdate) = VALUE tt_itemupdate( ).

    SELECT SINGLE userparametervalue
      FROM p_userparameter
     WHERE userparameter EQ @zcl_p2p_wb_weight_capture=>mc_device_pid
      INTO @DATA(lv_default_device).

    SELECT SINGLE userparametervalue
      FROM p_userparameter
     WHERE userparameter EQ @zif_p2p_gp_const~mc_default_tdp
      INTO @DATA(lv_default_tdp).

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
         ENTITY otbgatepass
         FIELDS ( transpplanpoint wbdeviceid wbunit truckcapacityunit )
         WITH CORRESPONDING #( keys )
         RESULT DATA(otbgp).

    LOOP AT otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      IF <otbgp>-wbunit IS INITIAL.
        APPEND VALUE ts_itemupdate(
          %tky              = <otbgp>-%tky
          transpplanpoint   = lv_default_tdp
          wbdeviceid        = lv_default_device
          wbunit            = zcl_p2p_wb_weight_capture=>mc_default_unit
          truckcapacityunit = zcl_p2p_wb_weight_capture=>mc_default_unit
          containerunit     = zcl_p2p_wb_weight_capture=>mc_default_unit ) TO lt_itemupdate.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
        ENTITY otbgatepass
        UPDATE FIELDS ( transpplanpoint wbdeviceid wbunit truckcapacityunit containerunit )
        WITH lt_itemupdate.
  ENDMETHOD.

  METHOD printgpentry.
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_otbgatepass\\otbgatepass~printgpentry.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      TRY.
          DATA(lt_keys) = VALUE cl_somu_form_services=>ty_gt_key(
            ( name = 'ShipmentNum'    value = <otbgp>-%key-gatepassid )
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

      ls_result-%key            = <otbgp>-%key.
      ls_result-%param-mimetype = if_ai_attachment=>c_mimetype_pdf.
      ls_result-%param-filename = |{ <otbgp>-%key-gatepassid }_Entry.pdf'|.

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
    TYPES: ts_result TYPE STRUCTURE FOR ACTION RESULT zr_p2p_otbgatepass\\otbgatepass~printgpexit.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      TRY.
          DATA(lt_keys) = VALUE cl_somu_form_services=>ty_gt_key(
            ( name = 'ShipmentNum'    value = <otbgp>-%key-gatepassid )
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

      ls_result-%key            = <otbgp>-%key.
      ls_result-%param-mimetype = 'application/pdf'.
      ls_result-%param-filename = |{ <otbgp>-%key-gatepassid }_Exit.pdf'|.

      CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
        EXPORTING
          input  = lv_mimecont
        IMPORTING
          output = ls_result-%param-mimecont.

      INSERT ls_result
        INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_tolerance.
    SELECT SINGLE *
      FROM zc_p2p_definbshiptype
     WHERE tplst EQ @is_otbgp-transpplanpoint
      INTO @DATA(ls_otbstdef).

    CHECK ls_otbstdef-checktolerance EQ abap_true.

    TRY.
        DATA(lv_difference) = VALUE zif_o2c_bundle_conv_factor=>tv_value_wgt( ).

        DATA(lo_shp) = NEW zcl_o2c_bundle_conv_factor_shp(
          iv_tknum       = is_otbgp-gatepassid
          iv_update_task = abap_false ).

        DATA(ls_reason) = is_reason.

        SELECT SINGLE tolerancereasontext
          FROM zc_p2p_tolerance_reasonvh
         WHERE tolerancereason EQ @is_reason-reason_code
          INTO @ls_reason-reason_text.

        lo_shp->set_reason( is_reason = ls_reason ).

        lo_shp->check_tolerance( IMPORTING ev_difference = lv_difference ).

      CATCH zcx_o2c_bundle_conv_factor INTO DATA(lo_ex).
        DATA(ls_return) = lo_ex->make_bapi_return( ).

        DATA(lv_severity) = COND #(
          WHEN lo_shp->authorized( )
          THEN if_abap_behv_message=>severity-success
          ELSE if_abap_behv_message=>severity-error ).

        APPEND VALUE #(
          %key = is_otbgp-%key
          %msg = me->new_message(
            id       = ls_return-id
            number   = ls_return-number
            severity = lv_severity
            v1       = ls_return-message_v1
            v2       = ls_return-message_v2
            v3       = ls_return-message_v3
            v4       = ls_return-message_v4 ) ) TO cs_reported-otbgatepass.

        IF lo_shp->authorized( ) EQ abap_false.
          INSERT VALUE #(
            %key           = is_otbgp-%key
            %fail-cause    = if_abap_behv=>cause-unspecific
            %action-postgi = if_abap_behv=>mk-on )
            INTO TABLE cs_failed-otbgatepass.

          RAISE EXCEPTION TYPE cx_bapi_custom_ex.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD complete_shipment.
    DATA(lt_shipment) = VALUE zif_p2p_gp_const~tt_shipment(  ).

    CASE is_otbgp-gatepasstype.
      WHEN zif_p2p_gp_const=>mc_gatepasstype-z004.

        IF is_otbgp-costrelevant   EQ abap_true AND
           is_otbgp-costcalcstatus NE 'C'.
          APPEND VALUE #(
            %key           = is_otbgp-%key
            %state_area    = 'OTBGATEPASS'
            %action-postgi = if_abap_behv=>mk-on
            %msg           = me->new_message(
              id       = zif_p2p_gp_const=>mc_msg_class
              number   = '007'
              severity = if_abap_behv_message=>severity-error
              v1       = is_otbgp-%key-gatepassid ) ) TO cs_reported-otbgatepass.

          INSERT VALUE #(
            %key           = is_otbgp-%key
            %fail-cause    = if_abap_behv=>cause-unspecific
            %action-postgi = if_abap_behv=>mk-on )
            INTO TABLE cs_failed-otbgatepass.

          RAISE EXCEPTION TYPE cx_bapi_custom_ex.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    DATA(ls_shipment) = VALUE zif_p2p_gp_const~ts_shipment(
      shipment_num        = is_otbgp-%key-gatepassid
      header-shipment_num = is_otbgp-%key-gatepassid ).

    CONVERT DATE sy-datum TIME sy-uzeit INTO TIME STAMP DATA(lv_completion) TIME ZONE sy-zonlo.

    DATA(ls_deadline) = VALUE bapishipmentheaderdeadline(
      time_type      = 'HDRSTCADT'
      time_stamp_utc = lv_completion
      time_zone      = sy-zonlo ).

    INSERT ls_deadline
      INTO TABLE ls_shipment-deadline.

    DATA(ls_deadlinex) = VALUE bapishipmentheaderdeadlineact(
      time_type      = zif_p2p_gp_const~mc_chg_change
      time_stamp_utc = zif_p2p_gp_const~mc_chg_change
      time_zone      = zif_p2p_gp_const~mc_chg_change ).

    INSERT ls_deadlinex
      INTO TABLE ls_shipment-deadlinex.

    ls_shipment-header-status_compl  = abap_true.
    ls_shipment-headerx-status_compl = zif_p2p_gp_const~mc_chg_change.


    DATA(lt_return) = VALUE bapiret2_tab( ).

    CALL FUNCTION 'BAPI_SHIPMENT_CHANGE' DESTINATION 'NONE'
      EXPORTING
        headerdata           = ls_shipment-header
        headerdataaction     = ls_shipment-headerx
      TABLES
        headerdeadline       = ls_shipment-deadline
        headerdeadlineaction = ls_shipment-deadlinex
        return               = lt_return.

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>)
      WHERE type CA 'AEX'.
      APPEND VALUE #(
        %key           = is_otbgp-%key
        %state_area    = 'OTBGATEPASS'
        %action-postgi = if_abap_behv=>mk-on
        %msg           = me->new_message(
          id       = <return>-id
          number   = <return>-number
          severity = if_abap_behv_message=>severity-error
          v1       = <return>-message_v1
          v2       = <return>-message_v2
          v3       = <return>-message_v3
          v4       = <return>-message_v4 ) ) TO cs_reported-otbgatepass.
    ENDLOOP.

    IF sy-subrc EQ 0.
      INSERT VALUE #(
        %key           = is_otbgp-%key
        %fail-cause    = if_abap_behv=>cause-unspecific
        %action-postgi = if_abap_behv=>mk-on )
        INTO TABLE cs_failed-otbgatepass.

      RAISE EXCEPTION TYPE cx_bapi_custom_ex.
    ENDIF.
  ENDMETHOD.

  METHOD post_delivery.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass BY \_item ALL FIELDS
      WITH VALUE #( (  %key = is_otbgp-%key  ) )
      RESULT DATA(lt_otbgpi).

    LOOP AT lt_otbgpi ASSIGNING FIELD-SYMBOL(<otbgpi>).
      DATA(lv_error)     = abap_false.
      DATA(lv_sys_msg)   = VALUE text255( ).
      DATA(ls_error_log) = VALUE vbfs( ).
      DATA(lt_protocol)  = VALUE tab_prott( ).

      CALL FUNCTION 'Z_P2P0006_OTB_PGI_RFC' DESTINATION 'NONE'
        EXPORTING
          iv_deliverydocument = <otbgpi>-deliverydocument
        IMPORTING
          et_protocol         = lt_protocol
        EXCEPTIONS
          system_failure      = 1 MESSAGE lv_sys_msg.

      IF lv_sys_msg IS NOT INITIAL.
        APPEND CORRESPONDING #( syst ) TO lt_protocol.
      ENDIF.

      LOOP AT lt_protocol ASSIGNING FIELD-SYMBOL(<protocol>)
        WHERE msgty CA 'AEX'.
        APPEND VALUE #(
          gatepassid  = <otbgpi>-%key-gatepassid
          %state_area = 'OTBGATEPASS'
          %op-%update = if_abap_behv=>mk-on
          %msg        = me->new_message(
            id       = <protocol>-msgid
            number   = CONV #( <protocol>-msgno )
            severity = if_abap_behv_message=>severity-error
            v1       = <protocol>-msgv1
            v2       = <protocol>-msgv2
            v3       = <protocol>-msgv3
            v4       = <protocol>-msgv4 ) ) TO cs_reported-otbgatepass.
      ENDLOOP.

      IF sy-subrc EQ 0.
        APPEND VALUE #(
          %key           = <otbgpi>-%key-gatepassid
          %fail-cause    = if_abap_behv=>cause-conflict
          %action-postgi = if_abap_behv=>mk-on ) TO cs_failed-otbgatepass.

        RAISE EXCEPTION TYPE cx_bapi_custom_ex.
      ELSE.
        APPEND VALUE #(
          %key = is_otbgp-%key
          %msg = me->new_message(
            id       = mc_msg_class
            number   = '003'
            v1       = <otbgpi>-deliverydocument
            severity = if_abap_behv_message=>severity-information ) ) TO cs_reported-otbgatepass.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD postgi.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      TRY.
          check_tolerance(
            EXPORTING
              is_otbgp = <otbgp>
            CHANGING
              cs_reported = reported
              cs_failed   = failed ).

          complete_shipment(
            EXPORTING
              is_otbgp = <otbgp>
            CHANGING
              cs_reported = reported
              cs_failed   = failed ).

          post_delivery(
            EXPORTING
              is_otbgp = <otbgp>
            CHANGING
              cs_reported = reported
              cs_failed   = failed ).

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'.

        CATCH cx_sbti_exception INTO DATA(lo_ex).
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
      ENDTRY.

      CALL FUNCTION 'RFC_CONNECTION_CLOSE'
        EXPORTING
          destination = 'NONE'
        EXCEPTIONS
          OTHERS      = 0.
    ENDLOOP.
  ENDMETHOD.

  METHOD calcgatepasstype.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH VALUE #( FOR key IN keys (
        %key      = key-%key
        %is_draft = if_abap_behv=>mk-off ) )
      RESULT DATA(lt_active).

    CHECK lt_active IS INITIAL.

    DATA(lv_one_time) = CONV tdlnr( zcl_asas_tvarv_constant=>get_value( iv_name = 'ZP2P0006_CLASSIC_SUPPLIER' ) ).

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    IF lt_otbgp IS NOT INITIAL.
      SELECT ebeln, bsart
        FROM ekko
         FOR ALL ENTRIES IN @lt_otbgp
        WHERE ebeln EQ @lt_otbgp-ordernumber
          AND bsart EQ @zif_p2p_gp_const~mc_bsart_zsto
         INTO TABLE @DATA(lt_orders).
    ENDIF.

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      <otbgp>-gatepasstype = zif_p2p_gp_const~mc_gatepasstype-z001.

      IF <otbgp>-transporter EQ lv_one_time.
        <otbgp>-gatepasstype = zif_p2p_gp_const~mc_gatepasstype-z002.
        CONTINUE.
      ENDIF.

      IF line_exists( lt_orders[ ebeln = <otbgp>-ordernumber ] ).
        <otbgp>-gatepasstype = zif_p2p_gp_const~mc_gatepasstype-z004.
        CONTINUE.
      ENDIF.

      CASE <otbgp>-processingindicator.
        WHEN zif_p2p_gp_const~mc_procind-p0001.
          <otbgp>-gatepasstype = zif_p2p_gp_const~mc_gatepasstype-z002.
        WHEN zif_p2p_gp_const~mc_procind-p0002
          OR zif_p2p_gp_const~mc_procind-p0003.
          <otbgp>-gatepasstype = zif_p2p_gp_const~mc_gatepasstype-z001.
      ENDCASE.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass
      UPDATE FIELDS ( gatepasstype )
      WITH VALUE #( FOR otbgp IN lt_otbgp
                  ( %tky         = otbgp-%tky
                    gatepasstype = otbgp-gatepasstype ) ).
  ENDMETHOD.

  METHOD checkobligfields.
    DATA(ls_permission_request) = VALUE ts_permission( ).

    DATA(lo_struct) = CAST cl_abap_structdescr(
      cl_abap_structdescr=>describe_by_data_ref( REF #(  ls_permission_request-%field  ) ) ).

    DATA(lt_components) = lo_struct->get_components( ).

    LOOP AT lt_components ASSIGNING FIELD-SYMBOL(<field>).
      ls_permission_request-%field-(<field>-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).
      GET PERMISSIONS ONLY INSTANCE FEATURES OF zr_p2p_otbgatepass
        ENTITY otbgatepass
        FROM VALUE #( ( %tky = <otbgp>-%tky ) )
        REQUEST ls_permission_request
        RESULT DATA(ls_permission_result).

      LOOP AT lt_components ASSIGNING <field>.

        CHECK ls_permission_result-instances[ KEY draft COMPONENTS %tky = <otbgp>-%tky ]-%field-(<field>-name) EQ if_abap_behv=>fc-f-mandatory
           OR ls_permission_result-global-%field-(<field>-name) EQ if_abap_behv=>fc-f-mandatory.

        CHECK <otbgp>-(<field>-name) IS INITIAL.

        APPEND VALUE #(  %tky = <otbgp>-%tky ) TO failed-otbgatepass.

        cl_dd_ddl_annotation_service=>get_annos_4_element(
          EXPORTING
            entityname  = 'ZC_P2P_OTBGATEPASS'
            elementname = CONV #( <field>-name )
          IMPORTING
            annos       = DATA(lt_annotations) ).

        DATA(lv_label) = VALUE #(  lt_annotations[ annoname = 'ENDUSERTEXT.LABEL' ]-value OPTIONAL ).

        DATA(ls_reported) = VALUE ts_response(
          %tky        = <otbgp>-%tky
          %state_area = 'OTBGATEPASS'
          %msg        = me->new_message(
            id       = mc_msg_class
            number   = '006'
            severity = if_abap_behv_message=>severity-error
            v1       = lv_label ) ).

        ls_reported-%element-(<field>-name) = if_abap_behv=>mk-on.

        APPEND ls_reported TO reported-otbgatepass.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD checkgrossweight.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>)
      WHERE trucktype EQ zif_p2p_gp_const=>mc_truck_type-container.
      IF <otbgp>-wbgrossweight GT <otbgp>-containerweight.
        APPEND VALUE ts_response(
          %tky        = <otbgp>-%tky
          %state_area = 'OTBGATEPASS'
          %msg        = me->new_message(
            id       = mc_msg_class
            number   = '008'
            severity = if_abap_behv_message=>severity-error )
          %element-wbgrossweight = if_abap_behv=>mk-on ) TO reported-otbgatepass.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calcbulk.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass FIELDS ( transpplanpoint trucktype isbulk )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    IF lt_otbgp IS NOT INITIAL.
      SELECT tplst, fillbulk
        FROM zc_p2p_definbshiptype AS dft
        JOIN @lt_otbgp AS otb
          ON otb~transpplanpoint EQ dft~tplst
        INTO TABLE @DATA(lt_defaults).
    ENDIF.

    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>)
      WHERE trucktype EQ zif_p2p_gp_const=>mc_truck_type-bulk.

      CHECK line_exists( lt_defaults[
        tplst    = <otbgp>-transpplanpoint
        fillbulk = abap_true ] ).

      <otbgp>-isbulk = abap_true.
    ENDLOOP.

    MODIFY ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass
      UPDATE FIELDS ( isbulk )
      WITH VALUE #(
        FOR otbgp IN lt_otbgp (
          %tky   = otbgp-%tky
          isbulk = otbgp-isbulk ) ).
  ENDMETHOD.

  METHOD postgiwithtolerance.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_otbgp).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      READ TABLE lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>) WITH KEY entity COMPONENTS
        %key = <key>-%key.
      CHECK sy-subrc EQ 0.

      TRY.
          check_tolerance(
            EXPORTING
              is_otbgp = <otbgp>
              is_reason = VALUE zso2c_chtol_s_reason_info(
                reason_code = <key>-%param-reason
                reason_empl = <key>-%param-employee_name )
            CHANGING
              cs_reported = reported
              cs_failed   = failed ).

          complete_shipment(
            EXPORTING
              is_otbgp = <otbgp>
            CHANGING
              cs_reported = reported
              cs_failed   = failed ).

          post_delivery(
            EXPORTING
              is_otbgp = <otbgp>
            CHANGING
              cs_reported = reported
              cs_failed   = failed ).

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'.

        CATCH cx_sbti_exception INTO DATA(lo_ex).
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
      ENDTRY.

      CALL FUNCTION 'RFC_CONNECTION_CLOSE'
        EXPORTING
          destination = 'NONE'
        EXCEPTIONS
          OTHERS      = 0.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_p2p_otbgatepass DEFINITION INHERITING FROM cl_abap_behavior_saver_failed.
  PUBLIC SECTION.
    INTERFACES zif_p2p_gp_const.

  PROTECTED SECTION.

    TYPES:
      ts_otbgp_chg     TYPE STRUCTURE FOR CHANGE zr_p2p_otbgatepass\\otbgatepass,
      ts_otbgp_itm_chg TYPE STRUCTURE FOR CHANGE zr_p2p_otbgatepass\\otbgatepassitem,
      tt_otbgp_itm_chg TYPE TABLE FOR CHANGE zr_p2p_otbgatepass\\otbgatepassitem,
      ts_otbgp_itm_del TYPE STRUCTURE FOR KEY OF zr_p2p_otbgatepass\\otbgatepassitem,
      ts_otbgp_del     TYPE STRUCTURE FOR KEY OF zr_p2p_otbgatepass\\otbgatepass,
      tt_otbgp_itm_del TYPE TABLE FOR KEY OF  zr_p2p_otbgatepass\\otbgatepassitem,
      ts_otbgp_dlv_chg TYPE STRUCTURE FOR CHANGE zr_p2p_otbgatepass\\otbgatepassdlvitem,
      tt_otbgp_dlv_chg TYPE TABLE FOR CHANGE zr_p2p_otbgatepass\\otbgatepassdlvitem,
      ts_otbgp_dlv_del TYPE STRUCTURE FOR KEY OF zr_p2p_otbgatepass\\otbgatepassdlvitem,
      tt_otbgp_dlv_del TYPE TABLE FOR KEY OF zr_p2p_otbgatepass\\otbgatepassdlvitem,
      ts_reported      TYPE RESPONSE FOR REPORTED LATE zr_p2p_otbgatepass,
      ts_failed        TYPE RESPONSE FOR FAILED LATE zr_p2p_otbgatepass.

    METHODS map_control
      IMPORTING is_data    TYPE any
      CHANGING  cs_control TYPE any.

    METHODS adjust_numbers REDEFINITION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

  PRIVATE SECTION.
    METHODS update_shipment
      IMPORTING
        is_otbgp_chg TYPE ts_otbgp_chg
      CHANGING
        ct_shipment  TYPE zif_p2p_gp_const~tt_shipment.

    METHODS delete_shipment
      IMPORTING
        is_otbgp_del TYPE ts_otbgp_del
      CHANGING
        ct_shipment  TYPE zif_p2p_gp_const~tt_shipment.

    METHODS update_delivery
      IMPORTING
        is_otbgp_chg TYPE ts_otbgp_chg
      CHANGING
        ct_delivery  TYPE zif_p2p_gp_const~tt_delivery_upd.

    METHODS insert_shipment_item
      IMPORTING
        it_otbgp_itm_ins TYPE tt_otbgp_itm_chg
      CHANGING
        ct_shipment      TYPE zif_p2p_gp_const~tt_shipment
        ct_delivery      TYPE zif_p2p_gp_const~tt_delivery_upd.

    METHODS insert_delivery_item
      IMPORTING
        it_otbgp_dlv_itm_ins TYPE tt_otbgp_dlv_chg
      CHANGING
        ct_delivery          TYPE zif_p2p_gp_const~tt_delivery_upd.

    METHODS update_delivery_item
      IMPORTING
        it_otbgp_dlv_itm_chg TYPE tt_otbgp_dlv_chg
      CHANGING
        ct_delivery          TYPE zif_p2p_gp_const~tt_delivery_upd.

    METHODS delete_delivery_item
      IMPORTING
        it_otbgp_dlv_itm_del TYPE tt_otbgp_dlv_del
      CHANGING
        ct_delivery          TYPE zif_p2p_gp_const~tt_delivery_upd.

    METHODS update_shipment_item
      IMPORTING
        it_otbgp_itm_chg TYPE tt_otbgp_itm_chg
      CHANGING
        ct_shipment      TYPE zif_p2p_gp_const~tt_shipment.

    METHODS delete_shipment_item
      IMPORTING
        it_otbgp_itm_del TYPE tt_otbgp_itm_del
      CHANGING
        ct_shipment      TYPE zif_p2p_gp_const~tt_shipment.

    METHODS update_weight
      IMPORTING
        is_otbgp_chg TYPE ts_otbgp_chg
      RAISING
        zcx_p2p_wb_weight_capture.

ENDCLASS.

CLASS lsc_zr_p2p_otbgatepass IMPLEMENTATION.

  METHOD adjust_numbers.
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH VALUE #( FOR otbgp IN mapped-otbgatepass ( %pky = otbgp-%pre ) )
      RESULT DATA(lt_otbgp)
      ENTITY otbgatepass BY \_item ALL FIELDS
      WITH VALUE #( FOR otbgpi IN mapped-otbgatepass ( %pky = otbgpi-%pre ) )
      RESULT DATA(lt_otbgpi).

    DATA(lv_count) = 1.

    LOOP AT mapped-otbgatepassitem ASSIGNING FIELD-SYMBOL(<otbgp_itm>).
      <otbgp_itm>-%key-gatepassid     = <otbgp_itm>-%tmp-gatepassid.
      <otbgp_itm>-%key-gatepassitemid = lv_count.
      lv_count = lv_count + 1.
    ENDLOOP.

    LOOP AT mapped-otbgatepassdlvitem ASSIGNING FIELD-SYMBOL(<otbgp_dlv_itm>).
      <otbgp_dlv_itm>-%key-gatepassid           = <otbgp_dlv_itm>-%tmp-gatepassid.
      <otbgp_dlv_itm>-%key-gatepassitemid       = <otbgp_dlv_itm>-%tmp-gatepassitemid.
      <otbgp_dlv_itm>-%key-deliverydocument     = <otbgp_dlv_itm>-%tmp-deliverydocument.
      <otbgp_dlv_itm>-%key-deliverydocumentitem = <otbgp_dlv_itm>-%tmp-deliverydocumentitem.
    ENDLOOP.


    LOOP AT lt_otbgp ASSIGNING FIELD-SYMBOL(<otbgp>).

      DATA(ls_header) = CORRESPONDING bapishipmentheader( <otbgp>-%data MAPPING FROM ENTITY ).

      DATA(lt_deliveries) = VALUE zttp2p_bapishipmentitem(
        FOR <item> IN lt_otbgpi WHERE ( %pidparent = <otbgp>-%pid ) ( delivery = <item>-deliverydocument ) ).

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
            %state_area = 'OTBGATEPASS'
            %op-%create = if_abap_behv=>mk-on
            %msg        = me->new_message(
                id       = <return>-id
                number   = <return>-number
                severity = if_abap_behv_message=>severity-error
                v1       = <return>-message_v1
                v2       = <return>-message_v2
                v3       = <return>-message_v3
                v4       = <return>-message_v4 ) ) TO reported-otbgatepass.
      ENDLOOP.

      IF lv_error EQ abap_true.
        INSERT VALUE #(
            %fail-cause = if_abap_behv=>cause-conflict
            %op-%create = if_abap_behv=>mk-on )
          INTO TABLE failed-otbgatepass.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
      ELSE.
        APPEND VALUE #(
            %pre-%pid       = <otbgp>-%pid
            %key-gatepassid = ls_header-shipment_num ) TO mapped-otbgatepass.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD save_modified.
    DATA(lt_shipment) = VALUE zif_p2p_gp_const~tt_shipment(  ).
    DATA(lt_delivery) = VALUE zif_p2p_gp_const~tt_delivery_upd( ).

    IF create-otbgatepass IS NOT INITIAL.
    ENDIF.

    LOOP AT update-otbgatepass ASSIGNING FIELD-SYMBOL(<otbgp_upd>).
      update_shipment(
        EXPORTING
          is_otbgp_chg = <otbgp_upd>
        CHANGING
          ct_shipment  = lt_shipment ).

      update_delivery(
        EXPORTING
          is_otbgp_chg = <otbgp_upd>
        CHANGING
          ct_delivery  = lt_delivery ).
    ENDLOOP.

    LOOP AT delete-otbgatepass ASSIGNING FIELD-SYMBOL(<otbgp_del>).
      delete_shipment(
        EXPORTING
          is_otbgp_del = <otbgp_del>
        CHANGING
          ct_shipment = lt_shipment ).
    ENDLOOP.

    insert_shipment_item(
      EXPORTING
        it_otbgp_itm_ins = create-otbgatepassitem
      CHANGING
        ct_shipment      = lt_shipment
        ct_delivery      = lt_delivery ).

    update_shipment_item(
      EXPORTING
        it_otbgp_itm_chg = update-otbgatepassitem
      CHANGING
        ct_shipment      = lt_shipment ).

    delete_shipment_item(
      EXPORTING
        it_otbgp_itm_del = delete-otbgatepassitem
      CHANGING
        ct_shipment      = lt_shipment ).

    insert_delivery_item(
      EXPORTING
        it_otbgp_dlv_itm_ins = create-otbgatepassdlvitem
      CHANGING
        ct_delivery          = lt_delivery ).

    update_delivery_item(
      EXPORTING
        it_otbgp_dlv_itm_chg = update-otbgatepassdlvitem
      CHANGING
        ct_delivery          = lt_delivery ).

    delete_delivery_item(
      EXPORTING
        it_otbgp_dlv_itm_del = delete-otbgatepassdlvitem
      CHANGING
        ct_delivery          = lt_delivery ).

    DATA(lv_sys_msg) = VALUE text255( ).

    LOOP AT lt_shipment ASSIGNING FIELD-SYMBOL(<shipment>).
      DATA(lv_error)   = abap_false.
      DATA(lt_return)  = VALUE bapiret2_tab( ).

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

        APPEND VALUE #(
          gatepassid  = <shipment>-shipment_num
          %state_area = 'OTBGATEPASS'
          %op-%update = if_abap_behv=>mk-on
          %msg        = me->new_message(
            id       = <return>-id
            number   = <return>-number
            severity = if_abap_behv_message=>severity-error
            v1       = <return>-message_v1
            v2       = <return>-message_v2
            v3       = <return>-message_v3
            v4       = <return>-message_v4 ) ) TO reported-otbgatepass.

        lv_error = abap_true.
      ENDLOOP.

      IF lv_error EQ abap_true.
        INSERT VALUE #(
          gatepassid  = <shipment>-shipment_num
          %fail-cause = if_abap_behv=>cause-conflict
          %op-%update = if_abap_behv=>mk-on )
          INTO TABLE failed-otbgatepass.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK' DESTINATION 'NONE'.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_delivery ASSIGNING FIELD-SYMBOL(<delivery>).
      DATA(lt_protocol) = VALUE tab_prott( ).

      CALL FUNCTION 'WS_DELIVERY_UPDATE' DESTINATION 'NONE'
        EXPORTING
          vbkok_wa                 = <delivery>-header
          if_error_messages_send_0 = abap_false
          synchron                 = abap_true
          update_picking           = <delivery>-picking_update
          commit                   = abap_false
          delivery                 = <delivery>-header-vbeln_vl
          nicht_sperren            = abap_false
          it_partner_update        = <delivery>-partners
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
            %state_area = 'OTBGATEPASS'
            %op-%update = if_abap_behv=>mk-on
            %msg        = me->new_message(
                id       = <protocol>-msgid
                number   = CONV #( <protocol>-msgno )
                severity = if_abap_behv_message=>severity-error
                v1       = <protocol>-msgv1
                v2       = <protocol>-msgv2
                v3       = <protocol>-msgv3
                v4       = <protocol>-msgv4 ) ) TO reported-otbgatepass.
      ENDLOOP.

      IF lv_error EQ abap_true.
        INSERT VALUE #(
          gatepassid  = <delivery>-shipment_num
          %fail-cause = if_abap_behv=>cause-conflict
          %op-%update = if_abap_behv=>mk-on )
          INTO TABLE failed-otbgatepass.
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

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH VALUE #( FOR shipment IN lt_shipment ( %key-gatepassid = shipment-shipment_num ) )
      RESULT DATA(lt_otbgp).

    SELECT *
      FROM zc_p2p_definbshiptype
       FOR ALL ENTRIES IN @lt_otbgp
     WHERE tplst EQ @lt_otbgp-transpplanpoint
      INTO TABLE @DATA(lt_otbstdef).

    LOOP AT lt_shipment ASSIGNING <shipment>.
      lt_return = VALUE #( ).

      DATA(ls_otbgp)    = VALUE #( lt_otbgp[ KEY entity COMPONENTS %key-gatepassid = <shipment>-shipment_num ] OPTIONAL ).
      DATA(ls_otbstdef) = VALUE #( lt_otbstdef[ tplst = ls_otbgp-transpplanpoint ] OPTIONAL ).

      IF ls_otbgp-wbnetweight IS NOT INITIAL AND ls_otbstdef-checktolerance EQ abap_true.
        TRY.
            DATA(lo_shp) = NEW zcl_o2c_bundle_conv_factor_shp(
              iv_tknum = <shipment>-shipment_num ).

            DATA(lv_difference) = VALUE zif_o2c_bundle_conv_factor=>tv_value_wgt( ).
            lo_shp->check_tolerance( IMPORTING ev_difference = lv_difference ).

          CATCH zcx_o2c_bundle_conv_factor INTO DATA(lx_bcf).
            DATA(ls_return) = lx_bcf->make_bapi_return( ).

            APPEND VALUE #(
              gatepassid  = ls_otbgp-%key
              %op-%update = if_abap_behv=>mk-on
              %msg        = me->new_message(
                id       = ls_return-id
                number   = ls_return-number
                severity = if_abap_behv_message=>severity-success
                v1       = ls_return-message_v1
                v2       = ls_return-message_v2
                v3       = ls_return-message_v3
                v4       = ls_return-message_v4 ) ) TO reported-otbgatepass.

        ENDTRY.
      ENDIF.

      IF ls_otbstdef-savebcf EQ abap_true.
        LOOP AT lt_delivery ASSIGNING <delivery>.
          DATA(lt_bcf_return) = VALUE bapiret2_t( ).

          CALL FUNCTION 'Z_O2C0001_BCF_SAVE' DESTINATION 'NONE'
            EXPORTING
              iv_vbeln  = <delivery>-delivery_num
              iv_commit = abap_false
            TABLES
              et_return = lt_bcf_return.

          lt_return = VALUE #( BASE lt_return ( LINES OF lt_bcf_return ) ).

          CALL FUNCTION 'Z_O2C0001_BCF_UPDATE' DESTINATION 'NONE'
            EXPORTING
              iv_vbeln  = <delivery>-delivery_num
            TABLES
              et_return = lt_bcf_return.

          lt_return = VALUE #( BASE lt_return ( LINES OF lt_bcf_return ) ).
        ENDLOOP.

        LOOP AT lt_return ASSIGNING <return>
          WHERE type CA 'AEX'.

          APPEND VALUE #(
            gatepassid  = <shipment>-shipment_num
            %state_area = 'OTBGATEPASS'
            %op-%update = if_abap_behv=>mk-on
            %msg        = me->new_message(
              id       = <return>-id
              number   = <return>-number
              severity = if_abap_behv_message=>severity-error
              v1       = <return>-message_v1
              v2       = <return>-message_v2
              v3       = <return>-message_v3
              v4       = <return>-message_v4 ) ) TO reported-otbgatepass.

          lv_error = abap_true.
        ENDLOOP.

        IF lv_error EQ abap_true.
          INSERT VALUE #(
            gatepassid  = <shipment>-shipment_num
            %fail-cause = if_abap_behv=>cause-conflict
            %op-%update = if_abap_behv=>mk-on )
            INTO TABLE failed-otbgatepass.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT update-otbgatepass ASSIGNING <otbgp_upd>.
      TRY.
          update_weight( is_otbgp_chg = <otbgp_upd> ).

        CATCH zcx_p2p_wb_weight_capture INTO DATA(lo_ex).
          INSERT VALUE #(
            %key     = <otbgp_upd>-%key
            %msg     = new_message_with_text(
            text     = lo_ex->get_text( )
            severity = if_abap_behv_message=>severity-error ) ) INTO TABLE reported-otbgatepass.

          INSERT VALUE #(
            %key     = <otbgp_upd>-%key
            %action-getwbgrossweight = if_abap_behv=>mk-on
            %fail-cause              = if_abap_behv=>cause-unspecific ) INTO TABLE failed-otbgatepass.
      ENDTRY.
    ENDLOOP.

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
    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH VALUE #( ( %key-gatepassid = is_otbgp_chg-%key-gatepassid ) )
      RESULT DATA(lt_otbgp).

    DATA(otbgp) = VALUE #( lt_otbgp[ KEY entity COMPONENTS %key = is_otbgp_chg-%key ] ).

    READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
        shipment_num = is_otbgp_chg-%key-gatepassid.
    IF sy-subrc NE 0.
      INSERT VALUE #(
        shipment_num        = is_otbgp_chg-%key-gatepassid
        header-shipment_num = is_otbgp_chg-%key-gatepassid )
        INTO TABLE ct_shipment ASSIGNING <shipment>.
    ENDIF.

    <shipment>-header  = CORRESPONDING bapishipmentheader( is_otbgp_chg MAPPING FROM ENTITY ).
    <shipment>-headerx = CORRESPONDING bapishipmentheaderaction( is_otbgp_chg MAPPING FROM ENTITY ).

    map_control(
      EXPORTING
        is_data    = <shipment>-header
      CHANGING
        cs_control = <shipment>-headerx ).

    IF is_otbgp_chg-%control-entrydate EQ if_abap_behv=>mk-on.
      CONVERT DATE is_otbgp_chg-entrydate TIME is_otbgp_chg-entrytime
         INTO TIME STAMP DATA(lv_entry) TIME ZONE sy-zonlo.

      <shipment>-deadline = VALUE #( (
        time_type      = 'HDRSTCIPDT'
        time_stamp_utc = lv_entry
        time_zone      = sy-zonlo ) ).

      <shipment>-deadlinex = VALUE #( (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

      IF otbgp-wbnotrelevant EQ abap_true.
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

    IF is_otbgp_chg-%control-exitdate EQ if_abap_behv=>mk-on.
      CONVERT DATE is_otbgp_chg-exitdate TIME is_otbgp_chg-exittime
         INTO TIME STAMP DATA(lv_exit) TIME ZONE sy-zonlo.

      <shipment>-deadline = VALUE #( (
        time_type      = 'HDRSTSSADT'
        time_stamp_utc = lv_exit
        time_zone      = sy-zonlo ) ).

      <shipment>-deadlinex = VALUE #( (
        time_type      = zif_p2p_gp_const~mc_chg_change
        time_stamp_utc = zif_p2p_gp_const~mc_chg_change
        time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

      <shipment>-header-status_shpmnt_start  = abap_true.
      <shipment>-headerx-status_shpmnt_start = zif_p2p_gp_const~mc_chg_change.
    ENDIF.

    SELECT SINGLE dpreg, upreg
      FROM vttk
     WHERE tknum EQ @is_otbgp_chg-%key-gatepassid
      INTO @DATA(ls_entry).

    CONVERT DATE ls_entry-dpreg TIME ls_entry-upreg
       INTO TIME STAMP lv_entry TIME ZONE sy-zonlo.

    IF is_otbgp_chg-%control-wbtareweight EQ if_abap_behv=>mk-on.
      CONVERT DATE sy-datum TIME sy-uzeit
         INTO TIME STAMP DATA(lv_wb_tare_entry) TIME ZONE sy-zonlo.

      IF otbgp-isreturn EQ abap_false.
        <shipment>-deadline = VALUE #( (
          time_type      = 'HDRSTPLDT'
          time_stamp_utc = lv_entry
          time_zone      = sy-zonlo ) (
          time_type      = 'HDRSTCIADT'
          time_stamp_utc = lv_entry
          time_zone      = sy-zonlo ) (
          time_type      = 'HDRSTLSADT'
          time_stamp_utc = lv_wb_tare_entry
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
      ELSE.
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
    ENDIF.

    IF is_otbgp_chg-%control-wbgrossweight EQ if_abap_behv=>mk-on.
      CONVERT DATE sy-datum TIME sy-uzeit
         INTO TIME STAMP DATA(lv_wb_gross_entry) TIME ZONE sy-zonlo.

      IF otbgp-isreturn EQ abap_false.
        <shipment>-deadline = VALUE #( (
          time_type      = 'HDRSTLEADT'
          time_stamp_utc = lv_wb_gross_entry
          time_zone      = sy-zonlo ) ).

        <shipment>-deadlinex = VALUE #( (
          time_type      = zif_p2p_gp_const~mc_chg_change
          time_stamp_utc = zif_p2p_gp_const~mc_chg_change
          time_zone      = zif_p2p_gp_const~mc_chg_change ) ).

        <shipment>-header-status_load_end  = abap_true.
        <shipment>-headerx-status_load_end = zif_p2p_gp_const~mc_chg_change.
      ELSE.
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
    ENDIF.

    IF is_otbgp_chg-%control-radiationcertificatefile EQ if_abap_behv=>mk-on.
    ENDIF.
  ENDMETHOD.


  METHOD insert_shipment_item.
    CHECK it_otbgp_itm_ins IS NOT INITIAL.

    READ ENTITIES OF zr_p2p_otbgatepass IN LOCAL MODE
      ENTITY otbgatepass ALL FIELDS
      WITH VALUE #( FOR itm IN it_otbgp_itm_ins ( %key-gatepassid = itm-%key-gatepassid ) )
      RESULT DATA(lt_otbgp).

    SELECT *
      FROM zc_p2p_definbshiptype
       FOR ALL ENTRIES IN @lt_otbgp
     WHERE tplst EQ @lt_otbgp-transpplanpoint
      INTO TABLE @DATA(lt_otbstdef).

    DATA(lv_itenerary) = 1.

    LOOP AT it_otbgp_itm_ins ASSIGNING FIELD-SYMBOL(<otbgp_itm_ins_group>)
      GROUP BY ( gatepassid = <otbgp_itm_ins_group>-gatepassid ) ASSIGNING FIELD-SYMBOL(<lt_otbgp_itm_ins>).

      DATA(ls_otbgp) = VALUE #( lt_otbgp[ KEY entity COMPONENTS gatepassid = <lt_otbgp_itm_ins>-gatepassid ] OPTIONAL ).

      READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
         shipment_num = <lt_otbgp_itm_ins>-gatepassid.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          shipment_num        = <lt_otbgp_itm_ins>-gatepassid
          header-shipment_num = <lt_otbgp_itm_ins>-gatepassid )
          INTO TABLE ct_shipment ASSIGNING <shipment>.
      ENDIF.

      LOOP AT GROUP <lt_otbgp_itm_ins> ASSIGNING FIELD-SYMBOL(<otbgp_itm_ins>).
        DATA(ls_item) = VALUE bapishipmentitem(
          delivery  = <otbgp_itm_ins>-deliverydocument
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
          SELECT SINGLE route, vsart
            FROM likp
           WHERE vbeln EQ @<otbgp_itm_ins>-deliverydocument
            INTO @DATA(ls_likp).
          IF sy-subrc EQ 0.
            <shipment>-header-shipment_route  = ls_likp-route.
            <shipment>-header-shipping_type   = ls_likp-vsart.
            <shipment>-headerx-shipment_route = zif_p2p_gp_const~mc_chg_change.
            <shipment>-headerx-shipping_type  = zif_p2p_gp_const~mc_chg_change.
          ENDIF.
        ENDIF.

        DATA(ls_otbstdef) = VALUE #( lt_otbstdef[ tplst = ls_otbgp-transpplanpoint ] OPTIONAL ).

        IF ls_otbstdef-addtransporter EQ abap_true AND
           ls_otbgp-transporter       IS NOT INITIAL AND
           ls_otbgp-gatepasstype      NE zif_p2p_gp_const~mc_gatepasstype-z002.
          DATA(ls_delivery_upd) = VALUE zif_p2p_gp_const~ts_delivery_upd(
            delivery_num    = <otbgp_itm_ins>-deliverydocument
            shipment_num    = <otbgp_itm_ins>-%key-gatepassid
            header-vbeln_vl = <otbgp_itm_ins>-deliverydocument
            partners        = VALUE shp_partner_update_t( (
              vbeln_vl     = <otbgp_itm_ins>-deliverydocument
              parvw        = /spe/if_consolidator_constants=>c_partner_sold_to_party
              parnr        = ls_otbgp-transporter
              updkz_par    = 'I' ) ) ).

          INSERT ls_delivery_upd
            INTO TABLE ct_delivery.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_shipment_item.
  ENDMETHOD.

  METHOD delete_shipment_item.
    CHECK it_otbgp_itm_del IS NOT INITIAL.

    SELECT *
      FROM vttp
       FOR ALL ENTRIES IN @it_otbgp_itm_del
     WHERE tknum EQ @it_otbgp_itm_del-gatepassid
       AND tpnum EQ @it_otbgp_itm_del-gatepassitemid
      INTO TABLE @DATA(lt_deliveries).

    LOOP AT lt_deliveries ASSIGNING FIELD-SYMBOL(<delivery>).
      READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
          shipment_num = <delivery>-tknum.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          shipment_num        = <delivery>-tknum
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

  METHOD update_delivery.
    CHECK is_otbgp_chg-%key-gatepassid IS NOT INITIAL.

    DATA(ls_changed) = CORRESPONDING zsp2p0006_likp( is_otbgp_chg MAPPING FROM ENTITY ).
    DATA(ls_control) = CORRESPONDING zsp2p0006_likp_control( is_otbgp_chg MAPPING FROM ENTITY ).

    CHECK ls_control IS NOT INITIAL.

    DATA(ls_shipment)   = VALUE vttk( ).
    DATA(lt_ship_items) = VALUE vttp_tab( ).
    DATA(lt_ship_seg)   = VALUE vtts_tab( ).
    DATA(lt_ship_segi)  = VALUE vtsp_tab( ).

    DATA(lt_delivery)       = VALUE vtrlk_tab( ).
    DATA(lt_delivery_items) = VALUE vtrlp_tab( ).

    CALL FUNCTION 'RV_SHIPMENT_READ'
      EXPORTING
        shipment_number       = is_otbgp_chg-%key-gatepassid
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

    CHECK lines(  lt_delivery ) EQ 1.

    DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_control ) ).
    DATA(lt_fields) = lo_struct->get_ddic_field_list( ).

    LOOP AT lt_delivery ASSIGNING FIELD-SYMBOL(<delivery>).
      DATA(ls_header) = CORRESPONDING vbkok( <delivery>-ext ).

      LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<field>).
        ASSIGN COMPONENT <field>-fieldname OF STRUCTURE ls_header  TO FIELD-SYMBOL(<header>).
        ASSIGN COMPONENT <field>-fieldname OF STRUCTURE ls_changed TO FIELD-SYMBOL(<changed>).
        ASSIGN COMPONENT <field>-fieldname OF STRUCTURE ls_control TO FIELD-SYMBOL(<control>).

        CHECK sy-subrc EQ 0
          AND <control>  EQ abap_true.

        <header> = <changed>.
      ENDLOOP.

      ls_header-vbeln_vl                = <delivery>-vbeln.
      ls_header-komue                   = abap_true.
      ls_header-update_extension_fields = abap_true.

      IF ls_control-lifex EQ abap_true.
        ls_header-kzlifex = abap_true.
      ENDIF.

      DATA(ls_delivery_upd) = VALUE zif_p2p_gp_const~ts_delivery_upd(
        delivery_num = <delivery>-vbeln
        shipment_num = is_otbgp_chg-%key-gatepassid
        header       = ls_header ).

      IF ls_shipment-zzbulk EQ abap_true AND ls_header-zznet_weight NE 0.
        LOOP AT lt_delivery_items ASSIGNING FIELD-SYMBOL(<delivery_item>)
          WHERE vbeln EQ <delivery>-vbeln.
          DATA(ls_item) = VALUE vbpok(  ).

          ls_item-vbeln_vl  = <delivery_item>-vbeln.
          ls_item-posnr_vl  = <delivery_item>-posnr.

          ls_item-vbeln     = <delivery_item>-vbeln.
          ls_item-posnn     = <delivery_item>-posnr.

          ls_item-lfimg     = ls_header-zznet_weight.
          ls_item-lfimg_flo = ls_header-zznet_weight.
          ls_item-pikmg     = ls_header-zznet_weight.
          ls_item-lianp     = abap_true.

          INSERT ls_item
            INTO TABLE ls_delivery_upd-items.
        ENDLOOP.

        ls_delivery_upd-picking_update = abap_false.
      ENDIF.

      INSERT ls_delivery_upd
        INTO TABLE ct_delivery.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_weight.
    IF is_otbgp_chg-%control-wbgrossweight EQ if_abap_behv=>mk-on OR
       is_otbgp_chg-%control-wbtareweight  EQ if_abap_behv=>mk-on.

      READ ENTITY IN LOCAL MODE zr_p2p_otbgatepass
        FIELDS ( wbdeviceid )
        WITH VALUE #( ( %key = is_otbgp_chg-%key ) )
        RESULT DATA(lt_otbgp).

      DATA(otbgp) = lt_otbgp[ %key = is_otbgp_chg-%key ].

      GET TIME STAMP FIELD DATA(lv_crtmp).

      DATA(ls_params)  = VALUE zsp2p_wb_weight_capture(
        device_id = otbgp-wbdeviceid ).

      DATA(lo_capture) = NEW zcl_p2p_wb_weight_capture( is_params = ls_params ).

      IF is_otbgp_chg-%control-wbgrossweight EQ if_abap_behv=>mk-on.
        DATA(ls_weight_status) = VALUE ztp2p_wb_weight(
          guid          = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( )
          device_id     = otbgp-wbdeviceid
          weight        = is_otbgp_chg-wbgrossweight
          meins         = zcl_p2p_wb_weight_capture=>mc_default_unit
          tknum         = otbgp-gatepassid
          weight_id     = zcl_p2p_wb_weight_capture=>mc_weight_id-gross
          crtmp         = lv_crtmp
          crnam         = sy-uname
          weight_status = zcl_p2p_wb_weight_capture=>mc_weight_status-grosscaptured
          sttmp         = lv_crtmp
          stnam         = sy-uname ).

        lo_capture->set_weight_status( is_weight_status = ls_weight_status ).
      ENDIF.

      IF is_otbgp_chg-%control-wbtareweight EQ if_abap_behv=>mk-on.
        ls_weight_status = VALUE ztp2p_wb_weight(
          guid          = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( )
          device_id     = otbgp-wbdeviceid
          weight        = is_otbgp_chg-wbtareweight
          meins         = zcl_p2p_wb_weight_capture=>mc_default_unit
          tknum         = otbgp-gatepassid
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

  METHOD delete_shipment.
    READ TABLE ct_shipment ASSIGNING FIELD-SYMBOL(<shipment>) WITH TABLE KEY
        shipment_num = is_otbgp_del-gatepassid.
    IF sy-subrc NE 0.
      INSERT VALUE #(
        shipment_num        = is_otbgp_del-gatepassid
        ref_shipment        = is_otbgp_del-gatepassid
        header-shipment_num = is_otbgp_del-gatepassid )
        INTO TABLE ct_shipment ASSIGNING <shipment>.
    ENDIF.

    <shipment>-header-zzdeleted  = abap_true.
    <shipment>-headerx-zzdeleted = zif_p2p_gp_const~mc_chg_change.
  ENDMETHOD.

  METHOD insert_delivery_item.
    CHECK it_otbgp_dlv_itm_ins IS NOT INITIAL.

    LOOP AT it_otbgp_dlv_itm_ins ASSIGNING FIELD-SYMBOL(<otbgp_dlv_itm_ins>).
      READ TABLE ct_delivery ASSIGNING FIELD-SYMBOL(<delivery>) WITH TABLE KEY
        delivery_num = <otbgp_dlv_itm_ins>-deliverydocument.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          delivery_num    = <otbgp_dlv_itm_ins>-deliverydocument
          shipment_num    = <otbgp_dlv_itm_ins>-gatepassid  )
          INTO TABLE ct_delivery ASSIGNING <delivery>.

        <delivery>-header-vbeln_vl = <otbgp_dlv_itm_ins>-deliverydocument.
        <delivery>-header-komue    = abap_true.
        <delivery>-picking_update  = abap_true.
      ENDIF.

      DATA(ls_item) = VALUE vbpok(
        vbeln_vl                = <otbgp_dlv_itm_ins>-deliverydocument
        posnr_vl                = <otbgp_dlv_itm_ins>-mainitem
        vbeln                   = <otbgp_dlv_itm_ins>-referencesddocument
        posnn                   = <otbgp_dlv_itm_ins>-referencesddocumentitem
        taqui                   = abap_true
        werks                   = <otbgp_dlv_itm_ins>-plant
        lgort                   = <otbgp_dlv_itm_ins>-storagelocation
        matnr                   = <otbgp_dlv_itm_ins>-material
        charg                   = <otbgp_dlv_itm_ins>-batch
        lfimg                   = <otbgp_dlv_itm_ins>-actualdeliveryquantity
        pikmg                   = <otbgp_dlv_itm_ins>-actualdeliveryquantity
        lianp                   = abap_true
        zzpiececount_dli        = <otbgp_dlv_itm_ins>-billets
        update_extension_fields = abap_true ).

      INSERT ls_item INTO TABLE <delivery>-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_delivery_item.
    CHECK it_otbgp_dlv_itm_chg IS NOT INITIAL.

    LOOP AT it_otbgp_dlv_itm_chg ASSIGNING FIELD-SYMBOL(<otbgp_dlv_itm_chg>).
      READ TABLE ct_delivery ASSIGNING FIELD-SYMBOL(<delivery>) WITH TABLE KEY
        delivery_num = <otbgp_dlv_itm_chg>-deliverydocument.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          delivery_num    = <otbgp_dlv_itm_chg>-deliverydocument
          shipment_num    = <otbgp_dlv_itm_chg>-gatepassid  )
          INTO TABLE ct_delivery ASSIGNING <delivery>.

        <delivery>-header-vbeln_vl = <otbgp_dlv_itm_chg>-deliverydocument.
        <delivery>-header-komue    = abap_true.
        <delivery>-picking_update  = abap_true.
      ENDIF.

      DATA(ls_item) = VALUE vbpok(
        vbeln_vl                = <otbgp_dlv_itm_chg>-deliverydocument
        posnr_vl                = <otbgp_dlv_itm_chg>-deliverydocumentitem
        vbeln                   = <otbgp_dlv_itm_chg>-deliverydocument
        posnn                   = <otbgp_dlv_itm_chg>-deliverydocumentitem
        charg                   = <otbgp_dlv_itm_chg>-batch
        lfimg                   = <otbgp_dlv_itm_chg>-actualdeliveryquantity
        pikmg                   = <otbgp_dlv_itm_chg>-actualdeliveryquantity
        lianp                   = abap_true
        zzpiececount_dli        = <otbgp_dlv_itm_chg>-billets
        update_extension_fields = abap_true ).

      INSERT ls_item INTO TABLE <delivery>-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_delivery_item.
    CHECK it_otbgp_dlv_itm_del IS NOT INITIAL.

    LOOP AT it_otbgp_dlv_itm_del ASSIGNING FIELD-SYMBOL(<otbgp_dlv_itm_del>).
      READ TABLE ct_delivery ASSIGNING FIELD-SYMBOL(<delivery>) WITH TABLE KEY
        delivery_num = <otbgp_dlv_itm_del>-deliverydocument.
      IF sy-subrc NE 0.
        INSERT VALUE #(
          delivery_num    = <otbgp_dlv_itm_del>-deliverydocument
          shipment_num    = <otbgp_dlv_itm_del>-gatepassid  )
          INTO TABLE ct_delivery ASSIGNING <delivery>.

        <delivery>-header-vbeln_vl = <otbgp_dlv_itm_del>-deliverydocument.
        <delivery>-picking_update  = abap_true.
      ENDIF.

      DATA(ls_item) = VALUE vbpok(
        vbeln_vl          = <otbgp_dlv_itm_del>-deliverydocument
        posnr_vl          = <otbgp_dlv_itm_del>-deliverydocumentitem
        lips_del          = abap_true ).

      INSERT ls_item INTO TABLE <delivery>-items.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
