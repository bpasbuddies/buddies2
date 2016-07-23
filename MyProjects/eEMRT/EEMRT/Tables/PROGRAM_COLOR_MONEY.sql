CREATE TABLE eemrt.program_color_money (
  pcm_id NUMBER NOT NULL,
  pcm_color_of_money VARCHAR2(20 BYTE) NOT NULL,
  pcm_pgm_id NUMBER NOT NULL,
  pcm_created_by VARCHAR2(20 BYTE),
  pcm_created_on TIMESTAMP,
  pcm_last_modified_by VARCHAR2(20 BYTE),
  pcm_last_modified_on TIMESTAMP
);