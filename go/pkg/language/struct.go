// Package language - the package from "pkg" are intended to be imported by 3rd party apps
package language

import (
	"fmt"
	lang "github.com/matihost/learning/go/internal/language"
)

// Vertex - sample exported struct
type Vertex struct {
	X, Y int
	desc string
}

// CreateVertex - sample exported function which acts like constructor method
func CreateVertex(x, y int) Vertex {
	fmt.Printf("Creating Vertex with dimensions (%d, %d)\n", x, y)
	return Vertex{x, y, ""}
}

// ShowVertex - presents accessing struct content
func ShowVertex(v Vertex) {
	// creating pointe to struct
	pv := &v

	// accessing struct content
	// when struct is behind pointer - it is not necessary to dereference
	// aka pv.X is the same like (*pv).X
	fmt.Println("Vertex x dimension is:", v.X, pv.X, (*pv).X)
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
