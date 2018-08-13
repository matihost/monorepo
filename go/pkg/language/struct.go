package language

import "fmt"

// Vertex - sample exported struct
type Vertex struct {
	X int
	Y int
}

// CreateVertex - sample exported function which acts like constructor method
func CreateVertex(x, y int) Vertex{
	fmt.Printf("Creating Vertex with dimensions (%d, %d)", x, y)
	return Vertex{x, y}
}