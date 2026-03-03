@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPC: Purchase order value help'

@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@ObjectModel.representativeKey: 'PurchaseOrderItem'
@Search.searchable: true

define view entity ZI_P2P_GPC_PURCHASEORDERITEMVH
  as select from    I_PurchaseOrder                                                      as _Order
    join            ZC_P2P_FIRST_POI                                                     as _FirstPOI   on _FirstPOI.PurchaseOrder = _Order.PurchaseOrder
    join            I_PurchaseOrderItem                                                  as _Item       on _Item.PurchaseOrder = _Order.PurchaseOrder
    join            ttds                                                                 as _TransPoint on _TransPoint.bukrs = _Order.CompanyCode
    left outer join ZI_ASAS_UTILITIES_TVARVC( p_type: 'P', p_name: 'ZP2P0006_PG_SCRAP' ) as _Scrap      on _Scrap.low = _Order.PurchasingGroup
{
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 1 }
  key _Order.PurchaseOrder,

  key _Item.PurchaseOrderItem,

      _Item.Material,

      _Item._Material._Text.MaterialName,

      _Order.PurchaseOrderType,

      _FirstPOI.Plant,

      _Order._Supplier.SupplierFullName,

      _Order.PurchaseOrderDate,

      _Order.PurchasingGroup,

      _Order.CreatedByUser,

      _Order.CreationDate,

      _Order.CompanyCode,

      _TransPoint.tplst                                                        as TranspPlanPoint,

      _Order.PurchasingProcessingStatus,

      cast( case when _Scrap.low is null then '' else 'X' end as zp2p_scrap ) as isScrap
}
where
      _Order.PurchasingDocumentDeletionCode = ' '
  and _Item.ProductType                     = '1'
  and _Item.PurchasingDocumentDeletionCode  = ' '
  and _Item.IsCompletelyDelivered           = ' '
