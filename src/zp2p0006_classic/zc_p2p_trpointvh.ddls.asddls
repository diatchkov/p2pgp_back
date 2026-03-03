@EndUserText.label: 'Gate pass: transp point value help'
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
@ObjectModel.representativeKey: 'TranspPlanPoint'
@Search.searchable: true

define root view entity ZC_P2P_TRPOINTVH as select from ttds
    association [0..*] to ttdst as _TransPlanPointText on $projection.TranspPlanPoint = _TransPlanPointText.tplst
{
    @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}  
    @ObjectModel.text.element: [ 'TranspPlanPointText' ]
    key tplst as TranspPlanPoint,
    
    @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8}  
    @Semantics.text: true
    _TransPlanPointText[ 1:spras = $session.system_language ].bezei as TranspPlanPointText
}
