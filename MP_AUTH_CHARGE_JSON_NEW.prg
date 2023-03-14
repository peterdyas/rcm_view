drop program MP_AUTH_CHARGE_JSON_NEW:dba go
create program MP_AUTH_CHARGE_JSON_NEW:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Person Id:" = 27466041.00
	, "User Id:" = 0
	, "Search Begin Date" = CURDATE
	, "Search End Date" = CURDATE
 
 
with OUTDEV, ENCOUNTERID, USERID, PSDATE, PEDATE
 
DECLARE 320_priceupdate = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,320 ,"PRICEUPDATE"))
declare begDate = dq8 with protect
declare endDate = dq8 with protect
declare begDateParser = vc with protect
declare endDateParser = vc with protect
declare begOrdDateParser = vc with protect
declare endOrdDateParser = vc with protect
declare ncflgParser = vc with protect
declare incdflgParser = vc with protect
declare bohpflgParser = vc with protect
declare bohp_id = f8 with protect
 
 
 
 
 
if($pSDate = "")
	set begDateParser = "1=1"
	set begOrdDateParser = "1=1"
 
else
	set begDate = cnvtdatetime(cnvtdate2($pSDate, "MM/DD/YYYY"),0)
	set begDateParser = "c.service_dt_tm >= cnvtdatetime(begDate)"
	set begOrdDateParser = "o.orig_order_dt_tm >= cnvtdatetime(begDate)"
endif
 
if($pEDate = "")
	set endDateParser = "1=1"
	set endOrdDateParser = "1=1"
else
	set endDate = cnvtdatetime(cnvtdate2($pEDate, "MM/DD/YYYY"),235959)
	;set endDateParser = build2("c.service_dt_tm >= ",begDate)
	;set endDateParser = build2("c.service_dt_tm >= cnvtdatetime(cnvtdate2(", $pEDate, ", 'MM/DD/YYYY'),235959)")
	set endDateParser = "c.service_dt_tm <= cnvtdatetime(endDate)"
	set endOrdDateParser = "o.orig_order_dt_tm <= cnvtdatetime(endDate)"
endif
 
 
free record RECORD_DATA
record RECORD_DATA (
    1 CHARGE_CNT = I4
    1 RESUB_CODE = VC
    1 RESUB_COMMENT = VC
    1 AUTH = VC
    1 CHARGES_ACCESS = i2
    1 SEC_BENEFITS = I4
	1 CHARGE[*]
		2 CHARGE_ID = f8
		2 CHARGE_STATUS = vc
		2 CHARGE_TYPE = vc
	    2 CHARGE_DT_TM = VC
	    2 CHARGE_OUTLIER = i4
		2 CHARGE_NAME = VC
		2 CHARGE_ACT_TYPE = VC
		2 CHARGE_PHYS = VC
		2 CHARGE_PHYS_LICENSE = VC
		2 CHARGE_CODE = VC
		2 CHARGE_CPT = VC
		2 CHARGE_GROSS = F8
		2 CHARGE_NET = F8
		2 CHARGE_PS = F8
		2 CHARGE_CoPay = F8
		2 CHARGE_PS_FULL = F8
		2 CHARGE_VAT = F8
		2 CHARGE_QTY = I4
		2 CHARGE_NC = F8
		2 CHARGE_BALANCE = F8
		2 CHARGE_DISCOUNT = F8
		2 CHARGE_UNAPPLIED_DISCOUNT =F8
		2 CHARGE_RT = VC
		2 CHARGE_AUTH = VC
		2 CHARGE_OB = VC
		2 CHARGE_ATTACH = VC
		2 CHARGE_PAY_TTL = F8
		2 CHARGE_ADJ_TTL = F8
		2 CHARGE_ADJ_PS = F8
		2 CHARGE_ACT_ID = F8
		2 CHARGE_DENIAL = VC
		2 INV_CHARGE_ID = F8
		2 AUTH_QUANTITY = f8
 	    2 AUTH_COMMENT = vc
 	    2 AUTH_COMMENT_OC = vc
	    2 AUTH_DT_TM = vc
	    2 AUTH_ST_DT_TM = vc
	    2 AUTH_STATUS = vc
	    2 PAYMENT_STATUS = vc
	    2 RCM_COMMENT = vc
	    2 USER_COMMENT = vc
 
%i cclsource:status_block.inc
)
 
	set RECORD_DATA->status_data.status = "F"
 
 
	declare org_license = vc with noconstant(""),protect
 
 
	declare action_code = vc with noconstant(" "),protect
	declare action_code_comment = vc with noconstant(" "),protect
	declare search_str = vc with noconstant(" "),protect
 	declare fin_class = vc with noconstant(" "),protect
	DECLARE attach_code = vc WITH noconstant (" " ) ,protect
    DECLARE attach_code_comment = vc WITH noconstant (" " ) ,protect
    DECLARE attach_search_str = vc WITH noconstant (" " ) ,protect
 
 
 
  declare cnt = i4
  declare x = i4
  declare y = i4
  set fin_class = ""
 
 
 declare person_id = f8
 select into "nl:"
 finclass = uar_get_code_display(e.financial_class_cd)
 from
 encounter e
 where e.encntr_id = $ENCOUNTERID
 detail
 person_id = e.person_id
  fin_class = uar_get_code_display(e.financial_class_cd)
 with nocounter
 
 
