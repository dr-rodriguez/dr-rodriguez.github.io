; David Rodriguez
; Mar 4, 2009
; Plot object elevation as a function of time for the given observatory, month, day, and year
; Can also output to an eps file if a filename is given

PRO sky_elev, ra, de, obs=obs, YR=yr, MONTH=mon, DAY=day, FILE=file

ON_ERROR, 2

IF N_PARAMS() LT 2 THEN BEGIN
  print, 'SKY_ELEV, RA, DEC, [OBS=obs, YR=yr, MONTH=mon, DAY=day, FILE=file]'
  print, 'CTIO observatory, on March 15, 2009 is used by default'
  print, 'Be sure to include .eps in the file name'
  return
ENDIF

dev = 0
IF n_elements(obs) EQ 0 AND ~arg_present(obs) THEN obs='ctio'
IF n_elements(yr) EQ 0 AND ~arg_present(yr) THEN yr=2009
IF n_elements(mon) EQ 0 AND ~arg_present(mon) THEN mon=3
IF n_elements(day) EQ 0 AND ~arg_present(dau) THEN day=15
IF n_elements(file) NE 0 OR arg_present(file) THEN dev=1

observatory, obs, obsinfo
tz = obsinfo.tz
midn = 12 + tz

nhrs = 48
hr = findgen(nhrs) * 24./nhrs - 12
ut = hr + tz

;CT2LST, lst, -1*obsinfo.longitude, -1*obsinfo.tz, 0, day, mon, yr

jdcnv, yr, mon, day, ut, jd

;SUNPOS, jd, ra_s, dec_s
ra = replicate(ra,n_elements(jd))
de = replicate(de,n_elements(jd))
eq2hor, ra, de, jd, alt, az, OBSNAME=obs

for i=0, n_elements(ra)-1 do print, ra[i], de[i], jd[i], hr[i], ut[i], alt[i], az[i]

; Start plotting
IF dev THEN BEGIN
  !p.charthick = 4 ;5
  !p.charsize = 1. ;1.2
  !p.thick = 5 ;6
  !x.thick = 3 ;6
  !y.thick = 3 ;6
SET_PLOT, 'X'
Device, Decomposed=0
SET_PLOT, 'PS', /interpolate, /copy
DEVICE, FILENAME=file, /encapsulated, /color, bits_per_pixel=8
ENDIF

xmin = hr[0]
xmax = hr[n_elements(hr)-1]
ymin = -30
ymax = 90
plot, [0], /nodata, xrange=[xmin,xmax], yrange=[ymin, ymax], xstyle=5, ystyle=1, $
  ymargin=[4,4], xmargin=[10,6], ytitle='Altitude (deg)'

; Informative information
dawn = 6;+12
dusk = 19-24
oplot, [dawn,dawn], [-90,90], linestyle=1, color=fsc_color('blue')
oplot, [dusk,dusk], [-90,90], linestyle=1, color=fsc_color('blue')
oplot, [-200,200], [30,30], linestyle=2, color=fsc_color('red')
; Ground
xg = [xmin,xmax,xmax,xmin]
yg = [0, 0, ymin, ymin]
polyfill, xg, yg, color=fsc_color('dark green')
axis, yaxis=0, yrange=[ymin, ymax], ystyle=1
axis, yaxis=1, yrange=[ymin, ymax], ystyle=1

; Local Time
nice = [-12,-9,-6,-3,0,3,6,9,12]
tickv = nice
ind = where(tickv LT 0)
IF ind[0] GT -1 THEN tickv[ind] = tickv[ind]+24
tickv = STRCOMPRESS(STRING(tickv))
AXIS, xaxis=0, xtitle='Local Time', xrange=[xmin,xmax], xstyle=1, xtickv=nice, $
  xtickname=tickv, xticks=N_ELEMENTS(tickv)-1

; UT Time
tickv = nice + tz
ind = where(tickv LT 0)
IF ind[0] GT -1 THEN tickv[ind] = tickv[ind]+24
tickv = long(tickv)
tickv = STRCOMPRESS(STRING(tickv))
AXIS, xaxis=1, xtitle='UT Time', xrange=[xmin,xmax], xstyle=1, xtickv=nice, $
  xtickname=tickv, xticks=N_ELEMENTS(tickv)-1

; The actual data
oplot, hr, alt

IF dev THEN BEGIN
DEVICE, /CLOSE
SET_PLOT, 'X'
Device, Decomposed=1
  !p.charthick = 0
  !p.charsize = 0
  !p.thick = 0
  !x.thick = 0
  !y.thick = 0
  print, file, ' has been created.'
ENDIF

print, 'Done.'

END