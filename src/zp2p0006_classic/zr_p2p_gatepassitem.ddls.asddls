@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass item root'

define view entity ZR_P2P_GATEPASSITEM
  as select from ZI_P2P_GATEPASSITEM as _GPI
    join         ZI_P2P_GATEPASS     as _GP on _GP.GatePassID = _GPI.GatePassID
{
  key _GPI.GatePassID,
  key _GPI.GatePassItemID,
      _GPI.DeliveryDocument,
      _GP.GatePassType
}
where
       not(
         _GP.GatePassType    = 'Z030'
         or _GP.GatePassType = 'Z003'
       )
