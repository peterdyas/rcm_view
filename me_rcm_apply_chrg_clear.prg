DROP PROGRAM me_rcm_apply_chrg_clear GO
CREATE PROGRAM me_rcm_apply_chrg_clear
 prompt
	"Pft Charge ID" = ""
 
 
with PFT_CHARGE_ID
 
 
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
 DECLARE chargeid = vc WITH protect
 IF ((value ( $PFT_CHARGE_ID ) > "" ) )
  SET chargeid = build2 ("o.order_id in (" , $PFT_CHARGE_ID ,")" )
 ELSE
  SET chargeid = "SKIP"
 ENDIF
 CALL echo (chargeid )
 
 
 ;end select
 FREE RECORD charge
 RECORD charge (
   1 chrg_cnt = i4
   1 qual [* ]
     2 chrg_id = f8
     2 order_id = f8
     2 rcm_order_id = f8
     2 chrg_status = vc
 
 )
 
 
 SET cnt = 0
 
 if (chargeid != "SKIP")
 
 SELECT INTO "nl:"
  cr.payment_status
  FROM orders o  ,cust_rcm_Auth_status cr
 
  WHERE  parser (chargeid )
  and outerjoin( o.order_id) =   cr.order_id
  DETAIL
   cnt +=1 ,
   stat = alterlist (charge->qual ,cnt ) ,
   charge->qual[cnt ].chrg_id = cr.charge_id,
   charge->qual[cnt ].order_id = o.order_id,
   charge->qual[cnt ].rcm_order_id = cr.order_id,
   charge->qual[cnt ].chrg_status = cr.payment_status,
   charge->chrg_cnt = cnt
  WITH nocounter
 ;end select
 ELSE
 SET record_data->status_data.status = "F"
 ENDIF
 
 
 
 call echorecord(charge)
 FOR (x = 1 TO charge->chrg_cnt )
 
  if (charge->qual[x].rcm_order_id > 0)
 
	 update into cust_rcm_Auth_status cr1
	 set
	  cr1.payment_status = ""
	 where cr1.order_id= charge->qual[x].order_id
	 COMMIT
 
 
 else
	 insert into cust_rcm_Auth_status cr2
	 set
	 cr2.order_id= charge->qual[x].order_id,
	 cr2.payment_status = ""
	  COMMIT
 endif
 
 
 ENDFOR
 
 
 SET record_data->db_update_status = "S"
 SET record_data->status_data.status = "S"
 SET _memory_reply_string = cnvtrectojson (record_data )
 call echorecord(record_data)
 FREE RECORD record_data
END GO
