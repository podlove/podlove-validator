/*!
 * put application-specific JavaScript code
 */
'use strict';

jQuery(document).ready(function() {
    console.log("loaded app.js");

    function displayResult(data){
        console.log( "success data:'",data,"'");

        /*
         console.log( "START DISPLAY SCHEMATRON MESSAGES");
         $(data.schematron.report.message).each(function( index ) {
         console.log( index + ": " , this );
         var message = this;
         console.log("message level:", this.level)
         console.log("message text:", this["#text"])
         });
         console.log( "STOP DISPLAY SCHEMATRON MESSAGES");
         */
    }

    $("#validateBtn").click(function() {
        console.log("executing validate!");
        var feedURL = $("#inputFeedURL").val();
        console.log("feedURL: ", feedURL);
        var jqxhr = $.ajax({
            type: "POST",
            dataType: "json",
            url: "modules/feed-validator.xql",
            data: { feedURL: feedURL}
        }).done(function(data) {
            displayResult(data)
        })
        .fail(function(error) {
            console.log( "fail error:'",error,"'");
        })
        .always(function(data) {
            // console.log( ".always data: '", data, "'" );
        });
        // Perform other work here ...
        // Set another completion function for the request above
        // jqxhr.always(function() {
        //    console.log( "second complete" );
        // });
    });

    $( "#update-feeds" ).click(function() {
        console.log("executing updates-feeds");
        var jqxhr = $.ajax({
            type: "POST",
            dataType: "json",
            url: "modules/feed.xql"
        }).done(function(data) {
            displayResult(data)
        })
        .fail(function(error) {
                console.log( "fail error:'",error,"'");
        })
        .always(function(data) {
            // console.log( ".always data: '", data, "'" );
        });
    });

});
