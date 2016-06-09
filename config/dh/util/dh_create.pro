;=============================================================================
;+
; NAME:
;	dh_create
;
;
; PURPOSE:
;	Creates a minimal detached header.
;
;
; CATEGORY:
;	UTIL/DH
;
;
; CALLING SEQUENCE:
;	result = dh_create()
;
;
; ARGUMENTS:
;  INPUT: NONE
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
; RETURN:
;	String array in which each element is a line of the detached header.
;
;
; PROCEDURE:
;	dh_create creates a detached header containing a history line and 
;	the '<updates>' separator.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/1998
;	
;-
;=============================================================================
function dh_create

 dh = ['history = -1 / Current history value', $
       '<updates>' , ''] 


 return, dh
end
;=============================================================================