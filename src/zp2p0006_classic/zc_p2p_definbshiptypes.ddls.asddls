@EndUserText.label: 'Maintain GPC:default inbound shipment ty'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity ZC_P2P_DefInbShipTypes
  provider contract transactional_query
  as projection on ZI_P2P_DefInbShipTypes
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ZP2PDefInbShipType : redirected to composition child ZC_P2P_DefInbShipType
  
}
