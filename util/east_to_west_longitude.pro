;=============================================================================
; east_to_west_longitude
;
;=============================================================================
function east_to_west_longitude, lon, max=max
 return, reduce_angle(2d*!dpi - lon, max=max)
end
;=============================================================================
