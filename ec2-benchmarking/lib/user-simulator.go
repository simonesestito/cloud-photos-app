package lib

import (
	"fmt"
	"math/rand"
	"time"
)

type UserSimulation struct {
	currentState string
}

func NewUserSimulation() *UserSimulation {
	return &UserSimulation{currentState: "start"}
}

func (u *UserSimulation) start() string {
	fmt.Println("Entering start state...")
	// Define the list of possible next states from "start"
	possibleStates := []string{"searchUndefinedUser", "searchExistingUser", "openUserProfile", "uploadPhoto", "waitPhotoUpload"}
	// Randomly select the next state
	nextState := possibleStates[rand.Intn(len(possibleStates))]
	return nextState
}

func (u *UserSimulation) searchUndefinedUser() string {
	fmt.Println("Entering searchUndefinedUser state...")
	return "searchExistingUser"
}

func (u *UserSimulation) searchExistingUser() string {
	fmt.Println("Entering searchExistingUser state...")
	return "openUserProfile"
}

func (u *UserSimulation) openUserProfile() string {
	fmt.Println("Entering openUserProfile state...")
	return "uploadPhoto"
}

func (u *UserSimulation) uploadPhoto() string {
	fmt.Println("Entering uploadPhoto state...")
	return "waitPhotoUpload"
}

func (u *UserSimulation) waitPhotoUpload() string {
	fmt.Println("Entering waitPhotoUpload state...")
	return "start"
}

func (u *UserSimulation) Run() {
	for {
		nextState := ""
		switch u.currentState {
		case "start":
			nextState = u.start()
		case "searchUndefinedUser":
			nextState = u.searchUndefinedUser()
		case "searchExistingUser":
			nextState = u.searchExistingUser()
		case "openUserProfile":
			nextState = u.openUserProfile()
		case "uploadPhoto":
			nextState = u.uploadPhoto()
		case "waitPhotoUpload":
			nextState = u.waitPhotoUpload()
		}
		if nextState != "start" {
			time.Sleep(1 * time.Second)
		}
		u.currentState = nextState
	}
}
