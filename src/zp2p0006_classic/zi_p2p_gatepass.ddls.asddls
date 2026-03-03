@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate pass cockpit: gate pass object'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_P2P_GATEPASS
  as select from    vttk
    left outer join ztp2p_a_rc as _RadiationCertificate on _RadiationCertificate.tknum = vttk.tknum
  association        to ZC_P2P_SHIPMENT_TYPEVH         as _ShipmentType        on  _ShipmentType.ShipmentType = $projection.GatePassType
  association        to ZC_P2P_TRPOINTVH               as _TranspPlanPoint     on  _TranspPlanPoint.TranspPlanPoint = $projection.TranspPlanPoint
  association        to ZC_P2P_SUPPLIER                as _Transporter         on  _Transporter.Supplier        = $projection.Transporter
                                                                               and _Transporter.TranspPlanPoint = $projection.TranspPlanPoint
  association        to ZC_P2P_TRUCK_TYPEVH            as _TruckType           on  _TruckType.Type = $projection.TruckType
  association        to ZC_P2P_TRUCK                   as _Truck               on  _Truck.ID = $projection.TruckID
  association        to ZC_P2P_WB_SHP_CAPTURE          as _WBCapture           on  _WBCapture.GatePassID = $projection.GatePassID
  association        to I_SpecialProcessingCode        as _ProcessingIndicator on  _ProcessingIndicator.SpecialProcessingCode = $projection.ProcessingIndicator
  association [0..1] to ZC_P2P_WB_MANUAL_REASONVH      as _WBManualReason      on  $projection.WBManualReason = _WBManualReason.WBManualReason
  association [1..1] to ZC_P2P_GPC_STATUSVH            as _Status              on  _Status.Status = $projection.Status
{
  key vttk.tknum                    as GatePassID,
      vttk.shtyp                    as GatePassType,
      vttk.vsart                    as GatePassDirection,
      @Consumption.valueHelpDefinition: [ {
        entity: { name: 'I_SpecialProcessingCode' , element: 'SpecialProcessingCode' },
        distinctValues: true } ]
      vttk.sdabw                    as ProcessingIndicator,

      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZC_P2P_TRPOINTVH',
              element: 'TranspPlanPoint'
          },
          distinctValues: true
      }]
      vttk.tplst                    as TranspPlanPoint,

      vttk.exti1                    as BillOfLanding,
      cast( vttk.exti2 as ebeln )   as OrderNumber,
      vttk.zzebelp                  as OrderNumberItem,
      vttk.text1                    as RFID,
      vttk.text2                    as RadiationCertificate,
      vttk.text3                    as SealNumber,

      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZC_P2P_SupplierVH',
              element: 'Supplier'
          },

          additionalBinding: [{
              localElement: 'TranspPlanPoint',
              element: 'TranspPlanPoint',
              usage: #FILTER
          }]
      }]
      vttk.tdlnr                    as Transporter,

      vttk.signi                    as ContainerID,

      vttk.zzlgort                  as StorageLocation,

      vttk.zztruck_guid             as TruckGUID,

      @Consumption.valueHelpDefinition: [{
        entity: {
            name: 'ZC_P2P_TruckVH',
            element: 'ID'
        },
        distinctValues: true,
        additionalBinding: [{
          localElement: 'TruckType',
          element: 'Type',
          usage: #RESULT }, {

          localElement: 'TruckInsuranceNumber',
          element: 'Insurance',
          usage: #RESULT }, {

          localElement: 'TruckInsuranceDate',
          element: 'InsuranceDate',
          usage: #RESULT }, {

          localElement: 'ProcessingIndicator',
          element: 'ProcessingIndicator',
          usage: #RESULT }, {

          localElement: 'TruckCapacity',
          element: 'TruckCap',
          usage: #RESULT }, {

          localElement: 'TruckCapacityUnit',
          element: 'CapUnit',
          usage: #RESULT }, {

          localElement: 'DriverName',
          element: 'DriverName',
          usage: #RESULT }, {

          localElement: 'DriverPhone',
          element: 'DriverPhone',
          usage: #RESULT }, {

          localElement: 'DriverLicense',
          element: 'DriverLicense',
          usage: #RESULT }]
      }]
      vttk.zztruck_id               as TruckID,

      @Consumption.valueHelpDefinition: [ {
        entity: { name: 'ZC_P2P_TRUCK_TYPEVH' , element: 'Type' },
        distinctValues: true } ]
      vttk.zztruck_type             as TruckType,

      vttk.zztruck_insurance_number as TruckInsuranceNumber,
      vttk.zztruck_insurance_date   as TruckInsuranceDate,

      @Semantics.quantity.unitOfMeasure: 'TruckCapacityUnit'
      vttk.zztruck_capacity         as TruckCapacity,
      vttk.zztruck_capacity_unit    as TruckCapacityUnit,
      vttk.zzdriver_guid            as DriverGUID,

      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZC_P2P_DriverVH',
              element: 'Name'
          },
          distinctValues: true,
          additionalBinding: [{
              localElement: 'DriverPhone',
              element: 'Phone',
              usage: #RESULT
          }, {
              localElement: 'DriverLicense',
              element: 'License',
              usage: #RESULT
          }]
      }]
      vttk.zzdriver_name            as DriverName,

      vttk.zzdriver_phone           as DriverPhone,
      vttk.zzdriver_license         as DriverLicense,

      vttk.zzwb_not_relevant        as WBNotRelevant,

      vttk.zzwb_safety_check        as WBSafetyCheck,

      @Consumption.valueHelpDefinition: [{
         entity: {
             name: 'ZC_P2P_WB_DEVICEVH',
             element: 'DeviceID'
         },
         distinctValues: true
      }]
      vttk.zzwb_device_id           as WBDeviceID,
      vttk.zzwb_manual              as WBManual,

      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZC_P2P_WB_MANUAL_REASONVH',
              element: 'WBManualReason'
          },
          distinctValues: true
      }]
      vttk.zzwb_manual_reason       as WBManualReason,

      vttk.zzwb_notes               as WBNotes,

      @Semantics.quantity.unitOfMeasure: 'WBUnit'
      vttk.zzwb_gross_weight        as WBGrossWeight,

      @Semantics.quantity.unitOfMeasure: 'WBUnit'
      vttk.zzwb_tare_weight         as WBTareWeight,

      @Semantics.quantity.unitOfMeasure: 'WBUnit'
      vttk.zzwb_net_weight          as WBNetWeight,

      vttk.zzwb_unit                as WBUnit,

      vttk.zzbulk                   as isBulk,

      vttk.dpreg                    as EntryDate,
      vttk.upreg                    as EntryTime,
      vttk.zzentry_user             as EntryUser,
      vttk.zzentry_reason           as EntryReason,

      vttk.datbg                    as ExitDate,
      vttk.uatbg                    as ExitTime,
      vttk.zzexit_user              as ExitUser,
      vttk.zzscrap                  as isScrap,
      vttk.zzreturn                 as isReturn,
      vttk.zzdeleted                as isLogicallyDeleted,

      vttk.frkrl                    as CostRelevant,
      vttk.fbgst                    as CostCalcStatus,

      @Semantics.quantity.unitOfMeasure: 'ContainerUnit'
      vttk.zzct_gross_weight        as ContainerWeight,

      vttk.zzct_unit                as ContainerUnit,
      vttk.zzpiececount             as Pieces,
      
      vttk.zzcreatedtimestamp       as ZZCreatedTimestamp,
      vttk.zzchangedtimestamp       as ZZChangedTimestamp,

      _RadiationCertificate.rcert   as RadiationCertificateBody,
      _RadiationCertificate.mtype   as RadiationCertificateType,
      _RadiationCertificate.fname   as RadiationCertificateFile,

      cast(
        case when vttk.stten = 'X' then '07'
          else case when vttk.sttbg = 'X' then '06'
            else case when vttk.stabf = 'X' then '05'
              else case when vttk.stlad = 'X' then '04'
                else case when vttk.stlbg = 'X' then '03'
                  else case when vttk.streg = 'X' then '02'
                    else case when vttk.stdis = 'X' then '01'
                      else '00'
                      end
                    end
                  end
                end
              end
            end
          end as zp2p_ship_status ) as ShipmentStatus,

      cast(
        case when vttk.zzdeleted  = 'X' then '03'
          else case when  vttk.sttbg = 'X' or vttk.stten = 'X' then '02'
            else '01'
          end
        end as zp2p_gp_status )     as Status,

      /* Associations */
      _ShipmentType,
      _Status,
      _TranspPlanPoint,
      _Transporter,
      _Truck,
      _TruckType,
      _WBCapture,
      _WBManualReason,
      _ProcessingIndicator
}
