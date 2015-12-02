
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("SendGrid",function(request,response){
	var sendgrid = require("sendgrid");

	sendgrid.initialize("zburke1", "Burkenat0r");
	
	var email = sendgrid.Email({
	  to: "zburke1@ufl.edu",
	  from: "SendGrid@CloudCode.com",
	  subject: "Hello from Cloud Code!",
	  text: "Says fail, means yes",
	  replyto: "reply@example.com"
	});
	
	sendgrid.sendEmail(email, {
    success: function(httpResponse) {
        console.log(httpResponse);
        response.success("Email sent!");
    },
    error: function(httpResponse) {
        console.error(httpResponse);
        response.error("Uh oh, something went wrong");
    }
	});
	
});
