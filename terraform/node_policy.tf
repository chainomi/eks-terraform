

resource "aws_iam_policy" "additional_node_policy" {
  name        = "eks-${var.application_name}-${var.environment}-additional-node-policy"
  path        = "/"
  description = "additional policy for worker nodes"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:CreateFunction",
                "logs:DeleteSubscriptionFilter",
                "logs:DescribeSubscriptionFilters",
                "logs:StartQuery",
                "lambda:GetFunctionConfiguration",
                "logs:DescribeMetricFilters",
                "logs:ListLogDeliveries",
                "ses:GetIdentityDkimAttributes",
                "lambda:GetProvisionedConcurrencyConfig",
                "lambda:ListLayers",
                "lambda:DeleteFunction",
                "logs:FilterLogEvents",
                "lambda:GetAlias",
                "lambda:ListCodeSigningConfigs",
                "logs:DescribeDestinations",
                "ses:CreateConfigurationSet",
                "lambda:ListFunctions",
                "lambda:GetEventSourceMapping",
                "lambda:ListAliases",
                "logs:DeleteQueryDefinition",
                "lambda:GetFunctionCodeSigningConfig",
                "lambda:UpdateFunctionCode",
                "lambda:GetFunctionConcurrency",
                "lambda:PutProvisionedConcurrencyConfig",
                "lambda:PublishVersion",
                "logs:PutSubscriptionFilter",
                "lambda:DeleteEventSourceMapping",
                "logs:ListTagsLogGroup",
                "lambda:InvokeAsync",
                "logs:DeleteLogStream",
                "logs:CreateExportTask",
                "logs:DeleteMetricFilter",
                "lambda:ListTags",
                "logs:DeleteLogDelivery",
                "lambda:PutFunctionCodeSigningConfig",
                "logs:PutDestination",
                "logs:DisassociateKmsKey",
                "lambda:UpdateEventSourceMapping",
                "lambda:UpdateFunctionCodeSigningConfig",
                "s3:*",
                "ses:GetSendStatistics",
                "lambda:UpdateFunctionConfiguration",
                "lambda:ListFunctionUrlConfigs",
                "logs:TestMetricFilter",
                "lambda:UpdateCodeSigningConfig",
                "ses:DescribeActiveReceiptRuleSet",
                "lambda:DeleteAlias",
                "lambda:GetCodeSigningConfig",
                "logs:GetLogGroupFields",
                "logs:GetLogRecord",
                "lambda:DeleteProvisionedConcurrencyConfig",
                "lambda:ListProvisionedConcurrencyConfigs",
                "logs:CreateLogStream",
                "logs:CancelExportTask",
                "logs:DeleteRetentionPolicy",
                "logs:GetLogEvents",
                "lambda:ListLayerVersions",
                "ses:GetTemplate",
                "lambda:UpdateFunctionUrlConfig",
                "lambda:CreateFunctionUrlConfig",
                "lambda:UpdateFunctionEventInvokeConfig",
                "lambda:DeleteFunctionCodeSigningConfig",
                "lambda:InvokeFunctionUrl",
                "lambda:InvokeFunction",
                "lambda:GetFunctionUrlConfig",
                "logs:StopQuery",
                "logs:CreateLogGroup",
                "lambda:UpdateAlias",
                "logs:PutMetricFilter",
                "logs:CreateLogDelivery",
                "lambda:ListFunctionEventInvokeConfigs",
                "logs:DescribeExportTasks",
                "lambda:ListFunctionsByCodeSigningConfig",
                "logs:GetQueryResults",
                "logs:UpdateLogDelivery",
                "ses:CreateConfigurationSetEventDestination",
                "lambda:ListEventSourceMappings",
                "lambda:CreateAlias",
                "ses:ListTemplates",
                "lambda:ListVersionsByFunction",
                "lambda:GetLayerVersion",
                "logs:DescribeLogStreams",
                "ses:DescribeConfigurationSet",
                "lambda:PublishLayerVersion",
                "lambda:GetAccountSettings",
                "lambda:CreateEventSourceMapping",
                "lambda:GetLayerVersionPolicy",
                "logs:GetLogDelivery",
                "ses:CloneReceiptRuleSet",
                "lambda:PutFunctionConcurrency",
                "lambda:DeleteCodeSigningConfig",
                "ses:ListConfigurationSets",
                "lambda:DeleteLayerVersion",
                "lambda:PutFunctionEventInvokeConfig",
                "lambda:DeleteFunctionEventInvokeConfig",
                "logs:AssociateKmsKey",
                "logs:DescribeQueryDefinitions",
                "lambda:CreateCodeSigningConfig",
                "logs:DescribeResourcePolicies",
                "logs:DescribeQueries",
                "logs:DescribeLogGroups",
                "logs:DeleteLogGroup",
                "lambda:GetFunction",
                "logs:PutDestinationPolicy",
                "logs:PutQueryDefinition",
                "logs:DeleteDestination",
                "logs:PutLogEvents",
                "lambda:GetFunctionEventInvokeConfig",
                "lambda:DeleteFunctionConcurrency",
                "lambda:DeleteFunctionUrlConfig",
                "logs:PutRetentionPolicy",
                "lambda:GetPolicy"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}