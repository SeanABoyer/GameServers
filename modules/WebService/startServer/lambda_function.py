import boto3
region = ""
instances = [os.environ['INSTANCE_ID']]
ec2 = boto3.client('ec2',region_name=region)

def lambda_hanlder(event,context):
    print(instances)
    ec2.start_instances(InstanceIds=instances)