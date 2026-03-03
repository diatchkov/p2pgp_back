@EndUserText.label: 'GPC: gate pass print form'

define abstract entity ZD_P2P_GP_PRINT
{
  FileName : bds_filena;
  MimeType : bds_mimetp;
  MimeCont : abap.string( 0 );
}
