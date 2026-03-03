@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: first purchase order item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZC_P2P_FIRST_POI
  as select from ZR_P2P_FIRST_POI
{
  key PurchaseOrder,
      Plant,
      StorageLocation
}
