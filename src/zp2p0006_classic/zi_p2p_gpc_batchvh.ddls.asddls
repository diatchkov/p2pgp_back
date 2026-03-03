@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: batch value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZI_P2P_GPC_BatchVH as select from nsdm_e_mchb
  association[1..1] to I_Material as _Material on _Material.Material = $projection.Material
  association[1..1] to I_Plant as _Plant on _Plant.Plant = $projection.Plant
  association[1..1] to I_StorageLocation as _StorageLocation on _StorageLocation.Plant = $projection.Plant
    and _StorageLocation.StorageLocation = $projection.StorageLocation
{
  key matnr as Material,
  key werks as Plant,
  key lgort as StorageLocation,
  key charg as Batch,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  clabs as Leftover,
  _Material.MaterialBaseUnit as MaterialBaseUnit,
  
  _Material, 
  _Plant, 
  _StorageLocation
 
} where lvorm = ' '

