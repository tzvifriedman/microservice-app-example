data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke-network" {
    source = "terraform-google-modules/network/google"
    project_id = "example-microservice-app"
    network_name = "gke-network"
    subnets = [
    {
      subnet_name   = "gke-subnet-01"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = "us-east1"
    },
  ]
  secondary_ranges = {
    "gke-subnet-01" = [
      {
        range_name    = "gke-subnet-01-pods"
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = "gke-subnet-01-services"
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "example-microservice-app"
  name                       = "gke-microservice-test"
  region                     = "us-east1"
  zones                      = ["us-east1-b", "us-east1-c", "us-east1-d"]
  network                    = "gke-network"
  subnetwork                 = "gke-subnet-01"
  ip_range_pods              = "gke-subnet-01-pods"
  ip_range_services          = "gke-subnet-01-services"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "us-east1-b,us-east1-c"
      min_count                 = 1
      max_count                 = 5
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = "DEFAULT"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "example-microservice-app-admin@example-microservice-app.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 5
    }
    ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
   