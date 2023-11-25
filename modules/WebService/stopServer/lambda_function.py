import boto3
import os
region = ""
instances = [os.environ['INSTANCE_ID']]
ec2 = boto3.client('ec2',region_name=region)

def lambda_hanlder(event,context):
    print(instances)
    ec2.stop_instances(InstanceIds=instances)