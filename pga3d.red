Red [
	Needs: 		View
	Purpose: 	"3D Projective Geometric Algebra."
	Note: 		"Translation from python:"
	Original: 	https://bivector.net/tools.html
	Original-Author: 	"Enki"
]
comment {
; The binary operators we support
binops: [
	{ name:"Mul",   symbol:"*", desc:"The geometric product." },
	{ name:"Wedge", symbol:"^", desc:"The outer product. (MEET)" },
	{ name:"Vee",   symbol:"&", desc:"The regressive product. (JOIN)" },
	{ name:"Dot",   symbol:"|", desc:"The inner product."},
	{ name:"Add",   symbol:"+", desc:"Multivector addition" },
	{ name:"Sub",   symbol:"-", desc:"Multivector subtraction" },
	{ name:"smul",  symbol:"*", classname_a:"float", desc:"scalar/multivector multiplication" },
	{ name:"muls",  symbol:"*", classname_b:"float", desc:"multivector/scalar multiplication" },
	{ name:"sadd",  symbol:"+", classname_a:"float", desc:"scalar/multivector addition" },
	{ name:"adds",  symbol:"+", classname_b:"float", desc:"multivector/scalar addition" },
	{ name:"ssub",  symbol:"-", classname_a:"float", desc:"scalar/multivector subtraction" },
	{ name:"subs",  symbol:"-", classname_b:"float", desc:"multivector/scalar subtraction" },
]

; The unary operators we support
var unops = [
	{ name:"Reverse",   symbol:"~", desc:"Reverse the order of the basis blades." },
	{ name:"Dual",      symbol:"!", desc:"Poincare duality operator." },
	{ name:"Conjugate", desc:"Clifford Conjugation" },
	{ name:"Involute",  desc:"Main involution" }
]
}

