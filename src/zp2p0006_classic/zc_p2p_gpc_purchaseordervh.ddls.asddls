@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Purchase order value help'
@Metadata.ignorePropagatedAnnotations: true

@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@ObjectModel.representativeKey: 'PurchaseOrder'
@Search.searchable: true

define root view entity ZC_P2P_GPC_PurchaseOrderVH
  as select distinct from ZC_P2P_GPC_PURCHASEORDERITEMVH
{
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 1 }
  key PurchaseOrder,
      
      Plant, 
      
      SupplierFullName,
      
      PurchaseOrderDate,
        
      PurchasingGroup, 
      
      CreatedByUser,

      CreationDate,
      
      @UI.hidden: true  
      isScrap,
            
      @UI.hidden: true
      CompanyCode,

      @UI.hidden: true 
      TranspPlanPoint
}
