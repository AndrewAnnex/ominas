; docformat = 'rst'
;===============================================================================
;+
;                            ECLIPSE EXAMPLE
;
;  Created by Joe Spitale
;
;  This example script demonstrates  OMINAS' rendering functionality using the
;  2017 total Solar eclipse as an example. 
;
;  This example file can be executed from the UNIX command line using::
;
;  	ominas eclipse_example-batch
;
;  or from within IDL using::
;
;  	@eclipse_example-batch
;-
;==============================================================================
!quiet = 1

;-------------------------------------------------------------------------
;+
; OBSERVATION PARAMETERS
;
;  Here we set basic parameters of the observation; start and stop times,
;  number of time steps, name of instrument.  Note that the times could also
;  be given numerically.  The interpretation of the times is performed by
;  the translators (see next step):: 
;
;    instrument = 'CAS_ISS_NA'
;    times = ['2017-08-21T19:00:00','2017-08-21T20:00:00']
;    nt = 2
;
;-
;-------------------------------------------------------------------------
instrument = 'CAS_ISS_NA'
times = ['2017-08-21T19:00:00','2017-08-21T20:00:00']
nt = 1



;-------------------------------------------------------------------------
;+
; CAMERA PARAMETERS
;
;  Camera descriptors are obtained for the start and stop times in order
;  to convert the time strings in to numeric times.  The full set of camera
;  descriptors is then obtained by interpolating the numeric start and 
;  stop times.  We could also just give all the times, either as strings, or 
;  numerically.  Note that, because there is no data descriptor, the second 
;  call to PG_GET_CAMERAS creates one and returns it in the first argument.
;  the position and pointing of the cameras wil be changed in the next step:: 
;
;     cds = pg_get_cameras(instrument=instrument, time=times)
;     t_start = bod_time(cds[0])
;     t_stop = bod_time(cds[1])
;     
;     t = (dindgen(nt)/(nt-1) * (t_stop - t_start)) + t_start
;     cd = pg_get_cameras(dd, instrument=instrument, time=t)
;
;-
;-------------------------------------------------------------------------
cds = pg_get_cameras(instrument=instrument, time=times)
t_start = bod_time(cds[0])
t_stop = bod_time(cds[1])

t = t_start
if(nt GT 1) then t = (dindgen(nt)/(nt-1) * (t_stop - t_start)) + t_start
cd = pg_get_cameras(dd, instrument=instrument, time=t)



;-------------------------------------------------------------------------
;+
; SET CAMERA POSITIONS AND POINTING
;
;  If left alone, the camera pointing and positions will be whatever was 
;  returned by the translators (in this case, wherever Cassini was and 
;  where it was pointed at the specified times).  Here we force the cameras to 
;  point at the center of the Earth, and we place the camera along the 
;  Earth-Moon line at 4 times the Eart-Moon distance.  Note the use of 
;  the data descriptor created by PG_GET_CAMERAS:: 
;
;     pd0 = pg_get_planets(dd, od=cd, name='EARTH')
;     pd1 = pg_get_planets(dd, od=cd, name='MOON')
;     pg_reposition, bx=cd, bod_pos(pd0) + (bod_pos(pd1)-bod_pos(pd0))*4, /absolute
;     pg_repoint, cd=cd, bod_pos(pd0)-bod_pos(cd)
;
;-
;-------------------------------------------------------------------------
pd0 = pg_get_planets(dd, od=cd, name='EARTH')
pd1 = pg_get_planets(dd, od=cd, name='MOON')
pg_reposition, bx=cd, bod_pos(pd0) + (bod_pos(pd1)-bod_pos(pd0))*4, /absolute
pg_repoint, cd=cd, bod_pos(pd0)-bod_pos(cd)



;-------------------------------------------------------------------------
;+
; VIEW RENDERED SCENES WITH GRIM
;
;  We input the camera descriptors to GRIM, but let it compute all other
;  descriptors.  Planets are computed within 1 AU of the camera.  Note that 
;  the ordering of the initial overlays is intentional, causing the shadow 
;  to be computed for only the Moon's terminator before other overlays are 
;  computed.  /RENDER_AUTO causes all planes to be rendered intially, and
;  upon any descriptor events, for example, as a result of using GRIM's 
;  NAVIGATE mode:: 
;
;     grim, dd, cd=cd, order=0, xsize=768, ysize=768, /activate, $
;            plt_distmax=const_get('AU'), $
;            over=['terminator:MOON', $
;                  'shadow:MOON', $
;                  'center', $
;                  'limb:EARTH,MOON', $
;                  'planet_grid:EARTH,MOON'], frame='limb', /render_auto
;
;  Note that various renderng settings may be changed using options under
;  View->Render.  A more realistic shadow may be obtained by modifying
;  the NUMBRA value, though it will sow down the rendering significantly.
;
;-
;-------------------------------------------------------------------------
grim, dd, cd=cd, order=0, xsize=768, ysize=768, /activate, $
       plt_distmax=const_get('AU'), $
       over=['terminator:MOON', $
             'shadow:MOON', $
             'center', $
             'limb:EARTH,MOON', $
             'planet_grid:EARTH,MOON'], frame='limb', $
             /render_auto, /render_sky
