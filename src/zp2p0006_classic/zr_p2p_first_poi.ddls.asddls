@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: first purchase order item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZR_P2P_FIRST_POI
  as select from ZI_P2P_FIRST_POI as _FirstPOI
    join         I_PurchaseOrderItem as _Item on  _FirstPOI.PurchaseOrder     = _Item.PurchaseOrder
                                              and _FirstPOI.PurchaseOrderItem = _Item.PurchaseOrderItem
{
  key _FirstPOI.PurchaseOrder as PurchaseOrder,
      _Item.Plant as Plant, 
      _Item.StorageLocation as StorageLocation
}
