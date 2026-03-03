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

define view entity ZC_P2P_SUPPLIER
  as select distinct from ZR_P2P_SUPPLIERVH
{
      key TranspPlanPoint,
  
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8 }
      @ObjectModel.text.element: [ 'SupplierFullName' ]
      key Supplier,
           
      @Search: { ranking: #LOW, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      SupplierFullName
      
} where BusinessPartnerRole = 'CRM010'
