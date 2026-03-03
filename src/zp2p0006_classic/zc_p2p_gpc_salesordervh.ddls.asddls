@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Sales order value help'
@Metadata.ignorePropagatedAnnotations: true

@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@ObjectModel.representativeKey: 'SalesOrder'
@Search.searchable: true

define root view entity ZC_P2P_GPC_SalesOrderVH
  as select from I_SalesDocument as _Order
{
      @Search:{ defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 1 }
  key _Order.SalesDocument as SalesOrder,

      _Order.DistributionChannel,

      _Order.OrganizationDivision,

      _Order.SalesDocumentType as SalesOrderType,

      _Order.SalesOrganization
} where _Order.OverallDeliveryStatus <> 'C' 
    and _Order.OverallSDDocumentRejectionSts <> 'C'
