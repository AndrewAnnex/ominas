;=============================================================================
;+
; NAME:
;	rim.bat
;
;
; PURPOSE:
;	Access to rim from the unix command line.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE (from the csh prompt):
;	xidl rim.bat + files <keyvals>
;
;
; ARGUMENTS:
;  INPUT:
;	files:		One or more file specification strings following 
;			the standard csh rules.
;
;	keyvals:	Keyword-value pairs to be passed to rim.  
;
;
; RESTRICTIONS:
;	See bat_description.txt
;
;
; EXAMPLE:
;	Note that this is intended to be set up as an xidl alias.  In csh, it 
;	would be like this:
;
;	alias rim    'xidl rim.bat +'
;
;	Using that alias, rim can be run from the csh prompt as in this 
;	example:
;
;	rim 'N*.IMG' 
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	grim.bat brim.bat
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale; 8/2013
;	
;-
;=============================================================================
!quiet = 1
___argv = xidl_argv()

___filespecs = xidl_parse_argv(___argv, ___keys, ___val_ps, spec=___spec)
___filespecs = bat_expand(___filespecs, ___spec)
if(keyword_set(___filespecs)) then ___files = findfiles(___filespecs)

___stat = execute(xidl_command('rim, ___files', ___keys, ___val_ps))

exit