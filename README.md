# Cloud Photos App project

<div align="center">
   <b>AWS scalable project for a photo sharing Flutter app.</b>
</div>
<hr>


[![Download report (PDF)](.github/assets/Download_report_pdf.svg)](report.pdf?raw=true)


Folder structure:
- **cloud_photos_app**: Flutter source code for the client multi-platform application we developed
- **ec2-benchmarking**: custom tool written in Go to simulate user activities with an implementation of a Markov chain
- **flask-ec2-backend**: backend Python Flask code, that runs the core functionalities of the server-side application, excluding photo upload and compression
- **jmeter**: files used to test the AWS Step Function using the popular JMeter tool, including its results
- **lambda-backend**: source code of the Lambdas that are used in the photo upload processing Step Function
- **lambda-benchmark-OLD**: the old custom benchmarking tool written in Go and inspired from the custom one used to evaluate EC2
- **screenshots**: all screenshots available for our evaluations and AWS console while developing and testing
- **step-function-scheme**: the JSON of the Step Function, as described in AWS Console, for reproducibility purposes (ARNs excluded, of course)
