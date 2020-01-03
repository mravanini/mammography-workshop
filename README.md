# Amazon SageMaker Mammography Workshop

The purpose of this workshop is show how to use...

Below we have the architecture of this demo:

**SageMaker Training**

_architecture image here_

**Client application**
![demo](images/architecture.jpg)

To get started you will need an IAM user with the following access:
- CloudFormation
- S3
- IAM
- Cognito
- Lambda
- SageMaker

__Notes:__
* _Clone or download the repository before start_
    ```
    git clone https://github.com/gabrielmartinigit/melissa_workshop.git
    ```
* _Tested in the N. Virginia region (us-east-1)._

## CloudFormation
1. Open the CloudFormation console at https://console.aws.amazon.com/cloudformation
2. On the Welcome page, click on **Create stack** button
3. On the Step 1 - Specify template: Choose Upload a template file, click on **Choose file** button and select the **sagemaker_stemplate.yaml** located inside deploy directory
4. On the Step 2 - Specify stack details: Enter the Stack name as **sagemaker-mammography-workshop**
5. On the Step 3 - Configure stack options: Just click on **Next** button
6. On the Step 4 - Review: Enable the checkbox **I acknowledge that AWS CloudFormation might create IAM resources with custom names.**, and click on **Create Stack** button
7. Wait for the stack get into status **CREATE_COMPLETE**

## Amazon SageMaker
1. Open the SageMaker console at https://console.aws.amazon.com/sagemaker
2. Open the new notebook created
3. Click on **New** and **Terminal**. Paste the code below and close the Terminal tab:
    ```
    cd SageMaker
    git clone https://github.com/gabrielmartinigit/melissa_workshop.git
    ```
4. Go to workshop folder and open sagemaker folder to find the workshop's notebook
5. _workshop steps here_

## Deploying Client and Testing
1. Click on **New** and **Terminal**. Copy and paste the code below:
    ```
    cd SageMaker/melissa_workshop/deploy
    ```
2. Run deploy script with create function
    ```
    ./deploy.sh create <your_sagemaker_inference_endpoint_name>
    ```
3. Copy the Client URL from the script output
4. Open the URL in a browser, upload an image and see the results!

## Clean Up
* Deleting client app
    1. In the notebook Termina, run deploy script with delete function
    ```
    cd deploy
    ./deploy.sh delete
    ```
* Deleting SageMaker notebook
    1. Go to CloudFormation and delete **sagemaker-mammography-workshop** stack

## Reference Links
* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
* Python boto3: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html?id=docs_gateway
* SageMaker: https://docs.aws.amazon.com/sagemaker/latest/dg/gs.html

## License Summary
This sample code is made available under the MIT-0 license. See the LICENSE file.