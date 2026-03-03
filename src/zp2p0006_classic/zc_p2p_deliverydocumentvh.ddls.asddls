@EndUserText.label: 'Gate pass: delivery document value help'
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
@ObjectModel.representativeKey: 'DeliveryDocument'
@Search.searchable: true

define root view entity ZC_P2P_DeliveryDocumentVH
  as select distinct from I_DeliveryDocument  as _Delivery
    left outer join       ZR_P2P_GATEPASSITEM as _GPI on _GPI.DeliveryDocument = _Delivery.DeliveryDocument
{

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 1
      @Search.ranking: #HIGH
  key _Delivery.DeliveryDocument,

      @UI.hidden: true
      _Delivery._Item.ReferenceSDDocument as ReferenceSDDocument
}
where
      _Delivery.OverallGoodsMovementStatus <> 'C'
  and _GPI.DeliveryDocument                is null