/**************************************************
 *     Get the order      *
 **************************************************/
 declare charge_desc = vc
 
select into "nl:"
    serv_dt_tm = format(o.active_status_dt_tm ,"dd/mm/yyyy hh:mm;;d")
 
from
orders o,
CUST_RCM_AUTH_STATUS ci,
order_action oa,
prsnl pr ,
person p
 
plan o
where o.person_id = person_id
and  o.active_ind = 1
and o.encntr_id = 0
and not(o.orig_ord_as_flag IN (1 ,2 ) )
and o.orderable_type_flag != 6
and o.template_order_flag = 0
and o.catalog_type_cd !=         2512.00
and parser(begOrdDateParser)
and parser(endOrdDateParser)
and not exists (select 1 from charge cx
                    where cx.order_id = o.order_id)
 
and o.order_status_cd in
(
     ;  2542.00,	Canceled
       2543.00,	;Completed
     ;  2544.00,	Voided
     ;  2545.00,	Discontinued
       2546.00, ;	Future
       2547.00, ;	Incomplete
       2548.00,	;InProcess
       2549.00, ;	On Hold, Med Student
       2550.00,	;Ordered
     643466.00, ;	Pending Complete
       2551.00	;Pending Review
    ;   2552.00,	Suspended
     ;614538.00,	Transfer/Canceled
   ;    2553.00,	Unscheduled
    ; 643467.00,	Voided With Results
 
 
 
)
 
join ci
where outerjoin( o.order_id) =   ci.order_id
 
join oa
where oa.order_id = o.order_id
and oa.action_sequence = 1
 
join pr
where pr.person_id = oa.order_provider_id
 
join p
where p.person_id = o.person_id
and p.active_ind = 1
 
 
 
head report
   cnt = 0
 
head o.order_id
 
	cnt = cnt+1
	if (cnt > size(RECORD_DATA->charge,5))
		stat = alterlist(RECORD_DATA->CHARGE,cnt)
	endif
	charge_desc = TRIM(o.hna_order_mnemonic,3)
    RECORD_DATA->CHARGE[cnt].CHARGE_NAME = charge_desc
detail
    RECORD_DATA->CHARGE[cnt].CHARGE_TYPE = "ORDER"
 
 
