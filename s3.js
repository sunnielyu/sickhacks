// Import the AWS SDK
var AWS = require('aws-sdk');

config.update({accessKeyId: 'AKIAJPNMGGAMFD3F5NJA', secretAccessKey: '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'});
config.region = 'us-west-2';




// Set credentials and region,
// which can also go directly on the service client
AWS.config.update({region: 'REGION', credentials: {/* */}});

var s3 = new AWS.S3({apiVersion: '2006-03-01'});

/**
 * This function retrieves a list of objects
 * in a bucket, then triggers the supplied callback
 * with the received error or data
 */
function listObjects(bucket, callback) {
  s3.listObjects({
    Bucket: bucket
  }, callback);
}

// Export the handler function
module.exports = listObjects;
