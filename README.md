# Amazon SageMaker Mammography Workshop

[1 - Cloning Git Repository](#1---cloning-git-repository)

[2 - Creating the SageMaker Jupyter Notebook](#2---creating-the-sagemaker-jupyter-notebook)

[3 - Presentation](#3---presentation)

[4 - Ground Truth](#4---ground-truth)

[5 - Training, testing, and deploying the Mammography Classification model](#5---training-testing-and-deploying-the-mammography-classification-model)

[6 - Front end](#6---front-end)

[7 - Step Functions](#7---step-functions)

[8 - Clean Up](#8---clean-up)

[9 - Reference Links](#9---reference-links)


Today we will learn how to classify mammography images into 5 different categories using Amazon SageMaker, Amazon GroundTruth, AWS StepFunctions, AWS Lambda, and much more!

You will need to use your own AWS account for this workshop, and all information will be provided through this documentation.

**Let's begin!**

To get started you will need an IAM user with the following access:
- CloudFormation
- S3
- IAM
- Cognito
- Lambda
- SageMaker
- StepFunctions

*Pre-requirements:*
- Service limit of 1 GPU instance type (p2, p3, etc.)
- Service limit to create 2 more buckets

## 1 - Cloning Git Repository

Let's first clone the git repository with all the necessary files for this workshop:

    
    git clone https://github.com/gabrielmartinigit/melissa_workshop.git
    
* _Tested in the N. Virginia region (us-east-1)._

If you don't have Git installed in your machine, no problem. Just navigate to the **deploy** folder of this workshop and download the file **sagemaker_template.yml**.
You will need this file on the next step. 

***

## 2 - Creating the SageMaker Jupyter Notebook

Before we can start the workshop, we need to have a SageMaker Jupyter Notebook deployed in your account. It will also create a bucket for output files.

If you have one Notebook and one bucket you can work on already, you **may skip this part**. 

If not, we will deploy one using a CloudFormation template: 

**CloudFormation**
1. Open the CloudFormation console **in a new tab** at https://console.aws.amazon.com/cloudformation
2. On the Welcome page, click on **Create stack** button
3. On the "Step 1 - Specify template": Choose Upload a template file, click on **Choose file** button and select the **sagemaker_template.yaml** located inside the **deploy** folder
4. On the "Step 2 - Specify stack details": Enter the Stack name as **sagemaker-mammography-workshop**
5. On the "Step 3 - Configure stack options": Just click on **Next** button
6. On the "Step 4 - Review": Enable the checkbox **I acknowledge that AWS CloudFormation might create IAM resources with custom names.**, and click on **Create Stack** button
7. Wait for the stack to get into status **CREATE_COMPLETE**


## 3 - Presentation

While you wait for the template to be deployed, let's learn from our instructors the motivation behind this workshop and what we plan to deliver today.


## 4 - Ground Truth

Let's navigate to the [Ground Truth lab](groundtruth#sagemaker-ground-truth).

## 5 - Training, testing, and deploying the Mammography Classification model

The architecture below represents what we will deploy today:

![demo](images/backend-architecture.png)

In order for us to do that, we will need to open the Jupyter Notebook created in step 1.

1. Open the SageMaker Notebook console at https://console.aws.amazon.com/sagemaker/home#/notebook-instances
2. Click on **Open JupyterLab**
3. When the notebook opens, click on the **Upload Files**:
![upload](images/upload-sign.png) 

4. Browse through your files to go to workshop folder you cloned in the step 1 
5. Open **sagemaker** folder to find the workshop's notebook (.ipynb file)
6. Now follow the instructions described in the notebook (.ipynb file) 

## 6 - Front end

We will now deploy a front-end static application in order for us to test our model.

The client application architecture is depicted below:

![demo](images/architecture.jpg)

* _Note: You can clone the repository in the SageMaker Notebook or you can run it locally in your machine._


1. In SageMaker, click on **Git** and then **Open Terminal**. Copy and paste the code below:
    ```
    cd SageMaker
    git clone https://github.com/gabrielmartinigit/melissa_workshop.git
    ```
2. Now navigate to the **deploy** folder:
    ```
    cd melissa_workshop/deploy
    ```
3. Open a new tab in your browser and navigate to:
    https://console.aws.amazon.com/sagemaker/home#/endpoints

4. Copy the last successful endpoint-name. It will look like this: 'image-classification-2020-01-13-09-58-43-599'

5. Run the deploy script. Replace the <<endpoint_name>> below by the endpoint copied in step 4.
    ```
    ./deploy.sh create <endpoint_name>
    ```
3. Copy the Client URL from the script output
4. Open the URL in a browser, upload a mammography image and see the results!
Download a sample mammography image here: 

* CC-Right: https://mammography-workshop.s3.amazonaws.com/sample/resize_CCD_564.jpg
* CC-Left: https://mammography-workshop.s3.amazonaws.com/sample/resize_CCE_599.jpg
* MLO-Right: https://mammography-workshop.s3.amazonaws.com/sample/resize_MLOD_682.jpg
* MLO-Left: https://mammography-workshop.s3.amazonaws.com/sample/resize_MLOE_743.jpg
* Not a mammography: https://mammography-workshop.s3.amazonaws.com/sample/resize_NAO_MG_1.3.51.0.7.2949628217.25582.6989.45324.14121.15364.52196.dcm.jpg


## 7 - Step Functions

Let's navigate to the [Step Functions lab](workflow#ml-workflow).


## 8 - Clean Up
* Deleting client app
    1. In the notebook Terminal, run deploy script with delete function
    ```
    cd deploy
    ./deploy.sh delete
    ```
* Deleting SageMaker notebook
    1. Go to CloudFormation and delete **sagemaker-mammography-workshop** stack
    
* Deleting the SageMaker endpoint
    1. Go to the SageMaker console, navigate to the endpoint. Delete the endpoint created during the lab.

## 9 - Reference Links
* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
* Python boto3: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html?id=docs_gateway
* SageMaker: https://docs.aws.amazon.com/sagemaker/latest/dg/gs.html

## License Summary
This sample code is made available under the MIT-0 license. See the LICENSE file.