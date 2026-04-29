cloudfront_distributions = {
  frontend = {
    origin = {
      s3_frontend = {
        domain_name = "three-tier-frontend-bucket-aaditya-2901.s3.amazonaws.com"
        origin_id   = "S3Origin"
        oac_key     = "s3"
      }
    }
    origin_access_control = {
      s3 = {
        origin_type      = "s3"
        signing_behavior = "always"
        signing_protocol = "sigv4"
      }
    }
    default_cache_behavior = {
      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "S3Origin"
      
      forwarded_values = {
        query_string = false
        cookies = {
          forward = "none"
        }
      }
      
      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 3600
      max_ttl                = 86400
    }
    
    default_root_object = "index.html"
    
    enabled = true
    
    restrictions = {
      geo_restriction = {
        restriction_type = "none"
      }
    }
    
    viewer_certificate = {
      cloudfront_default_certificate = true
    }
    
    tags = {
      environment = "prod"
      name        = "three-tier-frontend-distribution"
    }
  }
}
