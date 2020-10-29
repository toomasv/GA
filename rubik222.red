options [
	;Points:
	p111: point -1 -1 -1 p112: point 0 -1 -1 p113: point 1 -1 -1 
	p121: point -1  0 -1 p122: point 0  0 -1 p123: point 1  0 -1 
	p131: point -1  1 -1 p132: point 0  1 -1 p133: point 1  1 -1 

	p211: point -1 -1  0 p212: point 0 -1  0 p213: point 1 -1  0 
	p221: point -1  0  0 p222: point 0  0  0 p223: point 1  0  0 
	p231: point -1  1  0 p232: point 0  1  0 p233: point 1  1  0 

	p311: point -1 -1  1 p312: point 0 -1  1 p313: point 1 -1  1 
	p321: point -1  0  1 p322: point 0  0  1 p323: point 1  0  1 
	p331: point -1  1  1 p332: point 0  1  1 p333: point 1  1  1 

	;Edge center duplicates
	p112': point  0 -1 -1
	p123': point  1  0 -1
	p132': point  0  1 -1
	p121': point -1  0 -1

	p211': point -1 -1  0 
	p213': point  1 -1  0 
	p233': point  1  1  0 
	p231': point -1  1  0 

	p312': point  0 -1  1 
	p323': point  1  0  1 
	p332': point  0  1  1 
	p321': point -1  0  1 

	;Side center duplicates
	p122': point  0  0 -1  p122'': point  0  0 -1  p122''': point  0  0 -1     ;Front
	p212': point  0 -1  0  p212'': point  0 -1  0  p212''': point  0 -1  0     ;Top
	p223': point  1  0  0  p223'': point  1  0  0  p223''': point  1  0  0     ;Bottom
	p221': point -1  0  0  p221'': point -1  0  0  p221''': point -1  0  0     ;Left
	p232': point  0  1  0  p232'': point  0  1  0  p232''': point  0  1  0     ;Right
	p322': point  0  0  1  p322'': point  0  0  1  p322''': point  0  0  1     ;Rear
	centers: [
		p122 p122' p122'' p122'''
		p212 p212' p212'' p212'''
		p223 p223' p223'' p223'''
		p221 p221' p221'' p221'''
		p232 p232' p232'' p232'''
		p322 p322' p322'' p322'''
	]
	
	faces: [r1 r2 r3 r4 g1 g2 g3 g4 b1 b2 b3 b4 o1 o2 o3 o4 y1 y2 y3 y4 w1 w2 w3 w4]
	;Front
	  r1: [p111    p112   p122   p121 ]
	  r2: [p112'   p113   p123   p122']
	  r3: [p121'   p122'' p132   p131 ]
	  r4: [p122''' p123'  p133   p132']
	;Top
	  g1: [p311    p312   p212   p211 ]
	  g2: [p312'   p313   p213   p212']
	  g3: [p211'   p212'' p112   p111 ]
	  g4: [p212''' p213'  p113   p112']
	;Bottom
	  b1: [p331    p332   p232   p231 ]
	  b2: [p332'   p333   p233   p232']
	  b3: [p231'   p232'' p132   p131 ]
	  b4: [p232''' p233'  p133   p132']
	;Rear
	  o1: [p311    p312   p322   p321 ]
	  o2: [p312'   p313   p323   p322']
	  o3: [p321'   p322'' p332   p331 ]
	  o4: [p322''' p323'  p333   p332']
	;Left
	  y1: [p111    p211'  p221   p121 ]
	  y2: [p211    p311   p321   p221']
	  y3: [p121'   p221'' p231'  p131 ]
	  y4: [p221''' p321'  p331   p231 ]
	;Right
	  w1: [p113    p213'  p223   p123 ]
	  w2: [p213    p313   p323   p223']
	  w3: [p123'   p223'' p233'  p133 ]
	  w4: [p223''' p323'  p333   p233 ]
	
	pieces: [RGY RGW RBY RBW OGY OGW OBY OBW]
	RGY: unique compose [(r1) (g3) (y1)] ;[p111    p112   p122 p121      p211'   p212''      p221   ]
	RGW: unique compose [(r2) (g4) (w1)] ;[p112'   p113   p123 p122'     p212''' p213'       p223   ]
	RBY: unique compose [(r3) (b3) (y3)] ;[p121'   p122'' p132 p131      p231'   p232''      p221'' ]
	RBW: unique compose [(r4) (b4) (w3)] ;[p122''' p123'  p133 p132'     p232''' p233'       p223'' ]
	OGY: unique compose [(o1) (g1) (y2)] ;[p311    p312   p322 p321      p212    p211        p221'  ]
	OGW: unique compose [(o2) (g2) (w2)] ;[p312'   p313   p323 p322'     p213    p212'       p223'  ]
	OBY: unique compose [(o3) (b1) (y4)] ;[p321'   p322'' p332 p331      p232    p231        p221''']
	OBW: unique compose [(o4) (b2) (w4)] ;[p322''' p323'  p333 p332'     p233    p232'       p223''']
	
	
]
;Rotated
compose [
	(RGY)
	(RGW)
	(RBY)
	(RBW)
	(OGY)
	(OGW)
	(OBY)
	(OBW)
]

shape [
;Front
  polygon/fill/name r1 'red '_r1
  polygon/fill/name r2 'red '_r2
  polygon/fill/name r3 'red '_r3
  polygon/fill/name r4 'red '_r4
;Top
  polygon/fill/name g1 'green '_g1
  polygon/fill/name g2 'green '_g2
  polygon/fill/name g3 'green '_g3
  polygon/fill/name g4 'green '_g4
;Bottom
  polygon/fill/name b1 'blue '_b1
  polygon/fill/name b2 'blue '_b2
  polygon/fill/name b3 'blue '_b3
  polygon/fill/name b4 'blue '_b4
;Rear
  polygon/fill/name o1 'orange '_o1
  polygon/fill/name o2 'orange '_o2
  polygon/fill/name o3 'orange '_o3
  polygon/fill/name o4 'orange '_o4
;Left
  polygon/fill/name y1 'yellow '_y1
  polygon/fill/name y2 'yellow '_y2
  polygon/fill/name y3 'yellow '_y3
  polygon/fill/name y4 'yellow '_y4
;Right
  polygon/fill/name w1 'white '_w1
  polygon/fill/name w2 'white '_w2
  polygon/fill/name w3 'white '_w3
  polygon/fill/name w4 'white '_w4
]