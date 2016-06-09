;=============================================================================
; ominas_array::init
;
;=============================================================================
function ominas_array::init, ii, crd=crd0, ard=ard0, $
@array__keywords.include
end_keywords
@core.include
 
 void = self->ominas_core::init(ii, crd=crd0, $
@core__keywords.include
end_keywords)
 if(keyword_set(ard0)) then struct_assign, ard0, self

 self.abbrev = 'ARR'



 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_array__define
;
;
; PURPOSE:
;	Class structure for the ARRAY class.
;
;
; CATEGORY:
;	NV/LIB/arr
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	bd:	BODY class descriptor.  
;
;		Methods: arr_body, arr_set_body
;
;
;	primary:	String giving the name of the primary body.
;
;			Methods: arr_primary, arr_set_primary
;
;	surface_pts:	Vector giving the surface coordinates of the 
;			array points on the primary.  
;
;			Methods: arr_surface_pts, arr_set_surface_pts
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
; 	Adapted by:	Spitale, 5/2016
;-
;=============================================================================
pro ominas_array__define

 struct = $
    { ominas_array, inherits ominas_core, $
	surface_pts_p:	 ptr_new(), $		; Surface coords of location.
        primary:         '' $                   ; Name of primary body
    }

end
;===========================================================================


