// Package language - the package from "pkg" are intended to be imported by 3rd party apps
package language

import (
	"fmt"
)

var (
	// a is an array of 10 strings, size is the part of array type
	// arrays cannot be resized
	a [10]string

	// slice is like table but with size declaration
	// slices are more common than tables
	// zero value of a slice is nil.
	slice []int

	// array variable can be initialized in place
	// last element is 0 because is not initialized
	primes = [6]int{2, 3, 5, 7, 11}
)

// ShowArraysAndSlices - show conversion from table to slice
func ShowArraysAndSlices() {

	var (
		// len is build in function for calculating size of the structure
		sliceMaxIndex = len(primes) - 1
	)

	// nil slice has a length and capacity of 0 and has no underlying array.
	printSlice(slice)

	// create slice from array
	slice = primes[2:4]

	// when slicing, the high or low bounds can be omitted
	// to use their defaults instead (low -> 0 , high -> len(table))
	// take all elements except the last one
	slice = primes[:sliceMaxIndex]

	slice = primes[1:]

	// shortest to convert table to same slice, equivalent for primes[0:len(primes)]
	slice = primes[:]

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

	printSlice(coolSlice)

	// slice capacity can be decreased by limiting it from the left
	coolSlice = coolSlice[2:]
	printSlice(coolSlice)

	// enlarging slice to the capacity
	coolSlice = coolSlice[:cap(coolSlice)]
	printSlice(coolSlice)

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

	// dynamically created slice - the way to dynamically allocate tables
	// build-in make function allocates a zeroed array and returns a slice that refers to that array
	// make(tableSpec, len, cap)
	slice = make([]int, 5, 10)
	slice[0] = 5
	slice[4] = 5
	printSlice(slice)

	// slice is also an interface
	Print(slice)

}

func printSlice(s []int) {
	// slice has length and capacity - so slice can be still enlarged to the underlying table
	fmt.Printf("Slice: %v len=%d cap=%d\n", s, len(s), cap(s))
}
