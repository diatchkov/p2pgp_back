@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: inbound delivery item root'

@ObjectModel.semanticKey: [ 'DeliveryDocumentItem' ]
@Metadata.allowExtensions: true

define view entity ZR_P2P_INBGATEPASSDLVITEM
  as select from ZI_P2P_INBGATEPASSDLVITEM
  association to parent ZR_P2P_INBGATEPASSITEM as _InbGatePassItem on  _InbGatePassItem.GatePassID     = $projection.GatePassID
                                                                   and _InbGatePassItem.GatePassItemID = $projection.GatePassItemID
{
  key GatePassID,
  key GatePassItemID,
  key DeliveryDocument,
  key DeliveryDocumentItem,
      ReferenceSDDocument,
      ReferenceSDDocumentItem,
      Material,
      Plant,
      StorageLocation,
      ZZCreatedTimestamp,
      ZZChangedTimestamp,
      /* Associations */
      _InbGatePass,
      _InbGatePassItem,
      _Item,
      _OrderItem,
      _Product
}
