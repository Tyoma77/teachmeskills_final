module "gitlab-runner" {
  source                    = "./gitlab_runner"
  runner_name               = "simple-k8s-runner"
  release_name              = "simple"
  namespace                 = "gitlab-runner"
  runner_tags               = "teachmeskills,k8s"
  runner_registration_token = "f1SsC9HzPZDg2i4sKT2j"
  mount_docker_socket       = true
  image_pull_secrets        = ["docker-registry-auth"]
}