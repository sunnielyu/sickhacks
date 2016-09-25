var creds = new AWS.Config();
//creds.update({accessKeyId: 'AKIAJPNMGGAMFD3F5NJA', secretAccessKey: '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'});
//creds.region = 'us-west-2';

var bucket = new AWS.({params: {Bucket: 'sickhacks'}, accessKeyId: 'AKIAJPNMGGAMFD3F5NJA', secretAccessKey: '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', region:"us-west-2"});
  bucket.listObjects(function (err, data) {
    if (err) {
      document.getElementById('status').innerHTML =
        'Could not load objects from S3';
    } else {
      document.getElementById('status').innerHTML =
        'Loaded ' + data.Contents.length + ' items from S3';
      for (var i = 0; i < data.Contents.length; i++) {
        document.getElementById('objects').innerHTML +=
          '<li>' + data.Contents[i].Key + '</li>';
      }
    }
  });
