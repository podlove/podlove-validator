xquery version "3.0";

import module namespace config="http://podlove.org/podlove-matrix/config" at "config.xqm";
import module namespace feed="http://podlove.org/podlove-matrix/feed" at "feed.xqm";
import module namespace schematron="http://podlove.org/podlove-matrix/schematron" at "schematron.xqm";
import module namespace fp="http://podlove.org/podlove-matrix/feedparser" at "feed-parser.xqm";

declare namespace svrl="http://purl.oclc.org/dsdl/svrl";



declare option exist:serialize "method=json media-type=text/javascript";

let $test-url := "http://www.wrint.de/category/fotografie/feed/"
let $inputURL := request:get-parameter("feedURL", $test-url)
let $log-in := xmldb:login($config:app-root, $config:user-name, $config:user-pwd)

let $feedURL := $inputURL cast as xs:anyURI
let $feedPath := feed:store-feed(xs:anyURI($feedURL))
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
                    let $id := substring-after($error//svrl:text/text(),"#")
                    let $template := $template-doc//template[@id = $id]
                    return 
                        if(exists($template))
                        then (
                            let $template := $template-doc//template[@id = $id]
                            return 
                                element {name($template)} {
                                    attribute { "test" } {$error/@test},
                                    attribute { "location" } {$error/@location},
                                    $template/@*,
                                    $template/*
                                }
                        )
                        else (
                            <error test="{$error/@test}" location="{$error/@location}">{$error/svrl:text/text()}</error> 
                        )
                        
                (:
                            for $error in $errors
                return 
                    $template-doc//template[@id eq $error/text()]

                :)
            )
        }
    </result>


