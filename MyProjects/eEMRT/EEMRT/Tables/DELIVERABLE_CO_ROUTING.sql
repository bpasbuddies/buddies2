CREATE TABLE eemrt.deliverable_co_routing (
  deliverable_co_routing_id NUMBER NOT NULL,
  deliverable_detail_id NUMBER NOT NULL,
  deliverable_id NUMBER NOT NULL,
  deliverable_status VARCHAR2(200 BYTE),
  co_id VARCHAR2(2000 BYTE),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  updated_by VARCHAR2(50 BYTE),
  updated_on TIMESTAMP,
  comments VARCHAR2(2000 BYTE),
  approve VARCHAR2(1 BYTE)
);