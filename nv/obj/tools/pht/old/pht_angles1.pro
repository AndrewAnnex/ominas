;=============================================================================
; pht_angles
;
;=============================================================================
pro pht_angles, image_pts, cd, gbx, sund, emm=emm, inc=inc, g=g, valid=valid

 np = n_elements(image_pts)/2
 nt = n_elements(gbx)

 ;-------------------------------
 ; construct view vectors
 ;-------------------------------
 _v = bod_inertial_to_body_pos(gbx, bod_pos(cd))
; v = _v##make_array(np, val=1d)
 v = _v[linegen3x(np,3,nt)]

 r = bod_inertial_to_body(gbx, $
       bod_body_to_inertial(cd, $
         cam_focal_to_body(cd, $
           cam_image_to_focal(cd, image_pts))))

 ;-------------------------------
 ; compute points on surface
 ;-------------------------------
 body_pts = (glb_intersect(gbx, v, r, d=d))[0:np-1,*,*]

vsub = vecgen(np,3,nt)
body_pts = body_pts[vsub]
r = r[vsub]
d = reform(d, np*nt, /overwrite)


 valid = where(d GE 0)
 if(valid[0] EQ -1) then return

 nvalid = n_elements(valid)

body_pts = body_pts[valid,*]

; invalid = where(d LT 0)
; if(invalid[0] NE -1) then body_pts[invalid,*,*] = 1

 ;-------------------------------
 ; construct sun vectors
 ;-------------------------------
 sun_pos = (bod_inertial_to_body(gbx, bod_pos(sund)))[gen3y(nvalid,3,nt)]
 s = v_unit(sun_pos - body_pts)

 ;-------------------------------
 ; compute surface normals
 ;-------------------------------
 normals = glb_surface_normal(gbx, body_pts)

 ;-------------------------------
 ; compute angles
 ;-------------------------------
 _emm = v_inner(-r, normals)

 _inc = v_inner(s, normals)
 w = where(_inc LT 0)
 if(w[0] NE -1) then _inc[w] = 0

 _g = v_inner(-r,s)

 emm = dblarr(np,nt)
 emm[valid] = _emm
 
 inc = dblarr(np,nt)
 inc[valid] = _inc

 g = dblarr(np,nt)
 g[valid] = _g

; valid = reform(valid, np,nt, /over)

end
;=============================================================================