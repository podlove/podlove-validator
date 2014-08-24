xquery version "3.0";

import module namespace config="http://podlove.org/podlove-matrix/config" at "config.xqm";
import module namespace feed="http://podlove.org/podlove-matrix/feed" at "feed.xqm";
import module namespace schematron="http://podlove.org/podlove-matrix/schematron" at "schematron.xqm";
import module namespace fp="http://podlove.org/podlove-matrix/feedparser" at "feed-parser.xqm";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace slash="http://purl.org/rss/1.0/modules/slash/";
declare namespace rawvoice="http://www.rawvoice.com/rawvoiceRssModule/";
declare namespace wfw="http://wellformedweb.org/CommentAPI/";
declare namespace sy="http://purl.org/rss/1.0/modules/syndication/";
declare namespace math = 'java:java.lang.Math';

declare option exist:serialize "method=json media-type=text/javascript";

let $inputURL := request:get-parameter("feedURL", "")
let $log-in := xmldb:login("/db", "admin", "efh241")
        (: let $feedURL := $inputURL cast as xs:anyURI
        let $feedPath := feed:store-feed(xs:anyURI($feedURL))
        let $feed := doc($feedPath):)

let $feed := doc($config:app-root || "/test/nsfw1.xml")
let $schematron-report := schematron:report($feed)

let $parseFeed := 
    try {
        <podcast>
            <debug>
                {
                    for $duration in $feed//itunes:duration
                        return
                            if(number((substring($duration,1,2)) or substring($duration,1,2) eq "00") and (number(substring($duration,4,2)) or substring($duration,4,2) eq "00") and (number(substring($duration,7,2)) or substring($duration,7,2) eq "00"))
                            then (
                                )
                                else (
                                    $duration
                                )
                }
                
            </debug>
            <schematron> 
                {
                    ( for $message in $schematron-report//message
                        let $error-code := substring-after($message, "#")
                        return
                            <error>{$error-code}</error>
                        ,
                        $schematron-report
                    )
                }
            </schematron>
            <!--local-parser>{
                    let $result := fp:parse($feed)
                    return 
                        (
                            <errors>{$result//error}</errors>,
                            <infos>{$result//info}</infos>
                        )
                        
            }</local-parser-->
        </podcast>
    } catch * {
        <error>ups.. error {$err:code}: {$err:description}</error>
    }

let $template-doc := doc($config:app-root || "/data/template/template.xml")
let $errors := for $error in distinct-values($parseFeed//error)
                    return 
                        <error>{$error}</error>
return
    <templating  xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"> 
        {
            for $error in $errors
                return 
                    $template-doc//template[@id eq $error/text()]
        }
    </templating>


    