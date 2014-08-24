xquery version "3.0";

import module namespace config="http://podlove.org/podlove-matrix/config" at "config.xqm";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

let $path-to-feeds := $config:app-root || "/../feed-data/data/feeds"
let $feeds := collection($path-to-feeds)//rss

(: 
let $distinct-feeds := count(distinct-values($feeds//channel/title))
let $number-of-feeds := count($feeds)  

return 
    <result total-feeds="??" wellformed-rss-feeds="{$number-of-feeds}" distinct-feeds-titles="{$distinct-feeds}">
       <generator total="{count($feeds//generator)}" podlove="{count($feeds//generator[contains(.,"Podlove")])}"/>
       <payment total="{count($feeds//atom:link[@rel='payment'])}" flattr="{count($feeds//atom:link[contains(@href,'Flattr')])}"/>
       <pritlove>
           {
            for  $feed in $feeds//channel[contains(itunes:author/text(), "Pritlove")]
                order by $feed/title
                    return 
                        <podcast base-uri="{base-uri($feed)}" feed-link="{$feed/link/text()}">{$feed/title/text()}</podcast>               
           }
       </pritlove>
    </result>
:)
let $languages := $feeds//language
let $feeds-with-language-elem := count($languages)
let $shortlang := for $lang in $languages
                    return 
                        if(string-length($lang/text()) gt 3)
                        then (
                            <language>{substring($lang/text(), 1,2)}</language>
                        )
                        else (
                            $lang
                        )
return 
<result>
    <language count="{$feeds-with-language-elem}" distinct-lang="{count(distinct-values($languages))}" distinct-short-lang="{count(distinct-values($shortlang))}">
        {
            for $lang in $shortlang
                return 
                    $lang
        }
    </language>
</result>