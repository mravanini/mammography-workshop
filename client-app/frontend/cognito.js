$(document).ready(function () {
    AWS.config.region = 'us-east-1';
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: 'us-east-1:b5775b41-8885-4a08-9f45-622f370f58d5',
    });
});