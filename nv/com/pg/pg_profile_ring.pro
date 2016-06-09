;=============================================================================
;+
; NAME:
;	pg_profile_ring
;
;
; PURPOSE:
;	Generates radial or longitudinal ring profiles from the given image
;	using an image outline.
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;    result = pg_profile_ring(dd, cd=cd, dkx=dkx, gbx=gbx, outline_ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;       outline_ptd:    POINT giving the outline of the sector to plot,
;                      as produced by the pg_ring_sector.
;
;  OUTPUT:
;        NONE
;
; KEYWORDS:
;  INPUT:
;	  cd:	Camera descriptor.
;
;        dkx:   Disk descriptor.
;
;	 gbx:   Array  of descriptors of objects which must be a subclass 
;               of GLOBE, describing the primary body for dkx.  For each
;               timestep, only the first descriptor is used.
;
;         gd:   Generic descriptor, if used, cd and dkx taken from it unless
;               overriden by cd and dkx arguments.
;
;  azimuthal:   If set, the plot is longitudinal instead of radial.
;
;       bin:    If set, pixels in sector are binned according to
;               radius or longitude rather than dn averaged at equal
;               radius or longitude spacing
;
;    interp:    Type of interpolation to use: 'nearest', 'bilinear', 'cubic',
;               or 'sinc'.  'sinc' is the default.
;
;         bg:	Uniform value to subtract from profile.
;
; arg_interp:   Arguments to pass to the interpolation function.
;
;   frame_bd:   Subclass of BODY giving the frame against which to 
;               measure inclinations and nodes, e.g., a planet 
;               descriptor.  One per bx.
;
;    anomaly:   If set, longitudes in outline_ptd are interpreted instead
;               as anomalies.
;
;  OUTPUT:
;    profile:   The profile.
;
;    dsk_pts:	Array of disk coordinates corresponding to each value in the
;		returned dn profile.
;
;    im_pts:	Array of image coordinates corresponding to each value in the
;		returned dn profile.
;
;      sigma:   Array giving the standard deviation at each point in the
;		profile.
;
;      width:   Array giving the width of the scan, in pixels along the 
;               averaging direction, at each point in the profile.
;
;         nn:   Number of image samples averaged into each profile point.
;
; RETURN:
;	Two data descriptors: the first contains the profile; the second contains
;	the profile sigma.
;
;
; PROCEDURE:
;	The image points of the sector outline are first calculated.  If 
;       /outline is selected then this is output.  If not, then the
;       /azimuthal keyword determines if this is a radius or longitude 
;       profile.  The radius and longitude spacing for profile is then is 
;       determined. If n_lon or n_rad is given, then these are used.  If not,
;       then the outline is used to determine the spacing in radius and
;       longitude so that the maximum spacing is a pixel.  If oversamp is
;       given then the number of samples is multiplied by this factor.
;       Then the image is sampled with this radius x longitude grid and
;       the dn interpolated with the routine image_interp at each point.
;       The dn's are then averaged along the requested profile direction.
;       If /bin keyword is selected then the image is not interpolated but
;       rather each pixel is binned in a histogram with the calculated
;       spacing.
;
;
; EXAMPLE:
;     lon = [175.,177.]
;     rad = [65000000.,138000000.]
;     outline_ptd = pg_ring_sector(cd=cd, dkx=rd, gbx=pd, rad=rad, lon=lon)
;     pg_draw, outline_ptd
;
;     profile = pg_profile_ring(dd, cd=cd, dkx=rd, gbx=pd, $
;                                          outline_ptd, dsk_pts=dsk_pts)
;     window, /free, xs=500, ys=300
;     plot, dsk_pts[*,0], profile
;
;
; MODIFICATION HISTORY:
;       Written by:     Vance Haemmerle & Spitale, 6/1998
;	Modified to use outline_ptd instead of (rad,lon): Spitale 5/2005
;	
;-
;=============================================================================
function pg_profile_ring, dd, cd=cd, dkx=dkx, gbx=_gbx, gd=gd, frame_bd=frame_bd, outline_ptd, $
                          azimuthal=azimuthal, sigma=sigma, width=width, nn=nn, $
                          bin=bin, dsk_pts=dsk_pts, im_pts=im_pts, $
                          interp=interp, arg_interp=arg_interp, profile=profile, $
                          anomaly=anomaly, bg=bg

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, dd=dd, cd=cd, dkx=dkx, gbx=_gbx

 if(NOT keyword__set(_gbx)) then $
            nv_message, name='pg_profile_ring', 'Globe descriptor required.'
 __gbx = get_primary(cd, _gbx, rx=dkx)
 if(keyword__set(__gbx[0])) then gbx = __gbx $
 else gbx = _gbx[0,*]

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 if(n_elements(dkx) GT 1) then nv_message, /continue, name='pg_profile_ring', $
                          'Using first disk descriptor.'
 if(n_elements(cd) GT 1) then nv_message, /continue, name='pg_profile_ring', $
                        'Using first camera descriptor.'
 dkd = dkx[0]

 if(NOT keyword_set(frame_bd)) then frame_bd=gbx

 ;-----------------------------------
 ; get the points and data
 ;-----------------------------------
 pnt_get, outline_ptd, $
	points=outline_pts, $
	data=dsk_outline_pts
 dsk_outline_pts = transpose(dsk_outline_pts)
 nrad = cor_udata(outline_ptd, 'nrad')
 nlon = cor_udata(outline_ptd, 'nlon')
 point0 = cor_udata(outline_ptd, 'point0')
 point = cor_udata(outline_ptd, 'point')
 point = cor_udata(outline_ptd, 'point')
 sample = cor_udata(outline_ptd, 'sample')
 sample = sample[0]


 ;--------------------------------------------------------
 ; if sample given, then we'll do this using polyfillv
 ;--------------------------------------------------------
 if(keyword_set(sample)) then $
  begin
   image = dat_data(dd)
   si = size(image)

   sample = float(sample)
   sx = si[1] * sample
   sy = si[2] * sample
   p = outline_pts * sample

   ii = polyfillv(p[0,*], p[1,*], sx, sy)

   im_pts = w_to_xy(0, ii, sx=sx, sy=sy) / sample

   dsk_pts = image_to_disk(cd, dkd, im_pts, frame=frame_bd)
   rad_pts = dsk_pts[*,0]
   lon_pts = dsk_pts[*,1]

   cp = total(outline_pts,2) / (n_elements(outline_pts)/2)
   cp_disk = image_to_disk(cd, dkd, cp, frame=frame_bd)
   cp_inertial = bod_body_to_inertial_pos(dkd, $
                       dsk_disk_to_body(dkd, cp_disk, frame_bd=frame_bd))
   dsk_projected_resolution, dkd, cd, cp_inertial, $
                               (cam_scale(cd))[0], rad=dr, lon=km_dlon, rr=rr
   dlon = km_dlon / rr
   dx = dr[0]
   if(keyword_set(azimuthal)) then dx = dlon[0]

   profile = get_ring_profile(dat_data(dd), cd, dkd, lon_pts, rad_pts, $
                 azimuthal=azimuthal, frame_bd=frame_bd, interp=interp, $
                 im_pts=im_pts, dx=dx, dsk_pts=dsk_pts, $
                 sigma=sigma, arg_interp=arg_interp, $
                 width=width, nn=nn)
  end $
 ;--------------------------------------------------------
 ; otherwise, extract along lines of constant radius
 ;--------------------------------------------------------
 else $
  begin
   nrad = nrad[0] & nlon = nlon[0]

   if(NOT keyword_set(dsk_outline_pts)) then $
           dsk_outline_pts = image_to_disk(cd, dkd, outline_pts, frame=frame_bd)

   ;----------------------------------------------------------
   ; compute sample points
   ;----------------------------------------------------------
   _rad_pts = dsk_outline_pts[lindgen(nlon),0]
   _rad_offsets = dsk_outline_pts[nlon+lindgen(nrad),0]
   rad_offsets = _rad_offsets - min(_rad_offsets)

   test = [_rad_pts, _rad_pts + max(rad_offsets)]
   if(abs(mean(test) - mean(dsk_outline_pts[*,0])) GT $
         stdev(dsk_outline_pts[*,0])) then $
                               rad_offsets = _rad_offsets - max(_rad_offsets)

   rad_pts = _rad_pts##make_array(nrad,val=1d) + $
             rad_offsets#make_array(nlon,val=1d)

   lon0_pts = dsk_outline_pts[lindgen(nlon), 1]
   lon_offsets = dsk_outline_pts[lindgen(nrad)+nlon,1]
   lon_offsets = lon_offsets - lon_offsets[0]

   lon_pts = lon0_pts##make_array(nrad,val=1d) + $
             lon_offsets#make_array(nlon,val=1d)

   cor_set_udata, outline_ptd, 'rad_pts', rad_pts
   cor_set_udata, outline_ptd, 'lon_pts', lon_pts


   ;----------------------------------------------------------
   ; extract profiles
   ;----------------------------------------------------------
   if(keyword_set(bin)) then $
      profile = get_ring_profile_bin(dat_data(dd), cd, dkd, $
                      lon_pts, rad_pts, azimuthal=azimuthal, frame_bd=frame_bd) $
   else $
      profile = get_ring_profile(dat_data(dd), cd, dkd, $
                    lon_pts, rad_pts, azimuthal=azimuthal, frame_bd=frame_bd, $
                               interp=interp, arg_interp=arg_interp, $
                                 im_pts=im_pts, dsk_pts=dsk_pts, sigma=sigma, $
                                   width=width, nn=nn)
  end


 if(arg_present(im_pts)) then $
   if(keyword_set(im_pts)) then im_pts = reform(im_pts, /over)

 if(NOT keyword_set(profile)) then return,0

 if(keyword_set(bg)) then profile = profile - bg[0]

 abscissa = dsk_pts[*,0]
 name = ' Radial ring Profile'
 if(keyword_set(azimuthal)) then $
  begin
   abscissa = dsk_pts[*,1]
   if(keyword_set(anomaly)) then abscissa = orb_lon_to_anom(dkd, abscissa, frame_bd)
   name = ' Azimuthal ring Profile'
  end

 dd_prof = [ dat_create_descriptors(1, data=[tr(abscissa), $
                                    tr(profile)], name=cor_name(dd), $
                                    header=dat_header(dd)), $
             dat_create_descriptors(1, data=[tr(abscissa), $
                                    tr(sigma)], name=cor_name(dd), $
                                    header=dat_header(dd)) ]
  
 return, dd_prof
end
;=============================================================================