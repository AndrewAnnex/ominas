;===========================================================================
; detect_tdl.pro
;
;===========================================================================
function detect_tdl, dd

 filename = dat_filename(dd)
 header = dat_header(dd)
 status = 0


 ;===============================================
 ; if no header, read the beginning of the file
 ;===============================================
 if(keyword_set(header)) then s = header $
 else $
  begin
   openr, unit, filename, /get_lun, error=error
   if(error NE 0) then nv_message, /anonymous, !err_string
   record = assoc(unit, bytarr(20,/nozero))
   s = string(record[0])
   close, unit
   free_lun, unit
  end


 ;===================================
 ; check for label field
 ;===================================
 if(strpos(s[0], 'TDL_LBLSIZE') NE -1) then status=1


 return, status
end
;===========================================================================
