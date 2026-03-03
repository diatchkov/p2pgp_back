@EndUserText.label: 'Maintain GPC: default inbound shipment t'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_P2P_DefInbShipType
  as projection on ZI_P2P_DefInbShipType
{
  key Tplst,
      Shtyp,
      CheckTolerance,
      SaveBCF, 
      AddTransporter,
      FillBulk, 
      @Consumption.hidden: true
      SingletonID,
      _ZP2PDefInbShipTypes : redirected to parent ZC_P2P_DefInbShipTypes

}
