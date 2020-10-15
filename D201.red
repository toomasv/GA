Red [
	Description: "2D projective geometric algebra functions (Clifford [2 0 1])"
]
#include %algebra.red

cpy: func [a [series! object!]][copy/deep a]
nearby: 4

norm-line: func [
	line [vector!]
	/local 
		n [scalar!]
][
	either 0 = n: sqrt system/words/add line/3 ** 2 line/4 ** 2 [line/2][n]
]

norm-point: func [
	point [vector!]
][
	either 0 = point/7 [sqrt system/words/add point/5 ** 2 point/6 ** 2][point/7]
]

norm-I: func [vec [vector!]][last vec]

normalized: func [
	vec [vector!]
	/line
	/point
	/I
][
	case [
		line  [vec * (1 / norm-line vec)]
		point [vec * (1 / norm-point vec)]
		I     [vec * (1 / norm-I vec)]
		true  [vec * (1 / norm vec)]
	]
]

len:   function [
	"Length of vector" 
	v [vector!]
][sqrt sum (a: grade v 1) * a]

cross: func [a [vector!] b [vector!]][(a * b) - (b * a) * 0.5]
¤: make op! :cross

rot: func [
	"Create rotator"
	ang [integer! float!] "Angle of rotation"
	/radians "Angle is given in radians"
][
	ang: ang / 2
	either radians [
		(cos ang) + ((sin ang) * e12)
	][
		(cosine ang) + ((sine ang) * e12)
	]
]

rotate: func [
	"Rotate blade by angle"
	blade [vector! object!] "Rotated blade or object"
	angle [integer! float!] "Angle of rotation"
	/radians
	/local
		rotor [vector!]
][
	rotor: either radians [
		rot/radians angle 
	][
		rot angle
	]
	rotor * blade * ~ rotor
]

vec: func [
	"Line by formula ax + by + cz";(?)
	a [integer! float!] 
	b [integer! float!] 
	c [integer! float!] ;ideal
][create/grade reduce [c a b] 1]

pnt: func [
	x [integer! float!] 
	y [integer! float!] 
	z [integer! float!] 
][create/grade reduce [y x z] 2]

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
						block! [pnt points/1/1 points/1/2 1]
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
	return: [object!]
][
	;figure/with circle reduce [pnt x y 1] 1
	pnt x y 1
]