PGA3D: object [
	_base:  ["1" "e0" "e1" "e2" "e3" "e01" "e02" "e03" "e12" "e31" "e23" "e021" "e013" "e032" "e123" "e0123"]
    
	init: func [val [float!] key [integer!] return: [vector!] /local res [vector!]][
		res: make vector! [float! 32 16]
		res/:key: val
		res
	]
	create: func [array [block! vector!] return: [vector!]][
        {Check / Initiate a new multivector}
        if (length? array) <> 16 [
            cause-error 'user 'message "Length of array must be identical to the dimension of the algebra."
		]
		either block? array [
			make vector! compose/only [float! 32 (array)]
		][
			array
		]
	]
    invert: func [a [vector!] return: [vector!] /local res [vector!]][ ;symbol ~ 
        {PGA3D.Reverse
        Reverse the order of the basis blades.}
        res: copy a
        res/6:  0 - a/6
        res/7:  0 - a/7
        res/8:  0 - a/8
        res/9:  0 - a/9
        res/10: 0 - a/10
        res/11: 0 - a/11
        res/12: 0 - a/12
        res/13: 0 - a/13
        res/14: 0 - a/14
        res/15: 0 - a/15
        create res
	]
	
	set '~ :invert
	
    dual: func [a [vector!] return: [vector!] /local res [vector!]][ ;symbol !
        {PGA3D.Dual
        Poincare duality operator.}
        res: copy a
        reverse res
        create res
	]
	
	set '! :dual
	
    conjugate: func [a [vector!] return: [vector!] /local res [vector!]][
        {PGA3D.Conjugate
        Clifford Conjugation}
        res: copy a
        res/2:  0 - a/2
        res/3:  0 - a/3
        res/4:  0 - a/4
        res/5:  0 - a/5
        res/6:  0 - a/6
        res/7:  0 - a/7
        res/8:  0 - a/8
        res/9:  0 - a/9
        res/10: 0 - a/10
        res/11: 0 - a/11
        create res
	]
	
    involute: func [a [vector!] return: [vector!] /local res [vector!]][
        {PGA3D.Involute
        Main involution}
        res:  copy a
        res/2:  0 - a/2
        res/3:  0 - a/3
        res/4:  0 - a/4
        res/5:  0 - a/5
        res/12: 0 - a/12
        res/13: 0 - a/13
        res/14: 0 - a/14
        res/15: 0 - a/15
        create res
	]

    mul: func [a [vector! number!] b [vector! number!] return: [vector!] /local res [vector!]][ ;symbol *
        {PGA3D.Mul
        The geometric product.}
        case [
			all [number? a number? b][return multiply a b]
			number? a [return smul a b]
			number? b [return muls a b]
		]
        res: copy a
        res/1:  b/1  * a/1  + (b/3  * a/3)  + (b/4  * a/4)  + (b/5  * a/5)  - (b/9  * a/9)  - (b/10 * a/10) - (b/11 * a/11) - (b/15 * a/15)
		res/2:  b/2  * a/1  + (b/1  * a/2)  - (b/6  * a/3)  - (b/7  * a/4)  - (b/8  * a/5)  + (b/3  * a/6)  + (b/4  * a/7)  + (b/5  * a/8) + 
		       (b/12 * a/9) + (b/13 * a/10) + (b/14 * a/11) + (b/9  * a/12) + (b/10 * a/13) + (b/11 * a/14) + (b/16 * a/15) - (b/15 * a/16)
		res/3:  b/3  * a/1  + (b/1  * a/3)  - (b/9  * a/4)  + (b/10 * a/5)  + (b/4  * a/9)  - (b/5  * a/10) - (b/15 * a/11) - (b/11 * a/15)
		res/4:  b/4  * a/1  + (b/9  * a/3)  + (b/1  * a/4)  - (b/11 * a/5)  - (b/3  * a/9)  - (b/15 * a/10) + (b/5  * a/11) - (b/10 * a/15)
        res/5:  b/5  * a/1  - (b/10 * a/3)  + (b/11 * a/4)  + (b/1  * a/5)  - (b/15 * a/9)  + (b/3  * a/10) - (b/4  * a/11) - (b/9  * a/15)
        res/6:  b/6  * a/1  + (b/3  * a/2)  - (b/2  * a/3)  - (b/12 * a/4)  + (b/13 * a/5)  + (b/1  * a/6)  - (b/9  * a/7)  + (b/10 * a/8) + 
		       (b/7  * a/9) - (b/8  * a/10) - (b/16 * a/11) - (b/4  * a/12) + (b/5  * a/13) + (b/15 * a/14) - (b/14 * a/15) - (b/11 * a/16)
		res/7:  b/7  * a/1  + (b/4  * a/2)  + (b/12 * a/3)  - (b/2  * a/4)  - (b/14 * a/5)  + (b/9  * a/6)  + (b/1  * a/7)  - (b/11 * a/8) - 
		       (b/6  * a/9) - (b/16 * a/10) + (b/8  * a/11) + (b/3  * a/12) + (b/15 * a/13) - (b/5  * a/14) - (b/13 * a/15) - (b/10 * a/16)
		res/8:  b/8  * a/1  + (b/5  * a/2)  - (b/13 * a/3)  + (b/14 * a/4)  - (b/2  * a/5)  - (b/10 * a/6)  + (b/11 * a/7)  + (b/1  * a/8) - 
		       (b/16 * a/9) + (b/6  * a/10) - (b/7  * a/11) + (b/15 * a/12) - (b/3  * a/13) + (b/4  * a/14) - (b/12 * a/15) - (b/9  * a/16)
		res/9:  b/9  * a/1  + (b/4  * a/3)  - (b/3  * a/4)  + (b/15 * a/5)  + (b/1  * a/9)  + (b/11 * a/10) - (b/10 * a/11) + (b/5  * a/15)
        res/10: b/10 * a/1  - (b/5  * a/3)  + (b/15 * a/4)  + (b/3  * a/5)  - (b/11 * a/9)  + (b/1  * a/10) + (b/9  * a/11) + (b/4  * a/15)
        res/11: b/11 * a/1  + (b/15 * a/3)  + (b/5  * a/4)  - (b/4  * a/5)  + (b/10 * a/9)  - (b/9  * a/10) + (b/1  * a/11) + (b/3  * a/15)
        res/12: b/12 * a/1  - (b/9  * a/2)  + (b/7  * a/3)  - (b/6  * a/4)  + (b/16 * a/5)  - (b/4  * a/6)  + (b/3  * a/7)  - (b/15 * a/8) - 
		       (b/2  * a/9) + (b/14 * a/10) - (b/13 * a/11) + (b/1  * a/12) + (b/11 * a/13) - (b/10 * a/14) + (b/8  * a/15) - (b/5  * a/16)
		res/13: b/13 * a/1  - (b/10 * a/2)  - (b/8  * a/3)  + (b/16 * a/4)  + (b/6  * a/5)  + (b/5  * a/6)  - (b/15 * a/7)  - (b/3  * a/8) - 
		       (b/14 * a/9) - (b/2  * a/10) + (b/12 * a/11) - (b/11 * a/12) + (b/1  * a/13) + (b/9  * a/14) + (b/7  * a/15) - (b/4  * a/16)
        res/14: b/14 * a/1  - (b/11 * a/2)  + (b/16 * a/3)  + (b/8  * a/4)  - (b/7  * a/5)  - (b/15 * a/6)  - (b/5  * a/7)  + (b/4  * a/8) + 
		       (b/13 * a/9) - (b/12 * a/10) - (b/2  * a/11) + (b/10 * a/12) - (b/9  * a/13) + (b/1  * a/14) + (b/6  * a/15) - (b/3  * a/16)
        res/15: b/15 * a/1  + (b/11 * a/3)  + (b/10 * a/4)  + (b/9  * a/5)  + (b/5  * a/9)  + (b/4  * a/10) + (b/3  * a/11) + (b/1  * a/15)
        res/16: b/16 * a/1  + (b/15 * a/2)  + (b/14 * a/3)  + (b/13 * a/4)  + (b/12 * a/5)  + (b/11 * a/6)  + (b/10 * a/7)  + (b/9  * a/8) + 
		       (b/8  * a/9) + (b/7  * a/10) + (b/6  * a/11) - (b/5  * a/12) - (b/4  * a/13) - (b/3  * a/14) - (b/2  * a/15) + (b/1  * a/16)
        create res
    ]

	rmul: :mul
	
	set '* make op! :mul
	
    xor: func [a [vector!] b [vector!] return: [vector!] /local res [vector!]][ ;symbol ^ (Wedge, MEET, outer product)
        res: copy a
        res/1:  b/1  * a/1 
        res/2:  b/2  * a/1 + (b/1  * a/2)
        res/3:  b/3  * a/1 + (b/1  * a/3)
        res/4:  b/4  * a/1 + (b/1  * a/4)
        res/5:  b/5  * a/1 + (b/1  * a/5)
        res/6:  b/6  * a/1 + (b/3  * a/2) - (b/2  * a/3) + (b/1 * a/6)
        res/7:  b/7  * a/1 + (b/4  * a/2) - (b/2  * a/4) + (b/1 * a/7)
        res/8:  b/8  * a/1 + (b/5  * a/2) - (b/2  * a/5) + (b/1 * a/8)
        res/9:  b/9  * a/1 + (b/4  * a/3) - (b/3  * a/4) + (b/1 * a/9)
        res/10: b/10 * a/1 - (b/5  * a/3) + (b/3  * a/5) + (b/1 * a/10)
        res/11: b/11 * a/1 + (b/5  * a/4) - (b/4  * a/5) + (b/1 * a/11)
        res/12: b/12 * a/1 - (b/9  * a/2) + (b/7  * a/3) - (b/6 * a/4)  - (b/4  * a/6) + (b/3  * a/7)  - (b/2 * a/9)   + (b/1 * a/12) 
        res/13: b/13 * a/1 - (b/10 * a/2) - (b/8  * a/3) + (b/6 * a/5)  + (b/5  * a/6) - (b/3  * a/8)  - (b/2 * a/10)  + (b/1 * a/13) 
        res/14: b/14 * a/1 - (b/11 * a/2) + (b/8  * a/4) - (b/7 * a/5)  - (b/5  * a/7) + (b/4  * a/8)  - (b/2 * a/11)  + (b/1 * a/14) 
        res/15: b/15 * a/1 + (b/11 * a/3) + (b/10 * a/4) + (b/9 * a/5)  + (b/5  * a/9) + (b/4  * a/10) + (b/3 * a/11)  + (b/1 * a/15) 
        res/16: b/16 * a/1 + (b/15 * a/2) + (b/14 * a/3) + (b/13 * a/4) + (b/12 * a/5) + (b/11 * a/6)  + (b/10 * a/7)  + (b/9 * a/8) + 
		       (b/8 * a/9) + (b/7 * a/10) + (b/6 * a/11) - (b/5 * a/12) - (b/4 * a/13) - (b/3  * a/14) - (b/2  * a/15) + (b/1 * a/16)
        create res
	]
  
	set '^ make op! :xor

    and: func [a [vector!] b [vector!] return: [vector!] /local res [vector!]][ ;symbol & (Vee, JOIN, regressive product)
        res: copy a
        res/1:  a/1  * b/16 - (a/2  * b/15) - (a/3  * b/14) - (a/4  * b/13) - (a/5  * b/12) + (a/6  * b/11) + (a/7  * b/10) + (a/8  * b/9) +
		       (a/9  * b/8) + (a/10 * b/7)  + (a/11 * b/6)  + (a/12 * b/5)  + (a/13 * b/4)  + (a/14 * b/3)  + (a/15 * b/2)  + (a/16 * b/1)
        res/2:  a/2  * b/16 - (a/6  * b/14) - (a/7  * b/13) - (a/8  * b/12) - (a/12 * b/8)  - (a/13 * b/7)  - (a/14 * b/6)  + (a/16 * b/2)
        res/3:  a/3  * b/16 + (a/6  * b/15) - (a/9  * b/13) + (a/10 * b/12) + (a/12 * b/10) - (a/13 * b/9)  + (a/15 * b/6)  + (a/16 * b/3)
        res/4:  a/4  * b/16 + (a/7  * b/15) + (a/9  * b/14) - (a/11 * b/12) - (a/12 * b/11) + (a/14 * b/9)  + (a/15 * b/7)  + (a/16 * b/4)
        res/5:  a/5  * b/16 + (a/8  * b/15) - (a/10 * b/14) + (a/11 * b/13) + (a/13 * b/11) - (a/14 * b/10) + (a/15 * b/8)  + (a/16 * b/5)
        res/6:  a/6  * b/16 + (a/12 * b/13) - (a/13 * b/12) + (a/16 * b/6)
        res/7:  a/7  * b/16 - (a/12 * b/14) + (a/14 * b/12) + (a/16 * b/7)
        res/8:  a/8  * b/16 + (a/13 * b/14) - (a/14 * b/13) + (a/16 * b/8)
        res/9:  a/9  * b/16 + (a/12 * b/15) - (a/15 * b/12) + (a/16 * b/9)
        res/10: a/10 * b/16 + (a/13 * b/15) - (a/15 * b/13) + (a/16 * b/10)
        res/11: a/11 * b/16 + (a/14 * b/15) - (a/15 * b/14) + (a/16 * b/11)
        res/12: a/12 * b/16 + (a/16 * b/12)
        res/13: a/13 * b/16 + (a/16 * b/13)
        res/14: a/14 * b/16 + (a/16 * b/14)
        res/15: a/15 * b/16 + (a/16 * b/15)
        res/16: a/16 * b/16
        create res
	]
	
	set '& make op! :and

    or: func [a [vector!] b [vector!] return: [vector!] /local res [vector!]][ ;symbol | (dot, inner product)
        res: copy a
        res/1:  b/1  * a/1  + (b/3  * a/3)  + (b/4  * a/4)  + (b/5  * a/5) - (b/9  * a/9)  - (b/10 * a/10) - (b/11 * a/11) - (b/15 * a/15)
        res/2:  b/2  * a/1  + (b/1  * a/2)  - (b/6  * a/3)  - (b/7  * a/4) - (b/8  * a/5)  + (b/3  * a/6)  + (b/4  * a/7)  + (b/5 * a/8) + 
		       (b/12 * a/9) + (b/13 * a/10) + (b/14 * a/11) + (b/9 * a/12) + (b/10 * a/13) + (b/11 * a/14) + (b/16 * a/15) - (b/15 * a/16)
        res/3:  b/3  * a/1  + (b/1  * a/3)  - (b/9  * a/4)  + (b/10 * a/5) + (b/4  * a/9)  - (b/5  * a/10) - (b/15 * a/11) - (b/11 * a/15)
        res/4:  b/4  * a/1  + (b/9  * a/3)  + (b/1  * a/4)  - (b/11 * a/5) - (b/3  * a/9)  - (b/15 * a/10) + (b/5  * a/11) - (b/10 * a/15)
        res/5:  b/5  * a/1  - (b/10 * a/3)  + (b/11 * a/4)  + (b/1  * a/5) - (b/15 * a/9)  + (b/3  * a/10) - (b/4  * a/11) - (b/9 * a/15)
        res/6:  b/6  * a/1  - (b/12 * a/4)  + (b/13 * a/5)  + (b/1  * a/6) - (b/16 * a/11) - (b/4  * a/12) + (b/5  * a/13) - (b/11 * a/16)
        res/7:  b/7  * a/1  + (b/12 * a/3)  - (b/14 * a/5)  + (b/1  * a/7) - (b/16 * a/10) + (b/3  * a/12) - (b/5  * a/14) - (b/10 * a/16)
        res/8:  b/8  * a/1  - (b/13 * a/3)  + (b/14 * a/4)  + (b/1  * a/8) - (b/16 * a/9)  - (b/3  * a/13) + (b/4  * a/14) - (b/9 * a/16)
        res/9:  b/9  * a/1  + (b/15 * a/5)  + (b/1  * a/9)  + (b/5  * a/15)
        res/10: b/10 * a/1  + (b/15 * a/4)  + (b/1  * a/10) + (b/4  * a/15)
        res/11: b/11 * a/1  + (b/15 * a/3)  + (b/1  * a/11) + (b/3  * a/15)
        res/12: b/12 * a/1  + (b/16 * a/5)  + (b/1  * a/12) - (b/5  * a/16)
        res/13: b/13 * a/1  + (b/16 * a/4)  + (b/1  * a/13) - (b/4  * a/16)
        res/14: b/14 * a/1  + (b/16 * a/3)  + (b/1  * a/14) - (b/3  * a/16)
        res/15: b/15 * a/1  + (b/1  * a/15)
        res/16: b/16 * a/1  + (b/1  * a/16)
        create res
	]
	
	set '| make op! :or
	
    add: func [a [vector! number! pair!] b [vector! number! pair!] return: [vector!] /local res [vector!]][
        {PGA3D.Add
        Multivector addition}
        case [
			not any [vector? a vector? b][return system/words/add a b]
			not vector? a [return sadd a b]
			not vector? b [return adds a b]
		]
        res: system/words/add a b
        create res
	]
	
	set '+ make op! :add
	
    radd: :add

    sub: func [a [vector! number!] b [vector! number!] return: [vector! number!]][
        {PGA3D.Sub
        Multivector subtraction}
        case [
			all [number? a number? b][subtract a b]
			number? a [return ssub a b]
			number? b [return subs a b]
		]
		create a - b
	]
	
	set '_ make op! :sub
	
    rsub: func [a [vector! number!] b [vector! number!] return: [vector! number!]][
        {PGA3D.Sub
        Multivector subtraction}
        case [
			all [number? a number? b][subtract b a]
			number? a [return ssub a b]
			number? b [return subs a b]
		]
        create b - a
	]

    smul: func [a [number!] b [vector!] return: [vector!]][
		multiply a copy b
	]

    muls: func [a [vector!] b [number!] return: [vector!]][
        multiply copy a b
	]
	
    sadd: func [a [number!] b [vector!] return: [vector!] /local res [vector!]][
		res: copy b
        res/1: system/words/add a b/1
        create res
	]

    adds: func [a [vector!] b [number!] return: [vector!] /local res [vector!]][
        res: copy a
        res/1: system/words/add a/1 b
        create res
	]

    ssub: func [a [number!] b [vector!] return: [vector!] /local res [vector!]][
        res: copy b
		multiply -1 res
		res/1: system/words/add res/1 a
        create res 
	]

    subs: function [a [vector!] b [number!] return: [vector!] /local res [vector!]][
        res: copy a
        res/1: subtract a/1 b
        create res
	]

    norm: func [a [vector!] return: [float!]][
        (absolute (first a * conjugate a)) ** 0.5
    ]

    inorm: func [a [vector!] return: [float!]][
        norm dual a
    ]

    set 'normalized func [a [vector!] return: [float!]][
		res: copy a
        res * (1 / norm res)
	]
]
;if __name__ : :  '__main__':
    ; A rotor (Euclidean line) and translator (Ideal line)
    rotor: func [angle line][
	    (cosine angle / 2) + ((sine angle / 2) * normalized line)
	]
    translator: func [dist line][
	    1.0 + (dist / 2 * line)
	]
	rotate: func [what rot][
		rot * what * ~ rot
	]
	translate: func [what trans][
		trans * what * ~ trans
	]
    ; PGA is plane based. Vectors are planes. (think linear functionals)
    E0:  PGA3D/init 1.0 2        ; ideal plane
    E1:  PGA3D/init 1.0 3        ; x: 0 plane
    E2:  PGA3D/init 1.0 4        ; y: 0 plane
    E3:  PGA3D/init 1.0 5        ; z: 0 plane

    ; A plane is defined using its homogenous equation ax + by + cz + d :  0 
    PLANE: func [a b c d][
        a * E1 + (b * E2) + (c * E3) + (d * E0)
	]
	
	; Lines are bivectors.
	E01: E0 ^ E1
	E02: E0 ^ E2
	E03: E0 ^ E3
	E12: E1 ^ E2
	E31: E3 ^ E1
	E23: E2 ^ E3
	
    ; PGA points are trivectors.
    E123: E1 ^ E2 ^ E3
    E032: E0 ^ E3 ^ E2
    E013: E0 ^ E1 ^ E3
    E021: E0 ^ E2 ^ E1
	
	E0123: E0 ^ E1 ^ E2 ^ E3

    ; A point is just a homogeneous point, euclidean coordinates plus the origin
    POINT: func [x y z][
        E123 + (x * E032) + (y * E013) + (z * E021)
	]
