# Quote of the day Python Application
This application loads the quote of the day from an external api.

## Local Deployment
### Requirements/ dependencies for local deployment
1. Docker
2. Docker compose

### Steps
1. Run application with docker compose (build image and run containers) - `docker-compose -f ./app/docker-compose.yml up -d`
2. Open application `http://localhost:8080/qod`
3. Kill application (stop containers and delete images from local repo) - `docker-compose -f ./app/docker-compose.yml down`