@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: tolerance reason value help'
@ObjectModel.dataCategory: #VALUE_HELP
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Analytics.dataCategory: #DIMENSION
@ObjectModel.usageType:{
  serviceQuality: #A,
  sizeCategory: #S,
  dataClass: #MIXED
}
@ObjectModel.representativeKey: 'ToleranceReason'
@Search.searchable: true

define view entity ZC_P2P_TOLERANCE_REASONVH
  as select from ZC_DOMAIN_VALUES( p_domain_name: 'ZP2P_TOLERANCE_REASON' )
{
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}
      @ObjectModel.text.element: [ 'ToleranceReasonText' ]
  key cast( DomainValue as zp2p_tolerance_reason ) as ToleranceReason,
      
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      DomainValueText                              as ToleranceReasonText
}
