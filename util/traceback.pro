;===============================================================================
; traceback
;
;
;===============================================================================
function traceback, n

 help, /tr, out=s

 w = where(strmid(s, 0, 1) EQ '%')
 s = s[w]

 return, s[n+2]
end
;===============================================================================