comment {
	;Ideal point
	iPOINT: func [x y z][
		(x * E032) + (y * E013) + (z * E021)
	]
	; With Plücker coordinates (?)
	line: func [px py pz dx dy dz][
		(px * e01) + (py & e02) + (pz * e03) + (dx * e12) + (dy * e31) + (dz * e23)
	]
    ; for our toy problem (generate points on the surface of a torus)
    ; we start with a function that generates motors.
    ; circle(t) with t going from 0 to 1.
    CIRCLE: func [t radius line][
    	(rotor t * pi * 2 line) * (translator radius E1 * E0)
	]

    ; Elements of the even subalgebra (scalar + bivector + pss) of unit length are motors
    ROT:  rotor pi / 2  E1 * E2

    ; The outer product ^ is the MEET. Here we intersect the yz (x: 0) and xz (y: 0) planes.
    AXZ:  E1 ^ E2                ; x: 0, y: 0 -> z - axis line

    ; line and plane meet in point. We intersect the line along the z - axis (x: 0,y: 0) with the xy (z: 0) plane.
    ORIG:  AXZ ^ E3              ; x: 0, y: 0, z: 0 -> origin

    ; We can also easily create points and join them into a line using the regressive (vee, &) product.
    PX:  POINT 1 0 0
    LINE:  ORIG & PX             ; & :  regressive product, JOIN, here, x - axis line.

    ; Lets also create the plane with equation 2x + z - 3 :  0
    P:  PLANE 2 0 1 -3
	
	pole: P | PX  ;orthogonal line from PX to plane P
    ; See the 3D PGA Cheat sheet for a huge collection of useful formulas
    POINT_ON_PLANE:  pole * P
	p2: e2 ^ P
	l2: PX & p2
    ; rotations work on all elements ..
    ROTATED_LINE:   rotate LINE ROT ;ROT * LINE * ~ ROT
    ROTATED_POINT:  rotate PX ROT ;ROT * PX * ~ ROT
    ROTATED_PLANE:  rotate P ROT ;ROT * P * ~ ROT

	
    ; a torus is now the product of two circles.
    TORUS: func [s t r1 l1 r2 l2][
	    (CIRCLE s r2 l2) * (CIRCLE t r1 l1)
	]
	
	; sample the torus points by sandwich with the origin
    POINT_ON_TORUS: func [s t /local to][
	    to:  TORUS s  t  0.25  E1 * E2  0.6  E1 * E3
	    to * E123 * ~ to
	]

	comment {
    ; output some numbers.
    print ["a point       :" PX]
    print ["a line        :" LINE]
    print ["a plane       :" P]
    print ["a rotor       :" ROT]
    print ["rotated line  :" ROTATED_LINE]
    print ["rotated point :" ROTATED_POINT]
    print ["rotated plane :" ROTATED_PLANE]
    print ["point on plane:" pga3d/normalized POINT_ON_PLANE]
    print ["point on torus:" POINT_ON_TORUS 0.0 0.0]
    print [E0 _ 1]
    print [1 _ E0]
	}
}
comment {
start1: start2: 0 step1: 0.05 step2: 1 
view [
	box 500x500 
	draw [transform 0 1 1 250x250 line -250x0 250x0 line 0x-250 0x250 line] 
	rate 10 
	on-time [
		set pt: [z y x] at to-block point_on_torus 
			start1: start1 + step1 
			start2: start2 + step2 
			12 
		repend face/draw [as-pair 200 * x 200 * y] 
		if 500 < length? face/draw [remove at face/draw 13]
	]
]
}
