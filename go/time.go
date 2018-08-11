// Every Go program is made up of packages.
// Executable Programs start running in package main.
package main

import (
	// ( ) factored statement to be used to gather more the same elements
	// in here it is used for imports
	"fmt"
	"math"
	"time"

	// import subpackage
	"math/rand"
)

// In Go, a name is exported if it begins with a capital letter.
// Defining constants visible in package:
// Constants can be character, string, boolean, or numeric values.
// Constants cannot be declared using the := syntax.
const (
	// constant is high precision value
	nonExportedConstant = 1 << 100
	// ExportedConstant exported entries are only started with capital lette
	ExportedConstant = nonExportedConstant >> 95
)

// Definining variables visible in the package (non-exported)
// These variables are initiliazed with default value per type
var (
	c            int
	python, java bool
)

// type is inherited if initialized
var initializedVar = 5

func main() {
	// variable declaration (w/o initializer it initializes to "zero" value)
	var i int

	// Inside a function,
	// the := short assignment statement can be used in place of a var declaration
	a, b := swap("ala", "ma")

	// When importing a package, you can refer only to its exported names.
	// Any "unexported" names are not accessible from outside the package.
	fmt.Println("Welcome!")
	fmt.Println("The time is", time.Now())
	fmt.Println("My favorite numbers are ", addTwo(rand.Intn(10), 5), add(1, 2, 3))
	fmt.Printf("Now you have %g problems and PI is %g and i is: %v\n", math.Sqrt(7), math.Pi, i)
	// casting too big constant to floating value
	c := float64(nonExportedConstant)
	fmt.Printf("Big constant value type: %T and value: %v\n", c, sqrt(c))

	x, y := split(ExportedConstant)
	fmt.Println("Swapped strings: ", a, b, "and splitted value", x, y)

}

// x and y are the same type arguments
func addTwo(x, y int) int {
	return x + y
}

// last argument is table
func add(a ...int) int {
	sum := 0
	// for statement
	// there are no parentheses surrounding the three components of the for statement
	// and the braces { } are always required.
	// all parts are optional - and there is no separate *while* statement
	for i := 0; i < len(a); i++ {
		sum += a[i]
	}
	return sum
}

func sqrt(x float64) string {
	// if statements are like its for loops;
	// the expression need not be surrounded by parentheses ( ) but the braces { } are required.
	if x < 0 {
		return sqrt(-x) + "i"
	}
	return fmt.Sprint(math.Sqrt(x))
}

// function can return more than one result
func swap(x, y string) (string, string) {
	return y, x
}

// named return variables with "naked" return
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}
