xquery version "3.0";

import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";
import module namespace feed="http://podlove.org/podlove-validator/feed" at "feed.xqm";
import module namespace schematron="http://podlove.org/podlove-validator/schematron" at "schematron.xqm";
import module namespace fp="http://podlove.org/podlove-validator/feedparser" at "feed-parser.xqm";

declare namespace svrl="http://purl.oclc.org/dsdl/svrl";



declare option exist:serialize "method=json media-type=text/javascript";

declare function local:validate-feed($feedPath){
    let $feed := doc($feedPath)

    (:   let $feed := doc($config:app-root || "/test/nsfw1.xml") :)
    let $schematron-report := schematron:xsl($feed)
    
    let $parser-result := fp:parse($feed)
    let $parser-error := $parser-result//error
    let $parser-info := $parser-result//info
    
    let $template-doc := doc($config:app-root || "/data/template/template.xml")
    return
        <result>
            {
                (
                    for $error in $schematron-report//svrl:failed-assert
                        
                        let $id := substring-after(fn:tokenize($error//svrl:text/text(),"\s")[1],"#")
                        let $error-location := if(contains($error/@location,"/rss"))
                                                then ("/rss" || substring-after($error/@location,"/rss")) 
                                                else (data($error/@location))
                        
                        let $template := $template-doc//template[@id = $id]
                        return 
                            if(exists($template))
                            then (
                                let $template := $template-doc//template[@id = $id]
                                return 
                                    element {name($template)} {
                                        attribute { "test" } {$error/@test},
                                        attribute { "location" } {$error-location},
                                        $template/@*,
                                        $template/*,
                                        <info>{normalize-space(substring-after($error//svrl:text/text(),"#" || $id))}</info>
                                    }
                            )
                            else (
                                <template test="{$error/@test}" location="{$error-location}">
                                    <message>{$error/svrl:text/text()}</message>
                                </template> 
                            )
                            
                    (:
                                for $error in $errors
                    return 
                        $template-doc//template[@id eq $error/text()]
    
                    :)
                )
            }
        </result>
};


(:
 let $test-url := "http://www.wrint.de/category/fotografie/feed/" 
 let $test-url := "http://freakshow.fm/feed/m4a/"
 : :)
let $test-url := "http://www.wrint.de/category/fotografie/feed/" 

let $inputURL := request:get-parameter("feedURL", $test-url)
let $log-in := xmldb:login($config:app-root, $config:user-name, $config:user-pwd)

let $feedURL := $inputURL cast as xs:anyURI
let $feedPath := feed:store-feed(xs:anyURI($feedURL))
return 
    if($feedPath)
    then (
        local:validate-feed($feedPath)
    )
    else (
        $feedPath    
    )




