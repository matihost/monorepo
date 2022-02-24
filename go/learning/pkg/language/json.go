package language

import (
	"encoding/json"
	"io"

	"github.com/pkg/errors"
)

func WriteJSON(w io.Writer, v interface{}) error {
	e := json.NewEncoder(w)
	e.SetIndent("", "  ")
	return errors.Wrap(e.Encode(v), "failed to encode JSON")
}
