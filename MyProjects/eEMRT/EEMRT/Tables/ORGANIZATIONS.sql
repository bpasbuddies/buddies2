CREATE TABLE eemrt.organizations (
  org_cd VARCHAR2(25 BYTE),
  rgn_cd VARCHAR2(2 BYTE),
  org_title VARCHAR2(240 BYTE),
  parent_org_cd VARCHAR2(10 BYTE),
  parent_org_rgn_cd VARCHAR2(2 BYTE),
  city_cd VARCHAR2(4 BYTE),
  cntry_cd VARCHAR2(2 BYTE),
  st_abbrv VARCHAR2(2 BYTE),
  st_cd VARCHAR2(2 BYTE),
  eff_dt VARCHAR2(10 BYTE),
  org_fac_addrs VARCHAR2(300 BYTE),
  org_fac_addrs_rtg_sym VARCHAR2(10 BYTE),
  expiration_dt VARCHAR2(20 BYTE)
);