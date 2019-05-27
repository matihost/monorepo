package language

import "testing"

// Go has a lightweight test framework:
// go test company.com/git_project/git_repo/package
// like this:
// go test github.com/matihost/learning/go/pkg/language
// Requirements:
// - Test file : *_test.go that contains functions named TestXXX with signature func (t *testing.T).
// - The test framework runs each such function;
// - If the function calls a failure function such as t.Error or t.Fail, the test is considered to have failed.
func TestReverse(t *testing.T) {
	// given
	cases := []struct {
		in, expected string
	}{
		{"Hello, world", "dlrow ,olleH"},
		{"Hello, Mati", "itaM ,olleH"},
		{"", ""},
	}
	for _, c := range cases {
		// when
		got := Reverse(c.in)

		//then
		if got != c.expected {
			t.Errorf("Reverse(%q) == %q, want %q", c.in, got, c.expected)
		}
	}
}
