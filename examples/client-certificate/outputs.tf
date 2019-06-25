# ------------------------------------------------------------------------------
# CLIENT CERTIFICATE OUTPUTS
# ------------------------------------------------------------------------------

output "client_ca_cert" {
  description = "Certificate data for the client certificate."
  value       = google_sql_ssl_cert.client_cert.cert
}

# In real-world cases, the output for the private key should always be encrypted
output "client_private_key" {
  description = "Private key associated with the client certificate."
  value       = google_sql_ssl_cert.client_cert.private_key
}
