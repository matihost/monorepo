package language

import (
	"fmt"
	lang "github.com/matihost/learning/go/internal/language"
	"math"
)

// Vertex - sample exported struct
type Vertex struct {
	X, Y int
	desc string
}

// Abs - sample example of a method - the function with receiver part that appears in its own argument list between the func keyword and the method name
// receiver is like a special first argument - struct + function with struct receiver essentially mimic class from
// other object languages
func (v *Vertex) Abs() float64 {
	return math.Sqrt(float64(v.X*v.X + v.Y*v.Y))
}

// Sum -  methods usually get pointer to type, not type itself only
// it is rare to pass "not" pointers as receiver
// it is because receiver is like any other argument pass to function - so it is passed by value
// without pointer - a copy of Vertex struct is pass to function - so it is not possible to modify it in place
// (not to mention creating a copy is time consuming)
//
// What is more - it is legal to not dereference variable to run its method
// or pass pointer to receiver being not pointer
//
// all methods on a given type should have either value or pointer receivers, but not a mixture of both
// main reason is that signature of receiver is a type definition which can or may not be convertible to interface
// See interface.go
func (v *Vertex) Sum() int {
	return v.X + v.Y
}

// SumBare - a sample method to show that variable being pointer or not can be used to call a method
// the difference is only with semantic - method accepting pointer - can mutate type
// method accepting bare type - operates on copy of the type
func (v Vertex) SumBare() int {
	return v.X + v.Y
}

// CreateVertex - sample exported function which acts like constructor method
func CreateVertex(x, y int) Vertex {
	fmt.Printf("Creating Vertex with dimensions (%d, %d)\n", x, y)
	return Vertex{x, y, ""}
}

// ShowVertex - presents accessing struct content
func (v Vertex) ShowVertex() {
	// creating pointe to struct
	pv := &v

	// accessing struct content and calling methods
	// when struct is behind pointer - it is not necessary to dereference
	// aka pv.X is the same like (*pv).X
	fmt.Println("Vertex x dimension is:", v.X, pv.X, (*pv).X, " and abs: ", pv.Abs())

	// it is legal to take pointer directly upon struct construction because it is created on heap
	pv = &Vertex{}

	// again methdos like fields of the struct - can be accessed without need of dereference
	pv.Sum()
	// pv is pointer ,even thou SumBare with receiver w/o pointer can be called
	pv.SumBare()
	(*pv).Sum()

	// it is also legal call method on variable without pointer
	v.Sum()
}

// ShowStructOperations - show various vertex operation
func ShowStructOperations() {
	// s is a variable to anonymous struct containing one int
	s := struct{ int }{4}
	// be default is field has no name, its type is the name of the field
	s.int = 3
	lang.Print(s)

	// same by divide declaration from initialization
	// semicolon to make struct declaration in one line (however it is against gofmt -s)
	// when struct field name is not provided - its type cannot repeat in the declaration
	var ds struct {
		int
		string
		s string
	}
	// providing values are optional - default zero values are used
	ds = struct {
		int
		string
		s string
	}{}
	ds.int = 5
	ds.string = "ala"
	ds.s = "ma"

	lang.Print(ds)
}
