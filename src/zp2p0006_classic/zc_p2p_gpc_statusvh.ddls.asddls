@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate pass: status'
@ObjectModel.dataCategory: #VALUE_HELP
@Metadata.ignorePropagatedAnnotations: true
@Analytics.dataCategory: #DIMENSION
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@ObjectModel.representativeKey: 'Status'
@Search.searchable: true

define view entity ZC_P2P_GPC_STATUSVH
  as select from ZC_DOMAIN_VALUES( p_domain_name: 'ZP2P_GP_STATUS' )
{
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}
      @ObjectModel.text.element: [ 'StatusText' ]
  key cast( DomainValue as zp2p_gp_status ) as Status,

      @UI.hidden:true
      case DomainValue
          when '01' then 3
          when '02' then 2
          when '03' then 1
      end                                   as StatusCriticality,

      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      DomainValueText                       as StatusText
}
