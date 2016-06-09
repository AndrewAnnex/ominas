;=============================================================================
; grim_pixel_readout_event
;
;=============================================================================
pro grim_pixel_readout_event, event

 ;-----------------------------------------------
 ; get form base and data
 ;-----------------------------------------------
 base = event.top
 widget_control, base, get_uvalue=data
 struct = tag_names(event, /struct)

 ;-----------------------------------------------
 ; adjust base size
 ;-----------------------------------------------
 if(struct EQ 'WIDGET_BASE') then $
  begin
   dx = event.x - data.base_xsize
   dy = event.y - data.base_ysize

   widget_control, data.text, scr_xsize=data.text_xsize+dx, scr_ysize=data.text_ysize+dy

   geom = widget_info(data.base, /geom)
   data.base_xsize = geom.xsize
   data.base_ysize = geom.ysize

   geom = widget_info(data.text, /geom)
   data.text_xsize = geom.scr_xsize
   data.text_ysize = geom.scr_ysize

   widget_control, base, set_uvalue=data
   return
  end



end
;=============================================================================



;=============================================================================
; grpr_hide_button_event
;
;=============================================================================
pro grpr_hide_button_event, event

 widget_control, event.top, map=0

end
;=============================================================================



;=============================================================================
; grim_pixel_readout
;
;=============================================================================
function grim_pixel_readout, base, text=text, grnum=grnum


 ;-----------------------------------------------------
 ; if base given, just realize it and bring to front
 ;-----------------------------------------------------
 if(keyword_set(base)) then $
  if(widget_info(base, /valid_id)) then $
   begin
    widget_control, /map, /show, base
    widget_control, base, get_uvalue=data
    text = data.text
    return, base
   end


 ;-----------------------------------------------------
 ; otherwise, set up new widgets
 ;-----------------------------------------------------
 title = 'grim ' + strtrim(grnum,2) + '; pixel data'
 base = widget_base(/col, title=title, /tlb_size_events)
 text = widget_text(base, xsize=80, ysize=15, /scroll)
 hide_button = widget_button(base, value='hide', $
                                  event_pro='grpr_hide_button_event')

 widget_control, base, set_uvalue=text

 ;-----------------------------------------------
 ; save data
 ;-----------------------------------------------
 data = { $
		base			:	base, $
		text			:	text, $
		hide_button		:	hide_button, $
		base_xsize		:	0l, $
		base_ysize		:	0l, $
		text_xsize		:	0l, $
		text_ysize		:	0l, $
		data_p			:	nv_ptr_new() $
	     }

 data.data_p = nv_ptr_new(data)

 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 xmanager, 'grim_pixel_readout', base, /no_block

 geom = widget_info(base, /geom)
 data.base_xsize = geom.xsize
 data.base_ysize = geom.ysize

 geom = widget_info(text, /geom)
 data.text_xsize = geom.scr_xsize
 data.text_ysize = geom.scr_ysize

 widget_control, base, set_uvalue=data


 return, base
end
;=============================================================================