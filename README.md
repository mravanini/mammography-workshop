# Amazon SageMaker Mammography Workshop

The purpose of this workshop is show how to use... Under construction...

Below we have the architecture of this demo:

![demo](images/architecture.jpg)

To get started you will need an IAM user with the following access:
- CloudFormation
- S3
- IAM
- Cognito
- Lambda
- SageMaker

__Notes:__
* _Before start, clone or download the repository_
* _Tested in the N. Virginia region (us-east-1)._

## Development Environment (optional)
1. Open the Cloud9 console at https://console.aws.amazon.com/cloud9
2. On the Step 1 - Name environment: Enter the Environment name as **'sagemaker-mammography-workshop'**
3. On the Step 2 - Configure settings: Just click on **Next** button
4. On the Step 3 - Review: Check the resources being created, and click on **Create Environment** button 
5. Once your envionment was provisioned, select the **bash** tab and execute the following commands:
```
git clone ...
```

## Amazon SageMaker ...
Under construction...

## Deploying Client and testing
1. Run deploy script with create function
```
cd deploy
./deploy.sh create
```
2. Copy the Client URL from the script output
3. Open the URL in a browser
4. Upload an image
5. Under construction...
**(Deixar as funções lambda dentro do template ou colocar como step do workshop para que o pessoal consiga ver o código que chama o sagemaker endpoint e como você fez o resize?)**

## Clean up
1. Run deploy script with delete function
```
cd deploy
./deploy.sh delete
```

## Reference Links
* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
* Python boto3: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html?id=docs_gateway
* SageMaker: https://docs.aws.amazon.com/sagemaker/latest/dg/gs.html

## License Summary
This sample code is made available under the MIT-0 license. See the LICENSE file.