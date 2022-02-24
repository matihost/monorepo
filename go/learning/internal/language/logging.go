package language

import (
	"fmt"
	"go.uber.org/zap"
)

var (
	// when function return more than one result it can be ignored via referencing it to _
	logger, _ = zap.NewProduction()
)

// Info - log as JSON
func Info(s string) {
	logger.Info(s)
}

// Print - generic way to print any type, int, struct, map, table, slice and pointer to them
// every type is an interface
func Print(s interface{}) {
	Info(fmt.Sprintf("Interface=%v", s))
}
