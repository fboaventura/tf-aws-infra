/**
 *
 * Outputs
 *
 */

output "Manifest" {
  value = jsonencode(data.local_file.manifest.content)
}
