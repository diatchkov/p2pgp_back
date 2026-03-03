@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: first purchase order item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZI_P2P_FIRST_POI as select from I_PurchaseOrderItem
{
  key PurchaseOrder,
  min( PurchaseOrderItem ) as PurchaseOrderItem 
} group by PurchaseOrder
