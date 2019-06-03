resource "google_redis_instance" "gitlab_redis" {
  name           = "gitlab"
  memory_size_gb = 2
}