foot o.order_id
  RECORD_DATA->CHARGE[cnt].CHARGE_DT_TM =  trim(serv_dt_tm,3)
 
      RECORD_DATA->CHARGE[cnt].CHARGE_ID = o.order_id
      RECORD_DATA->CHARGE[cnt].CHARGE_ACT_ID = 0
      RECORD_DATA->CHARGE[cnt].CHARGE_ACT_TYPE = uar_get_code_display(o.activity_type_cd)
	  RECORD_DATA->CHARGE[cnt].CHARGE_GROSS = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_QTY = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_NET = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_CoPay = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_NC = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_DENIAL = ""
	  RECORD_DATA->CHARGE[cnt].CHARGE_PS = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_PS_FULL = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_STATUS = ci.auth_status
	  RECORD_DATA->CHARGE[cnt].INV_CHARGE_ID = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_RT = ""
	  RECORD_DATA->CHARGE[cnt].CHARGE_AUTH = ""
	  RECORD_DATA->CHARGE[cnt].CHARGE_OB = ""
	  RECORD_DATA->CHARGE[cnt].CHARGE_VAT = 0
	  RECORD_DATA->CHARGE[cnt].CHARGE_ATTACH = " "
	  RECORD_DATA->CHARGE[cnt].CHARGE_PHYS = substring (1 ,50 ,pr.name_full_formatted )
	;  RECORD_DATA->CHARGE[cnt].CHARGE_PHYS_LICENSE = pa.alias
	  RECORD_DATA->CHARGE[cnt].AUTH_COMMENT = ci.auth_comment
	  RECORD_DATA->CHARGE[cnt].AUTH_COMMENT_OC = ci.auth_comment
	  ;RECORD_DATA->CHARGE[cnt].AUTH_STATUS = ci.auth_status
	  RECORD_DATA->CHARGE[cnt].PAYMENT_STATUS = ci.payment_status
	  RECORD_DATA->CHARGE[cnt].AUTH_QUANTITY =  ci.auth_quantity
	  RECORD_DATA->CHARGE[cnt].AUTH_DT_TM = ci.auth_expiry_dt_tm
	  RECORD_DATA->CHARGE[cnt].AUTH_ST_DT_TM = ci.auth_dt_tm
	  RECORD_DATA->CHARGE[cnt].RCM_COMMENT = ci.rcm_comment
	  RECORD_DATA->CHARGE[cnt].USER_COMMENT = ci.nurse_comment
      RECORD_DATA->CHARGE_CNT = CNT
 
 
      call echo(RECORD_DATA->CHARGE[cnt].AUTH_COMMENT)
      x = findstring(nopatstring("User Remarks :"),RECORD_DATA->CHARGE[cnt].AUTH_COMMENT,1,0)
      y = TEXTLEN(RECORD_DATA->CHARGE[cnt].AUTH_COMMENT)
 
      x = cnvtint(x)
      y = cnvtint(y)
 
 
      if(x = 0 and RECORD_DATA->CHARGE[cnt].AUTH_COMMENT_OC  != "Pre Approval not required")
      	RECORD_DATA->CHARGE[cnt].AUTH_COMMENT = ""
 
      elseif( RECORD_DATA->CHARGE[cnt].AUTH_COMMENT_OC  = "Pre Approval not required")
      	RECORD_DATA->CHARGE[cnt].AUTH_STATUS = "Covered under Package"
      else
      	;RECORD_DATA->CHARGE[cnt].AUTH_COMMENT = SUBSTRING(x,y,RECORD_DATA->CHARGE[cnt].AUTH_COMMENT)
      	RECORD_DATA->CHARGE[cnt].AUTH_COMMENT = RECORD_DATA->CHARGE[cnt].AUTH_COMMENT
      	RECORD_DATA->CHARGE[cnt].AUTH_COMMENT_OC ="Updated- Pre Approval not required"
      endif
 
 
 
foot report
	stat = alterlist(RECORD_DATA->CHARGE,cnt)
with nocounter
 
 
 
for (x =1 to   RECORD_DATA->CHARGE_CNT)
 
	SELECT into "nl:"
	FROM
	orders o
	, bill_item b
	, bill_item_modifier cdm
	, price_sched_items psi
	plan o where o.order_id = RECORD_DATA->CHARGE[x].CHARGE_ID
	join b where b.ext_parent_reference_id = o.catalog_cd
	and b.active_ind=1
	join cdm where cdm.bill_item_id=b.bill_item_id
	and cdm.active_ind=1
	and cdm.bill_item_type_cd =           3459.00 ;BILLCODE_VAR
	and cdm.key1_id =      615214.00 ;CPTKey
	and cdm.key6 != ""
	join psi where psi.bill_item_id = cdm.bill_item_id
	and psi.price != 0
	detail
	RECORD_DATA->CHARGE[x].CHARGE_CODE = cdm.key6
with nocounter
 
 
	select
	o.oe_field_display_value
	from
	order_Detail o
	where o.order_id = RECORD_DATA->CHARGE[x].CHARGE_ID
	and o.oe_field_id =   277304455.00
	detail
	RECORD_DATA->CHARGE[x].CHARGE_CODE = o.oe_field_display_value
	with nocounter
 
endfor
 
;Set public memory variable equal to our XML string
set RECORD_DATA->status_data.status = "S"
;call echoxml(record_data,"ccluserdir:petermpagetest23.xml")
call echorecord(record_data)
set _Memory_Reply_String = CNVTRECTOJSON(RECORD_DATA)
 
end
go
