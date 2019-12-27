
$(document).ready(function(){
      //instanciando cognito, trocar ou apagar isso depois
      AWS.config.region = 'us-east-1'; // Region
      AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: 'us-east-1:b5775b41-8885-4a08-9f45-622f370f58d5',
//      AWS.config.credentials = new AWS.CognitoIdentityCredentials({
//        IdentityPoolId: 'us-east-1:61d1690e-b3f3-4800-80e7-6949e7727dbe',
        });

      var viewModel = {};
      viewModel.fileData = ko.observable({
        dataURL: ko.observable(),
        // base64String: ko.observable(),
      });
      viewModel.multiFileData = ko.observable({
        dataURLArray: ko.observableArray(),
      });
      viewModel.onClear = function(fileData){
        if(confirm('Tem certeza?')){
          fileData.clear && fileData.clear();
          $(".result").empty();
        }                            
      };
      ko.applyBindings(viewModel);


    document.getElementById("submit").onclick = function(e){
        $(".result").empty();
        e.preventDefault();
       
        var files = document.getElementById("img").files;
        if (!files.length) {
            return alert("Selecione um arquivo");
        }
        
        
        var file = files[0];
        var name = "raw/" + file.name;
        var bucketName = "mammographyupload"
//        var bucketName = "bucket-for-lambda-fidi-function"
        lambda = new AWS.Lambda({region: 'us-east-1', apiVersion: '2015-03-31'});

//        alert("bucket to upload: " + bucketName)

        var upload = new AWS.S3.ManagedUpload({
            params:{
                Bucket: bucketName,
                Key: name,
                Body: file
            }  
        });
        
        var promise = upload.promise();
        
         promise.then(
            function(data){
//                alert("Imagem enviada com sucesso!");
                //pegando o caminho, chave e bucket das imagens para passar pra a função
                var location = JSON.stringify(data.Location);
                var key = JSON.stringify(data.Key);
                var bucket = JSON.stringify(data.Bucket);
                
                
                var obj = '{"location" :'+location+',"key":'+key+',"bucket":'+bucket+'}'
                    
                
                var lambdaParams = {
//                FunctionName : 'FuncaoFrontFIDI',
                    FunctionName : 'InvokeMammographyClassification',
                    InvocationType : 'RequestResponse',
                    LogType : 'None',
                    Payload: obj
                    }
                
                lambda.invoke(lambdaParams, function(err, data) {
                  
                    if(err){
                        alert(err)
                    } else {
                        var resultado = JSON.parse(data.Payload);
                        $(".result").append(resultado);
                    
                    }
                })
                
             },
            
            function(err){
                return alert("erro: " + err);
            }
        
        );
                
    }
});




