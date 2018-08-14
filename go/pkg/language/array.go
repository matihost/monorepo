package language

import (
	"fmt"
)

var (
	// a is an array of 10 strings, size is the part of array type
	// array cannot be resized
	a [10]string

	// array variable can be initialized in place
	// last element is 0 because is not initialized
	primes = [6]int{2, 3, 5, 7, 11}
)

// ShowArraysAndSlices - show convertion from table to slice
func ShowArraysAndSlices() {

	var (
		// slice is like table but with size declaration
		// slices are more common than tables
		slice []int
		// len is build in function for calculating size of the structure
		sliceMaxIndex = len(primes) - 1
	)

	// create slice from array
	slice = primes[2:4]

	// when slicing, the high or low bounds can be omitted
	// to use their defaults instead (low -> 0 , high -> len(table))
	// take all elements except the last one
	slice = primes[:sliceMaxIndex]

	slice = primes[1:]

	coolSlice := slice[:len(slice)-1]

	/*
		Slices are like references to arrays
		A slice does not store any data, it just describes a section of an underlying array.
		Changing the elements of a slice modifies the corresponding elements of its underlying array.
		Other slices that share the same underlying array will see those changes.
	*/
	// these statements edit the same array entry
	slice[0] = 1
	primes[1] = 2

	fmt.Println("Not really primes:", coolSlice)

	// slice literal - is in fact an array of the size and then slice version of it
	slice = []int{1, 5, 8}

	// literal being slice of struct containing int and bool
	s := []struct {
		i int
		b bool
	}{
		{2, true},
		{3, false},
		{5, true},
		{7, true},
		{11, false},
		{13, true},
	}

	fmt.Println("Complex slice literal:", s)
}
