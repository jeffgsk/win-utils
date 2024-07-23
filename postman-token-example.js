// Define the URL for the token request
const tokenUrl = pm.environment.get("baseUrl") + "/authendpoint/token";

// Define the client credentials
const clientId = pm.environment.get("clientId");
const clientSecret = pm.environment.get("clientSecret");

// Set up the request options
const requestOptions = {
  url: tokenUrl,
  method: 'POST',
  header: {
    'Content-Type': 'application/json'
  },
  body: {
    mode: 'raw',
    raw: JSON.stringify({
      client_id: clientId,
      client_secret: clientSecret,
      grant_type: 'client_credentials'
    })
  }
};

// Send the request
pm.sendRequest(requestOptions, function (err, res) {
  if (err) {
    console.log(err);
  } else {
    // Parse the response and set the token as a global variable
    const responseBody = res.json();
    const token = responseBody.token;
    pm.globals.set("bearerToken", token);
  }
});
