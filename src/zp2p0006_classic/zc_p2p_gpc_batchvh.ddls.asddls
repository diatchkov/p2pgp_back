@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: batch value help'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZC_P2P_GPC_BatchVH
  as select from ZI_P2P_GPC_BatchVH
{
      @ObjectModel.text.element: [ 'MaterialName' ]
      @UI.textArrangement: #TEXT_FIRST
  key Material,

      @ObjectModel.text.element: [ 'PlantName' ]
      @UI.textArrangement: #TEXT_FIRST
  key Plant,

      @ObjectModel.text.element: [ 'StorageLocationName' ]
      @UI.textArrangement: #TEXT_FIRST
  key StorageLocation,

  key Batch,

      _Material._Text[ Language = $session.system_language ].MaterialName as MaterialName,

      _Plant.PlantName                                                    as PlantName,

      _StorageLocation.StorageLocationName                                as StorageLocationName,

      Leftover,
      
      @UI.hidden: true
      MaterialBaseUnit
} where Leftover > 0
