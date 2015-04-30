xquery version "3.0";

import module namespace podlove="http://podlove.org/ns/PodloveModule" at "java:org.podlove.PodloveModule";
import module namespace httpclient="http://exist-db.org/xquery/httpclient";

(: URI of the REST interface of eXist instance :)


declare function local:http-head($url as xs:anyURI, $persist as xs:boolean, $options as item(), $result) {
    let $response := podlove:http-head($url, $persist, $options)
    let $statusCode as xs:double := number($response/@statusCode)
    let $location := $response//httpclient:header[@name = 'Location']
    return 
    if( $statusCode = 200 ) 
        then ( $result, $response)
    else if( $statusCode = 301 or $statusCode = 302 or $statusCode = 303 or $statusCode = 307)
        then (local:http-head( xs:anyURI($location/@value), $persist, $options, $response )
    )else ( 
        <error statusCode="{$statusCode}" url="{$url}">{$response}</error>
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
let $url := xs:anyURI("http://feedproxy.google.com/~r/mobile-macs-podcast/~3/Ekp8qQMF7j8/fs142-prime-directive")
return 
    local:http-head($url, false(), <headers/>,())

