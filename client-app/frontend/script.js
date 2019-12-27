
$(document).ready(function () {
    var viewModel = {};
    viewModel.fileData = ko.observable({
        dataURL: ko.observable(),
    });
    viewModel.multiFileData = ko.observable({
        dataURLArray: ko.observableArray(),
    });
    viewModel.onClear = function (fileData) {
        if (confirm('Tem certeza?')) {
            fileData.clear && fileData.clear();
            $(".result").empty();
        }
    };
    ko.applyBindings(viewModel);


    document.getElementById("submit").onclick = function (e) {
        $(".result").empty();
        e.preventDefault();

        var files = document.getElementById("img").files;
        if (!files.length) {
            return alert("Selecione um arquivo");
        }


        var file = files[0];
        var name = "raw/" + file.name;
        var bucketName = "mammographyupload"
        lambda = new AWS.Lambda({ region: 'us-east-1', apiVersion: '2015-03-31' });

        var upload = new AWS.S3.ManagedUpload({
            params: {
                Bucket: bucketName,
                Key: name,
                Body: file
            }
        });

        var promise = upload.promise();

        promise.then(
            function (data) {
                var location = JSON.stringify(data.Location);
                var key = JSON.stringify(data.Key);
                var bucket = JSON.stringify(data.Bucket);

                var obj = '{"location" :' + location + ',"key":' + key + ',"bucket":' + bucket + '}'

                var lambdaParams = {
                    FunctionName: 'InvokeMammographyClassification',
                    InvocationType: 'RequestResponse',
                    LogType: 'None',
                    Payload: obj
                }

                lambda.invoke(lambdaParams, function (err, data) {

                    if (err) {
                        alert(err)
                    } else {
                        var resultado = JSON.parse(data.Payload);
                        $(".result").append(resultado);

                    }
                })

            },

            function (err) {
                return alert("erro: " + err);
            }

        );

    }
});




