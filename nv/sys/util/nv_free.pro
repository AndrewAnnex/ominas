;=============================================================================
;+
; NAME:
;	nv_free
;
;
; PURPOSE:
;	Recursively frees a descriptor.  Pointers and structures are 
;	dereferenced and descended, freeing any pointers encountered.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_free, p
;
;
; ARGUMENTS:
;  INPUT:
;	p:	Pointer or structure.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================



;=============================================================================
; nvf_recurse
;=============================================================================
pro nvf_recurse, p

 type = size(p, /type)
 n = n_elements(p)

 if(type EQ 10) then $
  begin
   for i=0, n-1 do if(ptr_valid(p[i])) then nvf_recurse, *p[i]
   nv_ptr_free, p
  end $
 else if(type EQ 8) then $
  begin
   for i=0, n-1 do $
    begin
     if(nv_get_directive(p[i]) EQ 'NV_STOP') then return

     ntags = n_tags(p[i])
     for j=0, ntags-1 do nvf_recurse, p[i].(j)
    end
  end $
 else if(type EQ 11) then $
  begin
   for i=0, n-1 do if(obj_valid(p[i])) then $
    begin
     _p = cor_dereference(p[i])

     if(nv_get_directive(_p) EQ 'NV_STOP') then return

     ntags = n_tags(_p)
     for j=0, ntags-1 do nvf_recurse, _p.(j)
     obj_destroy, p
    end
  end 

end
;=============================================================================



;=============================================================================
; nv_free
;
;=============================================================================
pro nv_free, dp
@core.include
 nvf_recurse, dp

 heap_gc	; this should not be necessary
end
;=============================================================================



