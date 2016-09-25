var config = new AWS.config();
config.update({accessKeyId: 'AKIAIG2WWMIGQEUR7DHA', secretAccessKey: 'MIIEogIBAAKCAQEAt27sU+ekxc4dQCSNEcSHQzlzaVEgiVxRqJY0/dqr7hhPqbem7PfmdvPp3KZ9yIMuRbhiPEAl1O8IQpEL6MoLKq2PfQHwj/1ibzkzc886+n2CtbtmUvTBZkFtkaayteNA2rOhCAism5BhC7nvhhp5IMjBvLoNS+LX+KTXduutPlqkwWEnmTg71vuywHXUO/Ov/AJv+CHqA7I7KnBgDsFqhunGg3jKAHbtNSXKGR7tB/8Gc/aikUYCzwLrHr24sxWY8RrJPf0zswIDAQABAoIBAEHq45RXVvgaVJqbR/KNnEoFGDtNgxK5kUKzD8H11fkO1XnY3GylvTUb+/tl/SeUNImrc+nQ54d4ipBZTV1PVen1Su4SR1+HH9t2Q84nNzuS5OjnuiKvf9x+QKCptej1DHZLPOAFNdUQttJUQWuPqjyeYIPVIujCgJv2q9IwtvxvBS7xMam6DPQXZtDTxx6C+PDVZ0uzMrmJWQSwHgdNJtHiJMhfn4xRNsJqNoQfVZPrTl8i0IYjZbV49DJSOw2liHgOM9RYidWMZF5dmROA4qLXgrBgsnJNeinUZE5Lt4YsdvJKft3zU7l0aAidC+l4wvrGRg/75gbylj0gY6iXwYkCgYEA9ioS3BpP7OlKYMYhUbfj2svm/v6396Lz0Evg55CJo5XAVrrxl6/rihx+5qZJC+NQEbYTKh0tRd23g6R7oRbX/HVSeWL5djHfibX9yAxWZ3Dfy3C7w+X2SzDwz3hgzDRtzfAxDSlistc+vfASIFXR/PjzWztjROlQBaq4DDHaVdUCgYEAvsMyNgpLtW67frSoUTmeluaYPgEsejZstu2F/x90+fImMFrjJkJU8f/J4jyK4SHzuJdzeRlOnj1sCGQ1zrAGEY7UXlQDlqkPrs294FtuONLHl96gdXkRxcNzC3i08hdX4pLjqNU7Zjdm8rT93N8rlH0TdI7cbNJ41LRqiNxQf2cCgYBQ+mA/5av7PHdKRIM7danQFRmFMtfj78gS8pMmugZ9OMsP/Olyw91RDrS0PWl0Lq/tU58UUIrPG/O9q4M7597fXtzlr6huuFNX4vV8NIrL9na4Xvp1pBWUgKIHLgtxwaGJiIUqVj3wpRwvsWTVHEY62M59aZjrV3EKnDF1WYUAjQKBgBjcXYXXb6h0hvDrYGg9hyKJaNvj0UUYJLDuYaEvG1KbsUhp/+JzkJh9SnU2iK7wes/axQzKNInA3Xx2euC15gSRxbGJZ3JSFB4m6BD+OW4kYiiztdu5bIyGfU7Ia2SFkEmR9SOCrpwSqlMFLXSEjSxr5IYzPBzejSrDXIL7m24PAoGAVscXKvmWb92RtW6yzFO/RUzRBHGOTsi8bSzcAavuDSzE9WR35ZWL1YurlvPsedSek0lGfP9AZIpH8JZoc17oTaWQYNCnZyG1qGQVpPbChJRKmAE0ZttNpWzvv1APV498MPrf2dBrii7LFZwlEJHv1e8I34nuf94yIW8hX9lvF1k='});
config.region = 'us-west-2';

var sick = new AWS.EC2();
var params = {
  ImageId: 'ami-7172b611',
  InstanceType: 't2.medium',
  MinCount: 1, MaxCount: 1
};

sick.runInstances(params, function(err, data) {
  if(err) { console.log("Could not create instance.", err); return; }
  var instanceId = data.Instances[0].InstanceId;
  console.log("Created instance.", instanceId);
  params = {Resources: [instanceId], Tags: [
    {Key: 'Name', Value: 'instanceName'}
  ]};
sick.createTags(params, function(err) {
    console.log("Tagging instance", err ? "failure" : "success");
  })
});
