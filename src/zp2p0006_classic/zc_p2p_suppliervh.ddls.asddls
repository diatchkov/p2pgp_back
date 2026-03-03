@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate pass cockpit: supplier value help'

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.representativeKey: 'Supplier'
@Search.searchable: true

define view entity ZC_P2P_SupplierVH
  as select from ZR_P2P_SUPPLIERVH
{

      @UI.lineItem: [{  position: 10 }]
  key TranspPlanPoint,
  
      @UI.lineItem: [{  position: 20 }]
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8 }
      @ObjectModel.text.element: [ 'SupplierFullName' ]
  key Supplier,

      @UI.lineItem: [{  position: 40 }]
  key PurchaseContract,
  
      @UI.lineItem: [{  position: 30 }]
      @Search: { ranking: #LOW, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      SupplierFullName,
      
      @UI.lineItem: [{  
        position: 50,
        label: 'Target value',
        cssDefault.width: '10%' }]
        
      @EndUserText.label: 'Target value'  
      TargetAmount,

      @UI.lineItem: [{  
        position: 60,
        label: 'Exposure value',
        cssDefault.width: '10%' }]
        
      @EndUserText.label: 'Exposure value'
      ServiceAmount,
      
      @UI.hidden: true
      TargetCurrency,
      
      @EndUserText.label: 'Expire date'
      ValidityEndDate
}
where
       BusinessPartnerRole = 'CRM010'
  and(
       TargetAmount        > ServiceAmount
    or PurchaseContract    is initial
  )
