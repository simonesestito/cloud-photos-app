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

type jsonRequest struct {
	S3       string `json:"s3"`
	KeyPhoto string `json:"keyPhoto"`
	Username string `json:"username"`
	Ts       string `json:"ts"`
	UUID     string `json:"idPhoto"`
}

func createJsonRequest(posPhoto int) jsonRequest {
	uuid := uuid.New().String()
	return jsonRequest{
		S3:       "detect-bad-images",
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

func connectToStepFunction() *stepfunctions.StepFunctions {
	// Create a new session
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create a new Step Functions client
	return stepfunctions.New(sess)
}

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

func (u *UserSimulation) choosePhoto() string {
	return rand.Intn(10)
}

func (u *UserSimulation) uploadPhoto() string {
	
}

