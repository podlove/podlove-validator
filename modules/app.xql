xquery version "3.0";

module namespace app="http://podlove.org/podlove-validator/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

declare function app:each($node as node(), $model as map(*), $from as xs:string, $to as xs:string) {
    for $item in $model($from)
    return
           element { node-name($node) } {
            $node/@*, templates:process($node/node(), map:new(($model, map:entry($to, $item))))
        }       
};

declare %templates:wrap  function app:rss-alt($node as node(), $model as map(*)) {
    let $data-root := $config:app-root || "/data/podcast"
    
    (:  
        let $data :=  httpclient:get(xs:anyURI("http://cre.fm/feed/m4a/"),false(), ())
        let $aggregate-feed := local:get-page($data) 
    :)
    let $data := collection($data-root)/rss[1]
    
    let $enhanced-model :=map:new((
            $model,
            map:entry("rss",$data)
    ))
    return
        element { node-name($node) } {
                $node/@*, for $child in $node/node() return templates:process($child, $enhanced-model)
            }
};

declare %templates:wrap  function app:podcasts($node as node(), $model as map(*)) {
    let $data-root :=  $config:podcast-root
    let $podcasts := for $podcast in collection($data-root)//rss[1]
                        order by $podcast//channel[1]/title[1] ascending
                        return $podcast
    return 
        map {
            "podcasts" := $podcasts
        }
};



declare
    %templates:wrap
    %templates:default("title", "")
function app:podcast($node as node(), $model as map(*), $title) {
    let $data-root := $config:app-root || "/data/podcast"
    let $podcast := collection($data-root)//rss[channel/title/text() eq $title]
    return 
        map {
            "podcast" := $podcast
        }
};



declare 
    %templates:wrap
function app:podcast-title($node as node(), $model as map(*)) {
    let $title := $model("podcast")/channel/title/string()
    return 
        element { node-name($node) } {
            $node/@*, 
            if(string(node-name($node)) eq "a") 
            then (
                attribute href {"podcast.html?title=" || $title}
            )
            else (),
            $title
        }

    
};

declare 
    %templates:wrap
function app:podcast-subtitle($node as node(), $model as map(*)) {
    $model("podcast")/channel/itunes:subtitle/text()
};

declare 
    %templates:wrap
function app:podcast-desc($node as node(), $model as map(*)) {
     $model("podcast")/channel/itunes:summary/string() 
};

declare 
    %templates:replace
function app:podcast-icon($node as node(), $model as map(*)){
    let $title := $model("podcast")/channel[1]/title[1]/string()
    let $image := $model("podcast")/channel/itunes:image/@href
    
    return 
        element { node-name($node) } {
            $node/@*, 
            if(string(node-name($node)) eq "a") 
            then (
                attribute href {"podcast.html?title=" || $title},
                element img {
                    attribute class {'logo'},
                    attribute src { $image }        
                }
            )
            else (
                element img {
                    attribute class {'logo'},
                    attribute src { $image }        
                }
            )
        }
};

declare %templates:wrap  function app:podcast-episodes($node as node(), $model as map(*)) {
    let $data-root := $config:app-root || "/data/podcast"
    let $podcast := $model("podcast")
    
    let $episodes := for $episode in $podcast//item
                        return $episode
    return 
        map {
            "episodes" := $episodes
        }
};


declare 
    %templates:wrap
function app:episode-title($node as node(), $model as map(*)) {
     $model("episode")//title/string() 
};
declare 
    %templates:wrap
function app:episode-subtitle($node as node(), $model as map(*)) {
     $model("episode")//itunes:subtitle/string() 
};

declare 
    %templates:wrap
function app:episode-summary($node as node(), $model as map(*)) {
     $model("episode")//itunes:summary/string() 
};

declare 
    %templates:wrap
function app:adminlink($node as node(), $model as map(*)) {
     $node
};











declare %templates:wrap function app:meta($node as node(), $model as map(*)) {
    element { node-name($node) } {
                $node/@*, for $child in $node/node() return templates:process($child, $model)
            }    
};

declare %templates:wrap function app:feed-title($node as node(), $model as map(*)) {
    $model("rss")/channel/title/text()
};

declare %templates:wrap function app:feed-desc($node as node(), $model as map(*)) {
    $model("rss")/channel/description/text()
};


declare 
    %templates:wrap 
function app:items($node as node(), $model as map(*))  as map(*) {
    map { "items" := $model("rss")//item }
};

declare 
    %templates:wrap
function app:item-title($node as node(), $model as map(*)) {
     $model("item")/title/string() 
};

declare 
    %templates:wrap
function app:item-desc($node as node(), $model as map(*)) {
     $model("item")//itunes:subtitle/string() 
};

declare 
    %templates:wrap 
function app:persons($node as node(), $model as map(*)) {
    let $data-root := $config:app-root || "/data/podcast"
    let $data := collection($data-root)//rss
    let $distinct-persons :=  distinct-values($data//atom:name)
    let $persons := 
        for $person in $distinct-persons
            let $count := count($data//atom:name[. eq $person])
                return 
                    <person>
                        <name>{$person}</name>
                        <count>{$count}</count>
                    </person>
    
    for $person in $persons
        order by xs:integer($person//count) descending
        return 
            <div>
                <p>
                    <span>{$person/name/text()} ({$person/count/text()})</span>
                </p>
            </div>
};

declare 
    %templates:wrap 
function app:categories($node as node(), $model as map(*)) {
    let $data-root := $config:app-root || "/data/podcast"
    let $data := collection($data-root)//rss
    let $distinct-categories :=  distinct-values($data//itunes:category/@text)

    return 
        <ul>{
    
            for $category in $distinct-categories
                let $count := count($data//itunes:category/@text[. eq $category])
                let $podcasts := $data[.//itunes:category/@text[. eq $category]]
                return 
                    <li>
                        <span>{$category} (items: {$count})</span>
                        <span>
                            <span> <strong>Podcasts</strong></span>
                        {
                            for $podcast in $podcasts 
                                return 
                                    <span> - {$podcast//channel/title/text()}</span>
                        }
                        </span>
                    </li>
        }
        </ul>
};


