package language

import (
	lang "github.com/matihost/monorepo/go/learning/internal/language"
	"strings"
)

// A map maps keys to values.
// The zero value of a map is nil. A nil map has no keys, nor can keys be added.
// The make function returns a map of the given type, initialized and ready for use.
// make(map[keyType]valueType)
var m map[string]Vertex

// ShowMapsUsage - show Go map usages
func ShowMapsUsage() {

	v := Vertex{X: 1, Y: 2, desc: "maKota"}

	m = make(map[string]Vertex)

	m["Ala"] = v

	m["kot"] = Vertex{1, 4, "jestAli"}

	lang.Print(m)

	// creating map of pointer to Vertex
	mp := make(map[string]*Vertex)

	mp["Ala"] = &v
	v = m["kot"]
	mp["kot"] = &v

	// delete map entry for given key
	delete(m, "kot")
	lang.Print(m)

	// testing whether element for given key is present in the map
	// v, ok := m["Ala"]
	if v, ok := m["Ala"]; ok {
		lang.Print(v)
	}

	//map literals are like struct literals, but the keys are required.
	// value type can be omitted because it is taken from map declaration
	m := map[string]Vertex{
		"ala":  {1, 2, "s"},
		"ma":   {},
		"kota": {3, 4, "s"},
	}
	lang.Print(m)

	lang.Print(wordCount("Ala ma kota. Ala lubi kota."))
}

func wordCount(s string) map[string]int {
	r := make(map[string]int)

	for _, v := range strings.Fields(s) {
		if _, ok := r[v]; ok {
			r[v]++
		} else {
			r[v] = 1
		}
	}
	return r
}
