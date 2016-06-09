;===========================================================================
; glb_intersect_inertial.pro
;
; Inputs and outputs are in INERTIAL coordinates
;
;  ***ACTUALLY, OUTPUTS ARE <<<<BODY>>>>
;
; computes vectors at which rays with origins v(nv,3,nt) and directions
; r(nv,3,nt) intersect the globe.
;
; Returns array points(2*nv,3,nt), where points[0:nv-1,*,*] correspond to the 
; negative sign in the quadratic formula and points[nv:2*nv-1,*,1] correspond
; to the positive sign.  Zero vector is returned for points with no solution.
;
;===========================================================================
function glb_intersect_inertial, gbd, v_inertial, r_inertial, discriminant=discriminant
 
@core.include

 v = bod_inertial_to_body_pos(gbd, v_inertial)
 r = bod_inertial_to_body(gbd, r_inertial)

 ;----------------------------
 ; compute the discriminant
 ;----------------------------
 discriminant = glb_intersect_discriminant(gbd, v, r, $
                                           alpha=alpha, beta=beta, gamma=gamma)

 ;----------------------------------
 ; compute the intersection points
 ;----------------------------------
 points = glb_intersect_points(gbd, v, r, discriminant, alpha, beta, gamma)


 return, points
end
;===========================================================================