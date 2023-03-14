drop program CUST_EKM_ORD_ACTIVATE go
create program CUST_EKM_ORD_ACTIVATE
 
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 ; Variables available to this program
;   event_repeat_index       = i4  ---> The index into the list of the current element being checked.
;
;   link_accessionid         = f8  ---> The accession_id from the linked Logic Template.
;   link_orderid             = f8  ---> The order_id from the linked Logic Template.
;   link_encntrid            = f8  ---> The encntr_id from the linked Logic Template.
;   link_personid            = f8  ---> The person_id from the linked Logic Template.
;   link_taskassaycd         = f8  ---> The task_assay_cd from the linked Logic Template.
;   link_clineventid         = f8  ---> The clinical_event_id from the linked Logic Template.
;
;   log_accessionid          = f8  ---> The accession_id identified by this template, if applicable.
;   log_orderid              = f8  ---> The order_id identified by this template, if applicable.
;   log_encntrid             = f8  ---> The encntr_id identified by this template, if applicable.
;   log_personid             = f8  ---> The person_id identified by this template, if applicable.
;   log_taskassaycd          = f8  ---> The task_assay_cd identified by this template, if applicable.
;   log_clineventid          = f8  ---> The clinical_event_id identified by this template, if applicable.
;   log_message              = vc  ---> Message that will appear in EKS_MONITOR for this template.
;   log_misc1                = vc  ---> This will store the result being passed back to the Rule.
;
;   eksrequest               = f8 ---> The request number of the triggering request.
;   retval                   = i4 ---> The return value that must be set by the CCL program being executed.
;                                       -1 = SCRIPT FAILED
;                                        0 = FALSE
;                                        1 = TRUE
;                                      100 = TRUE for Rule Template
;
 
; CONSTANTS
declare start_time                   = dq8  with private, noconstant(cnvtdatetime(curdate,curtime3))
declare SCRIPT_NAME                  = c18  with protect, constant("cust_ekm_ord_activate")
declare SCRIPT_VERSION               = c21  with protect, constant("000 14/03/2023 pd014596")
declare FAILED                       = i4   with protect, constant (-1);script failed
declare FALSE                        = i4   with protect, constant (0) ;false
declare TRUE                         = i4   with protect, constant (1) ;TRUE
declare TRUE_RULE                    = i4   with protect, constant (100) ;TRUE for rule template
declare SUCCESS                      = i4   with protect, constant (1)
declare NOT_SUCCESS                  = i4   with protect, constant (0)
 
; Error message declarations.'
 
declare errorMsg            = vc with protect, noconstant("")
declare errorCd             = i4 with protect, noconstant(0)
declare log_misc1           = vc
declare log_misc2           = vc
/**************************************************************
; DVDev Start Coding
**************************************************************/
set log_misc1         = ""
set log_misc2         = ""
set retval            = FAILED
declare x=I2
declare fin_class = vc

 SET log_orderid = trigger_orderid
 SET log_personid = trigger_personid
;  SET log_orderid = 310241089.0 ;trigger_orderid
; SET log_personid = 18258904.0 ;trigger_personid
 
SELECT INTO "nl:"
from
 person p ,
 person_plan_reltn ppr ,
 health_plan hp
PLAN p
  WHERE p.person_id = log_personid
JOIN ppr
   WHERE ppr.person_id = p.person_id
   AND ppr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
   AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
JOIN hp
   WHERE hp.health_plan_id = ppr.health_plan_id
detail
fin_class = uar_get_code_display(hp.financial_class_cd)
with nocounter
 
select ord_id = cnvtstring(ci.order_id) from orders o , cust_rcm_auth_status ci 


plan o
where o.order_id =  log_orderid

join ci
where outerjoin( o.order_id) =   ci.order_id
detail
 call echo(fin_class)
 call echo(ci.auth_status)
 
if (o.order_id > 0)
	if (fin_class != "Self Pay" and ci.auth_status ="Not Covered" and ci.payment_status != "Payment Cleared" and ci.payment_status != "Payment Not Required")
		log_misc1 = " is not covered. Please obtain financial clearance before proceeding."
	elseif (fin_class != "Self Pay" and ci.auth_status = "Auth Required" and ci.payment_status != "Payment Cleared" and ci.payment_status != "Payment Not Required" )
		log_misc1 = " is not approved yet. Please obtain approval and financial clearance before proceeding."
	elseif (fin_class != "Self Pay" and ci.auth_status = "" and ci.payment_status != "Overide" and ci.payment_status != "Payment Cleared" and ci.payment_status != "Payment Not Required"  )
		log_misc1 = " has no approval status. Please validate with the insurance team."
	elseif(ci.payment_status ="Payment Due")
		log_misc1 = " has no financial clearance. Please refer patient back to the PR staff."
	elseif     (fin_class = "Self Pay" and ci.payment_status != "Overide" and ci.payment_status !="Payment Due" and ci.payment_status != "Payment Not Required")
		log_misc1 = " patient is Self Pay please check for payment before service."
	elseif(fin_class = "Self Pay" and ci.payment_status =" ")
		log_misc1 = " patient is Self Pay service is not overiden."
	elseif(fin_class != "Self Pay" and ci.payment_status =" ")
		log_misc1 = " patient is insurnace and has outstanding but service is not overiden."
	else
		log_misc1 = "N"
	endif
else
		 log_misc1 = "N"
endif
 
 
 
 
with nocounter
 
if (log_misc1 != "")
 
       set retval = TRUE_RULE
       set log_message = "Calculated Successfully"
else
       set retval = FALSE
       set log_message = "Calculation Failed"
endif
 
 call echo("log_misc1")
 call echo(log_misc1)
 set log_misc2 = log_misc1
 
 ;Check for any CCL errors
set errorCd = error(errorMsg,0)
if (errorCd != 0)
    set log_message = concat("SCRIPT FAILURE(Get result value from clinical_event table):  ", errorMsg)
    set retval = FALSE
    go to EXIT_SCRIPT
endif
;
 
 
call echo(build("End of script. Elapsed time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),start_time,5)))
;
 
#EXIT_SCRIPT
   call echo(build("log_misc1 .....", log_misc1))
   call echo(build("log_message ...", log_message))
   call echo(build("retval ........", retval))
 
 
end
go
;
;CUST_EKM_ORD_ACTIVATE go
 
