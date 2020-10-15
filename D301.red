Red [
	Description: "3D projective geometric algebra functions (Clifford [2 0 1])"
]
#include %algebra.red

cpy: func [a [series! object!]][copy/deep a]
nearby: 4
axis: none

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

figure: func [
	"Prepare object for given type of figure"
	'type [word!] "Type of figure"
	points [vector! block!] "Defining point(s) for the figure; as block, it may contain vectors or blocks of coordinates for each point"
	/with 
		rest [block! integer! word!] "Rest of parameters"
	return: [object!]
][
	points: collect [
		switch type?/word points [
			block! [
				forall points [
					keep switch/default type?/word points/1 [
						block! [pnt points/1/1 points/1/2 points/1/3 1]
					][points/1] 
				] 
			]
			vector! [keep points]
		]
	]
	object compose/only [
		type: (to-lit-word type) 
		points: (points) 
		rest: (rest)
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
	return: [object!]
][
	figure polygon reduce [p1 p2 p3 p4]
]

triangle: func [
	p1 [block! vector!] 
	p2 [block! vector!] 
	p3 [block! vector!]
	return: [object!]
][
	figure polygon reduce [p1 p2 p3]
]

polygon: func [points [block!]][
	figure polygon points
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

algebra [3 0 1]

ideal-plane: e0
origin-point: e123
tp: none

ctx: context [
	origin: 250x250
	scale:  100
	mv: 0x0
	bx: none
	rate: none
	el: none
	rotation-points: copy []
	ax: reduce ['x e23 'y e13 'z e12 'esc none]
	code: none
	degrees: 5
	cam: 10
	
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
	
	system/view/auto-sync?: no
	set 'play func [/local ar bt reduced ref] bind [
		reduced:  clear []
		view/flags/options [
			title "GA playground"
			below
			pan: panel [
				origin 0x0
				ar: area 340x100 
				opts: panel [
					origin 0x0 ;below 
					text "Scale:" 40 field 30 data scale on-change [
						scale: face/data 
						bt/actors/on-click bt none
					]
					bt: button "Show" [/local [p elem e draw]
						mv: 0x0
						draw: clear at bx/draw 15  ;draw - for parsing
						reduce/into code clear reduced 
						;parse code [collect into reduced any [
						;	ahead set-word! s: [keep (to-set-word rejoin ["_" s/1]) keep (do/next s 's)] :s
						;|	s: keep (do/next s 's) :s
						;]]
						;probe reduced
						foreach elem reduced [render elem]
						;probe at bx/draw 15
						set-focus bx
						show bx
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
			] on-down [;probe code probe face/draw
				ref: none
				parse face/draw [any [
					'circle s: 2 skip 'text if (nearby >= distance (event/offset - origin) - s/1) skip s: (
						ref: skip find code s/1 -3
					) 
					| skip
				]]
				system/view/auto-sync?: off
			] ;on-time []
			on-up [system/view/auto-sync?: on]
			all-over on-over [if event/down? [
				e: event/offset 
				if ref [
					either event/alt-down? [
						unless pin [pin: e]
						ref/3: ref/3 + (to-integer e/x - pin/x) / scale
					][
						pin: none
						change/part ref reduce [e/x - origin/x / scale e/y - origin/y / scale] 2 
					]
				]
				bt/actors/on-click bt none
				show face
			]]
			on-wheel [local [p p' elem e draw ref]
				if ax/:axis [
					mv: 0x0
					clear at bx/draw 15
					system/view/auto-sync?: off
					clear reduced 
					foreach p rotation-points [
						set p grade rotate/angle get p ax/:axis event/picked * degrees 3
						ref: next find/tail code p
						change/part ref next reverse grade/only p': get p 3 3
						append reduced p'
						if string? ref/4 [append reduced ref/4]
					]
					repend reduced rot-code
					foreach elem reduced [render elem]
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
e.g.: :comment
;Desargues's theorem in 3D
e.g. [
red 3
p0: point 0 -2 0 "P0" 		;tip of the pyramid (perspector)
p1: point -2 1 -1 "P1" 		;lower triangle vertices
p2: point .5 1 1 "P2"
p3: point 1 1.5 -.5 "P3"
o1: point -2.5 -.3 0 "O1" 		;points defining the plane of upper triangle
o2: point .5 -1.5 1 "O2"
o3: point 1 .5 -1 "O3"
[p0 p1 p2 p3 o1 o2 o3]
p123: p1 & p2 & p3 			;lower triangle plane
o123: o1 & o2 & o3 			;upper triangle plane
silver 1
p01: p0 & p1 p02: p0 & p2 p03: p0 & p3 ;pyramid edges
orange
op1: normalized/point o123 ^ p01 "OP1" ;vertices of lower triangle
op2: normalized/point o123 ^ p02 "OP2"
op3: normalized/point o123 ^ p03 "OP3"
green p12: p1 & p2 p13: p1 & p3 p23: p2 & p3 			;lines extending lower triangle edges
blue op12: op1 & op2 op13: op1 & op3 op23: op2 & op3 	;lines extending upper triangle edges
2 navy triangle op1 op2 op3	;triangles
leaf triangle p1 p2 p3
black
x1: normalized/point (op: o123 ^ p123) ^ (p0 & p1 & p2)	;points of intersection of corresponding edges extentions
x2: normalized/point op ^ (p0 & p1 & p3)
x3: normalized/point op ^ (p0 & p2 & p3)
1 red x1 & x3		;line through intersection points (perspetrix)
]
;3D cube
e.g. [
p1: point -1 -1 -1 "P1" p2: point 1 -1 -1 "P2" p3: point 1 1 -1 "P3" p4: point -1 1 -1 "P4"
p5: point -1 -1 1 "P5" p6: point 1 -1 1 "P6" p7: point 1 1 1 "P7" p8: point -1 1 1 "P8"
[p1 p2 p3 p4 p5 p6 p7 p8]
rectangle p1 p2 p3 p4
rectangle p5 p6 p7 p8 
line p1 p5 line p2 p6 line p3 p7 line p4 p8
]