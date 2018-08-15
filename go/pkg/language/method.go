package language

import (
	"fmt"
)

// MyInt - creating own wrapper, alias for already existing type (even basic) type
// that allows adding methods (function with receiver part) to them
type MyInt int

// Abs - added method to type Int
// method with a receiver can be added to types defined in the same package
// it is not possible to add a method with a receiver to type from other packages
func (f MyInt) Abs() int {
	if f < 0 {
		return int(-f)
	}
	return int(f)
}

// ShowAddedMethodToBasicType - show added method to int type
func ShowAddedMethodToBasicType() {

	// casting basic type to aliased type, so that methods can be run on that
	i := MyInt(5)

	fmt.Println(i.Abs())
}
