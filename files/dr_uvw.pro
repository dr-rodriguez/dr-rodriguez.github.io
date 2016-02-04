;+
; NAME:
;     DR_UVW
; PURPOSE:
;     Calculate the heliocentric Galactic space velocity (U,V,W) of star for a range of radial velocites.
;     Uses GAL_UVW from the IDL astronomy library, but with U towards the galactic center. 
; EXPLANATION:
;     Calculates the Galactic space velocity U, V, W of star given its 
;     coordinates, proper motion, distance
;     Will use a range of radial velocites to return a table of UVW values.
;     Will also mark with an asterisk those radial velocities that give UVW within the "good UVW box" for 
;     young stars as defined by Zuckerman & Song ARAA 2004, 42, 685
; CALLING SEQUENCE:
;     DR_UVW, RA, DEC, DIST, PMRA, PMDEC, [/PMCOS, RVMIN=RVMIN, RVMAX=RVMAX, RVSTEP=RVSTEP]
; OUTPUT:
;     A table of UVW for the given RV range. 
; REQUIRED INPUT KEYWORDS:
;     RA       Right Ascension of target in degrees
;     DEC      Declination of target in degrees
;     DIST     Distance in parsecs
;     PMRA     Proper motion in RA in mas/yr. If /PMCOS is not set then this should be PMRA*COS(DEC)
;     PMDEC    Proper motion in DEC in mas/yr
; OPTIONAL INPUT KEYWORD:
;     /PMCOS  Multiply the proper motion in RA by cos(DEC)
;     RVMIN   Radial velocity to start in (in km/s). Default is -80km/s.
;     RVMAX   Radial velocity to end in (in km/s). Default is 80km/s.
;     RVSTEP  Radial velocity step size in km/s. Default is 10km/s.
; METHOD:
;      Uses GAL_UVW which follows the general outline of Johnson & Soderblom (1987, AJ, 93,864)
;      and the J2000 transformation matrix to Galactic coordinates is taken from  
;      the introduction to the Hipparcos catalog.   
; REVISION HISTORY:
;      Written, D. Rodriguez                       February   2009
;-

PRO DR_UVW, RA, DEC, DIST, PMRA, PMDEC, PMCOS=PMCOS, RVMIN=RVMIN, RVMAX=RVMAX, RVSTEP=RVSTEP

ON_ERROR, 2

IF N_PARAMS() LT 5 THEN BEGIN
  print, 'Syntax - DR_UVW, RA, DEC, DIST, PMRA, PMDEC, /PMCOS, RVMIN=RVMIN, RVMAX=RVMAX, RVSTEP=RVSTEP
  RETURN
ENDIF

IF n_elements(pmcos) NE 0 OR arg_present(pmcos)   THEN pmra   = pmra*cos(dec/!RADEG)
IF n_elements(rvmin) EQ 0 AND ~arg_present(rvmin)   THEN rvmin  = -80.
IF n_elements(rvmax) EQ 0 AND ~arg_present(rvmax)   THEN rvmax  = 80.
IF n_elements(rvstep) EQ 0 AND ~arg_present(rvstep) THEN rvstep = 10.

len = LONG((rvmax-rvmin)/rvstep) + 1
rv = findgen(len) * rvstep + rvmin

print, 'RV  U  V  W'
FOR i=0, len-1 DO BEGIN
  GAL_UVW, u, v, w, RA=ra, DEC=dec, PMRA=pmra, PMDEC=pmdec, VRAD=rv[i], DISTANCE=dist 
  u = -u  ; Convert U to be towards the galactic center

  ; Check if within the "good UVW box" of Zuckerman & Song ARAA 2004, 42, 685
  IF ( (U GE -15) AND (U LE 0) AND (V GE -34) AND (V LE -10) AND (W GE -20) AND (W LE 3) ) THEN BEGIN
    print, rv[i], u, v, w, ' *'
  ENDIF ELSE print, rv[i], u, v, w

ENDFOR

END