resource "volterra_origin_pool" "op-ip-internal" {
  name = "malicious-user-originpool"
  //Name of the namespace where the origin pool must be deployed
  namespace = var.namespace
   origin_servers {
    public_ip {
      ip = var.originip
    }
    labels = {}
  }
  no_tls = true
  port = var.originport
  endpoint_selection     = "LOCALPREFERED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}

resource "volterra_app_type" "auto-app-type" {
  name = "malicious-user-app-type"
  namespace = "shared"
  features {  
        type = "USER_BEHAVIOR_ANALYSIS"   
  }
  business_logic_markup_setting {
      enable = true
    }
}

resource "volterra_app_setting" "auto-app-settings" {
  name = "malicious-user-app-settings"
  namespace = var.namespace
  app_type_settings {
    app_type_ref {
      name = "malicious-user-app-type"
      namespace = "shared"
    }
    business_logic_markup_setting {
      // One of the arguments from this list "disable enable" must be set
      enable = true
    }
    user_behavior_analysis_setting {
      // One of the arguments from this list "enable_learning disable_learning" must be set
      enable_learning = true
      // One of the arguments from this list "enable_detection disable_detection" must be set
      enable_detection {
        // One of the arguments from this list "cooling_off_period" must be set
        cooling_off_period = "20"
        // One of the arguments from this list "include_failed_login_activity exclude_failed_login_activity" must be set
        include_failed_login_activity {
          login_failures_threshold = "10"
        }
        // One of the arguments from this list "include_forbidden_activity exclude_forbidden_activity" must be set
        include_forbidden_activity {
	  forbidden_requests_threshold = "10"
	}
        // One of the arguments from this list "exclude_ip_reputation include_ip_reputation" must be set
        include_ip_reputation = true
        // One of the arguments from this list "exclude_non_existent_url_activity include_non_existent_url_activity_custom include_non_existent_url_activity_automatic" must be set
        exclude_non_existent_url_activity = true
        // One of the arguments from this list "include_waf_activity exclude_waf_activity" must be set
        include_waf_activity = true
      }
    }
  }
}

resource "volterra_malicious_user_mitigation" "auto-mitigation" {
  name = "malicious-user-mitigation"
  namespace = var.namespace

  mitigation_type {
      rules {      
          threat_level {
            low = true
          }
          mitigation_action {
            javascript_challenge = true
          }
      }
      rules {
          threat_level {
            medium = true
          }
          mitigation_action {
            captcha_challenge = true
          }
      }
      rules {
          threat_level {
            high = true
          }
          mitigation_action {
            block_temporarily = true
          }
      }
   }
}

resource "volterra_app_firewall" "auto-firewall-policy" {
  name = "malicious-user-firewall-policy"
  namespace = var.namespace

  // One of the arguments from this list "allow_all_response_codes allowed_response_codes" must be set
  allow_all_response_codes = true

  // One of the arguments from this list "disable_anonymization default_anonymization custom_anonymization" must be set
  default_anonymization = true

  // One of the arguments from this list "use_default_blocking_page blocking_page" must be set
  use_default_blocking_page = true

  // One of the arguments from this list "default_bot_setting bot_protection_setting" must be set
  default_bot_setting = true

  // One of the arguments from this list "default_detection_settings detection_settings" must be set
  default_detection_settings = true

  // One of the arguments from this list "use_loadbalancer_setting blocking monitoring" must be set
  blocking = true
}

resource "volterra_http_loadbalancer" "lb-https-tf" {
  depends_on = [volterra_origin_pool.op-ip-internal]
  //Mandatory "Metadata"
  name = "malicious-user-httpslb"
  //Name of the namespace where the origin pool must be deployed
  namespace = var.namespace
  labels = {
    "ves.io/app_type" = "malicious-user-app-type"
  }
  domains = [var.domain]
  https_auto_cert {
    add_hsts = true
    http_redirect = true
    no_mtls = true
    enable_path_normalize = true
    tls_config {
        default_security = true
      }
  }
  default_route_pools {
      pool {
        name = "malicious-user-originpool"
        namespace = var.namespace
      }
      weight = 1
    }
  //Mandatory "VIP configuration"
  advertise_on_public_default_vip = true
  //End of mandatory "VIP configuration"
  //Mandatory "Security configuration"
  no_service_policies = true
  //enable_malicious_user_detection = true
  no_challenge = false
  // no_challenge set to false will allow to create mitigation rules
  disable_rate_limit = true
  disable_waf = false
  app_firewall {
	  namespace = var.namespace
	  name = "malicious-user-firewall-policy"
  }
  multi_lb_app = true
  user_id_client_ip = true
  source_ip_stickiness = true
  policy_based_challenge {
    malicious_user_mitigation {
            namespace = var.namespace
            name = "malicious-user-mitigation"
    }      
  }
}
