;=============================================================================
;+
; NAME:
;	grim.bat
;
;
; PURPOSE:
;	Access to grim from the unix command line.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE (from the csh prompt):
;	xidl grim.bat + files <keyvals>
;
;
; ARGUMENTS:
;  INPUT:
;	files:		One or more file specification strings following 
;			the standard csh rules.
;
;	keyvals:	Keyword-value pairs to be passed to grim.  
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
;	alias grim    'xidl grim.bat +'
;
;	Using that alias, grim can be run from the csh prompt as in this 
;	example:
;
;	grim 'N*.IMG' z=0.75
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	brim.bat
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale; sometime before 5/2005
;	
;-
;=============================================================================
!quiet = 1
___argv = xidl_argv()

___filespecs = xidl_parse_argv(___argv, ___keys, ___val_ps, spec=___spec)
___filespecs = bat_expand(___filespecs, ___keys, ___val_ps, ___spec)
if(keyword_set(___filespecs)) then ___files = findfiles(___filespecs)

if(keyword__set(___files)) then $
 begin &$
  ___w = where(___files EQ '') &$
  if(___w[0] NE -1) then $
   begin &$
    for ___i=0, n_elements(___w)-1 do $
     nv_message, /con, 'File not found: ' + ___filespecs[___w[___i]] + ' skipping.' &$

    ___w = where(___files NE '') &$
    if(___w[0] EQ -1) then retall &$
    ___files = ___files[___w] &$
   end &$
 end

;if(keyword__set(___files)) then dd = nv_read(___files, /silent)
;___stat = execute(xidl_command('grim, dd', ___keys, ___val_ps))

___stat = execute(xidl_command('grim, ___files', ___keys, ___val_ps))

