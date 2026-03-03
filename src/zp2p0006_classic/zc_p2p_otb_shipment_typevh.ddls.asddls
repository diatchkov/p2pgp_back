@EndUserText.label: 'Gate pass: outbound shipment type VH'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.representativeKey: 'ShipmentType'
@Search.searchable: true

define root view entity ZC_P2P_OTB_Shipment_TypeVH
  as select from ZC_P2P_SHIPMENT_TYPEVH
{
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}
      @ObjectModel.text.element: [ 'ShipmentTypeText' ]
  key ShipmentType,

      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}
      @Semantics.text: true
      ShipmentTypeText
}
where abfer = '1'
  and abwst = '1'
  and ( vsart = 'Z1' or vsart = 'Z3' )
