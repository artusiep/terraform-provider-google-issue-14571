module "test" {
  source = "./module"
  location   = "europe-west1"
  name       = "issue-14571"
  project_id = "artusiep-gcp-project"
}
