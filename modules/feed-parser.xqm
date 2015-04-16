xquery version "3.0";

module namespace fp="http://podlove.org/podlove-validator/feedparser";
import module namespace imageanalyzer="http://exist-db.org/xquery/imageanalyzer" at "java:org.exist.xquery.modules.imageanalyzer.ImageAnalyzerModule";

declare variable $fp:ATOM-HANDLER :=
    map {
         
         "atom:link" := fp:atom-link#1
};

declare variable $fp:RSS-HANDLER :=
    map {
        "rss" := fp:rss#1,
        "channel" := fp:channel#1,
        "title" := fp:title#1,
        "link" := fp:link#1,
        "comments" := fp:comments#1,
        "pubDate" := fp:pubDate#1,
        "category" := fp:category#1,
        "guid" := fp:guid#1,
        "description" := fp:description#1,
        "category" := fp:category#1,
        "enclosure" := fp:enclosure#1,
        "lastBuildDate" := fp:lastBuildDate#1,
        "language" := fp:language#1,
        "generator" := fp:generator#1,
        "webMaster" := fp:webMaster#1,
        "managingEditor" := fp:managingEditor#1,
        "image" := fp:image#1,
        "item" := fp:item#1
};

declare variable $fp:DC-HANDLER :=
    map {
        "dc:creator" := fp:dc-creator#1
};

declare variable $fp:SY-HANDLER :=
    map {
        "sy:updatePeriod" := fp:sy-updatePeriod#1,
        "sy:updateFrequency" := fp:sy-updateFrequency#1
};


declare variable $fp:XHTML-HANDLER :=
    map {
        "xhtml:body" := fp:ignore#1
};

declare variable $fp:CONTENT-HANDLER := 
    map {
        "content:encoded" := fp:content-encoded#1
};

declare variable $fp:ITUNES-HANDLER := 
    map {
        "itunes:subtitle" := fp:itunes-subtitle#1,
        "itunes:summary" := fp:itunes-summary#1,
        "itunes:author" := fp:itunes-author#1,
        "itunes:owner" := fp:itunes-owner#1,
        "itunes:name" := fp:itunes-name#1,
        "itunes:email" := fp:itunes-email#1,
        "itunes:image" := fp:itunes-image#1,
        "itunes:explicit" := fp:itunes-explicit#1,
        "itunes:duration" := fp:itunes-duration#1,
        "itunes:category" := fp:itunes-category#1,
        "itunes:keywords" := fp:itunes-keywords#1
};



(: higher order function tests :)
declare function fp:rss($item as item()*){
     <info>element rss is fine</info>
};

declare function fp:channel($item as item()*){
     <info>element channel is fine</info>
};



declare function fp:pubDate($item as item()*){
     <info>element 'pubDate' is fine</info>
};
declare function fp:category($item as item()*){
     <info>element 'category' is fine</info>
};
declare function fp:guid($item as item()*){
     <info>element 'guid' is fine</info>
};
declare function fp:description($item as item()*){
     <info>element 'description' is fine</info>
};
declare function fp:enclosure($item as item()*){
     <info>element 'enclosure' is fine</info>
};

declare function fp:lastBuildDate($item as item()*){
     <info>element 'lastBuildDate' is fine</info>
};

declare function fp:language($item as item()*){
     <info>element 'language' is fine</info>
};

declare function fp:generator($item as item()*){
     <info>element 'generator' is fine</info>
};

declare function fp:webMaster($item as item()*){
     <info>element 'webMaster' is fine</info>
};


declare function fp:managingEditor($item as item()*){
     <info>element 'managingEditor' is fine</info>
};

declare function fp:image($item as item()*){
     <info>element 'image' is fine</info>
};

declare function fp:item($item as item()*){
     <info>element 'item' is fine</info>
};

declare function fp:title($item as item()*){
    <info>element title is fine</info>
};

declare function fp:link($item as item()*){
    <info>element link is fine</info>
        (: 
            element { "a"} {
                $item/(@*),            
                $item/text()
        }
        :)     
};

declare function fp:comments($item as item()*){
    <info>element 'comments' is fine</info>
};

declare function fp:dc-creator($item as item()*){
    <info>element 'dc:creator' is fine</info>
};

declare function fp:sy-updatePeriod($item as item()*){
    <info>element 'sy:updatePeriod' is fine</info>
};

declare function fp:sy-updateFrequency($item as item()*){
    <info>element 'sy:updateFrequency' is fine</info>
};

declare function fp:content-encoded($item as item()*){
    <info>element 'content:encoded' is fine</info>
};

declare function fp:itunes-subtitle($item as item()*){
    <info>element 'itunes:subtitle' is fine</info>
};
declare function fp:itunes-summary($item as item()*){
    <info>element 'itunes:summary' is fine</info>
};
declare function fp:itunes-author($item as item()*){
    <info>element 'itunes:author' is fine</info>
};
declare function fp:itunes-owner($item as item()*){
    <info>element 'itunes-owner' is fine</info>
};

declare function fp:itunes-name($item as item()*){
    <info>element 'itunes-name' is fine</info>
};
declare function fp:itunes-email($item as item()*){
    <info>element 'itunes-email' is fine</info>
};
declare function fp:itunes-image($item as item()*){
    let $url := $item/@href
    let $analyzed-image := imageanalyzer:analyze(xs:anyURI($url))
    let $mime-type := data($analyzed-image/@mimeType)
    let $width := number(data($analyzed-image/@width))
    let $height := number(data($analyzed-image/@height))
    let $error := ""

    return 
        <info>element 'itunes:image' is fine {$mime-type} {$width} {$height}</info>
    
};
declare function fp:itunes-explicit($item as item()*){
    <info>element 'itunes:explicit' is fine</info>
};
declare function fp:itunes-duration($item as item()*){
    <info>element 'itunes-duration' is fine</info>
};
declare function fp:itunes-category($item as item()*){
    <info>element 'itunes-category' is fine</info>
};
declare function fp:itunes-keywords($item as item()*){
    <info>element 'itunes-keywords' is fine</info>
};


declare function fp:atom-link($item as item()*){
    <info>element atom:link is fine</info>
};

declare function fp:ignore($item as item()*){
    ()
};


declare function fp:parse-rss($xml, $config){
 for $node in $xml
    let $fn-name := name($node)
    return
         if ($node instance of element()) 
            then ( 
                if(map:contains($config, $fn-name))
                then (
                    $config($fn-name)($node),
                    fp:parse-rss($node/*, $config)
                )else (
                    (
                        <error>no function for elment '{$fn-name}'</error>,
                        if(exists($node/*)) then (
                            fp:parse-rss($node/*,$config)
                        ) else ()
                    )
                )
            )
         else if ($node instance of attribute()) then 'attribute'
         else if ($node instance of text()) then 'text'
         else if ($node instance of document-node()) 
            then (
                fp:parse-rss($node/*, $config)
            )
         else if ($node instance of comment()) then 'comment'
         else if ($node instance of processing-instruction())
                 then 'processing-instruction'
         else 'unknown'            
};


declare function fp:parse($feed as item()){
    let $config := map:new (($fp:RSS-HANDLER,$fp:ATOM-HANDLER,$fp:ITUNES-HANDLER, $fp:DC-HANDLER, $fp:SY-HANDLER, $fp:XHTML-HANDLER, $fp:CONTENT-HANDLER))
   
    return 
        <result>
            {
                fp:parse-rss($feed, $config)    
            }
        </result>
    
};
    

