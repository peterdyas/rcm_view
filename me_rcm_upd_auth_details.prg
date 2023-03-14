DROP PROGRAM me_rcm_upd_auth_details :dba GO
CREATE PROGRAM me_rcm_upd_auth_details :dba
 prompt
	"Output to File/Printer/MINE" = "MINE"
	, "AUTH_ID" = 903115639
	, "coder_comment" = ""
	, "nurse_comment" = ""
	, "user" = "0"
 
with OUTDEV, AUTH_ID, CC, NC, USER
 
 
 FREE RECORD record_data
 RECORD record_data (
   1 db_update_status = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD upd_price
 RECORD upd_price (
   1 status = vc
   1 row [1 ]
     2 auth_id = f8
     2 nc = vc
     2 cc = vc
     2 dc = vc
 
 )
 SET upd_price->row[1 ].auth_id =  $auth_id
 SET upd_price->row[1 ].cc =  $cc
 SET upd_price->row[1 ].nc =  $nc
; SET upd_price->row[1 ].dc = $dc
 
 
 
 DECLARE auth_id = f8 WITH protect
 DECLARE charge_id = f8 WITH protect
 DECLARE order_id = f8 WITH protect
 DECLARE SCRIPT_RUN = DQ8 WITH protect
 DECLARE userid = vc WITH protect
 
 SET SCRIPT_RUN = cnvtdatetime(curdate,curtime)
 set userid = $user
 
 SELECT INTO "nl:"
  FROM (CUST_RCM_AUTH_STATUS cr )
 
  PLAN (cr
   WHERE (cr.order_id =  $auth_id ) )
 
  HEAD cr.order_id
   order_id = cr.order_id
  WITH nocounter
 ;end select
 
  SELECT INTO "nl:"
  FROM (CUST_RCM_AUTH_STATUS cr )
 
  PLAN (cr
   WHERE (cr.charge_id =  $auth_id ) )
 
  HEAD cr.charge_id
   charge_id = cr.charge_id
  WITH nocounter
 ;end select
 
 IF ((order_id > 0 ) )
  UPDATE FROM (CUST_RCM_AUTH_STATUS ci )
   SET
 
     ci.rcm_comment = concat(trim(userid) , "-", format(SCRIPT_RUN,"dd-mmm-yyyy hh:mm:ss;;q"),"--", trim(upd_price->row[1 ].cc)
                       , "******" ,ci.rcm_comment )
 
    , ci.nurse_comment =concat(trim(userid) , "-", format(SCRIPT_RUN,"dd-mmm-yyyy hh:mm:ss;;q"),"--", trim(upd_price->row[1 ].nc)
                       , "******" ,ci.nurse_comment )
    ,ci.updt_dt_tm = cnvtdatetime (curdate ,curtime )
;    ,ci.charge_name = "test"
;	ci.rcm_comment = "",
;	ci.nurse_comment = "",
;	ci.dhpo_comment = "",
;	ci.charge_name = ""
   WHERE (ci.order_id = order_id )
  ;end update
  COMMIT
ENDIF
 
 IF ((charge_id > 0 ) )
  UPDATE FROM (CUST_RCM_AUTH_STATUS ci )
   SET
     ci.rcm_comment = concat(trim(userid) , "-", format(SCRIPT_RUN,"dd-mmm-yyyy hh:mm:ss;;q"),"--", trim(upd_price->row[1 ].cc)
                       , "******" ,ci.rcm_comment )
 
    , ci.nurse_comment =concat(trim(userid) , "-", format(SCRIPT_RUN,"dd-mmm-yyyy hh:mm:ss;;q"),"--", trim(upd_price->row[1 ].nc)
                       , "******" ,ci.nurse_comment )
 
    ,ci.updt_dt_tm = cnvtdatetime
   WHERE (ci.charge_id = charge_id )
  ;end update
  COMMIT
ENDIF
 
 
 SET record_data->db_update_status = "S"
 SET record_data->status_data.status = "S"
 SET _memory_reply_string = cnvtrectojson (record_data )
 call echorecord(record_data)
 FREE RECORD record_data
END GO
