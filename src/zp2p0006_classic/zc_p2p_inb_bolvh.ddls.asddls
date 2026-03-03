@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Bill of Landing value help'
@ObjectModel.dataCategory: #VALUE_HELP
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}

@ObjectModel.representativeKey: 'BillOfLanding'
@Search.searchable: true

define view entity ZC_P2P_INB_BOLVH
  as select distinct from vttk
{
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 1 }
  key exti1 as BillOfLanding,
  
      @UI.hidden: true 
  key tknum as GatePassID
}
where
  shtyp = 'Z030'
