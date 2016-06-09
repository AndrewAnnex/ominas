;===========================================================================
;+
; NAME:
;	jup_header
;
;
; PURPOSE:
;	To create ominas detached header files from Cassini Jupiter era
;	images using a FORTRAN program to interface to SPICE.
;
; CATEGORY:
;	UTIL/SPICE
;
; USAGE:
;	jup_header, filename
;
; ARGUMENTS:
;	filename:	Cassini VICAR image
;
; RESTRICTIONS:
;	This is a basic implementation.  It creates a detached header
;	with a Camera descriptor, Ring descriptor, Star descriptor for
;	the Sun and 5 planet descriptors of Jupiter, Io, Europa, Ganymede
;	and Callisto.  If the TARGET_NAME of the observation in the
;	label is not one of these, then a planet descriptor of the target
;	object is also made.  Dimensions use meters and meters/sec.  Time is
;	Ephemeris time (close to seconds past J2000).  Coordinate system
;	for Position and velocity and orientation matricies is J2000.
;	NAIF kernel names are named in a file jup_header.kernels.  If new
;	kernels are received, this file will have to be modified with the
;	new kernel names.
;
;       If no C kernel is available, the orientation matrix is set so
;	that the optic axis points torward the TARGET_NAME in the label.
;	and has the planets pole axis aligned in the line direction, with
;	North in the direction of decreasing line number.
;
;
; MODIFICATION HISTORY:
;	Original version:  A. Vasavada (2000)
;       Major changes:     Haemmerle, 12/2000
;
;-
;===========================================================================
pro jup_header, filename

 dhname = dh_fname(filename)        ; name of output

 ;-------------
 ; Define paths
 ;-------------
 jup_path = getenv('NV_SPICE')      ; location of Fortan binaries
 ck_path = getenv('NV_SPICE_CK')    ; location of NAIF CK kernels

 ;-------------------------
 ; Get info from file label
 ;-------------------------
 label = read_vicar_label(filename, /silent)
 time = vicgetpar(label, 'IMAGE_TIME')
 if(strmid(time,strlen(time)-1,1) EQ 'Z') then $
  time = strmid(time,0,strlen(time)-1)
 exposure = vicgetpar(label, 'EXPOSURE_DURATION')/1000d
 cam_name = vicgetpar(label, 'INSTRUMENT_ID')
 target = vicgetpar(label, 'TARGET_NAME')

 ;------------------------------
 ; See if extra target is needed
 ;------------------------------
 if((target NE 'JUPITER') AND (target NE 'IO') AND (target NE 'EUROPA') AND $
    (target NE 'GANYMEDE') AND (target NE 'CALLISTO')) THEN $
   newtarget = target

 ;-------------------------
 ; Set instrument ID number
 ;-------------------------
 if(cam_name EQ 'ISSNA') then inst=-82360
 if(cam_name EQ 'ISSWA') then inst=-82361

 ;-------------
 ; Kernel names
 ;-------------
 kernellist = jup_path + '/jup_header.kernels'
 year = strmid(time,2,2)
 doy = strmid(time,5,3)
 mon = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
 if(float(year)/4. - fix(float(year)/4.) EQ 0) then mon[1] = 29
 imon = 0
 while(doy GT mon[imon]) do $
  begin
   doy = doy - mon[imon]
   imon = imon + 1
  end
 ctime = year + string(imon+1, format='(i2.2)') + string(doy, format='(i2.2)')
 clist = [findfile(ck_path+'/*.bc'), findfile(ck_path+'/*.BC')]
 for i=0,n_elements(clist)-1 do $
  begin
    p = rstrpos(clist[i], '/')
    start_time = strmid(clist[i],p+1,6)
    end_time = strmid(clist[i],p+8,6)
    if(ctime GE start_time AND ctime LE end_time) then $
     begin 
      if(n_elements(cker) EQ 0) then cker = clist[i] $
       else cker = [cker, clist[i]]
     end
  end
 if(n_elements(cker) EQ 0) THEN nv_message, name='jup_header', $
                           'C kernel for this image is not available', $
                           /continue
 if(n_elements(cker) GT 2) THEN nv_message, name='jup_header', $
                           'Found more than 2 C kernels will use first two', $
                           /continue

 ;-----------------------------------------------------------
 ; write temp file to pass info to routine OMINAS_MKHEADER_JUP
 ;-----------------------------------------------------------
 get_lun, unit
 openw, unit, 'temp1.idl'
  printf, unit, strtrim(kernellist,2)
  printf, unit, strtrim(time,2)
  printf, unit, strtrim(exposure,2)
  printf, unit, strtrim(string(inst),2)
  printf, unit, strtrim(string(min([n_elements(cker),2])),2)
  if(n_elements(cker) GE 1) THEN printf, unit, strtrim(cker[0],2)
  if(n_elements(cker) GE 2) THEN printf, unit, strtrim(cker[1],2)
  if(keyword__set(newtarget)) THEN printf, unit, strtrim(newtarget,2) $
  else printf, unit, 'NONE'
 close, unit
 free_lun, unit

 ;----------------------------------
 ; Call routine OMINAS_MKHEADER_JUP.F
 ;----------------------------------
 command = jup_path + '/ominas_mkheader_jup < temp1.idl'
 spawn, command

 ;--------------------
 ; read fortran output
 ;--------------------
 ntrgt = 0
 get_lun, unit
 f = findfile('temp1.fort')
 if(f[0] EQ '') then $
  begin
   nv_message, 'SPICE interface failed', /continue
   goto, cleanup
  end
 openr, unit, 'temp1.fort'
 readf, unit, ntrgt
 if(ntrgt NE 6 AND ntrgt NE 7) THEN $
  begin
    nv_message, 'Output of SPICE interface not expected', $
                name='jup_header', /continue
    goto, cleanup
  end

