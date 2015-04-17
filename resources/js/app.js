/*!
 * put application-specific JavaScript code
 */
'use strict';

jQuery(document).ready(function() {
    console.log("loaded app.js");

    function displayResult(data){
        console.log( "success data:'",data,"'");

        console.log( "START DISPLAY MESSAGES");
        $("#messagebox").append($("<ul id='msgContainer' class='container courses-container media-list'/>"))
        $(data.template).each(function( index ) {
            console.log( index + ": " , this );
            var tmpl = this;
            console.log("message location:", tmpl.location)
            console.log("message text:", tmpl.message["#text"])
            var mediaList = $("<li class='media " + tmpl.message.type +"'>");
            var mediaBody = $("<div class='media-body'>");
            $(mediaBody).append("<h6 class'media-heading'>" + tmpl.message["#text"] + "</h6>");
            $(mediaBody).append("<p>Location:" + tmpl.location+ "</p>");
            if(tmpl.info){
                $(mediaBody).append("<p>Info: "+tmpl.info+"</p>");
            } 
            // $(mediaList).append("<a class='pull-left' href='#'><p class='glyphicon glyphicon-zoom-in'/></a>");
            $(mediaList).append(mediaBody);
            var $mediaContainer = 
            $("#msgContainer").append(mediaList);
         });
         console.log( "STOP DISPLAY  MESSAGES");
    }

    $("#validateBtn").click(function() {
        console.log("executing validate!");
        $( "#messagebox *" ).remove();
        var feedURL = $("#inputFeedURL").val();
        console.log("feedURL: ", feedURL);
        $("#messagebox").append("<div><p style='font-weight:bold;color:darkred;'>loading....</p></div>")
        // setTimeout(function(){ $("#messagebox").append("<div><p style='font-weight:bold;color:darkred;'>we're testing your patience....</p></div>")}, 10000)
        
        var jqxhr = $.ajax({
            type: "POST",
            dataType: "json",
            url: "modules/feed-validator.xql",
            data: { feedURL: feedURL}
        }).done(function(data) {
            $( "#messagebox *" ).remove();
            displayResult(data)
        })
        .fail(function(error) {
            // console.log( "fail error:'",error,"'");
            $( "#messagebox *" ).remove();
            $("#messagebox").append("<div><p>Status: "+ error.statusText + "</p><p>Error Code:"+ error.status+"</p></div>")
        })
        .always(function(data) {
            console.log( ".always data: '", data, "'" );
        });
        // Perform other work here ...
        // Set another completion function for the request above
        // jqxhr.always(function() {
        //    console.log( "second complete" );
        // });
    });

});
