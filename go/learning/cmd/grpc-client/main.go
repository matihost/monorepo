/*
 *
 * Original work Copyright 2015 gRPC authors.
 * Modified work Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/*
 * Changes:
 * 2019-06-24: Log the SayHello response header called hostname
 */

// Package main implements a client for Greeter service.
package main

import (
	"context"
	"flag"
	"log"
	"os"
	"strings"
	"time"
	"crypto/tls"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	pb "google.golang.org/grpc/examples/helloworld/helloworld"
	"google.golang.org/grpc/metadata"
)

const (
	defaultName = "world"
	timeout     = 5 * time.Second
)

func main() {
	hostname, _ := os.Hostname()
	address := flag.String("addr", hostname + ":6565", "host:port of gRPC server")
	cert := flag.String("cert", "/data/cert.pem", "path to TLS certificate")
	repeat := flag.Int("repeat", 3, "number of unary gRPC requests to send")
	secure := flag.Bool("tls", true, "connect with TLS")
	tlsNoCheck := flag.Bool("tls-no-verify", false, "connect with TLS with ignoring TLS cert")
	flag.Parse()

	// Set up a connection to the server.
	var conn *grpc.ClientConn
	var err error
	if !*secure {
		conn, err = grpc.Dial(*address, grpc.WithInsecure())
	} else if *tlsNoCheck {
		config := &tls.Config{
			InsecureSkipVerify: true,
		}
		conn, err = grpc.Dial(*address, grpc.WithTransportCredentials(credentials.NewTLS(config)))
	}	else {
		tc, tcErr := credentials.NewClientTLSFromFile(*cert, "")
		if tcErr != nil {
			log.Fatalf("Failed to generate credentials %v", tcErr)
		}
		conn, err = grpc.Dial(*address, grpc.WithTransportCredentials(tc))
	}

	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewGreeterClient(conn)

	// Determine name to send to server.
	name := defaultName
	nonFlagArgs := make([]string, 0)
	for _, arg := range os.Args {
		if !strings.HasPrefix(arg, "-") {
			nonFlagArgs = append(nonFlagArgs, arg)
		}
	}
	if len(nonFlagArgs) > 1 {
		name = nonFlagArgs[len(nonFlagArgs) -1 ]
	}

	// Contact the server and print out its response multiple times.
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	for i := 0; i < *repeat; i++ {
		var header metadata.MD
		r, err := c.SayHello(ctx, &pb.HelloRequest{Name: name}, grpc.Header(&header))
		if err != nil {
			log.Fatalf("could not greet: %v", err)
		}
		hostname := "unknown"

		if len(header["hostname"]) > 0 {
			hostname = header["hostname"][0]
		}
		log.Printf("%s from %s", r.Message, hostname)
	}
}
