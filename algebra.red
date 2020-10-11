Red []
algebra-ctx: context [
	dimensions: dim: degenerate?: signature: length: begin: table: none
	digit: charset "0123456789" 
	prod:   none
	scprod: none ;"scalar product" see L.Dorst https://www.researchgate.net/publication/2842332_The_Inner_Products_of_Geometric_Algebra
	wedge:  none
	dot:    none
	ldot:   none
	rdot:   none
	vee:    none
	plus:   none
	minus:  none
	dual-signs: none
	;basis: none

	set 'algebra func [
		"Initialize algebra"
		spec [block! integer!] "Value(s) for dimensions: positive (negative, zero)"
		/show
		/local 
			pos  [integer!]
			neg  [integer!]
			nul  [integer!]
			enum [integer!]
			i 	 [integer!]
			dims [block!]
	][
		dims: head [pos neg nul]
		set dims 0
		either integer? spec [
			set first dims spec
		][
			parse spec [any [set d integer! (set first dims d dims: next dims)]]
		]
		dims: head dims
		if any [pos < 0 neg < 0 nul < 0][cause-error 'user 'message "Algebra indices cannot be negative!"]
		dim: pos + neg + nul
		degenerate?: nul > 0
		signature: copy dimensions: make block! dim
		length: 2 ** dim
		enum: 0
		begin: 1
		case/all [
			nul > 0 [begin: 0 enum: -1 repeat i nul [append dimensions to-word rejoin [#"e" enum: enum + 1] append signature 0]]
			pos > 0 [repeat i pos [append dimensions to-word rejoin [#"e" enum: enum + 1] append signature 1]]
			neg > 0 [repeat i neg [append dimensions to-word rejoin [#"e" enum: enum + 1] append signature -1]]
			;nul > 0 [repeat i nul [append dimensions to-word rejoin [#"e" enum: enum + 1] append signature 0]]
		]
		set 'basis make-basis dimensions
		;set 'pseudo-scalar get last basis
		table: cayley/numeric
		make-dual-signs
		make-products
		;Initiate dimensions
		repeat i length - 1 [poke v: make vector! reduce ['float! 32 length] j: i + 1 1.0 set basis/:j v unset [v i j]]
		if show [play]
	]
		
	set 'print-basis function [
		"Print basis symbols for algebra"
	][
		foreach b basis [
			prin pad/left rejoin [b ": "] dim + 3 
			print reduce b
		]
	]
	
	;CREATION
	set 'init func [
		"Initialize new multivector"
		val [float! integer!] "Value all slots are initialized to"
		/only "Initialize specific value for given index key only"
			key [integer! block!] "Index key of value to be set"
		/grade "Initialize given grade(s) only"
			gr [integer! block! action!] "Grade(s) to be initialized to given value (can also be `:even?` and `:odd?`)"
		return: [vector!] 
		/local 
			res [vector!]
	][
		res: make vector! reduce ['float! 32 length]
		if val = 0 [return res]
		case [
			only  [
				either integer? key [
					res/:key: to-float val
				][
					foreach k key [res/:k: to-float val]
				]
			]
			grade [
				forall res [
					gi: grade? index? res 
					if case [
						block?   :gr [find gr gi]
						integer? :gr [gr = gi]
						action?  :gr [gr gi]
					][
						set-vals res val
					]
				]
			]
			true [forall res [res/1: to-float val]]
		]
		res
	]
	
	set-vals: func [
		"Helper function for `create`"
		res [vector!] 
		vals [block! integer!]
	][
		either block? vals [
			res/1: to-float vals/1 
			next vals
		][
			res/1: to-float vals 
			vals + 1
		]
	]
	
	set 'create func [
		"Create new multivector with given values"
		vals [block! integer!] {Initial values for multivector (or range starting from given integer)}
		/grade "Set values for specific grade(s) only"
			gr [integer! block! action!] "Grade(s) to set values for (`:even?` and `:odd?` too)"
		return: [vector!] 
		/local 
			res [vector!]  "Resulting multivector"
			gi  [integer!] "Grade of given element"
	][
		res: init 0 
		either grade [
			forall res [
				gi: grade? index? res
				if case [
					block?   :gr [find gr gi]
					integer? :gr [gr = gi]
					action?  :gr [gr gi]
				][
					vals: set-vals res vals
				]
			]
		][
			forall res [vals: set-vals res vals]
		]
		head res
	]
	
	;CAYLEY
	gp: func [
		"Compute (symbolic) geometric product for Cayley table"
		'a "First symbol"
		'b "Second symbol"
		/numeric "Output product as index in basis"
		/local 
			digits 	[string!]
			sign 	[integer!]
			symbol 	[word! integer!]
			idx 	[integer!]
			s 		[integer!]
	][
		case [
			all [a = 1 b = 1] [return 1]
			a = 1 [return either numeric [index? find basis b][b]]
			b = 1 [return either numeric [index? find basis a][a]]
		]
		sign: 0
		digits: parse rejoin [a b][collect some [keep digit | skip]] 
		until [
			if all [set [a b] digits a b] [
				case [
					a > b [sign: sign + 1 swap digits next digits digits: back digits] 
					a = b [
						switch s: signature/(1 - begin - 48 + to-integer a) [
							0 [return 0] 
							1 -1 [
								remove/part digits 2 digits: back digits
								if s < 0 [sign: sign + 1]
							]
						]
					]
					true [digits: next digits]
				]
			] 
			1 >= length? digits
		]
		digits: head digits
		sign: -1 ** sign
		insert digits either empty? digits [#"1"][#"e"]
		either numeric [
			symbol: load rejoin digits
			idx: index? find basis symbol
			either sign < 0 [negate idx][idx]
		][
			if sign < 0 [insert digits #"-"]
			load rejoin digits
		]
	]
	
	combine: function [dims [string! block!]][
		out: copy []
		either string? dims [
			out: collect [repeat i length? dims [keep head remove at copy dims i]]
		][
			foreach dms dims [append out combine dms]
		]
		out
	]
	
	make-basis: function [dimensions][
		basis: make block! 2 ** len: length? dimensions
		if len > 1 [
			remove-each char dims: trim/all form dimensions [find "e" char]
			insert basis copy dims
			while [len > 2][
				insert basis dims: combine dims
				len: len - 1
			]
			basis: unique basis
			sort/compare basis func [a b][case [(la: length? a) < (lb: length? b) [true] la = lb [a < b] 'else [false]]]
			forall basis [basis/1: to-word rejoin ["e" basis/1]]
		]
		insert basis dimensions
		insert basis 1
		basis
	]
	
	set 'cayley function [/with spec /numeric /show /extern basis][
		if with [algebra spec]
		table: make block! (l: 2 ** (length? dimensions)) ** 2
		foreach a basis [
			foreach b basis [
				append table either numeric [gp/numeric :a :b][gp :a :b]
			]
		]
		either show [
			forall table [table/1: pad form table/1 3 + length? dimensions]
			repeat i length? table [either i % l = 0 [print table/:i][prin table/:i]]
		][	table	]
	]
	
	make-dual-signs: func [][
		dual-signs: init 1
		either degenerate? [
			switch length? dimensions [
				3 [foreach i [3 6][dual-signs/:i: -1.0]]
				4 [foreach i [2 4 7 10 12 14][dual-signs/:i: -1.0]]
			]
		][
			repeat i length? dual-signs [
				if 0 > ((v: table/((length? table) - i + 1)) / absolute v) [
					dual-signs/:i: -1.0
				]
			]
		]
	]
	
	;UNARY FUNCTIONS
	invert: func [a [vector!] return: [vector!] /local res [vector!]][ ;symbol ~ ;revert?
		{Reverse the order of the basis blades.}
		res: copy a
		forall res [if odd? to-integer (grade? index? res) / 2 [res/1: -1 * res/1]]
		res
	]
	
	set '~ :invert 
	
	dual: func [a [vector!] return: [vector!]][ ;symbol !  ;revert?
        {Poincare duality operator.(?)}
        multiply reverse copy a dual-signs
	]
	
	set '! :dual
	
	set 'involute func [a [vector!] return: [vector!] /local res [vector!]][
        {Main involution}
        res:  copy a
		;forall res [if odd? grade? index? res [res/1: 0 - res/1]]
		forall res [res/1: -1 ** (grade? index? res) * res/1]
		res
	]
	
	set 'conjugate func [a [vector!] return: [vector!] /local res [vector!]][
		res: copy a
		;involute invert a
		forall res [if odd? to-integer (1 + grade? index? res) / 2 [res/1: -1 * res/1]] 
		res
	]
	
	invertible?: func [a [vector!]][
		a * a <> 0
	]
	
	grade?: func [ ;Number of dimensions it spans
		idx [integer!] "Index of blade"
	][
		if integer? sym: basis/:idx [return 0]
		(length? form sym) - 1
	]
	
	;BINARY FUNCTIONS
	set 'grade func [a [vector!] g [integer! action! block!] /only /local res [vector! block!]][
		either only [
			if 0 = :g [return first a]
			collect [
				switch type?/word :g [
					integer! [repeat i length? a [if g = grade? i    [keep a/:i]]]
					action!	 [repeat i length? a [if g grade? i      [keep a/:i]]]
					block!   [repeat i length? a [if find g grade? i [keep a/:i]]]
				]
			]
		][
			res: copy a
			switch type?/word :g [
				integer! [repeat i length? res [if g <> grade? i       [res/:i: 0.0]]]
				action!	 [repeat i length? res [if not g grade? i      [res/:i: 0.0]]]
				block!   [repeat i length? res [if not find g grade? i [res/:i: 0.0]]]
			]
			res
		]
	]
	
	;Product tables
	add-blade: func [blade i idx row col /vee /local sign][
		sign: pick [- +] table/:i < 0
		if vee [
			idx: length - idx + 1
			row: length - row + 1
			col: length - col + 1
		]
		repend blade/:idx [
			;either negate [
			;	pick [+ -] table/:i < 0
			;][
			;	pick [- +] and~ table/:i < 0 not positive
			;]
			sign
			to-paren reduce [
				to-path reduce ['b col] '* to-path reduce ['a row]
			]
		]
	]
	
	syms: #(prod: * wedge: ^ dot: | ldot: _| rdot: |_ vee: &)
	
	make-products: function [/extern prod wedge dot ldot rdot vee field val j][
		;Prepare
		blades: object [
			prod: make block! length ** 2
			scprod: vee: dot: ldot: rdot: wedge: none
		]
		body: object [
			prod: make block! length ** 2 * 2
			scprod: copy vee: copy dot: copy ldot: copy rdot: copy wedge: copy prod
		]
		loop length [append/only blades/prod make block! length]
		foreach fn [vee dot ldot rdot wedge][blades/:fn: copy/deep blades/prod]
		blades/scprod: copy/deep [[]] ;scalar product (producing scalar only)
		
		;Fill in
		repeat i length? table [
			unless zero? table/:i [
				col: i - 1 % length + 1
				row: to-integer i - 1 / length + 1
				idx: absolute table/:i
				;Geometric product
				add-blade blades/prod i idx row col
				;Scalar product
				if 0 = grade? idx [add-blade blades/scprod i idx row col]
				;Wedge and vee products
				if (grade? col) + (grade? row) = (grade? idx) [
					;Wedge  product
					add-blade blades/wedge i idx row col
					;Vee product
					;row': length - row + 1
					;col': length - col + 1
					;idx': length - idx + 1
					;i': length - i + 1
					;either any [col = 1 row = 1][
					;	add-blade/positive blades/vee i idx' row' col'
					;][ 
					;	add-blade/negate blades/vee i idx' row' col'
					;]
					add-blade/vee blades/vee i idx row col
				]
				;Dot product
				if (grade? idx) = absolute gr: (grade? col) - (grade? row) [
					add-blade blades/dot i idx row col
					if gr >= 0 [
						add-blade blades/ldot i idx row col
					]
					if gr <= 0 [
						add-blade blades/rdot i idx row col
					]
				]
			]
		]
		foreach fn [prod scprod wedge dot ldot rdot vee][new-line/all blades/:fn true]
		;probe blades/wedge
		;probe blades/scprod
		;probe blades/dot
		;probe blades/ldot
		;probe blades/rdot
		;probe blades/vee
		
		insert body/prod [
			case [
				object? a [
					either not empty? a/points [
						repeat j length? a/points [
							if vector? a/points/:j [a/points/:j: a/points/:j * b]
						] 
						return a
					][return a]
				]
				object? b [
					either not empty? b/points [
						repeat j length? b/points [
							if vector? b/points/:j [b/points/:j: a * b/points/:j]
						] 
						return b
					][return b]
				]
				not any [vector? a vector? b][return multiply a b]
				all [number? a vector? b] [return multiply a copy b]
				all [vector? a number? b] [return multiply copy a b]
			]
			res: copy a
		]
		foreach fn [wedge dot ldot rdot vee] [
			insert body/:fn compose/deep [
				case [
					object? a [
						if not empty? a/points [
							repeat j length? a/points [
								if vector? a/points/:j [a/points/:j: a/points/:j (syms/:fn) b]
							] 
						]
						return a
					]
					object? b [
						if not empty? b/points [
							repeat j length? b/points [
								if vector? b/points/:j [b/points/:j: a (syms/fn) b/points/:j]
							] 
						]
						return b
					]
				]
				res: copy a
			]
		]
		insert body/scprod [res:]
		
		repeat i length [
			foreach fn [prod wedge dot ldot rdot vee][
				repend body/:fn [to-set-path compose [res (i)]] 
				append body/:fn next blades/:fn/:i
			]
		]
		append body/scprod next blades/scprod/1
		
		foreach fn [prod scprod wedge dot ldot rdot vee][
			append body/:fn 'res
		]
		;probe body/wedge
		
		self/prod:   func [a [number! vector! pair! object!] b [number! vector! pair! object!] /local res [vector!]] body/prod
		self/scprod: func [a [vector!] b [vector!] /local res [vector!]] body/scprod
		foreach fn [wedge dot ldot rdot vee][
			self/:fn: func [a [vector! object!] b [vector! object!] /local res [vector! object!]] body/:fn
		]
		foreach key keys-of syms [set syms/:key make op! :self/:key]
	]
	
	;Simple binary funcs
	add: func [a [vector! number! pair!] b [vector! number! pair!] return: [vector!] /local res [vector!]][
		{Multivector addition}
		case [
			not any [vector? a vector? b][return system/words/add a b]
			not vector? a [return sadd a b]
			not vector? b [return adds a b]
		]
		system/words/add a b
	]

	set '+ make op! :add
	
	sadd: func [a [number!] b [vector!] return: [vector!] /local res [vector!]][
		res: copy b
		res/1: system/words/add a b/1
		res
	]

	adds: func [a [vector!] b [number!] return: [vector!] /local res [vector!]][
		res: copy a
		res/1: system/words/add a/1 b
		res
	]

	sub: func [a [vector! number!] b [vector! number!] return: [vector! number!]][
		{Multivector subtraction}
		either same? type? a type? b [
			a - b
		][
			case [
				number? a [return ssub a b]
				number? b [return subs a b]
			]
		]
	]
	
	set '_ make op! :sub
	
	ssub: func [a [number!] b [vector!] return: [vector!] /local res [vector!]][
		res: copy b
		multiply -1 res
		res/1: system/words/add res/1 a
		res 
	]

	subs: function [a [vector!] b [number!] return: [vector!] /local res [vector!]][
		res: copy a
		res/1: subtract a/1 b
		res
	]

	;NORMALIZING
	set 'norm func [a [vector!] return: [float!]][
		(absolute (first a * conjugate a)) ** 0.5
	]

	set 'inorm func [a [vector!] return: [float!]][
		norm dual a
	]

	set 'normalized func [a [vector!] return: [float!]][
		a * (1 / norm a)
	]

	set 'inormalized func [a [vector!] return: [float!]][
		a * (1 / inorm a)
	]
]
