xquery version "3.0";

import module namespace http = "http://expath.org/ns/http-client";
import module namespace httpclient="http://exist-db.org/xquery/httpclient";

(: URI of the REST interface of eXist instance :)


declare function local:resolve($url as xs:anyURI) {
    let $options := <headers></headers>  
    let $params := <headers></headers>  
    let $response := httpclient:head($url, false(), $options, $params)
    let $statusCode := $response/@statusCode
    let $finalResponse := if($statusCode = 200) 
                            then ($response)
                            else if($statusCode = 301)
                            then (local:resolve(xs:anyURI(data($response//httpclient:header[@name = 'Location']/@value))))
                            else( $statusCode)
    return
        $response
};

declare function local:check-itunes-image($url as xs:anyURI) {
    let $response := httpclient:head($url, false(),())
    let $statusCode := $response/@statusCode
    return 
        if($statusCode = 200) 
        then (
            let $content-type := $response//httpclient:header[@name="Content-Type"]/@value
            return $content-type
        )
        else( 
            "error retreiving picture to analyze! Status Code: " || $statusCode    
        )
};

(: 
let $link := <link>http://feedproxy.google.com/~r/mobile-macs-podcast/~3/Ekp8qQMF7j8/fs142-prime-directive</link>
return
     local:resolve(xs:anyURI($link/text()))
:)

local:check-itunes-image(xs:anyURI("http://meta.metaebene.me/media/nsfw/not-safe-for-work-logo.jpg"))

