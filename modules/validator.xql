xquery version "3.0";

import module namespace config="http://podlove.org/podlove-matrix/config" at "config.xqm";

import module namespace xdiff="http://exist-db.org/xquery/xmldiff"
    at "java:org.exist.xquery.modules.xmldiff.XmlDiffModule";


declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

declare function local:validate-rss-item($item){
    if(exists($item/enclosure/@url))    
    then (
        let $http-head := httpclient:head($item/enclosure/@url, true(), ())
        let $http-options := httpclient:options($item/enclosure/@url, true(), ())
        return
            if(number($http-head/@statusCode) eq 200)
            then (
                <item status="ok">
                    <url>{data($item/enclosure/@url)}</url>
                    <response>{$http-head}</response>
                    <options>{$http-options}</options>
                </item>
            )
            else (
                <item status="false">
                     <url>{data($item/enclosure/@url)}</url>
                    <response>{$http-head}</response>
                    
                </item>
            )
            
    )
    else (
        false()
    )
};

declare function local:validate-rss($rss) {
     if(local-name($rss) eq 'rss' and exists($rss/channel) and exists($rss/channel/item[1]))
     then (
        for $item in $rss//item
        return 
            local:validate-rss-item($item)
     )
     else (false())
};


let $data-root := $config:app-root || "/test/"
let $nsfw1 := doc($data-root || "nsfw1.xml")//rss



return 
    <podcast>
    {    
        local:validate-rss($nsfw1) 
    }
    </podcast>
    