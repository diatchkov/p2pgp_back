@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Purchase order value help'

@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@ObjectModel.representativeKey: 'PurchaseOrderItem'
@Search.searchable: true

define view entity ZC_P2P_GPC_PURCHASEORDERITEMVH
    as select from ZI_P2P_GPC_PURCHASEORDERITEMVH
{
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 1 }
  key PurchaseOrder,

  key PurchaseOrderItem,
  
      Material,

      MaterialName,
      
      PurchaseOrderType, 
      
      Plant,

      SupplierFullName,

      PurchaseOrderDate,

      PurchasingGroup,

      @UI.hidden: true
      CreatedByUser,

      @UI.hidden: true
      CreationDate,

      @UI.hidden: true
      CompanyCode,
      
      @UI.hidden: true
      TranspPlanPoint,
      
      @UI.hidden: true
      isScrap
} where PurchasingProcessingStatus = '05'
