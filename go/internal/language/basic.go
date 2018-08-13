// Package language - this is the package documentation
// The name is always the last directory name in the path
// Even when the full package name is github.com/matihost/learning/go/internal/language
// The convention is to have the last directory in sync with cmd app name
//
// The "internal" package exported elements are visible only by the current application only.
package language

import (
	"fmt"
	"math"
	"runtime"
	"time"
)

// AddTwo -  exported function staring in capital letter - has to have a comment starting wiht name of the method
// x and y are the same type arguments - so do not need to repeast the int type for both
func AddTwo(x, y int) int {
	return x + y
}

// Add - last argument is table
func Add(a ...int) int {
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

// Sqrt - this is example of exported funtion from the package, start with capital letter and contains a comment
// with description
func Sqrt(x float64) string {
	// if statements are like its for loops;
	// the expression *need not be surrounded by parentheses ( ) but the braces { } are required.
	if x < 0 {
		return Sqrt(-x) + "i"
	}
	return fmt.Sprint(math.Sqrt(x))
}

// the if statement can have "init" section like for, v is visible only inside if statement
// or its else statement
func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	} else {
		fmt.Printf("%g >= %g\n", v, lim)
		return lim
	}
}

// OsName - switch statement - "break" is automatic, "init" statement as well
// case are run from top to bottown, case can be a function returnig desired type
func OsName() string {
	switch os := runtime.GOOS; os {
	case "linux":
		fmt.Println("Got linux!")
		return "Linux"
	case same(os):
		fmt.Println("Got Darwin!")
		return "Mac"
	default:
		return os
	}
}

// Welcome - welcome func comment
func Welcome() string {
	t := time.Now()
	// defering function - is to invoke function after the current function finishes (like finally in Java)
	// but the variables are evaluated at the moment of statement
	defer fmt.Printf("Time now is %s\n", t.String())

	// Deferred function calls are pushed onto a stack.
	// When a function returns, its deferred calls are executed in last-in-first-out order.
	defer fmt.Println("ala")
	defer fmt.Println("ma")
	defer fmt.Println("kota")

	// switch w/o variable - is like with bool = true  - usefull for long if/else chains
	switch {
	case t.Hour() < 12:
		return "Good morning"
	case t.Hour() < 17:
		return "Good afternoon"
	default:
		return "Good evening"
	}
}

// casting example
func same(os string) string {
	return string(os)
}

// Swap - function can return more than one result
func Swap(x, y string) (string, string) {
	return y, x
}

// Split - named return variables with "naked" return
func Split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}
