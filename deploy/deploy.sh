#!/bin/bash
echo "Creating CloudFormation stack. This can take about 3 minutes..."
stack_id=$(aws cloudformation create-stack --stack-name sagemaker-workshop-tko --template-body file://client_template.yml --output text --query StackId)

stack_status_check="aws cloudformation describe-stacks --stack-name $stack_id --output text --query Stacks[0].StackStatus"
stack_status=$($stack_status_check)

while [ $stack_status != "CREATE_COMPLETE" ]; do
	echo "Checking CloudFormation stack status..."
	if [[ $stack_status == ROLLBACK_* ]]; then
		echo "Something went wrong. Please check CloudFormation events in the AWS Console"
		exit 1
	fi
	sleep 2
	stack_status=$($stack_status_check)
done
echo "Stack created with success!"

frontend_bucket=$(aws cloudformation describe-stacks --stack-name $stack_id --output text --query Stacks[0].Outputs[0].OutputValue)

echo $frontend_bucket
