package lib

import (
	"encoding/json"
	"fmt"
	"math"
	"math/rand"
	"os"
	"sync"
	"time"
)

type UserSimulation struct {
	myUsername       string
	currentState     string
	lastSearchedUser string
	lastPhotoId      string
	durationsMutex   sync.Mutex
	durations        []int
	failedRequests   int
}

type UserSimulationStats struct {
	ValidRequests  int
	FailedRequests int
	TimeMean       float64
	TimeStdDev     float64
}

func NewUserSimulation() *UserSimulation {
	generatedUsername := fmt.Sprint("simulation0", rand.Intn(100_000))

	return &UserSimulation{
		currentState:   startState,
		myUsername:     generatedUsername,
		durationsMutex: sync.Mutex{},
		durations:      []int{},
		failedRequests: 0,
	}
}

const debugLog = false

func log(args ...any) {
	if debugLog {
		fmt.Println(args...)
	}
}

const startState = "start"

func (u *UserSimulation) start() string {
	log("Entering start state...")
	next := rand.Float32()
	if next < 0.1 {
		// 10%
		return uploadPhotoState
	}
	if next < 0.3 {
		// 20%
		return searchUndefinedUserState
	}
	// 70%
	return searchExistingUserState
}

const searchUndefinedUserState = "searchUndefinedUser"

func (u *UserSimulation) searchUndefinedUser() string {
	// Generate a random username [a-z]{5}
	username := ""
	for i := 0; i < 5; i++ {
		username += string(rune('a' + rand.Intn(26)))
	}

	_ = u.collectHTTPRequest("/users?username=" + username)

	return startState
}

const searchExistingUserState = "searchExistingUser"

func (u *UserSimulation) searchExistingUser() string {
	existingUsers := []string{
		"ciccio",
		"ciaooo",
		"ciaoo",
		"test",
		"simulation03614",
	}

	userToSearch := existingUsers[rand.Intn(len(existingUsers))]
	u.lastSearchedUser = userToSearch

	if err := u.collectHTTPRequest("/users?username=" + userToSearch); err != nil {
		// In case of error, go to the start state
		return startState
	}

	// With probability 0.8, open the user profile
	if rand.Float32() < 0.8 {
		return openUserProfileState
	}

	// Otherwise, go to the start state
	return startState
}

const openUserProfileState = "openUserProfile"

func (u *UserSimulation) openUserProfile() string {
	userToOpen := u.lastSearchedUser

	_ = u.collectHTTPRequest("/users/" + userToOpen)

	return startState
}

const uploadPhotoState = "uploadPhoto"

func (u *UserSimulation) uploadPhoto() string {
	log("Entering uploadPhoto state...")

	// List all files in ./test-assets
	assetsPhotos, err := os.ReadDir("./test-assets")
	if err != nil {
		panic(err) // Totally fine to panic here, as this is a developer error
	}

	// Pick a random photo
	photoToUpload := assetsPhotos[rand.Intn(len(assetsPhotos))].Name()
	photoPath := fmt.Sprintf("./test-assets/%s", photoToUpload)
	body, duration, err := timeHTTPPostFile("/photos", photoPath, photoToUpload, u.myUsername)
	if err != nil {
		// Failure!
		u.collectDuration(-1)
		return startState
	}

	u.collectDuration(duration)

	// Parse the response to get the photo ID
	// The response is a JSON object with a key "photo_id"
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(body), &data); err != nil {
		log("Error: uploadPhoto JSON is not valid")
		return startState
	}
	u.lastPhotoId = data["photo_id"].(string)

	return waitPhotoUploadState
}

const waitPhotoUploadState = "waitPhotoUpload"

func (u *UserSimulation) waitPhotoUpload() string {
	log("Entering waitPhotoUpload state...")

	// In this state, we need to do polling every 5 seconds, as the app really does
	response, err := u.collectHTTPRequestWithBody("/uploadStatus/" + u.lastPhotoId)
	if err != nil {
		// Retry again next loop
		return waitPhotoUploadState
	}

	// Parse the response to get the state (JSON key "status")
	// Values can be: SUCCESS, PENDING, ERROR
	// If the status is PENDING, retry again next loop
	// Otherwise, go back to the start state
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(response), &data); err != nil {
		return waitPhotoUploadState
	}

	status, ok := data["status"].(string)
	if !ok {
		log("Error: uploadStatus JSON 'status' is not a string")
		return waitPhotoUploadState
	}

	if status == "PENDING" {
		return waitPhotoUploadState
	}

	// Photo upload is either SUCCESS or ERROR, so it is completed
	return startState
}

func (u *UserSimulation) Run() {
	for {
		nextState := ""
		switch u.currentState {
		case startState:
			nextState = u.start()
		case searchUndefinedUserState:
			nextState = u.searchUndefinedUser()
		case searchExistingUserState:
			nextState = u.searchExistingUser()
		case openUserProfileState:
			nextState = u.openUserProfile()
		case uploadPhotoState:
			nextState = u.uploadPhoto()
		case waitPhotoUploadState:
			nextState = u.waitPhotoUpload()
		}

		if u.currentState == waitPhotoUploadState && nextState == waitPhotoUploadState {
			// In this case, we need to wait 5 seconds before retrying
			time.Sleep(5 * time.Second)
		} else if nextState != startState {
			// Wait 1 second before transitioning to the next state,
			// to simulate a user thinking about what to do next,
			// except when going back to the start state
			time.Sleep(1 * time.Second)
		}
		u.currentState = nextState
	}
}

func (u *UserSimulation) collectHTTPRequestWithBody(url string) (string, error) {
	body, duration, err := TimeHTTPRequestWithBody(url)
	if err != nil {
		u.collectDuration(-1)
	} else {
		u.collectDuration(duration)
	}
	return body, err
}

func (u *UserSimulation) collectHTTPRequest(url string) error {
	// Do not reuse collectHTTPRequestWithBody, as we don't need the body,
	// and we do not even want to read it from the response stream connection.
	duration, err := TimeHTTPRequest(url)
	if err != nil {
		u.collectDuration(-1)
	} else {
		u.collectDuration(duration)
	}
	return err
}

func (u *UserSimulation) collectDuration(duration int) {
	u.durationsMutex.Lock()
	defer u.durationsMutex.Unlock()

	log("Collecting duration", duration)

	if duration == -1 {
		u.failedRequests++
	} else {
		u.durations = append(u.durations, duration)
	}
}

func (u *UserSimulation) ResetStatistics() UserSimulationStats {
	u.durationsMutex.Lock()
	defer u.durationsMutex.Unlock()

	// Compute the mean
	var sum int
	for _, d := range u.durations {
		sum += d
	}
	mean := float64(sum) / float64(len(u.durations))

	// Compute the standard deviation
	var sumSquaredDiff float64
	for _, d := range u.durations {
		diff := float64(d) - mean
		sumSquaredDiff += diff * diff
	}
	stdDev := math.Sqrt(sumSquaredDiff / float64(len(u.durations)))

	stats := UserSimulationStats{
		ValidRequests:  len(u.durations),
		FailedRequests: u.failedRequests,
		TimeMean:       mean,
		TimeStdDev:     stdDev,
	}

	// Reset the accumulated durations
	u.durations = []int{}
	u.failedRequests = 0

	return stats
}
