resource "helm_release" "gitlab_runner" {
  name             = var.release_name
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = true

  values = [
    yamlencode({
      image                   = "gitlab/gitlab-runner:alpine-v14.1.0"
      gitlabUrl               = "https://gitlab.com/"
      concurrent              = var.concurrent
      runnerRegistrationToken = var.runner_registration_token
      checkInterval           = 3
      runners                 = {
        name        = var.runner_name
        runUntagged = var.run_untagged_jobs
        tags        = var.runner_tags
        locked      = var.runner_locked
        config      = local.config
      }
      rbac                    = {
        create                    = var.create_service_account
        serviceAccountName        = var.service_account
        serviceAccountAnnotations = var.service_account_annotations
        clusterWideAccess         = var.service_account_clusterwide_access
      }
    }),
    var.values_file != null ? file(var.values_file) : ""
  ]
}
