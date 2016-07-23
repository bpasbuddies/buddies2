CREATE TABLE eemrt.program_locations (
  pgl_id NUMBER NOT NULL,
  pgl_program VARCHAR2(20 BYTE) NOT NULL,
  pgl_location VARCHAR2(20 BYTE) NOT NULL,
  pgl_created_by VARCHAR2(20 BYTE),
  pgl_created_on TIMESTAMP,
  pgl_last_modified_by VARCHAR2(20 BYTE),
  pgl_last_modified_on TIMESTAMP,
  pgl_location_order NUMBER,
  CONSTRAINT pgl_pk PRIMARY KEY (pgl_id)
);