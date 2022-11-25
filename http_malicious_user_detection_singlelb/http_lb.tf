resource "volterra_origin_pool" "op-ip-internal" {
  name = "malicious-user-originpool"
  //Name of the namespace where the origin pool must be deployed
  namespace = var.namespace
   origin_servers {
    public_ip {
      ip = var.originip
    }
    labels= {}
  }
  no_tls = true
  port = var.originport
  endpoint_selection = "LOCALPREFERED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}

resource "volterra_http_loadbalancer" "lb-http-tf" {
  depends_on = [volterra_origin_pool.op-ip-internal]
  //Mandatory "Metadata"
  name = "malicious-user-httplb"
  //Name of the namespace where the origin pool must be deployed
  namespace = var.namespace

  domains = [var.domain]
  http {
    dns_volterra_managed = true
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
  enable_malicious_user_detection = true
  no_challenge = false
  disable_rate_limit = true
  disable_waf = true
  multi_lb_app = false
  user_id_client_ip = true
  source_ip_stickiness = true
  policy_based_challenge {
     default_js_challenge_parameters = true
     default_captcha_challenge_parameters = true
     default_mitigation_settings = true
     no_challenge = true
     rule_list {}
  }
}
