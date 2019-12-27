#!/bin/bash

usage() {
    echo "usage: $0 <command>"

    echo "Available commands:"
    echo -e "  create\tCreate workshop resources"
    echo -e "  delete\tDelete workshop resources"
}

create() {
	echo "Creating CloudFormation stack. This can take about 3 minutes..."
	stack_id=$(aws cloudformation create-stack --stack-name sagemaker-workshop-tko --template-body file://client_template.yml --capabilities CAPABILITY_NAMED_IAM --output text --query StackId)

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

	echo "Uploading frontend..."
	frontend_bucket=$(aws cloudformation describe-stacks --stack-name $stack_id --output text --query Stacks[0].Outputs[2].OutputValue)
	aws s3 cp ../client-app/frontend/ s3://$frontend_bucket --recursive

    client_url=$(aws cloudformation describe-stacks --stack-name $stack_id --output text --query Stacks[0].Outputs[1].OutputValue)
	echo "Client URL: " $client_url
}

delete() {
    echo "Deleting resources..."
}

if [[ $# == 1 ]]; then
    command=$1

    case $command in

    create )
        create
        ;;

    delete )
        delete
        ;;

    * )
        usage
        exit 1

    esac
else
    usage
    exit
fi