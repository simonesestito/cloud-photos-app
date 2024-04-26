#!/bin/bash

set -exu
set -o pipefail

# Change directory to the directory of the script
cd "$(dirname "$0")" || exit

# Archive the project
(
  cd ..
  tar czf cloud-backend.tar cloud-backend/{data_source,model,app.py,Dockerfile,requirements.txt,wsgi.ini,wsgi.py}
  ls -lh cloud-backend.tar
  scp cloud-backend.tar learnerlab:.
  rm cloud-backend.tar
)

# Build Docker image
ssh learnerlab "rm -rf cloud-backend && tar xzf cloud-backend.tar && rm cloud-backend.tar"
ssh learnerlab "cd cloud-backend && docker build -t cloud-backend:latest ."

# Stop remote container if running
ssh learnerlab "docker ps -q --filter name=cloud-backend | xargs docker rm -f" || true

# Start container in daemon mode
ssh learnerlab "docker run -d --name cloud-backend --restart unless-stopped -p 5000:5000 cloud-backend:latest"

# Test the connection
curl 'http://3.95.62.66/users?username=cicc' --silent --fail | jq
