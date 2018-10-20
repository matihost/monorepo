package language

// Go is shipped with build in basic types:
//
// bool
// string
// int  int8  int16  int32  int64
// uint uint8 uint16 uint32 uint64 uintptr
// byte // alias for uint8
// rune // alias for int32
//      // represents a Unicode code point
// float32 float64
// complex64 complex128  - build in complex type with imaginary part (like 2 + 3i)
//
// all of them and all build in functions (like make, len) are defined in auto imported virtual  build-in package
// https://golang.org/pkg/builtin
//
// In particular:
//
// *int* is a signed integer type that is at least 32 bits in size. It is a
// distinct type, however, and not an alias for, say, int32.
//
// *byte* is an alias for uint8 and is equivalent to uint8 in all ways
// type byte = uint8
// it is used, by convention, to distinguish byte values from 8-bit unsigned
// integer values.
//
//
// *rune* is an alias for int32 used, by convention, to distinguish character (Unicode) values from integer values.
// type rune = int32
//
// *string* is the set of all strings of 8-bit bytes, conventionally but not
// necessarily representing UTF-8-encoded text. A string may be empty, but
// not nil. Values of string type are immutable.
//
// The int, uint, and uintptr types are usually 32 bits wide on 32-bit systems and 64 bits wide on 64-bit systems.

import (
	"fmt"
)

// ShowBasicTypes - show basic type operations
func ShowBasicTypes() {

	// The non-initialized variables are initialized with "zero" value :
	//     0 for numeric types,
	//     false for the boolean type
	//     "" (the empty string) for strings.
	//     nil - for pointer, arrays, slices, struct
	var (
		ui uint32
		si int32
		b  byte
		f  float64
		c  complex64
		s  string
		p  *int
	)

	i := 5

	// Unlike in C, in Go assignment between items of different type requires an explicit conversion.
	b = byte(i)
	f = 1.1
	c = 3 + 2.0i
	i = -5
	// converting -5 to unsigned int will result 4294967291
	ui = uint32(i)
	// converting floating to integer will truncate the value  (will be value 1)
	si = int32(f)

	// the & operator generates a pointer to its operand.
	p = &i

	// go does not support pointer arithmetic
	// p = p +1

	// converting number to string will result in creating one character string
	// number is Unicode number
	// if number is invalid, then it so called "replacement character" It’s a replacement character (\uFFFD)
	s = string(322)

	// the * operator denotes the pointer's underlying value
	fmt.Println("Various basic types", b, i, f, ui, si, c, s, p, *p)

	// converting between slices of bytes, runes and strings
	// 3 characters string is in fact 4 characters slice
	bytes := []byte("abł")
	text := string(bytes)
	fmt.Printf("%#v\n", bytes) // []byte{0x61, 0x62, 0xc5, 0x82}
	fmt.Printf("%#v\n", text)  // "abł"

	// 3 characters string is ... 3 character aka runes slice
	runes := []rune("abł")
	fmt.Printf("%#v\n", runes)         // []int32{97, 98, 322}
	fmt.Printf("%+q\n", runes)         // ['a' 'b' '\u0142']
	fmt.Printf("%#v\n", string(runes)) // "abł"

	// floats
	one, two, three := 0.1, 0.2, 0.3 
	fmt.Println(one+two > three)
}
