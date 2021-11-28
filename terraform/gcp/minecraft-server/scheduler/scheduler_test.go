// Integration tests
// Tests are skipped unless run with:
//
// TEST=INT GCP_PROJECT_ID=projectId go test
package scheduler

import (
	"errors"
	"testing"
	"context"
	"os"
)

func TestMain(m *testing.M) {
	if os.Getenv("TEST") == "INT" {
		if os.Getenv("GCP_PROJECT_ID") == "" {
			panic(errors.New("Missing required GCP_PROJECT_ID env property"))
		}
		m.Run()
	}
}

// Test scheduler.Handle function
func TestInstanceGroupScaling(t *testing.T) {
	cases := []struct {
		minecraftServerName, zone, action string
	}{
		{"prod-01-minecraft-server", "us-central1-a", "start"},
		{"prod-01-minecraft-server", "us-central1-a", "stop"},
	}
	for _, c := range cases {
		// given
		t.Setenv("MINECRAFT_SERVER_NAME", c.minecraftServerName)
		t.Setenv("GCP_ZONE", c.zone)

		ctx := context.Background()
		pubsub := PubSubMessage{Data: []byte(c.action)}

		// when
		err := Handle(ctx, pubsub)

		// then
		if err != nil {
			t.Error(err)
		}
	}
}
