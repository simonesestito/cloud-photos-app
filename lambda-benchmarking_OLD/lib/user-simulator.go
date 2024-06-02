package lib

import (
	"encoding/json"
	"fmt"
	"math"
	"math/rand"
	"sync"
	"time"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sfn"
	"github.com/google/uuid"
)

type UserSimulation struct {
	myUsername       string
	lastPhotoId      int
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

type jsonRequest struct {
	S3       string `json:"s3"`
	KeyPhoto string `json:"keyPhoto"`
	Username string `json:"username"`
	Ts       string `json:"ts"`
	UUID     string `json:"idPhoto"`
}

func createJsonRequest(posPhoto int) jsonRequest {
	inputs := []string{
		"pistola.jpg",
		"smoke.jpg",
		"albero.jpg",
		"lago.jpg",
		"luna.jpg",
		"soffione.jpg",
		"torreEifel.jpg",
		"albero.jpg",
		"girasoli.jpg",
		"conigli.jpg",
		"mare.jpg",	
	}
	uuid := uuid.New().String()
	return jsonRequest{
		S3:       "images-to-resize",
		KeyPhoto: inputs[posPhoto],
		Username: "ciccio",
		Ts:       "1",
		UUID:     uuid,
	}
}

const debugLog = false

func log(args ...any) {
	if debugLog {
		fmt.Println(args...)
	}
}

func NewUserSimulation() *UserSimulation {
	generatedUsername := fmt.Sprint("simulation0", rand.Intn(100_000))

	return &UserSimulation{
		myUsername:     generatedUsername,
		durationsMutex: sync.Mutex{},
		durations:      []int{},
		failedRequests: 0,
	}
}

func connectToStepFunction() *sfn.SFN {
	// Create a new session
	sess := session.Must(session.NewSession())

	return sfn.New(sess, aws.NewConfig().WithRegion("us-east-1"))
}
func (u *UserSimulation) choosePhoto() int {
	return rand.Intn(10)
}

func (u *UserSimulation) uploadPhoto(session *sfn.SFN) (int, error) {
	stateMachineArn := "arn:aws:states:us-east-1:597859648927:stateMachine:MyStateMachine-thkcuvmmw"
	ind := u.choosePhoto()
	input := createJsonRequest(ind)
	inputJSON, err := json.Marshal(input)
	if err != nil {
		fmt.Println("Error marshalling input:", err)
		return 0, err
	}
	start := time.Now()

	startExecutionInput := &sfn.StartExecutionInput{
		StateMachineArn: aws.String(stateMachineArn),
		Input:           aws.String(string(inputJSON)),
	}
	resp, err := session.StartExecution(startExecutionInput)
	if err != nil {
		fmt.Println("Error starting Step Function execution:", err)
		return 0, err
	}

	u.lastPhotoId = ind

	duration := time.Since(start).Milliseconds()
	// Print the execution ARN
	fmt.Println("Step Function execution started successfully with ARN:", *resp.ExecutionArn)
	return int(duration),nil
}

func (u *UserSimulation) Run() {
	sess := connectToStepFunction()
	for {
		duration,err := u.uploadPhoto(sess)
		if err != nil {
			u.collectDuration(-1)
		} else {
			u.collectDuration(duration)
		}
		// aspetta 5 secondi prima di inviare la prossima richiesta
		time.Sleep(1 * time.Second)
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