line:  func [
	p1 [vector! block!] 
	p2 [vector! block!] 
	return: [object!]
][
	figure line reduce [
		either vector? p1 [p1] [pnt p1/1 p1/2 1] 
		either vector? p2 [p2] [pnt p2/1 p2/2 1]
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
	return: [object!] 
	/local 
		points [block!]
		angle [integer!]
][
	;points: make block! 12 
	;if vector? center [center: next grade/only center 2]
	;repeat i 12 [
	;	repend/only points [
	;		radius * (cosine angle: i * 30) + center/1 
	;		radius * (sine angle) + center/2
	;	]
	;] 
	;figure/with spline points [closed]
	figure/with circle center radius
]

algebra [2 0 1]
ideal-line: e0
origin-point: e12

context [
	origin: 250x250
	scale:  100
	mv: 0x0
	bx: none
	rate: none
	el: none
	
	ideal-line?: func [elem [vector!]][all [zero? elem/3 zero? elem/4 not zero? elem/2]]
	line?: func [elem [vector!]][
		;not zero? sum multiply el: normalized/line grade elem 1 el
		repeat i 3 [if not zero? elem/(i + 1) [return true]]
		return false
	]
	
	ideal-point?: func [elem [vector!]][zero? elem/7]
	point?: func [elem [vector!]][
		;not zero? sum multiply el: grade elem 2 el
		repeat i 3 [if not zero? elem/(i + 4) [return true]]
		return false
	]
	
	render: func [elem /local ln ln-perp a b d pt x y z trans t w l-weight][
		l-weight: (distance bx/size) / scale
		switch type?/word elem [
			;vector! [repend bx/draw ['line 0x0 p: as-pair scale * elem/2 scale * elem/3]]
			set-word! [append bx/draw elem]
			vector! [
				case [
					all [point? elem ideal-line? elem][
						repend bx/draw [
							'circle
							;p: to-pair copy next grade/only multiply scale grade elem 2 2
							p: as-pair scale * elem/6 scale * elem/5
							scale * elem/2
						]
					]
					line? elem [
						elem: normalized/line elem
						elem/4: elem/4 * -1 ;Need to reverse y-coordinate to make it work
						step: as-pair elem/2 * scale * elem/3 elem/2 * scale * elem/4
						
						l: e12 | elem
						start: as-pair l-weight * scale * l/3 l-weight * scale * l/4 ;
						end: -1 * start
						start: start + step
						end: end + step
						
						repend bx/draw ['line start end]
					]
					point? elem [
						set [y x z] grade/only elem 2
						repend bx/draw ['circle p: as-pair scale * x / z scale * y / z 1]
					]
				]
			]
			pair!   [mv: elem]
			string! [repend bx/draw ['text p + mv elem]]
			object! [
				;probe elem
				append bx/draw to-word elem/type
				foreach e elem/points [
					switch type?/word e [
						vector! [
							;append bx/draw p: to-pair copy next grade/only multiply scale grade e 2 2
							append bx/draw p: as-pair scale * e/6 scale * e/5
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
		]
	]
	
	distance: func [p1 [pair!] /from p2 [pair!]][
		if from [p1: p1 - p2]
		sqrt system/words/add p1/x ** 2 p1/y ** 2
	]
	
	set 'play func [/local ar bt code reduced ref] bind [
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
						;probe bx/draw
					] on-down [
						code: bind load ar/text self 
						bx/rate: none 
						clear body-of :bx/actors/on-time
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
					] 
					return
					check "Axis" data true 40 on-change [bx/draw/pen: pick [silver off] face/data]
					check "Grid" data true 40 on-change [bx/draw/2/4/pen: pick [snow off] face/data]
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
			] on-down [
				ref: none
				parse face/draw [any [
					'circle s: 2 skip 'text if (nearby >= distance (event/offset - origin) - s/1) skip s: (
						ref: skip find code s/1 -2
					) 
					| skip
				]]
			] on-time []
			all-over on-over [if event/down? [
				e: event/offset 
				if ref [
					change/part ref reduce [e/x - origin/x / scale e/y - origin/y / scale] 2 
				]
				bt/actors/on-click bt none
			]]
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
e.g. [
#blue F: polygon [[-.1 -.1][-.1 -1][-.6 -1][-.6 -.8][-.3 -.8][-.3 -.6][-.5 -.6][-.5 -.4][-.3 -.4][-.3 -.1]]
#red rotate F 90
]
e.g. [
;NB! y coordinate in lines is reversed to make it work
p1: point -1 2 "P1"	;func to create point (with implicit origin)
p2: pnt 1 1 1  "P2" ;func to create point (with explicit origin)
l1: p1 & p2			;join to points to form line
l2: (e0 + e1 + e2)	;line at 45 deg
l3: (e0 - e2)       ;y is reversed!
p3: l2 ^ l3 "P3"	;wedge (meet) two lines to get a point
p4: l1 ^ l2 "P4"
p5: (normalized/point l1 * e012) + e12 ;"l1 | p5" ;product of line with pseudoscalar gives ideal point (direction)
r1: (.1 * e0) + p1	;experimental circle (ideal line + euclidean point)
l4: normalized/line l1 | p5 ;dot-product of line and point creates line thruogh point perpendicular to original line
l4 ^ l2 form round/to arccosine first (normalized/line l2) | (normalized/line l4) 1 ;angle between lines; depends on relative directions of lines
(normalized/point p1 ¤ p3) + e12 ;"P1 ¤ P3" ;cross-product of points gives ideal point perpendicular to joining line of points
;norm-point p1 ¤ p5 ;norm of cross-product gives distance between point
r1 | l3 * l3		;point dot line prod line gives projection of point on line
;first (normalized/line l2) & p1 ;join of normalized line and point produces scalar, distance from line to point
]
;Pappus's theorem
e.g. [
q1: point -2 -2 "Q1"
q3: point 2 -2 "Q3"
o1: point -2 1 "O1"
o3: point 2 1 "O3"
p1: point 0 -2.2 "P1"
p2: point 0 1.3 "P2"
l1: q1 & q3
l2: o1 & o3
silver l3: p1 & p2 black
q2: normalized l3 ^ l1 "Q2"
o2: normalized l3 ^ l2 "O2"
line q1 o2 line q1 o3
line q2 o1 line q2 o3
line q3 o1 line q3 o2
leaf
x: (q1 & o2) ^ (q2 & o1) "X"
y: (q1 & o3) ^ (q3 & o1) "Y"
z: (q2 & o3) ^ (q3 & o2) "Z"
x & z
]
;Desargues's theorem
e.g. [
red 2 ;Dragable points
p0: point 2 0 "P0" ;perspector
p1: point -2 -1 "P1" p2: point -1 0 "P2" p3: point -2 1 "P3"
q1: point -1 -2 "Q1" 
q2: point 1.5 2 "Q2" 
q3: point -1.5 2 "Q3"
;Non-dragables
silver 1 
l1: p0 & p1 l2: p0 & p2 l3: p0 & p3
leaf
l4: p1 & p2 l5: p3 & p2 l6: p1 & p3
orange
m1: q1 & q2 
o2: normalized/point l2 ^ m1 "O2" 
m2: q3 & o2
o1: normalized/point l1 ^ m1 "O1" 
o3: normalized/point m2 ^ l3 "O3"
m3: o3 & o1 m4: o2 & o3
black 2
triangle p1 p2 p3 
triangle o1 o2 o3
blue 
k1: l6 ^ m3 k2: l4 ^ m1 l5 ^ m4
1 k1 & k2 ;perspectrix
]
;Harmonic homology
e.g. [
red 3
z: point -2 1 "Z" p: point -1 1 "P"
z': point 0 -1 "Z'"
o1: point 0 2 "O1" o2: point -1.5 -2 "O2"
black 1
m: o1 & o2 ;vec 1 -.5 0 
k: z & p
blue s: m ^ k "S"
silver
zln: z & z' pln: p & z' sln: s & z'
z2ln: z & (m ^ pln)
xln: (zln ^ m) & (sln ^ z2ln)
leaf 
xln ^ k "P'"
]