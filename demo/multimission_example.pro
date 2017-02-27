;=======================================================================
;+
; MULTI-MISSION EXAMPLE
; ---------------------
;
;   Created by Joe Spitale
;   
;   Feb 2017
;
;    This example file loads images from various missions onto planes of a 
;    GRIM window and computes the centers of all available planets for each
;    image to demonstrates OMINAS' multi-mission capabilities.  
;
;    This example file can be executed from the UNIX command line using::
;
;     idl multimission_example.pro
;
;    or from within IDL using::
;
;     @multimission_example.pro
;-
;=======================================================================
grim, over='planet_center', './data/' + $
                  ['c3440346.gem', $			; Voyager
                   'N1350122987_2.IMG', $		; Cassini
                   '2100r.img']				; Galileo
                   