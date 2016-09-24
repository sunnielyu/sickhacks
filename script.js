var ec2 = new AWS.EC2();
var params = {
  ImageId: '',
  InstanceType: 't1.micro',
  MinCount: 1, MaxCount: 1
};

ec2.runInstances(params, function(err, data) {
  if(err) { console.log("Could not create instance.", err); return; }
  var instanceId = data.Instances[0].InstanceId;
  console.log("Created instance.", instanceId);
  params = {Resources: [instanceId], Tags: [
    {Key: 'Name', Value: 'instanceName'}
  ]};
  ec2.createTags(params, function(err) {
    console.log("Tagging instance", err ? "failure" : "success");
  })
});
