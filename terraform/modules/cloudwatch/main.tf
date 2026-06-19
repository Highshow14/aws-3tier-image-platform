resource "aws_cloudwatch_dashboard" "main" {

  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({

    widgets = [

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title = "ALB Request Count"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              var.alb_name
            ]
          ]

          period = 300
          stat   = "Sum"
          region = "eu-west-2"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title = "Target Response Time"

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              var.alb_name
            ]
          ]

          period = 300
          stat   = "Average"
          region = "eu-west-2"
        }
      }
    ]
  })
}