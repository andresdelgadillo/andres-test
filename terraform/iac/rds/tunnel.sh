#!/bin/bash

# Use the following command to create a SSH tunnel and a Port Forwarding, then access to the private RDS

aws --region us-east-1  ssm start-session --target <INSTANCE ID> \
--document-name AWS-StartPortForwardingSessionToRemoteHost \
--parameters '{"portNumber":["5432"],"localPortNumber":["5432"],"host":["<RDS ENDPOINT>"]}'





aws --region us-east-1  ssm start-session --target i-094a9385a96e4b4bb \
--document-name AWS-StartPortForwardingSessionToRemoteHost \
--parameters '{"portNumber":["5432"],"localPortNumber":["5432"],"host":["terraform-20230215025719243300000001.cxzv98yl84dh.us-east-1.rds.amazonaws.com"]}'
