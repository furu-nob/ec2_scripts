#!/bin/sh

DATE=`date +%Y%m%d%H%M%S`

export EC2_AMITOOL_HOME='/opt/aws/amitools/ec2'
export EC2_HOME='/opt/aws/apitools/ec2'
export JAVA_HOME='/usr/lib/jvm/jre'
export AWS_RDS_HOME='/opt/aws/apitools/rds'

#export EC2_CREATE_SNAPSHOT='/opt/aws/bin/ec2-create-snapshot'
#export EC2_CREATE_TAGS='/opt/aws/bin/ec2-create-tags'
#export EC2_DESCRIBE_SNAPSHOTS='/opt/aws/bin/ec2-describe-snapshots'
#export EC2_DELETE_SNAPSHOT='/opt/aws/bin/ec2-delete-snapshot'

export RDS_CREATE_DB_SNAPSHOT='/opt/aws/bin/rds-create-db-snapshot'
export RDS_DESCRIBE_DB_INSTANCES='/opt/aws/bin/rds-describe-db-instances'
export RDS_DESCRIBE_DB_SNAPSHOTS='/opt/aws/bin/rds-describe-db-snapshots'
export RDS_DELETE_DB_SNAPSHOT='/opt/aws/bin/rds-delete-db-snapshot'

export AWS_PRIVATEKEY='/home/ec2-user/pk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.pem'
export AWS_CERTIFICATE='/home/ec2-user/cert-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx.pem'
export AWS_REGION='ap-northeast-1'

export SNAPSHOT_DESCRIPTION="Daily_Backup"
export SNAPSHOT_GENERATION=7

#DB Instanceの表示
# $RDS_DESCRIBE_DB_INSTANCES yaoyorozu-test -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION

#DBsnapshotの表示
#$RDS_DESCRIBE_DB_SNAPSHOTS -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION

#$RDS_CREATE_DB_SNAPSHOT yaoyoroz-btest-001 -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION --db-snapshot-identifier "yaoyoroz-btest-001-daily-backup-$DATE"

#$RDS_DESCRIBE_DB_SNAPSHOTS -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION | grep 'yaoyoroz-btest-001-daily-backup-' | sort -k3 |awk '{print $2}'



function take_db_snapshot ()
{
    RDS_ID=$1
    $RDS_CREATE_DB_SNAPSHOT $RDS_ID -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION --db-snapshot-identifier "$RDS_ID-daily-backup-$DATE"
    
    SNAPSHOTS=`$RDS_DESCRIBE_DB_SNAPSHOTS -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION | grep "$RDS_ID-daily-backup-" | sort -k3 |awk '{print $2}'`
    
    COUNT=1
    for SNAPSHOT in ${SNAPSHOTS}; do
      if [ ${COUNT} -gt ${SNAPSHOT_GENERATION} ]; then
        echo "deleting ${SNAPSHOT}";
        $RDS_DELETE_DB_SNAPSHOT -f -K $AWS_PRIVATEKEY -C $AWS_CERTIFICATE --region $AWS_REGION --db-snapshot-identifier ${SNAPSHOT}
      fi
      COUNT=`expr ${COUNT} + 1`
    done
}

take_db_snapshot hoge-test
take_db_snapshot hoge-01

