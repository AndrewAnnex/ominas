;=============================================================================
; dawn_spice_lsk_detect
;
;=============================================================================
function dawn_spice_lsk_detect, dd, kpath, time=time, strict=strict, all=all
 return, eph_spice_lsk_detect(dd, kpath, time=time, strict=strict, all=all)
end
;=============================================================================
