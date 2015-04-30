xquery version "3.0";

import module namespace image="http://exist-db.org/xquery/image" at "java:org.exist.xquery.modules.image.ImageModule";
import module namespace podlove="http://podlove.org/ns/PodloveModule" at "java:org.podlove.PodloveModule";
import module namespace httpclient="http://exist-db.org/xquery/httpclient";
import module namespace http = "http://expath.org/ns/http-client";


declare function local:test-image-stuff() {
    let $image-path := "/db/apps/podlove-validator/data/image/not-safe-for-work-logo.jpg"       
    let $height := image:get-height(util:binary-doc($image-path)) 
    let $width := image:get-width(util:binary-doc($image-path))
    let $metadata := image:get-metadata(util:binary-doc($image-path),false())
    return
    
    <result>
        <imageAnalyzer info="podlove-validator image analyzer library">{
            podlove:analyze(xs:anyURI("http://meta.metaebene.me/media/mm/freakshow-logo-1.0.jpg"))}
        </imageAnalyzer>
        <image info="existdb image module" height="{$height}" widht="{$width}">{$metadata}</image>        
    </result>
    
    
};

declare function local:test-head-request() {
    let $options := <headers></headers>
    let $url := xs:anyURI("http://feedproxy.google.com/~r/mobile-macs-podcast/~3/Ekp8qQMF7j8/fs142-prime-directive")
    let $response1 := podlove:http-head($url, false(), $options)
    let $response2 := httpclient:head($url, false(), $options)    
    
    
     let $req := <http:request href="{$url}" method="get"/>
     let $response3 := http:send-request($req)
    
    return 
        <http 
            podloveStatusCode="{data($response1/@statusCode)}" 
            httclientStatusCode="{data($response2/@statusCode)}" 
            expathStatusCode="{data($response3/@status)}">
        
        </http>
        
};

local:test-image-stuff(),
local:test-head-request()
