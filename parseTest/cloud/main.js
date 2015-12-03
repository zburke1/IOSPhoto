
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
Parse.Cloud.define("MailGunSend",function(request,response){
	var Mailgun = require('mailgun');
	Mailgun.initialize('sandboxad669d823bcb44639dc2247e22b2827d.mailgun.org', 'key-f7da862b5bb12e1343e795bf6a1e6241');
	
	var toEmailString = "";
	var a = new Parse.Query("Signatures");
	a.equalTo("EventImageRef", request.params.imageId);
	a.find({
	    success: function(results)
	    {
			for (var i = 0; i < results.length; i++) {
			      var object = results[i];
				  if(i!=results.length - 1){
				  toEmailString = toEmailString + String(object.get('signeeEmail')) + ",";
				  }
				  else{
				  	toEmailString = toEmailString + String(object.get('signeeEmail'));
				  }
				  console.log(toEmailString)
			    }
		},
	  error: function(error) {
	    // The networking request failed.
		  console.log("could not add");
	  }
		
	}).then(function(){
		Mailgun.sendEmail({
		  to: toEmailString,
		  from: "zburke1@ufl.edu",
		  subject: "Thanks for taking a picture",
		  text: "We enjoyed seeing you at the event. Attached is your image!",
		  html: '<html><body><img src="' + request.params.imageUrl + '"></body></html>'
		}, {
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
	
	
	
	
});

Parse.Cloud.define("SendGrid",function(request,response){
	var sendgrid = require("sendgrid");
	var Buffer = require('buffer').Buffer;
	var Image = require("parse-image");
	var result = null;
	sendgrid.initialize("zburke1", "Burkenat0r");
	
	
	
	
	var a = new Parse.Query("EventImages");
	a.equalTo("objectId", request.params.imageId);
	a.find({
	    success: function(results)
	    {
			if ( results.length == 1 ){
				var result = results[0];
			    
						var email = sendgrid.Email({
						  to: "zburke1@ufl.edu",
						  from: "SendGrid@CloudCode.com",
						  subject: "Picture from UF PhotoBooth!",
						  text: "Temp",
						  replyto: "reply@example.com"
						});
						
						Parse.Cloud.httpRequest({
						  url: result.get("Image").url(),
						  success: function(response) {
							  email.addFileFromBuffer('email.png', response.buffer);
						    // The file contents are in response.buffer.
							  var image = new Image();
							      return image.setData(response.buffer, {
							        success: function() {
							          console.log("Image is " + image.width() + "x" + image.height() + ".");
							        },
							        error: function(error) {
							          // The image data was invalid.
							        }
							      })
						  },
						  error: function(error) {
						    // The networking request failed.
							  console.log("could not add");
						  }
						}).then(function(respone){
							console.log("Adding from buffer");
							
						})
						.then(function(ressponse){
							console.log("Doing sendEmail");
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
						
					   	
			          // email.setText(results[0].get('amountOfPeople')); 
					   
					   
				   	
			        }
			        else
			        {
			            
			            response.error("No event exists");
			        }
			}, error: function(error) {
        response.error("Query failed. Error = " + error.message);
    }
	});
	
	
	
	
	
	
});
