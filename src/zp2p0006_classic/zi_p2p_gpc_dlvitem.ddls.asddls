@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: delivery item hierarchy'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZI_P2P_GPC_DLVITEM
  as select from ZI_P2P_GatePassDlvItem
  association         to parent ZR_P2P_INBGATEPASSITEM as _InbGatePassItem on  _InbGatePassItem.GatePassID     = $projection.GatePassID
                                                                           and _InbGatePassItem.GatePassItemID = $projection.GatePassItemID
  association         to ZR_P2P_INBGATEPASS            as _InbGatePass     on  _InbGatePass.GatePassID = $projection.GatePassID
  association [0..1]  to I_DeliveryDocumentItem        as _Item            on  _Item.DeliveryDocument     = $projection.DeliveryDocument
                                                                           and _Item.DeliveryDocumentItem = $projection.DeliveryDocumentItem
  association of many to one ZI_P2P_GPC_DLVITEM        as _Main            on  $projection.DeliveryDocument         = _Main.DeliveryDocument
                                                                           and $projection.higherlvlitmofbatspltitm = _Main.DeliveryDocumentItem
{
  key GatePassID,
  key GatePassItemID,
  key DeliveryDocument,
  key DeliveryDocumentItem,
      _Item.Material,
      _Item.Plant,
      _Item.StorageLocation,
      _Item.Batch,
      _Item.HigherLvlItmOfBatSpltItm,
      _Item.ActualDeliveryQuantity,
      _Item.DeliveryQuantityUnit,
      _Item.ZZItemBundle_DLI,
      _Item.ZZCreatedTimestamp,
      _Item.ZZChangedTimestamp,
      /* Associations */
      _InbGatePassItem,
      _InbGatePass,
      _Item,
      _Main
}
