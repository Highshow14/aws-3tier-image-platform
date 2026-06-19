output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "web_target_group_arn" {
  value = module.alb.web_target_group_arn
}

output "raw_bucket_name" {
  value = module.s3.raw_bucket_name
}

output "processed_bucket_name" {
  value = module.s3.processed_bucket_name
}