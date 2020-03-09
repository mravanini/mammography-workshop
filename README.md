# Amazon SageMaker Mammography Workshop

[1 - Creating the SageMaker Jupyter Notebook](#1---creating-the-sagemaker-jupyter-notebook)

[2 - Ground Truth](#2---ground-truth)

[3 - Training, testing, and deploying the Mammography Classification model](#3---training-testing-and-deploying-the-mammography-classification-model)

[4 - Front end](#4---front-end)

[5 - Step Functions](#5---step-functions)

[6 - Clean Up](#6---clean-up)

[7 - Reference Links](#7---reference-links)


Today we will learn how to classify mammography images into 5 different categories using Amazon SageMaker, Amazon GroundTruth, AWS StepFunctions, AWS Lambda, and much more!

You will need to use your an AWS account for this workshop, and all information will be provided through this documentation.

**Let's begin!**

To get started, you will need an IAM user with permissions on the following services:
- CloudFormation
- CloudFront
- S3
- IAM
- Cognito
- Lambda
- SageMaker
- StepFunctions
- Lambda

*Pre-requirements:*
- Service limit of 1 SageMaker ml.t2.large instance
- Service limit of 1 SageMaker GPU instance type (ml.p2.xlarge, ml.p3.xlarge, etc)
- Service limit to create 3 buckets

*This lab has been tested in the following regions:*
- N. Virginia (us-east-1)
- Ohio (us-east-2)
- Oregon (us-west-2)
- Ireland (eu-west-1)

## 1 - Creating the SageMaker Jupyter Notebook

Before we can start the workshop, we need to have a SageMaker Jupyter Notebook deployed in your account. The CloudFormation below will also create a bucket for the files needed for this workshop.
And, finally, it will create a file inside that S3 bucket that contains a zip of OpenCV lib to be used in *Step 4 - Front End* of this workshop.

**CloudFormation**
1. [Click here](sagemaker_template.yml?raw=true) to download the **sagemaker_template.yml** template file you are going to use to deploy the basic infrastructure for this workshop.
1. Login in the [AWS Console](https://console.aws.amazon.com/console/home). Make sure you are in the correct region assigned for this workshop.
1. Navigate to CloudFormation console: [https://console.aws.amazon.com/cloudformation/home](https://console.aws.amazon.com/cloudformation/home)
1. Once there, choose **Create Stack**.
1. On "Step 1 - Create Stack", choose **Upload a template file**, then click on the **Choose file** button.
    1. Choose the template file you downloaded in Step 1. Click **Next**
1. On "Step 2", type in the stack name: **mammography-workshop-set-up**. <br/>
    Make sure you have VPC CIDR IP range available to create a new VPC in this region. Click [here](https://console.aws.amazon.com/vpc/home#vpcs) to see your VPCs.<br/>
     
Click **Next**
1. On "Step 3 - Configure stack options": Just click on **Next** button
1. On "Step 4 - Review": Enable the checkbox **I acknowledge that AWS CloudFormation might create IAM resources with custom names.**, and click on **Create Stack** button

Move on to the next part of the Lab.

## 2 - Ground Truth

Let's navigate to the [Ground Truth lab](groundtruth#sagemaker-ground-truth).

## 3 - Training, testing, and deploying the Mammography Classification model

The architecture below represents what we will deploy today:

![Backend architecture](images/backend-architecture.png)

In order for us to do that, we will need to open the Jupyter Notebook created in step 1.

1. Open the SageMaker Notebook console at https://console.aws.amazon.com/sagemaker/home#/notebook-instances
2. Click on **Open JupyterLab**
3. In the Jupyter Lab console, click on **Git** and then **Open Terminal**. Execute the code below in the terminal:
    ```
    cd SageMaker
    git clone https://github.com/mravanini/mammography-workshop.git
   
    ```
If successful, you should see a message like this:

>Receiving objects: 100% (359/359), 61.28 MiB | 26.27 MiB/s, done.
>
>Resolving deltas: 100% (109/109), done.

4. Now we will upload the mammography images from your local file into the S3 bucket your created in Module 1 of this workshop.
Those files will be necessary for us to train, test, and validate our model.

In order for us to do that, execute the following command. 

**Don't forget to change the bucket name for the name of the bucket created previously**.

``
cd mammography-workshop/mammography-images

aws s3 sync . s3://mammography-workshop-files-YY-YYYY-YY-XXXXXXXXXXXX

`` 

5. In the File Browse on the left, navigate to the folder mammography-workshop/sagemaker. You should see something like the image below. Open the notebook with the name mammography-classification.ipynb:

![How to open a notebook](images/open-notebook.png)


6. Now, follow the instructions described in the notebook.  

## 4 - Front end

After you've finished every step of Step 3 - Training, testing, and deploying the Mammography Classification model, it's time to see it in action.

We will now deploy a front-end static application in order for us to test our model.

The client application architecture is depicted below:

![demo](images/architecture.png)


1. Go back to the Git terminal you opened previously. 

2. Now navigate to the **deploy** folder:
    ```
    cd ../deploy
    ```
3. Run the deploy script. 
    ```
    ./deploy.sh create 
    ```
4. Copy the Client URL from the script output.
It will look something like this: 


d12yz34h5w67br.cloudfront.net


This is an URL for the AWS content delivery network called Amazon CloudFront. **If you get an error accessing the page, wait a few more minutes and refresh your page.** It might take some time for CloudFront to propagate your site to its edge locations. 


5. Open the URL in a browser, upload a mammography image and see the results!
If you don't have one already, download a sample mammography image here: 

* [CC-Right](https://mammography-workshop.s3.amazonaws.com/sample/RIGHT_CC.jpg?raw=true)
* [CC-Left](https://mammography-workshop.s3.amazonaws.com/sample/LEFT_CC.jpg?raw=true)
* [MLO-Right](https://mammography-workshop.s3.amazonaws.com/sample/RIGHT_MLO.jpg?raw=true)
* [MLO-Left](https://mammography-workshop.s3.amazonaws.com/sample/LEFT_MLO.jpg?raw=true)
* [Not a mammography](https://mammography-workshop.s3.amazonaws.com/sample/not-a-mammography.png?raw=true)


## 5 - Step Functions

Let's navigate to the [Step Functions lab](workflow#ml-workflow).


## 6 - Clean Up
1. Deleting Client App
    1. In the notebook Terminal, run the deploy script, but now with **delete** parameter:
    ```
    cd deploy
    ./deploy.sh delete
    ```
    This might several minutes to finish, since it will delete CloudFront distribution. 
  
2. Deleting the SageMaker endpoint
    1. Go to the [SageMaker Endpoints console](https://console.aws.amazon.com/sagemaker/home#/endpoints). Delete the endpoint created during the lab.

3. Deleting SageMaker notebook
    1. **Only execute this step when the clean-up of Step 1."Deleting Client App"  has finished.** 
    2. First delete the contents of the output bucket. Copy the content below in the Jupyter notebook Terminal. Don't forget to replace <\<REGION>> and <\<ACCOUNT_ID>> before executing.
    ```
            aws s3 rm s3://mammography-workshop-files-<<REGION>>-<<ACCOUNT_ID>>/ --recursive --quiet

    ```
    3. Then go to [CloudFormation](https://console.aws.amazon.com/cloudformation/home#/stacks) and delete **sagemaker-mammography-workshop** stack
    
## 7 - Reference Links
* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
* Python boto3: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html?id=docs_gateway
* SageMaker: https://docs.aws.amazon.com/sagemaker/latest/dg/gs.html

## License Summary
This sample code is made available under the MIT-0 license. See the LICENSE file.