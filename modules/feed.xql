xquery version "3.0";

import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";

import module namespace httpclient="http://exist-db.org/xquery/httpclient";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

(: get all feed pages :)
declare %private function local:get-feed-page($data,$has-next) {
    if(exists($has-next) and string-length($has-next) gt 0)
    then (
        let $nextPageData := httpclient:get(xs:anyURI($has-next),false(), ())
        let $updated-feed-data := 
            <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:psc="http://podlove.org/simple-chapters" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:fh="http://purl.org/syndication/history/1.0" >
                <channel>                    
                    {
                        $data//channel/*,
                        $nextPageData//item
                    }
                </channel>
            </rss>
         return
             local:get-feed-page($updated-feed-data,data($nextPageData//atom:link[@rel='next']/@href))
         
    )else (
        $data
    )
};

declare function local:aggregate-feed($feedURI as xs:anyURI) {
    let $data :=  httpclient:get($feedURI,false(), ())
    let $aggregated-feed := local:get-feed-page($data, data($data//atom:link[@rel='next']/@href)) 
    return $aggregated-feed

};


let $feeds := 
    <feeds>
        <feed>http://cre.fm/feed/m4a/</feed>
        <feed>http://freakshow.fm/feed/m4a/</feed>
        <feed>http://not-safe-for-work.de/feed/m4a/</feed>
        <feed>http://fokus-europa.de/feed/m4a/</feed>
        <feed>http://raumzeit-podcast.de/feed/m4a/</feed>
        <feed>http://der-lautsprecher.de/feed/m4a/</feed>
        <feed>http://logbuch-netzpolitik.de/feed/m4a</feed>
        <feed>http://newz-of-the-world.com/feed/m4a</feed>
    </feeds>
return
        <result>{                    
            for $feed in $feeds//feed
                let $data := local:aggregate-feed(xs:anyURI($feed/text()))
                let $name := util:uuid($feed/text()) || ".xml"
                let $stored := xmldb:store($config:podcast-root, $name, $data)
                    return <stored dir="{$config:podcast-root}" resource="{$name}"/>
        }
</result>

