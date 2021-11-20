resource "random_password" "generate_es_password" {
  length           = 12
  special          = true
  override_special = "_%@"
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  keepers          = {
    kepeer1 = var.es_admin_name
  }
}

// Store Username & Password in SSM Parameter Store
resource "aws_ssm_parameter" "es_user" {
  name        = "/es_user"
  description = "Master Username for ES"
  type        = "String"
  value       = var.es_admin_name
  overwrite   = true

}

resource "aws_ssm_parameter" "es_password" {
  name        = "/es_pswd"
  description = "Master Password for RDS Mysql"
  type        = "SecureString"
  value       = random_password.generate_es_password.result
  overwrite   = true
}

resource "aws_elasticsearch_domain" "cluster_elasticsearch" {
  domain_name           = "logs-service"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type = "t3.small.elasticsearch"
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.es_admin_name
      master_user_password = random_password.generate_es_password.result
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.cluster_elasticsearch.domain_name

  access_policies = <<POLICIES

    {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "es:*",
        "Resource": "${aws_elasticsearch_domain.cluster_elasticsearch.arn}/*"
      }
    ]
    }
  POLICIES
}

resource "helm_release" "fluent" {
  name             = "fluent"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  namespace        = "logging"
  create_namespace = true

  values = [
    <<-EOT
                tolerations:
                  - operator: Exists
                    effect: NoSchedule
                config:
                  service: |
                    [SERVICE]
                        Daemon Off
                        Flush 10
                        Log_Level {{ .Values.logLevel }}
                        Parsers_File parsers.conf
                        Parsers_File custom_parsers.conf
                        HTTP_Server On
                        HTTP_Listen 0.0.0.0
                        HTTP_Port {{ .Values.service.port }}
                        Health_Check off
                  inputs: |
                    [INPUT]
                        Name              tail
                        Tag               kube.*
                        Path              /var/log/containers/*.log
                        DB                /var/log/flb_kube.db
                        Parser            cri
                        Skip_Long_Lines    off
                        Refresh_Interval   20
                        Multiline_Flush    20
                        Buffer_Chunk_Size  1G
                        Buffer_Max_Size    1G
                        Ignore_Older       1D
                  filters: |
                    [FILTER]
                        Name kubernetes
                        Match *
                        Merge_Log on
                        Keep_Log Off
                        K8S-Logging.Parser On
                        K8S-Logging.Exclude On
                  outputs: |
                    [OUTPUT]
                        Name es
                        Match *
                        Host ${aws_elasticsearch_domain.cluster_elasticsearch.endpoint}
                        Port 443
                        HTTP_User ${var.es_admin_name}
                        HTTP_Passwd ${random_password.generate_es_password.result}
                        AWS_Auth Off
                        AWS_Region us-east-1
                        tls on
                        tls.verify off
                        Retry_Limit 10
                        Buffer_Size False
                        Type doc
                        Trace_Error On
                        Replace_Dots On
                  parsers: |
                    [PARSER]
                        Name cri
                        Format regex
                        Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<message>.*)$
                        Time_Key    time
                        Time_Format %Y-%m-%dT%H:%M:%S.%L%z
            EOT
  ]
}
