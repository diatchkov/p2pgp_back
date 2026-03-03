@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound gate pass item root'

@ObjectModel.semanticKey: [ 'GatePassItemID' ]
@Metadata.allowExtensions: true

define view entity ZR_P2P_OTBGATEPASSITEM
  as select from ZI_P2P_GATEPASSITEM
  association to parent ZR_P2P_OTBGATEPASS        as _OtbGatePass on _OtbGatePass.GatePassID = $projection.GatePassID
  composition [0..*] of ZR_P2P_OTBGATEPASSDLVITEM as _OtbGatePassDlvItem
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
      _OtbGatePass,
      _OtbGatePassDlvItem
}
