interface ZIF_P2P_GP
  public .


  methods SET_TARE_WEIGHT
    importing
      !IS_WEIGHT type ZTP2P_WB_WEIGHT .
  methods SET_GROSS_WEIGHT
    importing
      !IS_WEIGHT type ZTP2P_WB_WEIGHT .
  methods CHANGE
    importing
      !IV_RFC type BOOLE_D default ABAP_FALSE
    returning
      value(RT_RETURN) type BAPIRET2_TAB .
  methods CREATE .
endinterface.
