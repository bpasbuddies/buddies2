CREATE TABLE eemrt.deliverable_cor_routing (
  deliverable_cor_routing_id NUMBER NOT NULL,
  deliverable_detail_id NUMBER NOT NULL,
  deliverable_id NUMBER NOT NULL,
  deliverable_status VARCHAR2(200 BYTE),
  cor_id VARCHAR2(2000 BYTE),
  created_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  updated_by VARCHAR2(50 BYTE),
  updated_on TIMESTAMP,
  comments VARCHAR2(2000 BYTE),
  co_approval VARCHAR2(1 BYTE),
  accept VARCHAR2(1 BYTE),
  co_id VARCHAR2(20 BYTE),
  CONSTRAINT deliverable_cor_routing_fk1 FOREIGN KEY (deliverable_detail_id) REFERENCES eemrt.deliverable_detail (deliverable_detail_id),
  CONSTRAINT deliverable_cor_routing_fk2 FOREIGN KEY (deliverable_id) REFERENCES eemrt.deliverables (deliverable_id)
);