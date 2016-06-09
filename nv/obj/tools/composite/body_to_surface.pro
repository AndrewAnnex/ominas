;=============================================================================
;+
; NAME:
;       body_to_surface
;
;
; PURPOSE:
;       Transforms points in body coordinates to sirface coordinates.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = body_to_surface(bx, body_pts)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:      Array of nt object descriptors (subclass of BODY).
;
;	body_pts:       Array (nv x 3 x nt) of body points.
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;   INPUT: 
;	frame_bd:	Subclass of BODY giving the frame against which to 
;			measure inclinations and nodes, e.g., a planet 
;			descriptor.  One per bx.
;
;   OUTPUT: NONE
;
;
; RETURN:
;       Array (nv x 3 x nt) of surface coordinates.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function body_to_surface, bx, p, frame_bd=frame_bd

 if(NOT keyword_set(p)) then return, 0

 gbx = cor_select(bx, 'GLOBE', /class)
 dkx = cor_select(bx, 'DISK', /class)

 if(keyword_set(gbx)) then return, glb_body_to_globe(gbx, p)
 if(keyword_set(dkx)) then return, dsk_body_to_disk(dkx, p, frame_bd=frame_bd)
 return, bod_body_to_radec(bx, p)

end
;===========================================================================