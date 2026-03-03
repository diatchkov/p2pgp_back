@EndUserText.label: 'Gate pass: shipment type VH'
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

define root view entity ZC_P2P_SHIPMENT_TYPEVH as select from tvtk
association [0..*] to tvtkt as _ShipmentText on $projection.ShipmentType = _ShipmentText.shtyp
{
    @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}  
    @ObjectModel.text.element: [ 'ShipmentTypeText' ]
    key shtyp as ShipmentType,
    
    @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}  
    @Semantics.text: true
    _ShipmentText[ 1:spras = $session.system_language ].bezei as ShipmentTypeText,
    
    tvtk.abfer, 
    tvtk.abwst, 
    tvtk.vsart
} 
