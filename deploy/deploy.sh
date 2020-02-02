#!/bin/bash

usage() {
    echo "usage: $0 <command>"

    echo "Available commands:"
    echo -e "  create \tCreate client resources"
    echo -e "  delete\tDelete client resources"
}

create() {

  # Mandatory parameter validation
  endpoint=$(aws sagemaker list-endpoints --sort-by 'CreationTime' --sort-order 'Descending' --status-equals 'InService' --name-contains 'mammography-classification-' --query Endpoints[0].EndpointName)
  echo $endpoint
  if [ $endpoint == 'null' ]; then
      endpoint_not_ready=$(aws sagemaker list-endpoints --sort-by 'CreationTime' --sort-order 'Descending' --status-equals 'Creating' --name-contains 'mammography-classification-' --query Endpoints[0].EndpointName)

      echo $endpoint_not_ready

      if [ $endpoint_not_ready != 'null' ]; then
  			echo "Your endpoint is not In Service yet. Wait a few minutes and try again."
  			exit 1

      fi

			echo "Your model endpoint could not be found. Access https://console.aws.amazon.com/sagemaker/home?#/endpoints/ to make sure you have an endpoint called 'mammography-classification-<timestamp>' deployed."
			exit 1

  fi


  : <<'END'
  # Frontend resources
  echo "Deploying Client App frontend..."
  echo "Creating CloudFormation stack. This can take about 3 minutes..."
	stack_id_front=$(aws cloudformation create-stack --stack-name mammography-workshop-client-front --template-body file://frontend_client_template.yml --capabilities CAPABILITY_NAMED_IAM --output text --query StackId)

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


  cognito_id=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[?OutputKey==\`CognitoIdentityPoolId\`].OutputValue)
  region=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[?OutputKey==\`Region\`].OutputValue)
  website_bucket=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[?OutputKey==\`S3StaticWebsiteBucket\`].OutputValue)
  private_bucket=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[?OutputKey==\`PrivateBucket\`].OutputValue)
  origin_access_identity=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[?OutputKey==\`CloudFrontOriginAccessIdentity\`].OutputValue)
  origin_domain_name=$(aws cloudformation describe-stacks --stack-name $stack_id_front --output text --query Stacks[0].Outputs[?OutputKey==\`OriginDomainName\`].OutputValue)

	echo "Deploying CloudFront ..."

  stack_id_cloudfront=$(aws cloudformation create-stack --stack-name mammography-workshop-cloudfront --template-body file://cloudfront_template.yml --parameters ParameterKey=CloudFrontOriginAccessIdentity,ParameterValue=$origin_access_identity ParameterKey=S3StaticWebsiteBucket,ParameterValue=$origin_domain_name --capabilities CAPABILITY_NAMED_IAM --output text --query StackId)
  # Since this will take several minutes to deploy, we won't keep track of its status. Let's move on.

	echo "Uploading frontend..."
  cat > ../client-app/frontend/config.js << EOL

  const REGION='$region'
  const COGNITO_ID='$cognito_id'
  const PRIVATE_BUCKET='$private_bucket'
EOL

	aws s3 cp ../client-app/frontend/ s3://$website_bucket --recursive --quiet

  # Backend resources
  echo "Deploying Client App backend..."
  echo "Creating CloudFormation stack. This can take about 3 minutes..."
  zip -j ../client-app/lambda/code/lambda_invoke_classifier.zip ../client-app/lambda/code/lambda_invoke_classifier.py --quiet
  zip -j ../client-app/lambda/code/lambda_resize_image.zip ../client-app/lambda/code/lambda_resize_image.py --quiet
  aws s3 cp ../client-app/lambda/ s3://$private_bucket --recursive --quiet

  stack_id_back=$(aws cloudformation create-stack --stack-name mammography-workshop-client-back --template-body file://backend_client_template.yml --parameters ParameterKey=Endpoint,ParameterValue=$endpoint ParameterKey=PrivateBucket,ParameterValue=$private_bucket --capabilities CAPABILITY_NAMED_IAM --output text --query StackId)
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


END

  # Outputs

  outputs

}

outputs(){

#  yum install jq

  distribution=$(aws cloudfront list-distributions --query DistributionList.Items[*])
  printf "%s" "$distribution" > "distribution.json"

  jq -r ' .[] | select( .Origins.Items[].DomainName | startswith("mammography-static-website")) | .DomainName' distribution.json
}

delete() {
    echo "Deleting resources..."

    website_bucket=$(aws cloudformation describe-stacks --stack-name mammography-workshop-client-front --output text --query Stacks[0].Outputs[?OutputKey==\`S3StaticWebsiteBucket\`].OutputValue)
    private_bucket=$(aws cloudformation describe-stacks --stack-name mammography-workshop-client-front --output text --query Stacks[0].Outputs[?OutputKey==\`PrivateBucket\`].OutputValue)
    aws s3 rm s3://$website_bucket/ --recursive --quiet
    aws s3 rm s3://$private_bucket/ --recursive --quiet
    aws cloudformation delete-stack --stack-name mammography-workshop-client-front
    aws cloudformation delete-stack --stack-name mammography-workshop-client-back
    aws cloudformation delete-stack --stack-name mammography-workshop-cloudfront
}

if [[ $# -gt 0 ]]; then
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