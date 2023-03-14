DROP PROGRAM cme_rcm_chg_vw_driver :dba GO
CREATE PROGRAM cme_rcm_chg_vw_driver :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Person Id:" = 0.0 ,
  "Encounter Id:" = 0.0 ,
  "User Id:" = 0.00 ,
  "Static Content Location:" = ""
  WITH outdev ,personid ,encntrid ,userid ,sourcedir
 FREE RECORD criterion
 RECORD criterion (
   1 prsnl_id = f8
   1 encntrid = f8
   1 personid = f8
   1 position_cd = f8
   1 admitdate = vc
   1 dischdate = vc
   1 bohp_cnt = i4
   1 sec_ben = i4
   1 sec_reclc = i4
   1 sec_down = i4
   1 sec_commit = i4
   1 sec_vat = i4
   1 sec_nc = i4
   1 sec_del = i4
   1 sec_dis = i4
   1 sec_bat = i4
   1 sec_rsc = i4
   1 sec_rsi = i4
   1 sec_clm = i4
   1 sec_cat = i4
   1 sec_cdl = i4
   1 sec_cob = i4
   1 sec_cvt = i4
   1 sec_crs = i4
   1 drg_auth_status = vc
   1 payment_status = vc
   1 drg_denial_desc = vc
   1 user_denial_desc = vc
   1 drg_code = vc
   1 drg_name = vc
   1 drg_soi = vc
   1 drg_rom = vc
   1 drg_weight = vc
   1 diag_cnt = i4
   1 diag_qual[*]
	2 icd_code = vc
	2 icd_name = vc
	2 type = vc
	2 poa = vc
	2 dt_tm = vc
   1 pro_cnt = i4
   1 pro_qual [*]
   	2 cpt_code = vc
   	2 cpt_desc = vc
   	2 cpt_check = vc
   1 bohp [* ]
     2 bohp_name = vc
     2 bohp_id = f8
   1 static_content = vc
   1 price_rvu_up_access = i2
   1 webservurl = vc
   1 domain = vc
   1 runby = vc
   1 patient_info
     2 sex_cd = f8
     2 dob = vc
   1 category_mean = vc
   1 locale_id = vc
   1 be_cnt = i4
   1 belist [* ]
     2 be_name = vc
     2 be_id = f8
     2 selected = i2
   1 fac_cnt = i4
   1 faclist [* ]
     2 fac_name = vc
     2 fac_id = f8
     2 selected = i2
     2 be_id = f8
   1 bctype_cnt = i4
   1 codetypes [* ]
     2 display_name = vc
     2 code_value = f8
   1 ctype_cnt = i4
   1 categorytypes [* ]
     2 display_name = vc
     2 code_value = f8
   1 pricesch_cnt = i4
   1 priceschlist [* ]
     2 price_sch_display = vc
     2 price_sch_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,protect
 DECLARE current_time_zone = i4 WITH constant (datetimezonebyname (curtimezone ) ) ,protect
 DECLARE ending_date_time = dq8 WITH constant (cnvtdatetime ("31-DEC-2100" ) ) ,protect
 DECLARE bind_cnt = i4 WITH constant (50 ) ,protect
 DECLARE lower_bound_date = vc WITH constant ("01-JAN-1800 00:00:00.00" ) ,protect
 DECLARE upper_bound_date = vc WITH constant ("31-DEC-2100 23:59:59.99" ) ,protect
 DECLARE codelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnllistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE phonelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE code_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE phone_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_cnt = i4 WITH noconstant (0 ) ,protect
 DECLARE mpc_ap_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_doc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mdoc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_rad_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_txt_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_num_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_immun_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_med_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_date_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_done_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mbo_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_procedure_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_grp_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE eventclasscdpopulated = i2 WITH protect ,noconstant (0 )
 DECLARE getorgsecurityflag (null ) = i2 WITH protect
 DECLARE cclimpersonation (null ) = null WITH protect
 DECLARE invalid_cd = f8 WITH public ,noconstant (0.0 )
 SET stat = uar_get_meaning_by_codeset (24451 ,"INVALID" ,1 ,invalid_cd )
 DECLARE self_code = f8 WITH public ,noconstant (0.0 )
 SET stat = uar_get_meaning_by_codeset (354 ,"SELFPAY" ,1 ,self_code )
 declare PUBLIC::Scrub_Html_Special_Chars(text_str = vc) = vc with protect
 /*********************************************************************************************************************************
* Scrub_Html_Special_Chars                                                                                                    *
*********************************************************************************************************************************/
/**
Replace/scrub special HTML characters '&', '<' and '>' with corresponding "RTF safe" HTML names '&amp;', '&lt;' and '&gt;'.
@param text_str
  The text to be scrubbed for special HTML characters.
@returns vc
  The scrubbed text.
*/
subroutine PUBLIC::Scrub_Html_Special_Chars(text_str)
  declare retval = vc with protect, noconstant(text_str)
  ;Replace '&' first so that the escape character is not replaced further down the process.
  set retval = replace(retval, "&", "&amp;")
  set retval = replace(retval, "<", "&lt;")
  set retval = replace(retval, ">", "&gt;")
  set retval = replace(retval, "  ", " ")
  set retval = replace(retval, "   ", " ")
   set retval = replace(retval, "    ", " ")
  return(retval)
end
 
 
 
 SUBROUTINE  (addcodetolist (code_value =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  IF ((code_value != 0 ) )
   IF ((((codelistcnt = 0 ) ) OR ((locateval (code_idx ,1 ,codelistcnt ,code_value ,record_data->
    codes[code_idx ].code ) <= 0 ) )) )
    SET codelistcnt +=1
    SET stat = alterlist (record_data->codes ,codelistcnt )
    SET record_data->codes[codelistcnt ].code = code_value
    SET record_data->codes[codelistcnt ].sequence = uar_get_collation_seq (code_value )
    SET record_data->codes[codelistcnt ].meaning = uar_get_code_meaning (code_value )
    SET record_data->codes[codelistcnt ].display = uar_get_code_display (code_value )
    SET record_data->codes[codelistcnt ].description = uar_get_code_description (code_value )
    SET record_data->codes[codelistcnt ].code_set = uar_get_code_set (code_value )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (outputcodelist (record_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputCodeList() @deprecated" ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (addpersonneltolist (prsnl_id =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  CALL addpersonneltolistwithdate (prsnl_id ,record_data ,current_date_time )
 END ;Subroutine
 SUBROUTINE  (addpersonneltolistwithdate (prsnl_id =f8 (val ) ,record_data =vc (ref ) ,active_date =
  f8 (val ) ) =null WITH protect )
  DECLARE personnel_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) )
  IF ((((active_date = null ) ) OR ((active_date = 0.0 ) )) )
   SET active_date = current_date_time
  ENDIF
  IF ((prsnl_id != 0 ) )
   IF ((((prsnllistcnt = 0 ) ) OR ((locateval (prsnl_idx ,1 ,prsnllistcnt ,prsnl_id ,record_data->
    prsnl[prsnl_idx ].id ,active_date ,record_data->prsnl[prsnl_idx ].active_date ) <= 0 ) )) )
    SET prsnllistcnt +=1
    IF ((prsnllistcnt > size (record_data->prsnl ,5 ) ) )
     SET stat = alterlist (record_data->prsnl ,(prsnllistcnt + 9 ) )
    ENDIF
    SET record_data->prsnl[prsnllistcnt ].id = prsnl_id
    IF ((validate (record_data->prsnl[prsnllistcnt ].active_date ) != 0 ) )
     SET record_data->prsnl[prsnllistcnt ].active_date = active_date
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (outputpersonnellist (report_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputPersonnelList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE prsnl_name_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) ) ,
  protect
  DECLARE active_date_ind = i2 WITH protect ,noconstant (0 )
  DECLARE filteredcnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnl_seq = i4 WITH protect ,noconstant (0 )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  IF ((prsnllistcnt > 0 ) )
   SELECT INTO "nl:"
    FROM (prsnl p ),
     (left
     JOIN person_name pn ON (pn.person_id = p.person_id )
     AND (pn.name_type_cd = prsnl_name_type_cd )
     AND (pn.active_ind = 1 ) )
    PLAN (p
     WHERE expand (idx ,1 ,size (report_data->prsnl ,5 ) ,p.person_id ,report_data->prsnl[idx ].id )
     )
     JOIN (pn )
    ORDER BY p.person_id ,
     pn.end_effective_dt_tm DESC
    HEAD REPORT
     prsnl_seq = 0 ,
     active_date_ind = validate (report_data->prsnl[1 ].active_date ,0 )
    HEAD p.person_id
     IF ((active_date_ind = 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (pn
        .name_full ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (pn
        .name_first ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_middle = trim (pn
        .name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn
        .name_last ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3
        ) ,report_data->prsnl[prsnl_seq ].provider_name.initials = trim (pn.name_initials ,3 ) ,
       report_data->prsnl[prsnl_seq ].provider_name.title = trim (pn.name_initials ,3 )
      ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3 )
      ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,report_data
       ->prsnl[prsnl_seq ].provider_name.name_last = trim (p.name_last ,3 ) ,report_data->prsnl[
       prsnl_seq ].provider_name.username = trim (p.username ,3 )
      ENDIF
     ENDIF
    DETAIL
     IF ((active_date_ind != 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      WHILE ((prsnl_seq > 0 ) )
       IF ((report_data->prsnl[prsnl_seq ].active_date BETWEEN pn.beg_effective_dt_tm AND pn
       .end_effective_dt_tm ) )
        IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].person_name_id = pn.person_name_id ,
         report_data->prsnl[prsnl_seq ].beg_effective_dt_tm = pn.beg_effective_dt_tm ,report_data->
         prsnl[prsnl_seq ].end_effective_dt_tm = pn.end_effective_dt_tm ,report_data->prsnl[
         prsnl_seq ].provider_name.name_full = trim (pn.name_full ,3 ) ,report_data->prsnl[prsnl_seq
         ].provider_name.name_first = trim (pn.name_first ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_middle = trim (pn.name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_last = trim (pn.name_last ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.username = trim (p.username ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name
         .initials = trim (pn.name_initials ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.title
         = trim (pn.name_initials ,3 )
        ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3
          ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn.name_last ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3 )
        ENDIF
        ,
        IF ((report_data->prsnl[prsnl_seq ].active_date = current_date_time ) ) report_data->prsnl[
         prsnl_seq ].active_date = 0
        ENDIF
       ENDIF
       ,prsnl_seq = locateval (idx ,(prsnl_seq + 1 ) ,prsnllistcnt ,p.person_id ,report_data->prsnl[
        idx ].id )
      ENDWHILE
     ENDIF
    FOOT REPORT
     stat = alterlist (report_data->prsnl ,prsnllistcnt )
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"OutputPersonnelList" ,1 ,0 ,report_data )
   IF ((active_date_ind != 0 ) )
    SELECT INTO "nl:"
     end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm ,
     person_name_id = report_data->prsnl[d.seq ].person_name_id ,
     prsnl_id = report_data->prsnl[d.seq ].id
     FROM (dummyt d WITH seq = size (report_data->prsnl ,5 ) )
     ORDER BY end_effective_dt_tm DESC ,
      person_name_id ,
      prsnl_id
     HEAD REPORT
      filteredcnt = 0 ,
      idx = size (report_data->prsnl ,5 ) ,
      stat = alterlist (report_data->prsnl ,(idx * 2 ) )
     HEAD end_effective_dt_tm
      donothing = 0
     HEAD prsnl_id
      idx +=1 ,filteredcnt +=1 ,report_data->prsnl[idx ].id = report_data->prsnl[d.seq ].id ,
      report_data->prsnl[idx ].person_name_id = report_data->prsnl[d.seq ].person_name_id ,
      IF ((report_data->prsnl[d.seq ].person_name_id > 0.0 ) ) report_data->prsnl[idx ].
       beg_effective_dt_tm = report_data->prsnl[d.seq ].beg_effective_dt_tm ,report_data->prsnl[idx ]
       .end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm
      ELSE report_data->prsnl[idx ].beg_effective_dt_tm = cnvtdatetime ("01-JAN-1900" ) ,report_data
       ->prsnl[idx ].end_effective_dt_tm = cnvtdatetime ("31-DEC-2100" )
      ENDIF
      ,report_data->prsnl[idx ].provider_name.name_full = report_data->prsnl[d.seq ].provider_name.
      name_full ,report_data->prsnl[idx ].provider_name.name_first = report_data->prsnl[d.seq ].
      provider_name.name_first ,report_data->prsnl[idx ].provider_name.name_middle = report_data->
      prsnl[d.seq ].provider_name.name_middle ,report_data->prsnl[idx ].provider_name.name_last =
      report_data->prsnl[d.seq ].provider_name.name_last ,report_data->prsnl[idx ].provider_name.
      username = report_data->prsnl[d.seq ].provider_name.username ,report_data->prsnl[idx ].
      provider_name.initials = report_data->prsnl[d.seq ].provider_name.initials ,report_data->prsnl[
      idx ].provider_name.title = report_data->prsnl[d.seq ].provider_name.title
     FOOT REPORT
      stat = alterlist (report_data->prsnl ,idx ) ,
      stat = alterlist (report_data->prsnl ,filteredcnt ,0 )
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"FilterPersonnelList" ,1 ,0 ,report_data )
   ENDIF
  ENDIF
  CALL log_message (build ("Exit OutputPersonnelList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (addphonestolist (prsnl_id =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  IF ((prsnl_id != 0 ) )
   IF ((((phonelistcnt = 0 ) ) OR ((locateval (phone_idx ,1 ,phonelistcnt ,prsnl_id ,record_data->
    phone_list[prsnl_idx ].person_id ) <= 0 ) )) )
    SET phonelistcnt +=1
    IF ((phonelistcnt > size (record_data->phone_list ,5 ) ) )
     SET stat = alterlist (record_data->phone_list ,(phonelistcnt + 9 ) )
    ENDIF
    SET record_data->phone_list[phonelistcnt ].person_id = prsnl_id
    SET prsnl_cnt +=1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (outputphonelist (report_data =vc (ref ) ,phone_types =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputPhoneList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE personcnt = i4 WITH protect ,constant (size (report_data->phone_list ,5 ) )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  DECLARE idx2 = i4 WITH protect ,noconstant (0 )
  DECLARE idx3 = i4 WITH protect ,noconstant (0 )
  DECLARE phonecnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnlidx = i4 WITH protect ,noconstant (0 )
  IF ((phonelistcnt > 0 ) )
   SELECT
    IF ((size (phone_types->phone_codes ,5 ) = 0 ) )
     phone_sorter = ph.phone_id
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
     AND (ph.active_ind = 1 )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ELSE
     phone_sorter = locateval (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,
      phone_types->phone_codes[idx2 ].phone_cd )
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
     AND (ph.active_ind = 1 )
     AND expand (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,phone_types->
      phone_codes[idx2 ].phone_cd )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ENDIF
    INTO "nl:"
    HEAD ph.parent_entity_id
     phonecnt = 0 ,prsnlidx = locateval (idx3 ,1 ,personcnt ,ph.parent_entity_id ,report_data->
      phone_list[idx3 ].person_id )
    HEAD phone_sorter
     phonecnt +=1 ,
     IF ((size (report_data->phone_list[prsnlidx ].phones ,5 ) < phonecnt ) ) stat = alterlist (
       report_data->phone_list[prsnlidx ].phones ,(phonecnt + 5 ) )
     ENDIF
     ,report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_id = ph.phone_id ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type_cd = ph.phone_type_cd ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type = uar_get_code_display (ph.phone_type_cd ) ,
     report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_num = formatphonenumber (ph
      .phone_num ,ph.phone_format_cd ,ph.extension )
    FOOT  ph.parent_entity_id
     stat = alterlist (report_data->phone_list[prsnlidx ].phones ,phonecnt )
    WITH nocounter ,expand = value (evaluate (floor (((personcnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
   ;end select
   SET stat = alterlist (report_data->phone_list ,prsnl_cnt )
   CALL error_and_zero_check_rec (curqual ,"PHONE" ,"OutputPhoneList" ,1 ,0 ,report_data )
  ENDIF
  CALL log_message (build ("Exit OutputPhoneList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putstringtofile (svalue =vc (val ) ) =null WITH protect )
  CALL log_message ("In PutStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  IF ((validate (_memory_reply_string ) = 1 ) )
   SET _memory_reply_string = svalue
  ELSE
   FREE RECORD putrequest
   RECORD putrequest (
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line [* ]
       2 linedata = vc
     1 overflowpage [* ]
       2 ofr_qual [* ]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = svalue
   SET putrequest->document_size = size (putrequest->document )
   EXECUTE eks_put_source WITH replace ("REQUEST" ,putrequest ) ,
   replace ("REPLY" ,putreply )
  ENDIF
  CALL log_message (build ("Exit PutStringToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putjsonrecordtofile (record_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In PutJSONRecordToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  CALL putstringtofile (cnvtrectojson (record_data ) )
  CALL log_message (build ("Exit PutJSONRecordToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (getparametervalues (index =i4 (val ) ,value_rec =vc (ref ) ) =null WITH protect )
  DECLARE par = vc WITH noconstant ("" ) ,protect
  DECLARE lnum = i4 WITH noconstant (0 ) ,protect
  DECLARE num = i4 WITH noconstant (1 ) ,protect
  DECLARE cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE cnt2 = i4 WITH noconstant (0 ) ,protect
  DECLARE param_value = f8 WITH noconstant (0.0 ) ,protect
  DECLARE param_value_str = vc WITH noconstant ("" ) ,protect
  SET par = reflect (parameter (index ,0 ) )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo (par )
  ENDIF
  IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
   SET param_value = parameter (index ,0 )
   IF ((param_value > 0 ) )
    SET value_rec->cnt +=1
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = param_value
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
   SET param_value_str = parameter (index ,0 )
   IF ((trim (param_value_str ,3 ) != "" ) )
    SET value_rec->cnt +=1
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "L" ) )
   SET lnum = 1
   WHILE ((lnum > 0 ) )
    SET par = reflect (parameter (index ,lnum ) )
    IF ((par != " " ) )
     IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
      SET param_value = parameter (index ,lnum )
      IF ((param_value > 0 ) )
       SET value_rec->cnt +=1
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = param_value
      ENDIF
      SET lnum +=1
     ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
      SET param_value_str = parameter (index ,lnum )
      IF ((trim (param_value_str ,3 ) != "" ) )
       SET value_rec->cnt +=1
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
      ENDIF
      SET lnum +=1
     ENDIF
    ELSE
     SET lnum = 0
    ENDIF
   ENDWHILE
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getlookbackdatebytype (units =i4 (val ) ,flag =i4 (val ) ) =dq8 WITH protect )
  DECLARE looback_date = dq8 WITH noconstant (cnvtdatetime ("01-JAN-1800 00:00:00" ) )
  IF ((units != 0 ) )
   CASE (flag )
    OF 1 :
     SET looback_date = cnvtlookbehind (build (units ,",H" ) ,cnvtdatetime (sysdate ) )
    OF 2 :
     SET looback_date = cnvtlookbehind (build (units ,",D" ) ,cnvtdatetime (sysdate ) )
    OF 3 :
     SET looback_date = cnvtlookbehind (build (units ,",W" ) ,cnvtdatetime (sysdate ) )
    OF 4 :
     SET looback_date = cnvtlookbehind (build (units ,",M" ) ,cnvtdatetime (sysdate ) )
    OF 5 :
     SET looback_date = cnvtlookbehind (build (units ,",Y" ) ,cnvtdatetime (sysdate ) )
   ENDCASE
  ENDIF
  RETURN (looback_date )
 END ;Subroutine
 SUBROUTINE  (getcodevaluesfromcodeset (evt_set_rec =vc (ref ) ,evt_cd_rec =vc (ref ) ) =null WITH
  protect )
  DECLARE csidx = i4 WITH noconstant (0 )
  SELECT DISTINCT INTO "nl:"
   FROM (v500_event_set_explode vese )
   WHERE expand (csidx ,1 ,evt_set_rec->cnt ,vese.event_set_cd ,evt_set_rec->qual[csidx ].value )
   DETAIL
    evt_cd_rec->cnt +=1 ,
    stat = alterlist (evt_cd_rec->qual ,evt_cd_rec->cnt ) ,
    evt_cd_rec->qual[evt_cd_rec->cnt ].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  (geteventsetnamesfromeventsetcds (evt_set_rec =vc (ref ) ,evt_set_name_rec =vc (ref )
  ) =null WITH protect )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (v500_event_set_code v )
   WHERE expand (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
   HEAD REPORT
    cnt = 0 ,
    evt_set_name_rec->cnt = evt_set_rec->cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_rec->cnt )
   DETAIL
    pos = locateval (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     cnt +=1 ,evt_set_name_rec->qual[pos ].value = v.event_set_name ,pos = locateval (index ,(pos +
      1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_name_rec->cnt -=1 ,stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt ,(
      pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[
      index ].value )
    ENDWHILE
    ,evt_set_name_rec->cnt = cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
 END ;Subroutine
 SUBROUTINE  (returnviewertype (eventclasscd =f8 (val ) ,eventid =f8 (val ) ) =vc WITH protect )
  CALL log_message ("In returnViewerType()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  IF ((eventclasscdpopulated = 0 ) )
   SET mpc_ap_type_cd = uar_get_code_by ("MEANING" ,53 ,"AP" )
   SET mpc_doc_type_cd = uar_get_code_by ("MEANING" ,53 ,"DOC" )
   SET mpc_mdoc_type_cd = uar_get_code_by ("MEANING" ,53 ,"MDOC" )
   SET mpc_rad_type_cd = uar_get_code_by ("MEANING" ,53 ,"RAD" )
   SET mpc_txt_type_cd = uar_get_code_by ("MEANING" ,53 ,"TXT" )
   SET mpc_num_type_cd = uar_get_code_by ("MEANING" ,53 ,"NUM" )
   SET mpc_immun_type_cd = uar_get_code_by ("MEANING" ,53 ,"IMMUN" )
   SET mpc_med_type_cd = uar_get_code_by ("MEANING" ,53 ,"MED" )
   SET mpc_date_type_cd = uar_get_code_by ("MEANING" ,53 ,"DATE" )
   SET mpc_done_type_cd = uar_get_code_by ("MEANING" ,53 ,"DONE" )
   SET mpc_mbo_type_cd = uar_get_code_by ("MEANING" ,53 ,"MBO" )
   SET mpc_procedure_type_cd = uar_get_code_by ("MEANING" ,53 ,"PROCEDURE" )
   SET mpc_grp_type_cd = uar_get_code_by ("MEANING" ,53 ,"GRP" )
   SET mpc_hlatyping_type_cd = uar_get_code_by ("MEANING" ,53 ,"HLATYPING" )
   SET eventclasscdpopulated = 1
  ENDIF
  DECLARE sviewerflag = vc WITH protect ,noconstant ("" )
  CASE (eventclasscd )
   OF mpc_ap_type_cd :
    SET sviewerflag = "AP"
   OF mpc_doc_type_cd :
   OF mpc_mdoc_type_cd :
   OF mpc_rad_type_cd :
    SET sviewerflag = "DOC"
   OF mpc_txt_type_cd :
   OF mpc_num_type_cd :
   OF mpc_immun_type_cd :
   OF mpc_med_type_cd :
   OF mpc_date_type_cd :
   OF mpc_done_type_cd :
    SET sviewerflag = "EVENT"
   OF mpc_mbo_type_cd :
    SET sviewerflag = "MICRO"
   OF mpc_procedure_type_cd :
    SET sviewerflag = "PROC"
   OF mpc_grp_type_cd :
    SET sviewerflag = "GRP"
   OF mpc_hlatyping_type_cd :
    SET sviewerflag = "HLA"
   ELSE
    SET sviewerflag = "STANDARD"
  ENDCASE
  IF ((eventclasscd = mpc_mdoc_type_cd ) )
   SELECT INTO "nl:"
    c2.*
    FROM (clinical_event c1 ),
     (clinical_event c2 )
    PLAN (c1
     WHERE (c1.event_id = eventid ) )
     JOIN (c2
     WHERE (c1.parent_event_id = c2.event_id )
     AND (c2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100" ) ) )
    HEAD c2.event_id
     IF ((c2.event_class_cd = mpc_ap_type_cd ) ) sviewerflag = "AP"
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL log_message (build ("Exit returnViewerType(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
  RETURN (sviewerflag )
 END ;Subroutine
 SUBROUTINE  (cnvtisodttmtodq8 (isodttmstr =vc ) =dq8 WITH protect )
  DECLARE converteddq8 = dq8 WITH protect ,noconstant (0 )
  SET converteddq8 = cnvtdatetimeutc2 (substring (1 ,10 ,isodttmstr ) ,"YYYY-MM-DD" ,substring (12 ,
    8 ,isodttmstr ) ,"HH:MM:SS" ,4 ,curtimezonedef )
  RETURN (converteddq8 )
 END ;Subroutine
 SUBROUTINE  (cnvtdq8toisodttm (dq8dttm =f8 ) =vc WITH protect )
  DECLARE convertedisodttm = vc WITH protect ,noconstant ("" )
  IF ((dq8dttm > 0.0 ) )
   SET convertedisodttm = build (replace (datetimezoneformat (cnvtdatetime (dq8dttm ) ,
      datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
  ELSE
   SET convertedisodttm = nullterm (convertedisodttm )
  ENDIF
  RETURN (convertedisodttm )
 END ;Subroutine
 SUBROUTINE  getorgsecurityflag (null )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = "SEC_ORG_RELTN" )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
 END ;Subroutine
 SUBROUTINE  (getcomporgsecurityflag (dminfo_name =vc (val ) ) =i2 WITH protect )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = dminfo_name )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
 END ;Subroutine
 SUBROUTINE  (populateauthorizedorganizations (personid =f8 (val ) ,value_rec =vc (ref ) ) =null
  WITH protect )
  DECLARE organization_cnt = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (prsnl_org_reltn por )
   WHERE (por.person_id = personid )
   AND (por.active_ind = 1 )
   AND (por.beg_effective_dt_tm BETWEEN cnvtdatetime (lower_bound_date ) AND cnvtdatetime (sysdate )
   )
   AND (por.end_effective_dt_tm BETWEEN cnvtdatetime (sysdate ) AND cnvtdatetime (upper_bound_date )
   )
   ORDER BY por.organization_id
   HEAD REPORT
    organization_cnt = 0
   DETAIL
    organization_cnt +=1 ,
    IF ((mod (organization_cnt ,20 ) = 1 ) ) stat = alterlist (value_rec->organizations ,(
      organization_cnt + 19 ) )
    ENDIF
    ,value_rec->organizations[organization_cnt ].organizationid = por.organization_id
   FOOT REPORT
    value_rec->cnt = organization_cnt ,
    stat = alterlist (value_rec->organizations ,organization_cnt )
   WITH nocounter
  ;end select
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getuserlogicaldomain (id =f8 ) =f8 WITH protect )
  DECLARE returnid = f8 WITH protect ,noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (prsnl p )
   WHERE (p.person_id = id )
   DETAIL
    returnid = p.logical_domain_id
   WITH nocounter
  ;end select
  RETURN (returnid )
 END ;Subroutine
 SUBROUTINE  (getpersonneloverride (ppr_cd =f8 (val ) ) =i2 WITH protect )
  DECLARE override_ind = i2 WITH protect ,noconstant (0 )
  IF ((ppr_cd <= 0.0 ) )
   RETURN (0 )
  ENDIF
  SELECT INTO "nl:"
   FROM (code_value_extension cve )
   WHERE (cve.code_value = ppr_cd )
   AND (cve.code_set = 331 )
   AND (((cve.field_value = "1" ) ) OR ((cve.field_value = "2" ) ))
   AND (cve.field_name = "Override" )
   DETAIL
    override_ind = 1
   WITH nocounter
  ;end select
  RETURN (override_ind )
 END ;Subroutine
 SUBROUTINE  cclimpersonation (null )
  CALL log_message ("In cclImpersonation()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  EXECUTE secrtl
  DECLARE uar_secsetcontext ((hctx = i4 ) ) = i2 WITH image_axp = "secrtl" ,image_aix =
  "libsec.a(libsec.o)" ,uar = "SecSetContext" ,persist
  DECLARE seccntxt = i4 WITH public
  DECLARE namelen = i4 WITH public
  DECLARE domainnamelen = i4 WITH public
  SET namelen = (uar_secgetclientusernamelen () + 1 )
  SET domainnamelen = (uar_secgetclientdomainnamelen () + 2 )
  SET stat = memalloc (name ,1 ,build ("C" ,namelen ) )
  SET stat = memalloc (domainname ,1 ,build ("C" ,domainnamelen ) )
  SET stat = uar_secgetclientusername (name ,namelen )
  SET stat = uar_secgetclientdomainname (domainname ,domainnamelen )
  SET setcntxt = uar_secimpersonate (nullterm (name ) ,nullterm (domainname ) )
  CALL log_message (build ("Exit cclImpersonation(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 DECLARE log_program_name = vc WITH protect ,noconstant ("" )
 DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
 DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
 DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
 DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
 DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
 DECLARE hsys = i4 WITH protect ,noconstant (0 )
 DECLARE sysstat = i4 WITH protect ,noconstant (0 )
 DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
 DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
 DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle ()
 SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
 DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
 DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
 DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
 DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
 DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
 DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
 DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
 DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
 SELECT INTO "nl:"
  FROM (dm_info dm )
  PLAN (dm
   WHERE (dm.info_domain = crsl_info_domain )
   AND (dm.info_name = curprog ) )
  DETAIL
   IF ((dm.info_char = crsl_logging_on ) ) log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE  (log_message (logmsg =vc ,loglvl =i4 ) =null )
  SET icrslloglvloverrideind = 0
  SET scrsllogtext = ""
  SET scrsllogevent = ""
  SET scrsllogtext = concat ("{{Script::" ,value (log_program_name ) ,"}} " ,logmsg )
  IF ((log_override_ind = 0 ) )
   SET icrslholdloglevel = loglvl
  ELSE
   IF ((crsl_msg_level < loglvl ) )
    SET icrslholdloglevel = crsl_msg_level
    SET icrslloglvloverrideind = 1
   ELSE
    SET icrslholdloglevel = loglvl
   ENDIF
  ENDIF
  IF ((icrslloglvloverrideind = 1 ) )
   SET scrsllogevent = "Script_Override"
  ELSE
   CASE (icrslholdloglevel )
    OF log_level_error :
     SET scrsllogevent = "Script_Error"
    OF log_level_warning :
     SET scrsllogevent = "Script_Warning"
    OF log_level_audit :
     SET scrsllogevent = "Script_Audit"
    OF log_level_info :
     SET scrsllogevent = "Script_Info"
    OF log_level_debug :
     SET scrsllogevent = "Script_Debug"
   ENDCASE
  ENDIF
  SET lcrsluarmsgwritestat = uar_msgwrite (crsl_msg_default ,0 ,nullterm (scrsllogevent ) ,
   icrslholdloglevel ,nullterm (scrsllogtext ) )
  CALL echo (logmsg )
 END ;Subroutine
 SUBROUTINE  (error_message (logstatusblockind =i2 ) =i2 )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   SET reply->status_data.status = "F"
   CALL log_message (serrmsg ,log_level_audit )
   IF ((logstatusblockind = 1 ) )
    CALL populate_subeventstatus ("EXECUTE" ,"F" ,"CCL SCRIPT" ,serrmsg )
   ENDIF
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  RETURN (icrslerroroccured )
 END ;Subroutine
 SUBROUTINE  (error_and_zero_check_rec (qualnum =i4 ,opname =vc ,logmsg =vc ,errorforceexit =i2 ,
  zeroforceexit =i2 ,recorddata =vc (ref ) ) =i2 )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   CALL log_message (serrmsg ,log_level_audit )
   CALL populate_subeventstatus_rec (opname ,"F" ,serrmsg ,logmsg ,recorddata )
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  IF ((icrslerroroccured = 1 )
  AND (errorforceexit = 1 ) )
   SET recorddata->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((qualnum = 0 )
  AND (zeroforceexit = 1 ) )
   SET recorddata->status_data.status = "Z"
   CALL populate_subeventstatus_rec (opname ,"Z" ,"No records qualified" ,logmsg ,recorddata )
   GO TO exit_script
  ENDIF
  RETURN (icrslerroroccured )
 END ;Subroutine
 SUBROUTINE  (error_and_zero_check (qualnum =i4 ,opname =vc ,logmsg =vc ,errorforceexit =i2 ,
  zeroforceexit =i2 ) =i2 )
  RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply ) )
 END ;Subroutine
 SUBROUTINE  (populate_subeventstatus_rec (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ,recorddata =vc (ref ) ) =i2 )
  IF ((validate (recorddata->status_data.status ,"-1" ) != "-1" ) )
   SET lcrslsubeventcnt = size (recorddata->status_data.subeventstatus ,5 )
   SET lcrslsubeventsize = size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationname ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationstatus ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     targetobjectname ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     targetobjectvalue ) )
   IF ((lcrslsubeventsize > 0 ) )
    SET lcrslsubeventcnt +=1
    SET icrslloggingstat = alter (recorddata->status_data.subeventstatus ,lcrslsubeventcnt )
   ENDIF
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationname = substring (1 ,25 ,
    operationname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationstatus = substring (1 ,1 ,
    operationstatus )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectname = substring (1 ,25
    ,targetobjectname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectvalue =
   targetobjectvalue
  ENDIF
 END ;Subroutine
 SUBROUTINE  (populate_subeventstatus (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ) =i2 )
  CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
   targetobjectvalue ,reply )
 END ;Subroutine
 SUBROUTINE  (populate_subeventstatus_msg (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ,loglevel =i2 (value ) ) =i2 )
  CALL populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue
   )
  CALL log_message (targetobjectvalue ,loglevel )
 END ;Subroutine
 SUBROUTINE  (check_log_level (arg_log_level =i4 ) =i2 )
  IF ((((crsl_msg_level >= arg_log_level ) ) OR ((log_override_ind = 1 ) )) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 DECLARE generatestaticcontentreqs (null ) = null WITH protect
 DECLARE generatepagehtml (null ) = vc WITH protect
; DECLARE getbillingentities (null ) = vc WITH protect
 DECLARE getbohp (null ) = vc WITH protect
 
 DECLARE getfacilities (null ) = vc WITH protect
 DECLARE getstaticcontentloc (null ) = null WITH protect
 DECLARE getlocaledata (null ) = null WITH protect
 DECLARE vcjsreqs = vc WITH protect ,noconstant ("" )
 DECLARE vccssreqs = vc WITH protect ,noconstant ("" )
 DECLARE vcjsrenderfunc = vc WITH protect ,noconstant ("" )
 DECLARE vcpagelayout = vc WITH protect ,noconstant ("" )
 DECLARE vcstaticcontent = vc WITH protect ,noconstant ("" )
 DECLARE lstat = i4 WITH protect ,noconstant (0 )
 DECLARE z = i4 WITH private ,noconstant (0 )
 DECLARE localefilename = vc WITH noconstant ("" ) ,protect
 DECLARE localeobjectname = vc WITH noconstant ("" ) ,protect
 DECLARE temp_string = vc
 DECLARE 864_client = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!4974" ) ) ,protect
 DECLARE 3600_pricesch = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!3592" ) ) ,protect
 DECLARE 140002_cpt4 = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!3600" ) ) ,protect
 DECLARE 140002_hcpcs = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!507597" ) ) ,protect
 DECLARE 140002_cdm = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!1308145" ) ) ,protect
 DECLARE 140002_asa = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!4201393920" ) ) ,protect
 SET criterion->prsnl_id =  $USERID
 SET criterion->encntrid =  $ENCNTRID
 SET criterion->personid =  $PERSONID
 SET criterion->locale_id = ""
 SET criterion->static_content =  $SOURCEDIR
 SET criterion->domain = trim (curdomain )
 
   declare x = i4
  declare y = i4
 
 	select into "nl:"
 
 	 drg_exp_amnt = lt_exp.long_text
	, Fin_Clear = lt_fc.long_text
	, auth_status = uar_get_code_display(ei_auth.value_cd)
	, denial_desc = lt_den.long_text
		from
	encounter   e
	, encntr_info ei_exp
	, long_text lt_exp
	, encntr_info ei_auth
	, encntr_info ei_den
	, long_text lt_den
	, encntr_info ei_fc
	, long_text lt_fc
	where
	e.encntr_id = $ENCNTRID
AND ei_exp.encntr_id = outerjoin(e.encntr_id)
AND ei_exp.info_sub_type_cd =    outerjoin( 277028613.00)
AND lt_exp.long_text_id = outerjoin(ei_exp.long_text_id)
AND ei_auth.encntr_id = outerjoin(e.encntr_id)
AND ei_auth.info_sub_type_cd = outerjoin(277028595.00 )
AND ei_den.encntr_id = outerjoin(e.encntr_id)
AND ei_den.info_sub_type_cd =  outerjoin(    277351697.00 )
AND ei_fc.encntr_id = outerjoin(e.encntr_id)
AND ei_fc.info_sub_type_cd = outerjoin(277028521.00 )
AND lt_fc.long_text_id = outerjoin(ei_fc.long_text_id)
AND lt_den.long_text_id = outerjoin(ei_den.long_text_id)
 DETAIL
 criterion->drg_auth_status = auth_status
 criterion->payment_status =  Fin_Clear
 criterion->drg_denial_desc = denial_desc
 
 
 
 
 
      x = findstring(nopatstring("User Remarks :"),criterion->drg_denial_desc,1,0)
      y = TEXTLEN(criterion->drg_denial_desc)
 
      x = cnvtint(x)
      y = cnvtint(y)
 
 
      if(x = 0 and criterion->drg_denial_desc  != "Pre Approval not required")
      	criterion->drg_denial_desc = ""
      elseif( criterion->drg_denial_desc = "Pre Approval not required")
      	criterion->drg_denial_desc = "Covered under Package"
      	criterion->drg_denial_desc = "Updated- Pre Approval not required"
 
      else
      	criterion->user_denial_desc = trim(SUBSTRING(x+15,y,criterion->drg_denial_desc),3)
      	criterion->drg_denial_desc = trim(SUBSTRING(0,x-3,criterion->drg_denial_desc),3)
 
      endif
 
 
 
 
   with nocounter
 
				select into "nl:"
				from
				coding c,
				drg d,
				drg_encntr_extension dee,
				drg_extension de,
				nomenclature   n
				where
				c.encntr_id = $ENCNTRID
				and
				c.active_ind = 1
				and
				d.encntr_id =    c.encntr_id
				and
				d.active_ind = 1
				and
				dee.drg_id = d.drg_id
				and
				dee.source_identifier = de.source_identifier
				and
				n.nomenclature_id = d.nomenclature_id
				    head d.drg_id
				       criterion->drg_code = de.source_identifier
				       ;criterion->drg_type = d.d
				       criterion->drg_name = n.source_string
				       criterion->drg_soi = uar_get_code_meaning(d.severity_of_illness_cd)
				       criterion->drg_rom = uar_get_code_meaning(d.risk_of_mortality_cd)
				       criterion->drg_weight = format(de.drg_weight,"#######.######")
				    with nocounter
 
 
					select into "nl:"
					from
					diagnosis d,
					nomenclature n
					plan d
					where d.encntr_id =     $ENCNTRID
					 and d.active_ind = 1
					 and d.diag_priority > 0
					join n
					where n.nomenclature_id = d.nomenclature_id
					detail
						criterion->diag_cnt = criterion->diag_cnt + 1
						stat = alterlist(criterion->diag_qual, criterion->diag_cnt)
						criterion->diag_qual[criterion->diag_cnt].icd_code = n.source_identifier
						criterion->diag_qual[criterion->diag_cnt].icd_name = n.source_string
						criterion->diag_qual[criterion->diag_cnt].TYPE = UAR_GET_CODE_DISPLAY(D.DIAG_TYPE_CD)
						criterion->diag_qual[criterion->diag_cnt].POA = UAR_GET_CODE_DISPLAY(D.PRESENT_ON_ADMIT_CD)
						criterion->diag_qual[criterion->diag_cnt].DT_TM = FORMAT(D.UPDT_DT_TM,"DD-MM-YYYY;;D")
 					WITH NOCOUNTER
					; STOP GET ALL DIAGNOSIS
 
 
 
					select into "nl:"
					FROM
					procedure   p
					, nomenclature   n
					where p.encntr_id =   $ENCNTRID
					and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
					and p.nomenclature_id > 0
					and p.nomenclature_id = n.nomenclature_id
					ORDER BY 					p.proc_priority
					detail
					 criterion->pro_cnt = criterion->pro_cnt + 1
				     stat = alterlist(criterion->pro_qual, criterion->pro_cnt)
					criterion->pro_qual[criterion->pro_cnt].cpt_code = n.source_identifier
					criterion->pro_qual[criterion->pro_cnt].cpt_desc =  n.source_string
 
 
					WITH NOCOUNTER
 
					for ( x =1  to criterion->pro_cnt)
 
					set criterion->pro_qual[x].cpt_check = "No Match"
 
					select into "nl:"
					from
 
					encounter e,
					charge c,
					charge_mod cm
 
					plan e
					where e.encntr_id = $ENCNTRID
 
					join c
					where c.encntr_id = e.encntr_id
					and c.item_quantity > 0
 
					join cm
					where cm.charge_item_id = c.charge_item_id
					and cm.field6 = criterion->pro_qual[x].cpt_code
					and cm.field1_id in
							 (
							  value(uar_get_code_by("DISPLAY_KEY",14002,"CPT")),
							  value(uar_get_code_by("DISPLAY_KEY",14002,"HCPCS"))
				              )
					detail
					criterion->pro_qual[x].cpt_check = "Match"
 
					with nocounter
					endfor
 
 
select into "nl:"
from
prsnl p
 
plan p
where p.person_id = criterion->prsnl_id
 
detail
 
   criterion->runby = trim (p.username )
   criterion->position_cd = p.position_cd
 
 
with nocounter
 
 
 ;end select
 CALL getencounterdetails (null )
; CALL getbillingentities (null )
 CALL  getbohp (null )
; CALL getbillcodetype (null )
; CALL getactivitytypes (null )
; CALL getpriceschbyuser (null )
 CALL generatestaticcontentreqs (null )
 CALL generatepagehtml (null )
 SUBROUTINE  generatestaticcontentreqs (null )
  SET vcjsreqs = ""
  SET vcjsreqs = build2 ('<script type="text/javascript" src="' ,criterion->static_content ,
   '/js/amb_prvu_sch_vw.js"></script>' )
  SET vccssreqs = build2 ('<link rel="stylesheet" type="text/css" href="' ,criterion->static_content
   ,'/css/cme_rcm_chg_vw.css" />' )
  SET vcjsrenderfunc = "javascript:RenderPRVuFrame();"
 END ;Subroutine
 SUBROUTINE  generatepagehtml (null )
  SET _memory_reply_string = build2 ("<!DOCTYPE html>" ,"<html>" ,"<head>" ,
   '<meta http-equiv="X-UA-Compatible" content="IE=10">' ,'	<meta http-equiv="Content-Type" ' ,
   'content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST,CCLLINKPOPUP,CCLNEWSESSIONWINDOW" name="discern"/>'
   ,vcjsreqs ,vccssreqs ,'	<script type="text/javascript">' ,"	var m_criterionJSON = '" ,replace (
    cnvtrectojson (criterion ) ,"'" ,"\'" ) ,"';" ,'	var CERN_static_content = "' ,criterion->
   static_content ,'";' )
  SET _memory_reply_string = build2 (_memory_reply_string ,"	</script>" ,"</head>" )
  SET _memory_reply_string = build2 (_memory_reply_string ,'<body onload="' ,vcjsrenderfunc ,'">' ,
   '<div id="amb_PRVu_head"></div>' ,'<div id="amb_PRVu_content"></div>' )
  SET _memory_reply_string = build2 (_memory_reply_string ,"</body>" ,"</html>" )
 END ;Subroutine
 SUBROUTINE  getencounterdetails (null )
  SELECT INTO "nl:"
   FROM (encounter e )
   PLAN (e
    WHERE (e.encntr_id = value ( $ENCNTRID ) ) )
   ORDER BY e.encntr_id
   HEAD REPORT
    col + 0
   HEAD e.encntr_id
    criterion->admitdate = format (e.reg_dt_tm ,"dd-mm-yyyy;;d" ) ,
    IF ((e.disch_dt_tm = 0 ) ) criterion->dischdate = format (cnvtdatetime (curdate ,curtime ) ,
      "dd-mm-yyyy;;d" )
    ELSE criterion->dischdate = format (e.disch_dt_tm ,"dd-mm-yyyy;;d" )
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getbillingentities (null )
  SELECT DISTINCT
   FROM (prsnl_org_reltn por ),
    (be_org_reltn bor ),
    (billing_entity be )
   PLAN (por
    WHERE (por.person_id = criterion->prsnl_id )
    AND (por.active_ind = 1 )
    AND (por.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (bor
    WHERE (bor.organization_id = por.organization_id )
    AND (bor.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (be
    WHERE (be.billing_entity_id = bor.billing_entity_id )
    AND (be.active_ind = 1 ) )
   ORDER BY be.be_name ,
    be.billing_entity_id
   HEAD REPORT
    bcnt = 0
   HEAD be.billing_entity_id
    bcnt +=1 ,
    IF ((mod (bcnt ,10 ) = 1 ) ) stat = alterlist (criterion->belist ,(bcnt + 9 ) )
    ENDIF
    ,criterion->belist[bcnt ].be_id = be.billing_entity_id ,temp_string = replace (trim (be.be_name
      ) ,char (10 ) ," " ) ,criterion->belist[bcnt ].be_name = replace (temp_string ,char (13 ) ," "
     )
   FOOT  be.billing_entity_id
    null
   FOOT REPORT
    stat = alterlist (criterion->belist ,bcnt ) ,
    criterion->be_cnt = bcnt
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getbohp (null )
SELECT INTO "nl:"
   FROM
    pft_encntr pe,
    benefit_order bo ,
    bo_hp_reltn bohp
   PLAN pe
   where pe.encntr_id =      criterion->encntrid
   join bo
    WHERE bo.pft_encntr_id =     pe.pft_encntr_id
    AND bo.fin_class_cd != self_code
    AND bo.bo_status_cd != invalid_cd
   ;and bo.fin_class_cd !=      684153.00
    AND bo.active_ind = 1
    JOIN bohp
    WHERE bohp.benefit_order_id = bo.benefit_order_id
    AND bohp.active_ind = 1
 
   HEAD REPORT
    bcnt = 0
   HEAD  bohp.bo_hp_reltn_id
    bcnt +=1 ,
    IF ((mod (bcnt ,10 ) = 1 ) ) stat = alterlist (criterion->bohp ,(bcnt + 9 ) )
    ENDIF
    ,criterion->bohp[bcnt ].bohp_id =  bohp.bo_hp_reltn_id ,temp_string = replace (trim (uar_get_code_display(bohp.fin_class_cd  ) ) ,
    char (10 ) ," " ) ,
    criterion->bohp[bcnt ].bohp_name = replace (temp_string ,char (13 ) ," "
     )
 
 
   FOOT   bohp.bo_hp_reltn_id
    null
   FOOT REPORT
    stat = alterlist (criterion->bohp ,bcnt ) ,
    criterion->bohp_cnt = bcnt
   WITH nocounter
  ;end select
 END ;Subroutine
 
 
 SUBROUTINE  getbillcodetype (null )
  SELECT INTO "nl:"
   FROM (code_value c )
   WHERE (c.code_set = 14002 )
   AND (c.code_value IN (140002_cpt4 ,
   140002_hcpcs ,
   140002_cdm ,
   140002_asa ) )
   AND (c.active_ind = 1 )
   AND (cnvtdatetime (sysdate ) BETWEEN c.begin_effective_dt_tm AND c.end_effective_dt_tm )
   HEAD REPORT
    bccnt = 0
   DETAIL
    bccnt +=1 ,
    IF ((mod (bccnt ,10 ) = 1 ) ) stat = alterlist (criterion->codetypes ,(bccnt + 9 ) )
    ENDIF
    ,criterion->codetypes[bccnt ].display_name = c.display ,
    criterion->codetypes[bccnt ].code_value = c.code_value
   FOOT REPORT
    stat = alterlist (criterion->codetypes ,bccnt ) ,
    criterion->bctype_cnt = bccnt
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getactivitytypes (null )
  SELECT INTO "nl:"
   FROM (code_value c )
   WHERE (c.code_set = 106 )
   AND (c.active_ind = 1 )
   AND (cnvtdatetime (sysdate ) BETWEEN c.begin_effective_dt_tm AND c.end_effective_dt_tm )
   ORDER BY c.display
   HEAD REPORT
    catype = 0
   DETAIL
    catype +=1 ,
    IF ((mod (catype ,10 ) = 1 ) ) stat = alterlist (criterion->categorytypes ,(catype + 9 ) )
    ENDIF
    ,criterion->categorytypes[catype ].display_name = c.display ,
    criterion->categorytypes[catype ].code_value = c.code_value
   FOOT REPORT
    stat = alterlist (criterion->categorytypes ,catype ) ,
    criterion->ctype_cnt = catype
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getpriceschbyuser (null )
  SELECT DISTINCT
   ps.price_sched_desc ,
   ps.price_sched_short_desc ,
   ps_range_type_disp = uar_get_code_display (ps.range_type_cd ) ,
   ps.price_sched_id
   FROM (prsnl_org_reltn por ),
    (org_type_reltn otr ),
    (organization o ),
    (bill_org_payor bop ),
    (tier_matrix tm ),
    (price_sched ps )
   PLAN (por
    WHERE (por.person_id = criterion->prsnl_id ) )
    JOIN (otr
    WHERE (otr.org_type_cd = 864_client )
    AND (otr.organization_id = por.organization_id ) )
    JOIN (o
    WHERE (o.organization_id = otr.organization_id ) )
    JOIN (bop
    WHERE (bop.organization_id = o.organization_id )
    AND (bop.bill_org_type_cd IN (
    (SELECT
     cv3.code_value
     FROM (code_value cv3 )
     WHERE (cv3.code_set = 13031 )
     AND (trim (cv3.cdf_meaning ) IN ("CLTTIERGROUP" , "TIERGROUP" ) )
     AND (cv3.active_ind = 1 ) ) ) )
    AND (bop.active_ind = 1 )
    AND (bop.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (bop.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (tm
    WHERE (tm.tier_group_cd = bop.bill_org_type_id )
    AND (tm.tier_cell_type_cd = 3600_pricesch )
    AND (tm.active_ind = 1 )
    AND (tm.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (tm.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (ps
    WHERE (ps.price_sched_id = Outerjoin(tm.tier_cell_value_id ))
    AND (ps.active_ind = Outerjoin(1 ))
    AND (ps.beg_effective_dt_tm <= Outerjoin(cnvtdatetime (sysdate ) ))
    AND (ps.end_effective_dt_tm > Outerjoin(cnvtdatetime (sysdate ) )) )
   ORDER BY ps.price_sched_desc
   HEAD REPORT
    priceschcnt = 0
   DETAIL
    priceschcnt +=1 ,
    IF ((mod (priceschcnt ,10 ) = 1 ) ) stat = alterlist (criterion->priceschlist ,(priceschcnt + 9
      ) )
    ENDIF
    ,criterion->priceschlist[priceschcnt ].price_sch_display = ps.price_sched_desc ,
    criterion->priceschlist[priceschcnt ].price_sch_id = ps.price_sched_id
   FOOT REPORT
    stat = alterlist (criterion->priceschlist ,priceschcnt ) ,
    criterion->pricesch_cnt = priceschcnt
   WITH nocounter
  ;end select
 END ;Subroutine
#exit_script
 CALL echorecord (criterion )
END GO
