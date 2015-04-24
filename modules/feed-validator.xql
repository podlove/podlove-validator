xquery version "3.0";

import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";
import module namespace feed="http://podlove.org/podlove-validator/feed" at "feed.xqm";
import module namespace schematron="http://podlove.org/podlove-validator/schematron" at "schematron.xqm";
import module namespace fp="http://podlove.org/podlove-validator/feedparser" at "feed-parser.xqm";

declare namespace svrl="http://purl.oclc.org/dsdl/svrl";



declare option exist:serialize "method=json media-type=text/javascript";

declare variable $local:template-doc := doc($config:app-root || "/data/template/template.xml");

declare function local:create-error-message($template-id as xs:string*,$message as xs:string, $test-expr as xs:string*, $context as xs:string*){
    let $template := $local:template-doc//template[@id = $template-id]
    return 
        if(exists($template))
        then (
            element {"template"} {
                attribute { "test" } {$test-expr},
                attribute { "location" } {$context},
                attribute { "template-id"} {$template-id},
                $template/@*,
                $template/*,
                <info>{normalize-space(substring-after($message,"#" || $template-id))}</info>
            }
        )
        else if(exists($test-expr)) then(
            <template test="{$test-expr}" location="{$context}" template-id="{$template-id}">
                <message type="warning" lang="en">{$message}</message>
            </template> 
        )else (
            <template location="{$context}" template-id="{$template-id}">
                <message type="warning" lang="en">{$message}</message>
            </template> 
        )
        
    
};


declare function local:validate-feed($feed-url, $feed-db-path){
    let $feeddoc := doc($feed-db-path)
    let $feed := if(exists($feeddoc//httpclient:body)) 
                    then ($feeddoc//httpclient:body/*)
                    else ($feeddoc)
        

    (:   let $feed := doc($config:app-root || "/test/nsfw1.xml") :)
    let $schematron-report := schematron:xsl($feed)
    
    let $parser-result := fp:parse($feed)
    let $parser-errors := $parser-result//error
    let $parser-infos := $parser-result//info
    
    
    return
        <result feed-url="{$feed-url}" url="{$feed-db-path}">
            {(
                
                for $error in $parser-errors
                    return 
                        
                      (:local:create-error-message((), $error/text(),(),())  :)
                      ()
                ,

                for $error in $schematron-report//svrl:failed-assert
                    
                    let $id := substring-after(fn:tokenize($error//svrl:text/text(),"\s")[1],"#")
                    let $message := $error/svrl:text/text()
                    let $test-exp := $error/@test
                    let $error-location := if(contains($error/@location,"/rss"))
                                            then ("/rss" || substring-after($error/@location,"/rss")) 
                                            else (data($error/@location))
                    
                    
                    return 
                        local:create-error-message($id, $message,$test-exp,$error-location)
                    

            )}
        </result>
};


(:
let $test-url := "http://www.wrint.de/category/fotografie/feed/" 
let $test-url := "http://freakshow.fm/feed/m4a/"
let $test-url := "http://chaosradio.ccc.de/chaosradio-latest.rss/" 
let $test-url := "http://logbuch-netzpolitik.de/feed/m4a" 
:)

let $test-url := "http://www.wrint.de/category/fotografie/feed/" 
let $inputURL := request:get-parameter("feedURL", $test-url)
let $log-in := xmldb:login($config:app-root, $config:user-name, $config:user-pwd)

let $feed-url := $inputURL cast as xs:anyURI
let $feed-db-path := feed:store-feed(xs:anyURI($feed-url))
return 
    (
        if($feed-db-path)
        then (
            local:validate-feed($feed-url, $feed-db-path)
        )
        else (
            <result>
                <error>Error processing {$inputURL}</error>
            </result>
        )
    )




