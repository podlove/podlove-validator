xquery version "3.0";

import module namespace podlove="http://podlove.org/ns/PodloveModule" at "java:org.podlove.PodloveModule";
import module namespace httpclient="http://exist-db.org/xquery/httpclient";

(: URI of the REST interface of eXist instance :)


declare function local:resolve($url as xs:anyURI, $result) {
    let $options := <headers></headers>
    let $params := <headers></headers>
    let $response := podlove:head($url, false(), $options, $params)
    let $statusCode := $response/@statusCode
    return 
    if($statusCode = 200)
        then (
            $result,$response
        )
    else if($statusCode = 301)
        then (
            local:resolve(xs:anyURI(data($response//httpclient:header[@name = 'Location']/@value)), $response)
            
    )else( 
        <error>{$statusCode}</error>
            
    )
    
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

local:resolve(xs:anyURI("http://feedproxy.google.com/~r/mobile-macs-podcast/~3/Ekp8qQMF7j8/fs142-prime-directive"),())

