CREATE TABLE eemrt.deliverable_tr_routing (
  deliverable_tr_routing_id NUMBER NOT NULL,
  deliverable_detail_id NUMBER NOT NULL,
  deliverable_id NUMBER NOT NULL,
  deliverable_status VARCHAR2(200 BYTE),
  technical_reviewer_id VARCHAR2(2000 BYTE) NOT NULL,
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  updated_by VARCHAR2(50 BYTE),
  updated_on TIMESTAMP,
  comments VARCHAR2(2000 BYTE),
  rating VARCHAR2(100 BYTE)
);