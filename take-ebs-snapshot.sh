#!/bin/sh

export EC2_AMITOOL_HOME='/opt/aws/amitools/ec2'
export EC2_HOME='/opt/aws/apitools/ec2'
export JAVA_HOME='/usr/lib/jvm/jre'

export EC2_CREATE_SNAPSHOT='/opt/aws/bin/ec2-create-snapshot'
export EC2_CREATE_TAGS='/opt/aws/bin/ec2-create-tags'
export EC2_DESCRIBE_SNAPSHOTS='/opt/aws/bin/ec2-describe-snapshots'
export EC2_DELETE_SNAPSHOT='/opt/aws/bin/ec2-delete-snapshot'

export AWS_PRIVATEKEY='/home/ec2-user/pk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.pem'
export AWS_CERTIFICATE='/home/ec2-user/cert-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.pem'
export AWS_REGION='ap-northeast-1'

export SNAPSHOT_DESCRIPTION="Daily_Backup"
export SNAPSHOT_GENERATION=7


function take_snapshot ()
{
    EBS_VOLUME_ID=$1
    EBS_VOLUME_NAME=$2
    resource_id=`$EC2_CREATE_SNAPSHOT -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION --description $SNAPSHOT_DESCRIPTION $EBS_VOLUME_ID`
    resource_target=`echo $resource_id | awk '{print $2}'`
    $EC2_CREATE_TAGS -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION $resource_target --tag "Name=$EBS_VOLUME_NAME"

    SNAPSHOTS=`$EC2_DESCRIBE_SNAPSHOTS --private-key $AWS_PRIVATEKEY --cert $AWS_CERTIFICATE --region $AWS_REGION  | grep ${EBS_VOLUME_ID} | grep "${SNAPSHOT_DESCRIPTION}" | sort -k5 -r | awk '{print $2}'`
    
    COUNT=1
    for SNAPSHOT in ${SNAPSHOTS}; do
      if [ ${COUNT} -gt ${SNAPSHOT_GENERATION} ]; then
        echo "deleting ${SNAPSHOT}";
        $EC2_DELETE_SNAPSHOT --private-key ${AWS_PRIVATEKEY} --cert ${AWS_CERTIFICATE} --region ${AWS_REGION} ${SNAPSHOT}
      fi
      COUNT=`expr ${COUNT} + 1`
    done
}

take_snapshot vol-xxxxxxxx hoge-test       # hoge-test
take_snapshot vol-xxxxxxxy hoge-test-xvdf  # hoge-test-xvdf
take_snapshot vol-xxxxxxxz hoge-001         # hoge-001
take_snapshot vol-xxxxxxxa hoge-002         # hoge-002

