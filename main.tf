variable "github_pat" {}

provider "github" {
  organization = "dwp"
  token        = "${var.github_pat}"
}

data "github_team" "dataworks" {
  slug = "dataworks"
}

resource "github_repository" "example-repo" {
  name        = "github-repo-config-examples"
  description = "Examples and templates for configuring GitHub repositories using Terraform"

  allow_merge_commit = false
  default_branch     = "master"
}

resource "github_team_repository" "example-repo-dataworks" {
  repository = "${github_repository.example-repo.name}"
  team_id    = "${data.github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "master" {
  branch         = "${github_repository.example-repo.default_branch}"
  repository     = "${github_repository.example-repo.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "wip" {
  color      = "f4b342"
  name       = "WIP"
  repository = "${github_repository.example-repo.name}"
}

resource "github_repository_webhook" "example-repo" {
  events     = ["push"]
  name       = "web"
  repository = "${github_repository.example-repo.name}"

  configuration {
    url          = "https://ci.example.com"
    content_type = "form"
    insecure_ssl = false
  }
}

resource "github_repository_webhook" "example-repo-pr" {
  events     = ["pull_request"]
  name       = "web"
  repository = "${github_repository.example-repo.name}"

  configuration {
    url          = "https://ci.example.com"
    content_type = "form"
    insecure_ssl = false
  }
}
