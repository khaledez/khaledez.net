"use strict";
exports.handler = (event, context, callback) => {
  // Extract the request from the CloudFront event that is sent to Lambda@Edge
  let request = event.Records[0].cf.request;

  // Replace the received URI with the URI that includes the index page
  request.uri = handleUri(request.uri);

  // Return to CloudFront
  return callback(null, request);
};

const URI_REGEX = /\.[a-zA-Z0-9]{2,10}$/gm;

function handleUri(oldUri) {
  if (oldUri.match(URI_REGEX)) {
    return oldUri;
  }
  return oldUri.slice(-1) == "/"
    ? oldUri.replace(/\/$/, "/index.html")
    : oldUri + "/index.html";
}
