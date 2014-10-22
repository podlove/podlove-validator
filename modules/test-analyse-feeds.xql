xquery version "3.0";

import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

declare %private function local:analyse-lang() {
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
            <language count="{$feeds-with-language-elem}" 
                      distinct-lang="{count(distinct-values($languages))}" 
                      distinct-short-lang="{count(distinct-values($shortlang))}">
            {
                for $lang in $shortlang
                    return
                        $lang
            }
            </language>
        </result>
};

declare %private function local:analyse-full-feeds(){
    let $path-to-feeds := $config:app-root || "/../feed-data/data/feeds"
    let $rss-feeds := collection($path-to-feeds)//rss
    let $distinct-feeds := count(distinct-values($rss-feeds//channel/title))
    
    let $links := $rss-feeds//atom:link[@rel]
    let $payment-links := $links[@rel = "payment"]
    let $flattr := $payment-links[starts-with(@href, 'https://flattr.com/') or starts-with(@href, 'http://flattr.com')] 
    return 
        <result rss-feeds="{count($rss-feeds)}" distinct-feeds-titles="{$distinct-feeds}">
            <payment total="{count($payment-links)}" flattr="{count($flattr)}"/>
            {
                let $channel-desc := $rss-feeds//channel/description[ft:query(., 'pritlove')]
                let $channel-author := $rss-feeds//channel/itunes:author[ft:query(., 'pritlove')]
                let $description := $rss-feeds//description[ft:query(., 'pritlove')]
                let $author := $rss-feeds//itunes:author[ft:query(., 'pritlove')]
                    
                return 
                   <pritlove 
                        channel-description="{count($channel-desc)}"
                        channel-author="{count($channel-author)}"
                        description="{count($description)}"
                        author="{count($author)}"
                    />
            }
        </result>    
};

declare %private function local:analyse-feeds(){
    let $path-to-feeds := $config:app-root || "/../feed-data/data/feeds"
    let $rss-feeds := collection($path-to-feeds)//rss
    return 
        <result>
            {
            let $channel-desc := $rss-feeds//channel/description[ft:query(., 'pritlove')]
            let $channel-author := $rss-feeds//channel/itunes:author[ft:query(., 'pritlove')]
            let $description := $rss-feeds//description[ft:query(., 'pritlove')]
            let $author := $rss-feeds//itunes:author[ft:query(., 'pritlove')]
                
            return 
               <pritlove 
                    channel-description="{count($channel-desc)}"
                    channel-author="{count($channel-author)}"
                    description="{count($description)}"
                    author="{count($author)}"
                />
            }
        </result>    
};

local:analyse-full-feeds()
