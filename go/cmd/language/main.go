// Every Go program is made up of packages.
// Executable Programs start running in package main.
// This is only the program. It follows the pattern that is is in "cmd" subpackage
//
// The name of package "main" here is special exception - even for downloading the code
// the package has to be
// go get github.com/matihost/learning/go/cmd/language
//
// The library specific packages has normal name (the last directory) and can imported
//
// For more language structure go to github.com/matihost/learning/go/internal/language and
// github.com/matihost/learning/go/pkg/language
package main

import (
	// ( ) factored statement to be used to gather more the same elements
	// in here it is used for imports
	"fmt"
	"math"
	"time"

	// import subpackage, default name for package to access its functions et.c is the last word
	// in here it is rand
	"math/rand"

	// imports are like variables there can named differently, here to shortcut default language - lang is used
	// convention is to use "internal" subpackage for code not inteded for other apps do import
	// convention is that last word should represen the app code is intended for
	// do not split code to too many packages like in Java
	basic "github.com/matihost/learning/go/internal/language"

	// convention is to keep code for other apps to import in "pkg" subpackage
	lang "github.com/matihost/learning/go/pkg/language"
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
	p            *int
	// Go has pointers
	now  *time.Time
	vert *lang.Vertex
)

// type is inherited if initialized
var initializedVar = 5

// there can be only one "main" function in the same package and directory (essentually the same package)
func main() {
	// variable declaration (w/o initializer it initializes to "zero" value)
	var i int

	xx := time.Now()

	// setting pointer ferencing to xx
	now = &xx

	// Inside a function,
	// the := short assignment statement can be used in place of a var declaration
	a, b := basic.Swap("ala", "ma")

	// When importing a package, you can refer only to its exported names.
	// Any "unexported" names are not accessible from outside the package.
	fmt.Println(basic.Welcome(), "to", basic.OsName())

	// when object is not string, the .String() funtion is called to return string
	fmt.Println("The time is", time.Now())

	// to defererence pointer
	fmt.Println("The time is", *now)

	fmt.Println("My favorite numbers are ", basic.AddTwo(rand.Intn(10), 5), basic.Add(1, 2, 3))
	fmt.Printf("Now you have %g problems and PI is %g and i is: %v\n", math.Sqrt(7), math.Pi, i)
	// casting too big constant to floating value
	c := float64(nonExportedConstant)
	fmt.Printf("Big constant value type: %T and value: %v\n", c, basic.Sqrt(c))

	x, y := basic.Split(ExportedConstant)
	fmt.Println("Swapped strings: ", a, b, "and splitted value", x, y)
}
