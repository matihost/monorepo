// Package language - the package from "pkg" are intended to be imported by 3rd party apps
package language

import (
	"fmt"
	// lang "github.com/matihost/learning/go/internal/language"
)

func compute(x, y int) int {
	return x + y
}

// function value - as type is just without names of function itself and only types are present
func doComputation(fn func(int, int) int, x, y int) int {
	return fn(x, y)
}

// ShowFunctionValuesUsage - show usage of function as values
func ShowFunctionValuesUsage() {

	// function passed as variable
	fmt.Println(doComputation(compute, 1, 10))

	// anonymous function stored as local variable, same like global function but name is variable name
	multi := func(x, y int) int {
		return x * y
	}

	fmt.Println(doComputation(multi, 1, 10))
}
