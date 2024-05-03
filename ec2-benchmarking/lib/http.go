package lib

import (
	"bytes"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"sync"
	"time"
)

const defaultEndpoint = "http://CloudProd-ELB-1744064738.us-east-1.elb.amazonaws.com"

const defaultTimeout = 10 * time.Second

func timeHTTPRequest(url string, withBody bool) (string, int, error) {
	// Add the default endpoint if the URL is relative
	if url[0] == '/' {
		url = defaultEndpoint + url
	}

	client := http.Client{
		Timeout: defaultTimeout,
	}

	start := time.Now()
	resp, err := client.Get(url)
	if err != nil {
		// T = Timeout
		fmt.Fprintf(os.Stderr, "\033[1;31mT\033[0m")
		os.Stderr.Sync()
		return "", 0, err
	}
	defer resp.Body.Close()

	// Check that status code is 200
	if resp.StatusCode != http.StatusOK {
		// F = Failed request
		fmt.Fprintf(os.Stderr, "\033[1;31mF\033[0m")
		os.Stderr.Sync()
		return "", 0, fmt.Errorf("status code %d", resp.StatusCode)
	}

	// Calculate the time taken for the request in milliseconds
	duration := time.Since(start).Milliseconds()

	// Get the response body as a string, if needed
	var body string
	if withBody {
		bodyBytes, err := io.ReadAll(resp.Body)
		if err != nil {
			return "", 0, err
		}
		body = string(bodyBytes)
	} else {
		// Discard the response body, if not needed
		body = ""
	}

	// Print the success, as a green dot
	fmt.Fprintf(os.Stderr, "\033[32m.\033[0m")
	os.Stderr.Sync()

	return body, int(duration), nil
}

func timeHTTPPostFile(url string, filePath string, fileName string, authorization string) (string, int, error) {
	// Add the default endpoint if the URL is relative
	if url[0] == '/' {
		url = defaultEndpoint + url
	}

	client := http.Client{
		Timeout: defaultTimeout,
	}

	file, err := os.Open(filePath)
	if err != nil {
		log("Error: could not open file", filePath)
		panic(err)
	}
	defer file.Close()

	var requestBody bytes.Buffer
	writer := multipart.NewWriter(&requestBody)

	// Add the file to the request
	part, err := writer.CreateFormFile("photo", fileName)
	if err != nil {
		log("Error: could not create form file")
		panic(err)
	}

	if _, err := io.Copy(part, file); err != nil {
		log("Error: could not copy file to part")
		panic(err)
	}

	if err := writer.Close(); err != nil {
		log("Error: could not close writer")
		panic(err)
	}

	// Create the request (without sending it)
	req, err := http.NewRequest("POST", url, &requestBody)
	if err != nil {
		log("Error: could not create request")
		panic(err)
	}

	// Set the content type
	req.Header.Set("Content-Type", writer.FormDataContentType())

	// Set the authorization header
	req.Header.Set("Authorization", authorization)

	// Send the request
	start := time.Now()
	resp, err := client.Do(req)
	if err != nil {
		// T = Timeout
		fmt.Fprintf(os.Stderr, "\033[1;31mT\033[0m")
		os.Stderr.Sync()
		return "", 0, err
	}
	defer resp.Body.Close()

	// Check that status code is 200
	if resp.StatusCode != http.StatusOK {
		// F = Failed request
		fmt.Fprintf(os.Stderr, "\033[1;31mF\033[0m")
		os.Stderr.Sync()
		return "", 0, fmt.Errorf("status code %d", resp.StatusCode)
	}

	// Calculate the time taken for the request in milliseconds
	duration := time.Since(start).Milliseconds()

	// Get the response body as a string
	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		// F = Failed request
		fmt.Fprintf(os.Stderr, "\033[1;31mF\033[0m")
		os.Stderr.Sync()
		return "", 0, err
	}
	body := string(bodyBytes)

	// Print the success, as a green dot
	fmt.Fprintf(os.Stderr, "\033[32m.\033[0m")
	os.Stderr.Sync()

	return body, int(duration), nil
}

func TimeHTTPRequest(url string) (int, error) {
	_, duration, err := timeHTTPRequest(url, false)
	return duration, err
}

func TimeHTTPRequestWithBody(url string) (string, int, error) {
	return timeHTTPRequest(url, true)
}

func TimeHTTPRequestWaiting(url string, wg *sync.WaitGroup) (int, error) {
	defer wg.Done()
	return TimeHTTPRequest(url)
}
