  @AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass item root'

define view entity ZR_P2P_INBGATEPASSITEM
  as select from ZI_P2P_GATEPASSITEM
  association to parent ZR_P2P_INBGATEPASS as _InbGatePass on _InbGatePass.GatePassID = $projection.GatePassID
  composition [0..*] of ZR_P2P_INBGATEPASSDLVITEM as _InbGatePassDlvItem
{
  key GatePassID,
  key GatePassItemID,
      DeliveryDocument,
      CreatedByUser,
      CreationDate,
      CreationTime,
      ZZCreatedTimestamp,
      ZZChangedTimestamp,

      /* Associations */
      _DeliveryDocument, 
      _InbGatePass,
      _InbGatePassDlvItem
}
