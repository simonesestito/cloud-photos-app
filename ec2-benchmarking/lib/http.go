package lib

import (
	"fmt"
	"net/http"
	"os"
	"sync"
	"time"
)

func TimeHTTPRequest(url string) (int, error) {
	client := http.Client{
		Timeout: 10 * time.Second, // Set timeout
	}

	start := time.Now()
	resp, err := client.Get(url)
	if err != nil {
		fmt.Fprintf(os.Stderr, "\033[1;31mF\033[0m")
		os.Stderr.Sync()
		return 0, err
	}
	defer resp.Body.Close()

	// Calculate the time taken for the request in milliseconds
	duration := time.Since(start).Milliseconds()

	// Print the success, as a green dot
	fmt.Fprintf(os.Stderr, "\033[32m.\033[0m")
	os.Stderr.Sync()

	return int(duration), nil
}

func TimeHTTPRequestWaiting(url string, wg *sync.WaitGroup) (int, error) {
	defer wg.Done()
	return TimeHTTPRequest(url)
}
