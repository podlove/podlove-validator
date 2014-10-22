xquery version "3.0";

import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";
import module namespace feed="http://podlove.org/podlove-validator/feed" at "feed.xqm";


import module namespace xdiff="http://exist-db.org/xquery/xmldiff" at "java:org.exist.xquery.modules.xmldiff.XmlDiffModule";

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




declare variable $local:ITEM_HANDLERS :=
    local:title#2,
local:link#2,
local:guid#2,
local:pubDate#2,
local:description#2,
local:chapters#2,
local:duration#2,
local:subtitle#2,
local:author#2,
local:summary#2,
local:contributor#2,
local:origLink#2,
local:enclosure#2,
local:origEnclosureLink#2,
local:encoded#2;


declare variable $local:CONFIG := map {
"heading" := function($level as xs:int, $content as xs:string*) {
element { "h" || $level } {
$content
}
}
};

declare %private function local:handle-channel-item($item as item(), $handlers as function(*)*, $config as map(*)) {
if (empty($handlers))
then(
'unknown element ' || local-name($item)
)
else
let $handler := head($handlers)
let $result := $handler($item, $config)
return
if (exists($result)) then
element {name($item)} { $item/@*,
if(exists($item/*))
then ($item/*)
else ($item/text())
}
else
local:handle-channel-item($item, tail($handlers), $config)
};

declare %private function local:parse-item($item as item(), $config as map(*)) {


for $elem in $item/*
return
local:handle-channel-item($elem, $local:ITEM_HANDLERS, $config)

};


declare %private function local:atom-link($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'atom-link')
then (
'atom-link'
)else ()
};




declare %private function local:title($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'title')
then (
'title'
)else ()
};

declare %private function local:link($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'link')
then (
'link'
)else ()
};

declare %private function local:guid($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'guid')
then (
'guid'
)else ()
};
declare %private function local:pubDate($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'pubDate')
then (
'pubDate'
)else ()
};

declare %private function local:description($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'description')
then (
'description'
)else ()
};

declare %private function local:chapters($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'chapters')
then (
'chapters'
)else ()
};
declare %private function local:duration($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'duration')
then (
'duration'
)else ()
};
declare %private function local:subtitle($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'subtitle')
then (
'subtitle'
)else ()
};

declare %private function local:author($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'author')
then (
'author'
)else ()
};

declare %private function local:summary($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'summary')
then (
'summary'
)else ()
};

declare %private function local:contributor($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'contributor')
then (
'contributor'
)else ()
};

declare %private function local:origLink($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'origLink')
then (
'origLink'
)else ()
};
declare %private function local:enclosure($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'enclosure')
then (
'enclosure'
)else ()
};

declare %private function local:origEnclosureLink($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'origEnclosureLink')
then (
'origEnclosureLink'
)else ()
};
declare %private function local:encoded($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'encoded')
then (
'encoded'
)else ()
};
declare %private function local:itunes-category($elem as item(), $config as map(*)) {
if(local-name($elem) eq 'encoded')
then (
'encoded'
)else ()
};

declare %privage function local:validate-textnode($node, $message as xs:string*, $messages as item()) {
$messages
};


declare function local:validate-rss-channel($channel as item(), $messages as item()){

local:validate-textnode(channel/title,"title", $messages),
local:atom-link(channel/atom-link,$messages),
local:link($channel/link,$messages),
local:validate-textnode($channel/description, "description", $messages),
local:validate-textnode($channel/lastBuildDate, "lastBuildDate", $messages),
local:validate-textnode($channel/language,"language", $messages),
local:validate-textnode($channel/sy:updatePeriod,"sy:updatePeriod", $messages),
local:validate-textnode($channel/sy:updateFrequency,"sy:updateFrequency", $messages),
local:validate-textnode($channel/generator,"generator", $messages),
local:validate-textnode($channel/itunes:summary,"summary", $messages),
local:validate-textnode($channel/itunes:author,"author", $messages),
local:validate-textnode($channel/itunes:explicit,"explicit", $messages),
local:validate-textnode($channel/itunes:image,"image", $messages),
local:validate-textnode($channel/itunes:owner,"owner", $messages),
local:validate-textnode($channel/itunes:subtitle,"subtitle", $messages),
local:validate-textnode($channel/managingEditor,"managingEditor", $messages),
local:validate-textnode($channel/image,"image", $messages),
local:validate-textnode($channel/itunes:category,"category", $messages)

};


declare function local:validate-rss-feed($feed as item(), $messages as map()){
let $channel :=  $feed/rss/channel

(: checkRSS :)
let $timestamp1 := math:random()
let $checkRss := if(not(exists($feed/rss)))
then (
<error dateTime="{$timestamp1}">Root element 'rss' is missing</error>
)else(
<info dateTime="{$timestamp1}">element '/rss'  is fine</info>
)

let $timestamp2 := math:random()
let $checkChannel := if(not(exists($channel)))
then (
<error dateTime="{$timestamp2}">element '/rss/channel' is missing</error>
)else (
<info dateTime="{$timestamp2}">element '/rss/channel' is fine</info>
)

let $resultMessages := map:new(($messages, map { data($checkRss/@dateTime) := $checkRss, data($checkChannel/@dateTime) := $checkChannel }))
return
(: local:validate-rss-channel($channel, $resultMessages)                :)
$resultMessages



};

let $inputURL := request:get-parameter("feedURL", "")
let $log-in := xmldb:login($config:app-root,$config:user-name, $config:user-pwd)
let $parseFeed :=
try {
let $feedURL := $inputURL cast as xs:anyURI
let $feedPath := feed:store-feed(xs:anyURI($feedURL))
let $feed := doc($feedPath)
let $map := map{}
return
<podcast>
<feed checkedURL="{$inputURL}" dbLocation="{$feedPath}"/>
<messages>
{
let $returnMap : = local:validate-rss-feed($feed, $map)
return
for $messages in map:keys($returnMap)
return
$returnMap($messages)
}
</messages>
</podcast>
} catch * {
<error>ups.. error {$err:code}: {$err:description}</error>
}

return
$parseFeed
