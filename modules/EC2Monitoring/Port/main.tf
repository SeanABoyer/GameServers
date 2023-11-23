resource "aws_cloudwatch_metric_alarm" "port_connection" {
  alarm_name                = "StopInstance"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "4"
  metric_name               = "ConnectionsOn${port_number}"
  namespace                 = "CustomEC2"
  period                    = "900"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This alarm will trigger anytime the custom metric is below 1 for more than 1 hour straight."
  actions_enabled           = true
  alarm_actions             = [
    "arn:aws:automate:${var.aws_region_name}:ec2:stop"
  ]
  dimensions = {
    InstanceId = "${var.ec2_instance_id}"
  }
}