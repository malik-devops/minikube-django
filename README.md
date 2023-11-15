## docker

Docker is a platform designed to help developers build, share, and run container applications.

We will start by build the image.
 ```docker build -t django-project .```

Check if the image is built.
 ```docker images```

To verify if the image is built successfully.
```docker run -p 80:80 -d django-project```

Check if the image is running successfully.
 ```docker ps```

Tag the image.
 ```docker tag django-project:latest <user-name>/django-project:latest```

Check if the image is created
 ```docker images```

Push the image on dockerhub repository.
 ```docker push <user-name>/django-project:latest```

## start minikube

Open your terminal and run the command:

```minikube start```

## create deployment

Create a deployment with the new image pushed on dockerhub.

```kubectl create deploy django-app --image=<user-name>/django-project:latest -n <namespace>```

Run this command to download the deployment manifest.

```kubectl get deploy django-app -n <namespace> -o yaml > deployment.yaml```

or

To see if the deployment and pod are created successfully.

```kubectl apply -f deployment.yaml -n <namespace>```

## add secrets

Kubernetes Secrets are secure objects that store sensitive data, such as passwords, OAuth tokens, and SSH keys, with encryption in clusters. To secure your docker credentials, update this command line by adding your username, email and password.

```kubectl -n <namespace> create secret docker-registry registry-secret \ --docker-server=https://index.docker.io/v1/ \ --docker-username=<user-name> \ --docker-password=<user-name> \ --docker-email=<user-email>```


## add service

Create a service from the django-app deployment.

```kubectl -n <namespace> expose deploy django-app --port=80--type=NodePort```

```kubectl get svc django-app -n <namespace> -o yaml > service.yaml```
or 

```kubectl apply -f service.yaml -n <namespace>```

To view the project run on your terminal:

```minikube service django-app --url -n project```

## push new image on dockerhub

Create a github pipeline to create and push a new image on dockerhub. 
Whenever new changes are made on the hand branch or on a preference branch the image is created. 

```
name: Build and Deploy Docker Image

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        
      - name: Set Docker tag with dynamic version
        id: tag
        run: |
          VERSION="v1.$(( $GITHUB_RUN_NUMBER + 1 ))" 
          echo "VERSION=$VERSION" >> $GITHUB_ENV
        shell: bash
        
      - name: Login to Docker Hub
        run: docker login -u ${{ secrets.DOCKER_USERNAME }} -p ${{ secrets.DOCKER_PASSWORD }}

      - name: Build Docker Image
        run: docker build -t django-project:${{ env.VERSION }} .

      - name: Tag Docker Image
        run: docker tag django-project:${{ env.VERSION }} <user-name>/django-project:${{ env.VERSION }}
        
      - name: Push Docker Image
        run: docker push <user-name>/django-project:${{ env.VERSION }}
```

## change deployment image

Now to get the latest version of your project run this command:

```kubectl edit deploy django-app -n <namespace>```

```
 spec:
      containers:
      - image: <user-name>/django-project:latest
        imagePullPolicy: Never
        name: django-app
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
```

Edit the latest version of the current image according to the latest version pushed on dockerhub.

## Updates

To verify the latest version of your application run the following command:

```minikube service django-app --url -n project```
# minikube-django
