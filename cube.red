Red []
#include %pga3d.red

v: 0

ROT-x:  rotor pi / 2  E23 
ROT-y:  rotor pi / 2  E31
ROT-z:  rotor pi / 2  E12 
~ROT-x:  rotor pi / 2 * -1 E23 
~ROT-y:  rotor pi / 2 * -1 E31
~ROT-z:  rotor pi / 2 * -1 E12 

orient-planes: does [
	orto-x: rotor pi / 2 p0 & px 
	orto-y: rotor pi / 2 p0 & py 
	orto-z: rotor pi / 2 p0 & pz 
	~orto-x: rotor pi / 2 * -1 p0 & px 
	~orto-y: rotor pi / 2 * -1 p0 & py 
	~orto-z: rotor pi / 2 * -1 p0 & pz 
]

rota: func [rot /orto][
	if orto [orient-planes]
	foreach p [p0 p1 p2 p3 p4 p5 p6 p7 p8 px py pz cx cy cz] [
		set p rotate get p rot
	] 
	;display
]

trans-x: translator -.05 E01 
trans-y: translator -.05 E02
trans-z: translator -.05 E03 
~trans-x: translator .05 E01 
~trans-y: translator .05 E02
~trans-z: translator .05 E03 

trans-orient-planes: does [
	trans-orto-x: normalized translator -.05 ! normalized p0 & px 
	trans-orto-y: normalized translator -.05 ! normalized p0 & py 
	trans-orto-z: normalized translator -.05 ! normalized p0 & pz 
	~trans-orto-x: normalized translator .05 ! normalized p0 & px 
	~trans-orto-y: normalized translator .05 ! normalized p0 & py 
	~trans-orto-z: normalized translator .05 ! normalized p0 & pz 
]

trans: func [tra /orto][
	if orto [trans-orient-planes]
	foreach i [9 10 11][tra/:i: 0.0]
	tra: normalized tra
	foreach p [p0 p1 p2 p3 p4 p5 p6 p7 p8 px py pz cx cy cz] [
		set p translate get p tra 
	]
]

display: does [
	append clear at bx/draw 11 compose/into lines clear remade
	show [bx camera]
]
 
init-points: does [
	p0: point 0 0 0 
	p1: point -1 -1 -1 p2: point 1 -1 -1 p3: point 1 1 -1 p4: point -1 1 -1 
	p5: point -1 -1 1 p6: point 1 -1 1 p7: point 1 1 1 p8: point -1 1 1
	px: point 1.5 0 0 py: point 0 1.5 0 pz: point 0 0 1.5 
	cx: point 1 0 0 cy: point 0 1 0 cz: point 0 0 1
]
init-points
orient-planes
trans-orient-planes
cam: 11.5

make-pair: func [l /local x y z][
	x: to-path reduce [l 14]
	y: to-path reduce [l 13]
	z: to-path reduce [l 12]
	;if cam + (get z) > 0 [
		to-paren compose [
			as-pair 
			(x) * cam * 100 / (to-paren compose [cam + (z)])
			(y) * cam * 100 / (to-paren compose [cam + (z)])
		]
	;]
]

lines: collect [
	keep 'pen keep 'pink
	foreach [l1 l2] [p0 [px py pz]] [
		forall l2 [keep reduce ['line make-pair l1 make-pair l2/1]]
	]
	keep 'pen keep 'black
	foreach [l1 l2] [p1 [p2 p5] p2 [p3 p6] p3 [p4 p7] p4 [p1 p8] p5 [p6 p8] p6 [p7] p7 [p8] ] [
		forall l2 [keep reduce ['line make-pair l1 make-pair l2/1]]
	]
	foreach c [cx cy cz][keep reduce ['circle make-pair c 1]]
	foreach t [px py pz][keep reduce ['text make-pair t form t]]
]
lines2: compose/deep lines

remade: make block! 100
system/view/auto-sync?: off 
view compose/deep [
	title "PGA3D"
	below
	bx: box 700x700
	draw [translate 350x350 pen gray line -350x0 350x0 line 0x-350 0x350 (lines2)] 
	return
	sliders: panel [origin 0x0
		style legend: text 20
		text "OUTER AXIS" return
		text "Rotate:" return
		legend "X:" slider [if face/data <> v [either face/data > v [rota ROT-x][rota ~ROT-x] v: face/data display]] return
		legend "Y:" slider [if face/data <> v [either face/data > v [rota ROT-y][rota ~ROT-y] v: face/data display]] return
		legend "Z:" slider [if face/data <> v [either face/data > v [rota ROT-z][rota ~ROT-z] v: face/data display]] return
		text "Translate:" return
		legend "X:" slider [if face/data <> v [either face/data > v [trans trans-x][trans ~trans-x] v: face/data display]] return
		legend "Y:" slider [if face/data <> v [either face/data > v [trans trans-y][trans ~trans-y] v: face/data display]] return
		legend "Z:" slider [if face/data <> v [either face/data > v [trans trans-z][trans ~trans-z] v: face/data display]] return
		text "INNER AXIS" return
		text "Rotate:" return
		legend "X:" slider [if face/data <> v [either face/data > v [rota/orto orto-x][rota/orto ~orto-x] v: face/data display]] return
		legend "Y:" slider [if face/data <> v [either face/data > v [rota/orto orto-y][rota/orto ~orto-y] v: face/data display]] return
		legend "Z:" slider [if face/data <> v [either face/data > v [rota/orto orto-z][rota/orto ~orto-z] v: face/data display]] return
		text "Translate:" return
		legend "X:" slider [if face/data <> v [either face/data > v [trans trans-orto-x][trans/orto ~trans-orto-x] v: face/data display]] return
		legend "Y:" slider [if face/data <> v [either face/data > v [trans trans-orto-y][trans/orto ~trans-orto-y] v: face/data display]] return
		legend "Z:" slider [if face/data <> v [either face/data > v [trans trans-orto-z][trans/orto ~trans-orto-z] v: face/data display]] return
		text "CAMERA DISTORTION" return
		camera: slider data .5 [cam: face/data * 20 + 1.5 display]
	]
	button "Initial" [
		foreach-face/with sliders [face/data: 0%][face/type = 'slider] 
		show sliders
		init-points 
		orient-planes
		trans-orient-planes
		camera/data: .5
		cam: 11.5
		display 
	]
]
