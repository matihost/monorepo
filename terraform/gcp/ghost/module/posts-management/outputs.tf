output "removeAllPostsURL" {
  value = google_cloudfunctions2_function.removeAllPosts.service_config[0].uri
}
