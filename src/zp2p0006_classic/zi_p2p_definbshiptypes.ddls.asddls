@EndUserText.label: 'GPC:default inbound shipment types Sing'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_P2P_DefInbShipTypes
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_P2P_DEFINBSHIPTYPE'
  composition [0..*] of ZI_P2P_DefInbShipType as _ZP2PDefInbShipType
{
  key 1 as SingletonID,
  _ZP2PDefInbShipType,
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
