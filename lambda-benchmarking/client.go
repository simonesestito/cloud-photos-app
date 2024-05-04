package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/stepfunctions"
	"math/rand"
	"github.com/google/uuid"
)

func main() {
	// Create a new AWS session using the default credentials chain
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create a Step Functions client
	svc := stepfunctions.New(sess)

	// Avvia la goroutine per inviare le richieste
	go sendRequests()

	// Attendi che il programma non termini subito dopo l'avvio della goroutine
	select {}

	
}

func sendRequests() {
	// Definisci la quantità di tempo tra ogni richiesta
	interval := time.Minute / 10 // 10 richieste al minuto

	// Ciclo infinito per inviare continuamente le richieste
	for {
		// Invia la richiesta
		sendRequest()

		// Attendi prima di inviare la prossima richiesta
		time.Sleep(interval)
	}
}

func sendRequest() {
	// Replace 'YOUR_STATE_MACHINE_ARN' with the ARN of your Step Function state machine
	stateMachineArn := "arn:aws:states:us-east-1:061197399749:stateMachine:MyStateMachine-yvl2mnamm"

	
	inputs := []string{
		    "pistola.jpg",
			"sera.jpg",
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

	// Generate a random number between 0 and 9
	rand.Seed(time.Now().UnixNano())
	randomNum := rand.Intn(10)

	input := struct {
		S3       string `json:"s3"`
		KeyPhoto string `json:"keyPhoto"`
		Username string `json:"username"`
		Ts       string `json:"ts"`
		UUID     string `json:"idPhoto"`
	}{
		S3:       "detect-bad-images",
		KeyPhoto: inputs[randomNum],
		Username: "ciccio",
		Ts:       "1",
		UUID:     uuid,
	}

	inputJSON, err := json.Marshal(input)
	if err != nil {
		fmt.Println("Error marshalling input:", err)
		return
	}


	// Define the input for the StartExecution API call
	startExecutionInput := &stepfunctions.StartExecutionInput{
		StateMachineArn: aws.String(stateMachineArn),
		Input:           aws.String(string(inputJSON)),
	}

	// Start the execution of the Step Function
	resp, err := svc.StartExecution(startExecutionInput)
	if err != nil {
		fmt.Println("Error starting Step Function execution:", err)
		return
	}

	// Print the execution ARN
	fmt.Println("Step Function execution started successfully with ARN:", *resp.ExecutionArn)
}