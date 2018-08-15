package language

import (
	"fmt"
)

// closures  are function values which references to variables outside them
// adder return function which keeps own reference to own instance of sum
func adderFunc() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

// fibonacci - as closure
func fibonacci() func() int {
	x := 0
	y := 0
	return func() int {
		if y == 0 {
			y = 1
		} else {
			r := x + y
			x = y
			y = r
		}
		return x
	}
}

// ShowClosuresUsage  - closures  are function values which references to variables outside them
func ShowClosuresUsage() {

	// making function values as variables
	adder, subtractor := adderFunc(), adderFunc()

	// add will effectively result in 3
	adder(1)
	add := adder(2)

	// sub will effectively result in 6
	subtractor(10)
	sub := subtractor(-4)

	fmt.Println(add, sub)

	// fibonacci as closure
	fib := fibonacci()
	for i := 0; i < 10; i++ {
		fmt.Println(fib())
	}
}
