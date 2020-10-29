Red [
	Description: "3D projective geometric algebra functions (Clifford [2 0 1])"
]
#include %algebra.red

cpy: func [a [series! object!]][copy/deep a]
nearby: 4
axis: none
shaped?: no

norm-plane: func [
	plane [vector!]
	/local
		p [block!]
][
	p: grade/only plane 1
	either 0 = n: sqrt system/words/add system/words/add p/2 ** 2 p/3 ** 2 p/4 ** 2 [p/1][n]
]

norm-line: func [
	line [vector!]
	/dual
	/local 
		n [vector!]
][
	n: line * line
	case [
		all [n/1 < 0 n/16 <> 0] [
			m: -1 * n
			m/1: sqrt m/1 
			m/16: m/16 / (2 * m/1)
			return m
		]
		not zero? n/1 [absolute n/1]
		true [
			sqrt sum multiply line line
		]
	]
]

norm-point: func [
	point [vector!]
	/local
		p [block!]
][
	p: grade/only point 3
	either 0 = p/4 [sqrt system/words/add system/words/add p/1 ** 2 p/2 ** 2 p/3 ** 2][p/4]
]

norm-I: func [vec [vector!]][last vec]

norm: func [vec [vector!] return: [float!]][
	(absolute (first vec * conjugate vec)) ** 0.5
]

normalized: func [
	vec [vector!]
	/plane
	/line
	/point
	/I
	/local n
][
	case [
		plane [w: vec/2 head change at vec * (1 / norm-plane vec) 2 w]
		line  [
			n: norm-line vec
			either vector? n [
				vec * n * (1 / (n/1 ** 2))
			][
				vec * (1 / n)
			]
		]
		point [vec * (1 / norm-point vec)]
		I     [vec * (1 / norm-I     vec)]
		true  [vec * (1 / norm       vec)]
	]
]

len:   function [
	"Length of vector" 
	v [vector!]
	/grade g
][
	g: any [g 1]
	sqrt sum (a: grade v g) * a
]

cross: func [a [vector!] b [vector!]][(a * b) _ (b * a) * 0.5]
¤: make op! :cross

;Plücker inner product
plücker: func [p [vector!] q [vector!] /local res [block!]][
	;res: grade/only v 2
	(p/6 * q/11) + (p/7 * q/10) + (p/8 * q/9) +
	(p/9 * q/8) + (p/10 * q/7) + (p/11 * q/6)
]

rot: func [
	"Create rotator"
	ang [integer! float!] "Angle of rotation"
	axis [vector!] "Axis of rotation"
	/radians "Angle is given in radians"
][
	ang: ang / 2
	either radians [
		(cos ang) + ((sin ang) * axis)
	][
		(cosine ang) + ((sine ang) * axis)
	]
]

;rot2: func [ang bivec][cosine]

rotate: func [
	"Rotate blade by angle"
	blade [vector! object!]      "Rotated blade or object"
	rotor  [vector!]             "Rotor or axis of rotation (if angle is specified)"
	/angle ang [integer! float!] "Angle of rotation"
	/radians
	;/local
	;	rotor [vector!]
][
	if angle [
		rotor: either radians [
			rot/radians ang rotor
		][
			rot ang rotor
		]
	]
	rotor * blade * ~ rotor
]

pln: function [
	x [integer! float!] 
	y [integer! float!] 
	z [integer! float!] 
	w [integer! float!] 
][create/grade reduce [w x y z] 1 ] ;-1 * 

vec: func [
	"Line by Plücker coordinates"
	a [integer! float!] 
	b [integer! float!] 
	c [integer! float!] 
	d [integer! float!] 
	e [integer! float!] 
	f [integer! float!] 
][create/grade reduce [a b c d e f] 2]

pnt: func [
	x [integer! float!] 
	y [integer! float!] 
	z [integer! float!] 
	w [integer! float!] 
][create/grade reduce [z y x w] 3]

i-plane: func [p [scalar!]][p * e0]
e-plane: func [x [scalar!] y [scalar!] z [scalar!]][pln x y z 0]
i-line:  func [x [scalar!] y [scalar!] z [scalar!]][vec x y z 0 0 0]
e-line:  func [x [scalar!] y [scalar!] z [scalar!]][vec 0 0 0 z y x]
i-point: func [x [scalar!] y [scalar!] z [scalar!]][pnt z y x 0]
e-point: func [p [scalar!]][p * e123]

