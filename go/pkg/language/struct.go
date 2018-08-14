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
