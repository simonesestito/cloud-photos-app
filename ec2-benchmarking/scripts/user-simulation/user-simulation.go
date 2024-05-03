package main

import "ec2-benchmarking/lib"

func main() {
	// TODO: should run multiple users concurrently
	sim := lib.NewUserSimulation()
	sim.Run()
}