; ntrgt=6                            ; FORTRAN is hardwired to output 6 targets
;                                    ; first target is the Sun
; if(keyword__set(newtarget)) then ntrgt = 7

 c_matrix=dblarr(9) & me_matrix=dblarr(9,ntrgt)
 rabc=dblarr(3,ntrgt) & trgtname=strarr(ntrgt)
 rlora=dblarr(ntrgt) & sc_state=dblarr(6)
 trgt_state=dblarr(6,ntrgt) & trgt_avel=dblarr(3,ntrgt)
 sc_state[*]=0.d0
 value=' '

  for i=0,8 do begin
    readf, unit, value & c_matrix[i]=double(value)
  endfor
  readf, unit, value & et=double(value)
  for j=0,ntrgt-1 do begin
    readf, unit, value & trgtname[j]=strtrim(value,2)
    readf, unit, value & rabc[0,j]=double(value)
    readf, unit, value & rabc[1,j]=double(value)
    readf, unit, value & rabc[2,j]=double(value)
    readf, unit, value & rlora[j]=double(value)
    for i=0,8 do begin
      readf, unit, value & me_matrix[i,j]=double(value)
    endfor
    for i=0,5 do begin
      readf, unit, value & trgt_state[i,j]=double(value)
    endfor
    for i=0,2 do begin
      readf, unit, value & trgt_avel[i,j]=double(value)
    endfor
  endfor
 close, unit
 free_lun, unit

 ;--------------------------------------------------
 ; Create and write header using ominas 'dh' routines
 ;--------------------------------------------------
 me_matrix = reform(me_matrix,3,3,ntrgt, /overwrite)
 dh=dh_create()

 ; Sun as star descriptor
 dh_put_value, dh, 'str_lora', rlora[0]
 dh_put_value, dh, 'str_radii', rabc[*,0]
 dh_put_value, dh, 'str_pos', trgt_state[0:2,0]
 dh_put_value, dh, 'str_vel', trgt_state[3:5,0]
 dh_put_value, dh, 'str_time', et
 dh_put_value, dh, 'str_orient', transpose(me_matrix[*,*,0])
 dh_put_value, dh, 'str_name', trgtname[0]
 dh_put_value, dh, 'str_lum', 3.826d+26
 dh_put_value, dh, 'str_sp', 'G2 '

 ; Jupiter, Io, Europa, Ganymede and Callisto as planet descriptors
 for j=ntrgt-1,1,-1 do begin
  dh_put_value, dh, 'plt_lora', rlora[j], object_index=j-1
  dh_put_value, dh, 'plt_radii', rabc[*,j], object_index=j-1
  dh_put_value, dh, 'plt_avel', trgt_avel[*,j], object_index=j-1
  dh_put_value, dh, 'plt_pos', trgt_state[0:2,j], object_index=j-1
  dh_put_value, dh, 'plt_vel', trgt_state[3:5,j], object_index=j-1
  dh_put_value, dh, 'plt_time', et, object_index=j-1
  dh_put_value, dh, 'plt_orient', transpose(me_matrix[*,*,j]), object_index=j-1
  dh_put_value, dh, 'plt_name', trgtname[j], object_index=j-1
 endfor
 
 ; Ring descriptor
 dh_rings, dh, 'jupiter', et, trgt_state[0:2,1], trgt_state[3:5,1]

 ; Camera descriptor
 if(total(c_matrix) EQ 0d0) then $
  begin
   j = where(target EQ trgtname)
   if(j[0] EQ -1) then $
    begin
     nv_message, 'Camera orientation not in found using SPICE', $
                  name='jup_header', /continue
     nv_message, 'Not writing camera descriptor to detached header', $
                  name='jup_header', /continue
     nv_message, 'Do not use pg_get_cameras in OMINAS', $
                  name='jup_header', /continue
    end $
   else $
    begin
     nv_message, 'Camera orientation unknown', name='jup_header', /continue
     nv_message, 'Assuming Optic Axis to Target body, S/C +X to body Pole', $
                  name='jup_header', /continue
     nv_message, 'If this is not correct, use pg_get_cameras_radec in OMINAS', $
                  name='jup_header', /continue
     pos = reform(trgt_state[0:2,j],1,3)
     zdir = v_unit(pos)  ; C-matrix optic axis
     pole_j2000 = transpose(reform(me_matrix[*,*,j],3,3))##tr([0d,0d,1d])
     xdir = v_unit(v_cross(pos,pole_j2000)) ; Want pole || to -Y axis NAC frame
     ydir = v_cross(zdir,xdir)
     c_matrix = [tr(xdir), tr(ydir), tr(zdir)]
     dh_camera, dh, label, et, c_matrix
    end
  end $
 else dh_camera, dh, label, et, c_matrix

 dh_write, dhname, dh

 ;---------
 ; Clean up
 ;---------
cleanup:
 spawn, "'rm' temp1.idl"
 spawn, "'rm' temp1.fort"

end