@EndUserText.label: 'GPC: inbound crusher params'

define root abstract entity ZD_P2P_INB_CRUSHER_PARAMS
{
  @UI.defaultValue   : #('ELEMENT_OF_REFERENCED_ENTITY: Plant')
  @UI.hidden: true
  Plant : werks_d;

  @Consumption.valueHelpDefinition: [{ 
    entity: { 
      name: 'ZC_P2P_LOGISTICSORDERVH', 
      element: 'OrderID' },
    additionalBinding: [ { 
      element: 'Plant',
      localElement: 'Plant',
      usage: #FILTER } ] } ]
  OrderID : aufnr;
}
