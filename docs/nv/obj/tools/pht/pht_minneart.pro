;=============================================================================
; pht_minneart
;
;=============================================================================
function pht_minneart, mu, mu0, parm
 k = parm[0]
 return, mu0^(k)*mu^(k-1)
end
;=============================================================================
