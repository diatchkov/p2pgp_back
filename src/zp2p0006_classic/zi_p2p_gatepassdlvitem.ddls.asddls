@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate pass cockpit: delivery items'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_P2P_GatePassDlvItem
  as select from vttp
  association [0..*] to I_DeliveryDocumentItem as _GatePassDlvItem on  vttp.vbeln = _GatePassDlvItem.DeliveryDocument
  association [0..1] to I_DeliveryDocumentItem as _Item            on  _Item.DeliveryDocument     = $projection.DeliveryDocument
                                                                   and _Item.DeliveryDocumentItem = $projection.deliverydocumentitem
  association [0..1] to ZI_ASAS_UTILITIES_TVARVC as _Tvarvc on _Tvarvc.low <> ''                                                                                                                                       
{
  key tknum                                    as GatePassID,
  key tpnum                                    as GatePassItemID,
  key vbeln                                    as DeliveryDocument,
  key _GatePassDlvItem.DeliveryDocumentItem,
      _GatePassDlvItem.ReferenceSDDocument     as ReferenceSDDocument,
      _GatePassDlvItem.ReferenceSDDocumentItem as ReferenceSDDocumentItem,
      _Tvarvc( p_type: 'P', p_name: 'ZP2P0006_BATCH_WEIGHT' ).low as WeightVariable,  
      _Item
}
