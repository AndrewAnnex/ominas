;==============================================================================
; orb_lon_to_arg
;
;
;==============================================================================
function orb_lon_to_arg, xd, lon, frame_bd

 lan = orb_get_lan(xd, frame_bd)
 arg = lon - lan

 return, arg
end
;==============================================================================