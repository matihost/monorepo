package scheduler

import (
	"context"
	"log"
	"os"
	compute "cloud.google.com/go/compute/apiv1"
	computepb "google.golang.org/genproto/googleapis/cloud/compute/v1"
)

// PubSubMessage is the payload of a Pub/Sub event.
// See the documentation for more details:
// https://cloud.google.com/pubsub/docs/reference/rest/v1/PubsubMessage
type PubSubMessage struct {
	Data []byte `json:"data"`
}

// HelloPubSub consumes a Pub/Sub message.
func Handle(ctx context.Context, m PubSubMessage) error {
	operation := string(m.Data) // Automatically decoded from base64.
	var desiredSize int32 = 1
	if operation == "stop" {
		desiredSize = 0
	}
	minecraftServerName := os.Getenv("MINECRAFT_SERVER_NAME")
	zone := os.Getenv("GCP_ZONE")
	projectId := os.Getenv("GCP_PROJECT_ID")

	return ScaleInstanceGroup(projectId, minecraftServerName, zone, desiredSize)
}


func ScaleInstanceGroup(projectId, instanceGroup, zone string, desiredSize int32) error {
	log.Printf("About to scale instance group: %s/%s to %d", zone, instanceGroup, desiredSize)
	ctx := context.Background()
	c, err := compute.NewInstanceGroupManagersRESTClient(ctx)
	if err != nil {
		return err
	}
	defer c.Close()

	req := &computepb.ResizeInstanceGroupManagerRequest{
		// See https://pkg.go.dev/google.golang.org/genproto/googleapis/cloud/compute/v1#ResizeInstanceGroupManagerRequest.
		InstanceGroupManager: instanceGroup,
		Size: desiredSize,
		Zone: zone,
		Project: projectId,
	}
	resp, err := c.Resize(ctx, req)
	if err != nil {
		return err
	}
	if resp != nil {
		log.Printf("InstanceGroup: %v Status: %v", resp.Proto().GetName(), resp.Proto().Status.Enum().String())
	}
	return nil
}
