package language

// An interface type is defined as a set of method signatures.

import (
	"fmt"
	basic "github.com/matihost/monorepo/go/learning/internal/language"
)

// Abs - Value of interface type can hold any value that implements those methods.
//
// Interfaces are implemented implicitly
// A type implements an interface by implementing its methods. There is no explicit declaration of intent, no "implements" keyword.
// Implicit interfaces decouple the definition of an interface from its implementation,
// which could then appear in any package without prearrangement.
type Abs interface {
	Abs() float64
}

// ShowInterfaceUsage - show interface usages
func ShowInterfaceUsage() {
	var a Abs
	v := Vertex{}

	// actually only *Vertex implements "Abs", not bare Vertex
	// that is why it is good approach to make sure all methods operate either on pointer to struct or on bare struct
	// not mixed method declarations
	//
	//a = v
	a = &v

	fmt.Println(a.Abs())
	basic.Print(a)
}