get-e-plane: func [vec [vector!] /only /local res][
	either only [
		next grade/only vec 1
	][
		res: grade vec 1
		res/2: 0.0
		res
	]
]
get-i-line: func [vec [vector!] /only][
	either only [
		copy/part grade/only vec 2 3
	][
		head change at init 0 6 copy/part grade/only vec 2 3
	]
]
get-e-line: func [vec [vector!] /only][
	either only [
		copy at grade/only vec 2 4
	][
		head change at init 0 9 skip grade/only vec 2 3
	]
]
get-i-point: func [vec [vector!] /only /local res][
	either only [
		copy/part grade/only vec 3 3
	][
		res: grade vec 3
		res/15: 0.0
		res
	]
]

par: func [
	"Project component of v1 parallel to v2"
	v1 [vector! object!] "Vector or object projected"
	v2 [vector!] "Blade onto which it is projected"
][v1 | v2 * v2]

perp: func [
	"Project component of v1 perpendicular to v2"
	v1 [vector! object!] "Vector or object projected"
	v2 [vector!] "Blade from which it is rejected"
][v1 ^ v2 * v2]


options: func [opts [block!]][do opts]

get-point: func [point][
	switch type?/word point [
		block!  [pnt point/1 point/2 point/3 1]
		word!   [get-point get point]
		vector! [point]
	]
]

figure: func [
	"Prepare object for given type of figure"
	'type [word!] "Type of figure"
	points [vector! block!] "Defining point(s) for the figure; as block, it may contain vectors or blocks of coordinates for each point"
	/with 
		rest [block! integer! word!] "Rest of parameters"
	/name 'nam [lit-word! none!]
	/fill fill-clr
	/pen  pen-clr
	return: [object!]
][
	points: collect [
		switch type?/word points [
			block! [
				forall points [
					keep get-point points/1 
				] 
			]
			vector! [keep points]
		]
	]
	object compose/only [
		type: (to-lit-word type) 
		name: (nam)
		points: (points) 
		rest: (rest)
		fill: (fill-clr)
		pen: (pen-clr)
	]
]

point: func [
	x [integer! float!] 
	y [integer! float!] 
	z [integer! float!] 
	return: [object!]
][
	;figure/with circle reduce [pnt x y 1] 1
	pnt x y z 1
]

line:  func [
	p1 [vector! block!] 
	p2 [vector! block!] 
	return: [object!]
][
	figure line reduce [
		either vector? p1 [p1] [pnt p1/1 p1/2 p1/3 1] 
		either vector? p2 [p2] [pnt p2/1 p2/2 p1/3 1]
	]
]

lines: func [
	points [block!]
	return: [object!]
][
	figure line points
]

rectangle: func [
	p1 [block! vector!]
	p2 [block! vector!]
	p3 [block! vector!]
	p4 [block! vector!]
	/fill clr
	return: [object!]
][
	figure/fill polygon reduce [p1 p2 p3 p4] clr
]

triangle: func [
	p1 [block! vector!] 
	p2 [block! vector!] 
	p3 [block! vector!]
	return: [object!]
][
	figure polygon reduce [p1 p2 p3]
]

polygon: func [points [block!] /name 'nam /fill clr][
	either nam [
		figure/name/fill polygon points :nam clr
	][
		figure/fill polygon points clr
	]
]

circle: function [
	center [block! vector!] 
	radius [integer! float!] 
	axis   [vector!]
	return: [object!] 
	/local 
		points [block!]
		angle [integer!]
][
	points: make block! 12 
	if vector? center [center: copy/part grade/only center 3 3]
	rotor: rot 30 axis
	p: point
	repeat i 12 [
		repend/only points [
			radius * (cosine angle: i * 30) + center/1 
			radius * (sine angle) + center/2
		]
	] 
	figure/with spline points [closed]
]

circle2: function [
	center [block! vector!] 
	radius [integer! float!] 
	return: [object!] 
	/local 
		points [block!]
		angle [integer!]
][
	figure/with circle center radius
]

center-z: func [obj [object!] /local out [float!]][
	out: 0.0
	foreach p obj/points [out: out + p/12]
	out / length? obj/points
]

