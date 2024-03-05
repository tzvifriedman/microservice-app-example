terraform {
  cloud {
    organization = "example-microservice-app"

    workspaces {
      name = "microservice-test"
    }
  }
}

provider "google" {
    #credentials = "/home/tzvif/gcloud-key.json"
    project = "example-microservice-app"
    region = "us-east1"
    zone = "us-east1-b"
}