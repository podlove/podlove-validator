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

let $data-root := $config:app-root || "/test/"
    
    (:  
        let $data :=  httpclient:get(xs:anyURI("http://cre.fm/feed/m4a/"),false(), ())
        let $aggregate-feed := local:get-page($data) 
    :)
let $grammar :=    doc($data-root || "rss_validator.xml")
let $nsfw1 := doc($data-root || "nsfw1.xml")


return 
  validation:jing-report($nsfw1, $grammar)