shape: func [figs [block!] /local figures [block!]][
	out: clear []
	figures: []
	shaped?: yes
	reduce/into figs clear figures
	sort/compare figures func [a b][
		case [
			all [object? a object? b] [(center-z a) >= center-z b]
			all [object? a vector? b] [(center-z a) >= b/12]
			all [vector? a object? b] [a/12 >= center-z b]
			true [a/12 >= b/12]
		]
	]
	to-paren append/only out figures
]

map: func [block fn][forall block [block/1: fn block/1]]

algebra [3 0 1]

ideal-plane: e0
origin-point: e123
tp: none

code: none
ctx: context [
	origin: 250x250
	scale:  100
	mv: 0x0
	bx: none
	rate: none
	el: none
	rotation-points: none
	rotation-points2: clear []
	ax: reduce ['x e23 'y e13 'z e12 'esc none]
	degrees: 5
	cam: 10
	sides: clear []
	ofs: s1: s2: dr: side: axs: none
	ready?: yes
	tick: 0
	
	i-plane?: func [elem [vector!]][
		all [not zero? elem/2 zero? elem/3 zero? elem/4 zero? elem/5]
	]
	
	plane?: func [elem [vector!] /local el][
		el: at elem 2
		repeat i 4 [if not zero? el/:i [return true]]
		false
	]
	
	i-line?: func [elem [vector!]][
		all [
			not zero? elem/6 not zero? elem/7 not zero? elem/8 
			zero? elem/9 zero? elem/10 zero? elem/11
		]
	]

	e-line?: func [elem [vector!]][
		all [
			zero? elem/6 zero? elem/7 zero? elem/8 
			not zero? elem/9 not zero? elem/10 not zero? elem/11
		]
	]
	
	line?: func [elem [vector!]][
		el: at elem 6
		repeat i 6 [if not zero? el/:i [return true]]
		false
	]
	
	ideal-point?: func [elem [vector!]][zero? elem/15]
	
	point?: func [elem [vector!] /local el][
		el: at elem 12
		repeat i 4 [if not zero? el/:i [return true]]
		false
	]
	
	render: func [elem /local ln a b c d po pt x y z w trans t l-weight][
		l-weight: 5
		switch type?/word elem [
			;vector! [repend bx/draw ['line 0x0 p: as-pair scale * elem/2 scale * elem/3]]
			;set-word! [append bx/draw elem]
			vector! [
				case [
					plane? elem [
					;	set [w x y z] grade/only elem 1
					;	d: create/grade reduce [0 0 0 z y x] 2
					;	po: w * normalized/point elem ^ d
					;	set [a b c d] grade/only po 3
						
					;	append bx/draw 'push 
					;	repend/only bx/draw [
							;'fill-pen 'radial 0.0.0.254 0.0.0.239 
							;'pen 'silver 
							;'circle 0x0 to-integer scale * w ;e0 sphere
							;'line 0x0 p: as-pair cam * scale * x / (cam + z) ;plane orientation normal line
							;					 cam * scale * y / (cam + z)
							;'circle as-pair scale * x scale * y 1
							;'circle p 1
					;		'pen 'red   ;point on e0 sphere where plane touches
					;		'circle as-pair cam * scale * c / (cam + a) cam * scale * b / (cam + a) 1
					;		'pen 'orange
					;		'circle as-pair scale * c scale * b 1
					;	]
						;p1: 
					]
					;all [point? elem ideal-line? elem][
					;	repend bx/draw [
					;		'circle
					;		p: to-pair copy next grade/only multiply scale grade elem 2 2
					;		scale * elem/4
					;	]
					;]
					line? elem [
						set [d e f] skip grade/only ln: l-weight * elem 2 3 ;
						set [c b a] grade/only step: normalized/point e123 | elem * elem 3
						
						;end: as-pair scale * (f + a) scale * (e + b) ;/ (cam + c + d) 
						end: as-pair cam * scale * (f + a) / (cam + c + d) cam * scale * (e + b) / (cam + c + d)  ;
						ln: -1 * ln
						set [d e f] skip grade/only ln 2 3
						start: as-pair cam * scale * (f + a) / (c + d + cam) cam * scale * (e + b) / (c + d + cam); 
						repend/only bx/draw ['line start end]
					]
					point? elem [
						set [z y x w] grade/only elem 3
						;repend bx/draw ['circle tp: as-pair scale * x / w scale * y / w 1]
						tp: as-pair cam * scale * x / (cam + z) cam * scale * y / (cam + z)
						append bx/draw 'push
						repend/only bx/draw [
							'pen 'silver
							;'line 0x0 tp 
							'circle as-pair scale * x scale * y 1
						]
						repend bx/draw ['circle tp 1]
					]
				]
			]
			pair!   [mv: elem]
			string! [repend bx/draw ['text tp + mv elem]]
			object! [
				;probe elem
				if elem/fill [repend bx/draw ['fill-pen elem/fill]]
				if elem/name [append bx/draw to-set-word elem/name]
				append bx/draw to-word elem/type
				foreach e elem/points [
					switch type?/word e [
						vector! [
							;print e
							append bx/draw p: as-pair cam * scale * e/14 / (cam + e/12)
													  cam * scale * e/13 / (cam + e/12)
							
							;append bx/draw p: to-pair 
							;	copy/part next 
							;		reverse 
							;			grade/only 
							;				multiply scale grade e 3 
							;				3 
							;		2
						]
						word! []
						pair!   [mv: e]
						string! [repend bx/draw ['text p + mv e]]
					]
				]
				either elem/rest [append bx/draw elem/rest][]
			]
			word! tuple! [repend bx/draw ['pen elem]]
			issue! [repend bx/draw [
				'fill-pen case [
					#off = elem ['off] 
					error? try [t: get to-word elem][hex-to-rgb elem] 
					true [t]
				]
			]]
			integer! float! [repend bx/draw ['line-width elem]]
			;block! [append body-of :bx/actors/on-time anim/enabled?: yes elem rate: 10]
			block! [
				rotation-points: elem 
				rot-code: find/tail code block!
			]
		]
	]
	
	distance-3d: func [x y z][sqrt (x ** 2) + (y ** 2) + (z ** 2)]
	distance: func [p1 /from p2][
		if from [p1: p1 - p2]
		sqrt system/words/add p1/x ** 2 p1/y ** 2
	]
	distance-xy: func [blade][
		sqrt system/words/add blade/13 ** 2 blade/14 ** 2
	]

	rotate-point: func [p direction reduced /local r ref found][
		either block? p [
			foreach r p [rotate-point r direction reduced]
		][	
			set p grade rotate/angle get p ax/:axis -1 * direction * degrees 3
			unless found: find/tail code p [
				found: find/tail code/options p
			]
			ref: next found
			change/part ref next reverse grade/only p': get p 3 3
			append reduced p'
			if string? ref/4 [append reduced ref/4]
		]
	]
	
	rotate-point2: func [p axis direction reduced /local r ref found][
		set p grade rotate/angle get p axis direction * degrees 3
		unless found: find/tail code p [
			found: find/tail code/options p
		]
		ref: next found
		change/part ref next reverse grade/only p': get p 3 3
		append reduced p'
		;if string? ref/4 [append reduced ref/4]
	]

	between?: function [
	"Is angle c between angles a and b?"
		a [float!] b [float!] c [float!]
	][
		a-b: absolute a - b
		case [
			180 > a-b [all [c >= min a b c <= max a b]]
			180 < a-b [any [c <= min a b c >= max a b]]
		]
	]
	
	inside?: function [s ev][
		s12: s/2 - s/1
		s14: s/4 - s/1
		s1ev: ev - s/1
		a: arctangent2 s12/y s12/x
		b: arctangent2 s14/y s14/x
		e: arctangent2 s1ev/y s1ev/x
		all [
			between? a b e 
			s32: s/2 - s/3
			s34: s/4 - s/3
			s3ev: ev - s/3
			c: arctangent2 s32/y s32/x
			d: arctangent2 s34/y s34/x
			f: arctangent2 s3ev/y s3ev/x
			between? c d f
		]
	]
	
	set-direction: func [/local sid pl1 d11 d12 d21 d22 l1 l2 dp1 dp1' dp2][
		;plane of touched side
		sid: get side
		pl1: (get sid/1) & (get sid/2) & (get sid/3)
		
		;point of first touch
		ofs: ofs - origin
		d11: create/grade reduce [-1 ofs/y / scale ofs/x / scale 1] 3
		d12: create/grade reduce [ 1 ofs/y / scale ofs/x / scale 1] 3
		l1: d11 & d12
		dp1: normalized/point l1 ^ pl1
		
		;point after drag 5 points away
		eo: eo - origin
		d21: create/grade reduce [-1 eo/y / scale eo/x / scale 1] 3
		d22: create/grade reduce [ 1 eo/y / scale eo/x / scale 1] 3
		l2: d21 & d22
		dp2: normalized/point l2 ^ pl1
		
		;first point rotated by 1 degree
		dp1': rotate/angle dp1 axs 1
		
		;if distance after rotation of first point is shorter -> clockwise, otherwise -> ccw
		ddr: either (distance-xy dp2 - dp1) > (distance-xy dp2 - dp1')[1][-1]
	]
	
	system/view/auto-sync?: no
	set 'play func [/local ar bt reduced rotuced ref] bind [
		shaped?: no
		reduced:  clear []
		rotuced: clear []
		view lay: layout/flags/options [
			title "GA playground"
			below
			pan: panel [
				origin 0x0
				ar: area 340x100 with [text: read %rubik222.red]
				opts: panel [
					origin 0x0 ;below 
					text "Scale:" 40 field 30 data scale on-change [
						scale: face/data 
						bt/actors/on-click bt none
					]
					bt: button "Show" [/local [p elem e draw]
						mv: 0x0
						draw: clear at bx/draw 15  ;draw - for parsing?
						reduce/into code clear reduced 
						either shaped? [
							compose/into reduced clear rotuced 
							foreach elem rotuced [render elem]
						][
							foreach elem reduced [render elem]
						]
						;probe at bx/draw 15
						set-focus bx
						show lay
					] on-down [
						code: bind load ar/text self 
						;bx/rate: none 
						;clear body-of :bx/actors/on-time
					] 
					return
					text "Origin:" 40 
					orig: drop-list data ["Center" "Top-left" "Bottom-left"] select 1 on-change [
						origin: switch face/selected [
							1 [bx/size / 2]
							2 [0x0]
							3 [as-pair 0 bx/size/y - 1]
						]
						bx/draw/translate: origin
						bx/draw/8: as-pair 0 - origin/x 0
						bx/draw/9: as-pair bx/size/x - origin/x 0
						bx/draw/11: as-pair 0 0 - origin/y
						bx/draw/12: as-pair 0 bx/size/y - origin/y
						show bx
					] 
					return
					check "Axis" data true 40 on-change [bx/draw/pen: pick [silver off] face/data show bx]
					check "Grid" data true 40 on-change [bx/draw/2/4/pen: pick [snow off] face/data show bx]
					;anim: button 50 "Go" disabled [
					;	switch face/text [
					;		"Go"   [probe bx/rate: rate face/text: "Stop"]
					;		"Stop" [bx/rate: none face/text: "Go"]
					;	]
					;]
				]
			]
			bx: box 500x500 white draw [
				push [fill-pen pattern 10x10 [pen snow line 9x0 0x0 0x9] pen silver box 0x0 499x499]
				translate 250x250
				pen silver
				line -250x0 250x0
				line 0x-250 0x250
				pen black
			] on-down [local [draw s p found];probe code probe face/draw
				system/view/auto-sync?: off
				ref: ofs: side: none
				draw: tail face/draw ;Parsing from tail to head
				parse draw [any [p:
					;Grabing named points
					'circle s: 2 skip 'text if (nearby >= distance (event/offset - origin) - s/1) skip s: (
						ref: skip find code s/1 -3
						exit
					) ;(return true)
					;Grabing polygons
					| 'polygon s: if (inside? s event/offset - origin) (
						;pce: to-word copy/part skip 
						found: find/reverse find ar/text rejoin [#"(" side: next form to-word first skip s -2 #")"] #":" ;-3 3 
						collect/into [
							loop 3 [
								found: find/tail found #"(" 
								unless find/match found side [keep to-word copy/part found 2]
							]
						] clear sides
						set [s1 s2] reduce sides
						set [s1 s2] compose [(intersect s1 centers) (intersect s2 centers)] 
						ofs: event/offset
						s1d: arctangent2 0 - pick get s1 13 pick get s1 14 
						s2d: arctangent2 0 - pick get s2 13 pick get s2 14 
						ss1: grade/only s1: get s1 3
						ss2: grade/only s2: get s2 3
						map ss1 func [a][round/to a .01]
						map ss2 func [a][round/to a .01]
						side: to-word side
						dr: none
						exit
					)
					| if (head? p) (return false)
					| (p: back p) :p
				]]
			] 
			on-time [local [p]
				clear reduced 
				foreach p rotation-points2 [
					rotate-point2 p axs ddr reduced
				]
				repend reduced rot-code
				either shaped? [
					compose/into reduced clear rotuced 
					foreach elem rotuced [render elem]
				][
					foreach elem reduced [render elem]
				]
				set-focus bx
				bt/actors/on-click bt none
				show bx
				if 30 <= tick: tick + 1 [face/rate: none ready?: yes]
			]
			on-up [system/view/auto-sync?: on]
			all-over on-over [
				local [e pin f m faces2]
				if event/down? [
					e: event/offset 
					case [
						ref [
							either event/alt-down? [
								unless pin [pin: e]
								ref/3: ref/3 + (to-integer e/x - pin/x) / scale
							][
								pin: none
								change/part ref reduce [
									e/x - origin/x / scale 
									e/y - origin/y / scale
								] 2 
							]
						]
						ofs [
							if ready? [
								if 5 < distance d: (eo: event/offset) - ofs [
									dd: arctangent2 d/y d/x
									a: any [
										20 > absolute (absolute dd) - (absolute s1d) 
										20 > absolute (absolute dd - s1d) - 180
									]
									b: any [
										20 > absolute (absolute dd) - (absolute s2d) 
										20 > absolute (absolute dd - s2d) - 180
									]
									faces2: collect [
										foreach f faces [
											if all [
												m: get first intersect get f centers
												any [
													all [
														a not b
														ss2/1 = round/to m/12 .01
														ss2/2 = round/to m/13 .01
														ss2/3 = round/to m/14 .01
														ss2/4 = round/to m/15 .01
														axs: s2
													]
													all [
														b not a
														ss1/1 = round/to m/12 .01
														ss1/2 = round/to m/13 .01
														ss1/3 = round/to m/14 .01
														ss1/4 = round/to m/15 .01
														axs: s1
													]
												]
											][keep f]
										]
									] 
									;change/part at axis 9 probe reverse next grade/only axs 1 3
									if axs [
										axs: create/grade append copy [0 0 0] to-block copy/part at axs 12 3 2
										clear rotation-points2
										foreach m collect [;m - piece
											foreach f faces2 [;f - face having same central point
												keep to-word copy/part skip find/reverse find ar/text rejoin [#"(" form f #")"] #":" -3 3
											]
										][append rotation-points2 get m]
										rotation-points2: unique rotation-points2
										
										set-direction
										
										tick: 0
										ready?: no
										degrees: 3
										face/rate: 20
									]
								]
							]
						]
					]
					show face
				]
			]
			on-wheel [local [p p' elem e draw ref]
				degrees: 5
				if ax/:axis [
					mv: 0x0
					clear at bx/draw 15
					system/view/auto-sync?: off
					clear reduced 
					foreach p rotation-points [
						rotate-point p event/picked reduced
					]
					repend reduced rot-code
					either shaped? [
						compose/into reduced clear rotuced 
						foreach elem rotuced [render elem]
					][
						foreach elem reduced [render elem]
					]
					set-focus bx
					show bx
					
				]
			]
			on-key [axis: switch event/key [#"x" ['x] #"y" ['y] #"z" ['z] #"^[" ['esc]]]
			do [
				set-focus ar
				bx/draw/translate: bx/size / 2
			]
		] 'resize [
			actors: object [
				on-resizing: func [face event][
					pan/size/x: face/size/x - 20
					opts/offset/x: face/size/x - 171
					ar/size/x: opts/offset/x - 10
					bx/size: as-pair face/size/x - 20 face/size/y - pan/size/y - 30
					bx/draw/2/9: bx/size - 1
					orig/actors/on-change orig none
				]
			]
		]
	] algebra-ctx
]
