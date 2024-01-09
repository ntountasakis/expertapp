
DOCKER_CONTEXT=$(git rev-parse --show-toplevel)
IMAGE_NAME='expertapp-server'
PROJECT_NAME='expert-app-backend'
REPO_IMAGE_NAME="us-docker.pkg.dev/${PROJECT_NAME}/gcr.io/${IMAGE_NAME}:latest"

buildDockerImage() {
    docker build \
    --progress=plain \
    --build-arg IS_PROD_ARG=$1 \
    --build-arg STRIPE_PRIVATE_KEY_VERSION_ARG=$2 \
    --platform linux/amd64 \
    -t $REPO_IMAGE_NAME \
    $DOCKER_CONTEXT
}

uploadToArtifactRegistry() {
    docker push $REPO_IMAGE_NAME
}

runLocalDockerContainer() {
  # 9002 for local firestore emulator
  export LOCAL_NAME=$(docker run -d --env PORT=8080 \
  --env GOOGLE_APPLICATION_CREDENTIALS='/server/conf/expert-app-localdev.json' \
  -p 8080:8080 \
  --add-host=host.docker.internal:host-gateway \
  -t $REPO_IMAGE_NAME)
}

stopDockerContainer() {
  docker rm $(docker stop $(docker ps -a -q --filter ancestor=${REPO_IMAGE_NAME} --format="{{.ID}}"))
}
