package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sfn"
	// "math/rand"
	"github.com/google/uuid"
	// "github.com/aws/aws-sdk-go/aws/credentials/stscreds"
)

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


func main() {
	
	// Create a new AWS session using the default credentials chain
	sess := session.Must(session.NewSession())

	// role := "arn:aws:iam::597859648927:role/LabRole"
	// creds := stscreds.NewCredentials(sess, role)

	// Create a Step Functions client
	svc := sfn.New(sess, aws.NewConfig().WithRegion("us-east-1"))
	stateMachineArn := "arn:aws:states:us-east-1:597859648927:stateMachine:MyStateMachine-thkcuvmmw"
	input := createJsonRequest(1)
	fmt.Println("Input:")
	fmt.Println(input)
	inputJSON, err := json.Marshal(input)
	if err != nil {
		fmt.Println("Error marshalling input:", err)
		return 
	}
	startExecutionInput := &sfn.StartSyncExecutionInput{
		StateMachineArn: aws.String(stateMachineArn),
		Input:           aws.String(string(inputJSON)),
	}
	resp, err := svc.StartSyncExecution(startExecutionInput)
	fmt.Println(resp)	
	if err != nil {
		fmt.Println("Error starting Step Function execution:", err)
		return 
	}

	// // Avvia la goroutine per inviare le richieste
	// go sendRequests()

	// // Attendi che il programma non termini subito dopo l'avvio della goroutine
	// select {}

	
}

// func sendRequests() {
// 	// Definisci la quantità di tempo tra ogni richiesta
// 	interval := time.Minute / 10 // 10 richieste al minuto

// 	// Ciclo infinito per inviare continuamente le richieste
// 	for {
// 		// Invia la richiesta
// 		sendRequest()

// 		// Attendi prima di inviare la prossima richiesta
// 		time.Sleep(interval)
// 	}
// }

// func sendRequest() {
// 	// Replace 'YOUR_STATE_MACHINE_ARN' with the ARN of your Step Function state machine
// 	stateMachineArn := "arn:aws:states:us-east-1:061197399749:stateMachine:MyStateMachine-yvl2mnamm"

// 	// Generate a random number between 0 and 9
// 	rand.Seed(time.Now().UnixNano())
// 	randomNum := rand.Intn(10)

	// input := struct {
	// 	S3       string `json:"s3"`
	// 	KeyPhoto string `json:"keyPhoto"`
	// 	Username string `json:"username"`
	// 	Ts       string `json:"ts"`
	// 	UUID     string `json:"idPhoto"`
	// }{
	// 	S3:       "detect-bad-images",
	// 	KeyPhoto: inputs[randomNum],
	// 	Username: "ciccio",
	// 	Ts:       "1",
	// 	UUID:     uuid,
	// }

// 	inputJSON, err := json.Marshal(input)
// 	if err != nil {
// 		fmt.Println("Error marshalling input:", err)
// 		return
// 	}


// 	// Define the input for the StartExecution API call
// 	startExecutionInput := &stepfunctions.StartExecutionInput{
// 		StateMachineArn: aws.String(stateMachineArn),
// 		Input:           aws.String(string(inputJSON)),
// 	}

// 	// Start the execution of the Step Function
// 	resp, err := svc.StartExecution(startExecutionInput)
// 	if err != nil {
// 		fmt.Println("Error starting Step Function execution:", err)
// 		return
// 	}

// 	// Print the execution ARN
// 	fmt.Println("Step Function execution started successfully with ARN:", *resp.ExecutionArn)
// }