#!/bin/bash

usage() {
    echo "usage: $0 <command>"

    echo "Available commands:"
    echo -e "  create <SAGEMAKER ENDPOINT>\tCreate client resources"
    echo -e "  delete\tDelete client resources"
}

create() {
  # Frontend resources
  echo "Deploying Client App frontend..."
  echo "Creating CloudFormation stack. This can take about 3 minutes..."
	stack_id_front=$(aws cloudformation create-stack --stack-name mammography-workshop-client-front --template-body file://frontend_client_template.yml --capabilities CAPABILITY_NAMED_IAM --output text --query StackId)

  #Remove after testing
  output_0=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[0].OutputValue)
  echo "output_0 : " $output_0

  output_1=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[1].OutputValue)
  echo "output_1 : " $output_1

  output_2=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[2].OutputValue)
  echo "output_2 : " $output_2

  output_3=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[3].OutputValue)
  echo "output_3 : " $output_3

  output_4=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[4].OutputValue)
  echo "output_4 : " $output_4

  #End of Remove after testing

: <<'END'
	stack_status_check="aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].StackStatus"
	stack_status=$($stack_status_check)

	while [ $stack_status != "CREATE_COMPLETE" ]; do
		echo "Checking CloudFormation stack status..."
		if [[ $stack_status == ROLLBACK_* ]]; then
			echo "Something went wrong. Please check CloudFormation events in the AWS Console"
			exit 1
		fi
		sleep 3
		stack_status=$($stack_status_check)
	done
	echo "Stack created successfully!"

	echo "Uploading frontend..."
  region=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[2].OutputValue)
  private_bucket=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[4].OutputValue)
  cognito_id=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[0].OutputValue)
  cat > ../client-app/frontend/config.js << EOL

  const REGION='$region'
  const COGNITO_ID='$cognito_id'
  const PRIVATE_BUCKET='$private_bucket'
EOL

  public_bucket=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[3].OutputValue)
	aws s3 cp ../client-app/frontend/ s3://$public_bucket --recursive --quiet

  # Backend resources
  echo "Deploying Client App backend..."
  echo "Creating CloudFormation stack. This can take about 3 minutes..."
  zip -j ../client-app/lambda/code/lambda_invoke_classifier.zip ../client-app/lambda/code/lambda_invoke_classifier.py --quiet
  zip -j ../client-app/lambda/code/lambda_resize_image.zip ../client-app/lambda/code/lambda_resize_image.py --quiet
  aws s3 cp ../client-app/lambda/ s3://$private_bucket --recursive --quiet
  stack_id_back=$(aws cloudformation create-stack --stack-name mammography-workshop-client-back --template-body file://backend_client_template.yml --parameters ParameterKey=Endpoint,ParameterValue=$1 ParameterKey=PrivateBucket,ParameterValue=$private_bucket --capabilities CAPABILITY_NAMED_IAM --output text --query StackId)
  stack_status_check="aws cloudformation describe-stacks --stack-name $stack_id_back --output text --query Stacks[0].StackStatus"
	stack_status=$($stack_status_check)
  while [ $stack_status != "CREATE_COMPLETE" ]; do
		echo "Checking CloudFormation stack status..."
		if [[ $stack_status == ROLLBACK_* ]]; then
			echo "Something went wrong. Please check CloudFormation events in the AWS Console"
			exit 1
		fi
		sleep 3
		stack_status=$($stack_status_check)
	done
	echo "Stack created successfully!"

  # Outputs
  client_url=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[1].OutputValue)
  echo "Website URL: " $client_url

END
}

delete() {
    echo "Deleting resources..."
    private_bucket=$(aws cloudformation describe-stacks --stack-name mammography-workshop-client-front --output text --query Stacks[0].Outputs[4].OutputValue)
    public_bucket=$(aws cloudformation describe-stacks --stack-name mammography-workshop-client-front --output text --query Stacks[0].Outputs[3].OutputValue)
    aws s3 rm s3://$public_bucket/ --recursive --quiet
    aws s3 rm s3://$private_bucket/ --recursive --quiet
    aws cloudformation delete-stack --stack-name mammography-workshop-client-front
    aws cloudformation delete-stack --stack-name mammography-workshop-client-back
}

if [[ $# -gt 0 ]]; then
    command=$1
    parameter=$2

    case $command in

    create )
        if [[ $# == 2 ]]; then
            create $parameter
        else
            usage
            exit
        fi
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