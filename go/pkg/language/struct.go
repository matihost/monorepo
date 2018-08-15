// Package language - the package from "pkg" are intended to be imported by 3rd party apps
package language

import "fmt"

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
func ShowStructOperations(){
	// s is a variable to anonymous struct containing one int
	s :=  struct{int}{4}
	// be default is field has no name, its type is the name of the field
	s.int = 3
	Print(s)

	// same by divide declaration from initialization
	// semicolon to make struct declaration in one line 
	// when struct field name is not provided - its type cannot repeat in the declaration
	var ds struct{int; string; s string}
	// providing values are optional - default zero values are used
	ds = struct{int; string; s string}{}
	ds.int = 5
	ds.string = "ala"
	ds.s = "ma"

	Print(ds)
}


// Print - generic way to print struct, every struct is an interface
func Print(s interface{}){
	fmt.Printf("Interface=%v\n", s)
}
