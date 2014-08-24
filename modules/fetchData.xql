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
    
let $data := doc($data-root || "nsfw1.xml")//rss
let $channel := $data//channel

let $convertToPodlove := 
    <podcast timestamp="{current-dateTime()}" xml:lang="{$channel/language}">
        <title>{$channel/title/text()}</title>
        <description>{$channel/description/text()}</description>
        <links>
            {$channel/link},{$channel/atom:link},
        </links>
        <logo>{data($channel/itunes:image/@href)}</logo>
        <categories>
            <category>Tech News</category>
        </categories>
        <keywords></keywords>
        <explicit>{$channel/itunes:explicit/text()}</explicit>
        <credit>
            <person role="owner">
                <name>{$channel/itunes:owner/itunes:name/text()}</name>
                <email>{$channel/itunes:owner/itunes:email/text()}</email>
            </person>
        </credit>
        {
            for $item in $channel
                return
                    <item uuid="">
                        <title>Denk nicht in Layern, denk in Schichten</title>
                        <subtitle></subtitle>
                        <description>Der re:publica 14 ist eine längere Pause geschuldet aber dafür bieten wir auch einen ersten Rückblick auf die Veranstaltung. Clemens war wieder für das Netzwerk zuständig und berichtet vom Aufbau, Debugging und Performance des Netzwerks. Etwas gelangweilt setzen wir uns ein wenig mit Apple auseinander und grübeln über eine mögliche Zukunft von App.net nachdem die Zeichen der Plattform eher auf Sturm stehen und viele schon die Geier kreisen sehen.</description>
                        <link role="deeplink">http://freakshow.fm/fs132-denk-nicht-in-layern-denk-in-schichten</link>
                
                        <pubDate>2014-01-01T12:12:12</pubDate>
                        <duration></duration>
                        <chapters version="1.2">
                            <chapter start="00:00:00.000" title="Intro"/>
                            <chapter start="00:05:30.000" title="Intellektueller Verkehrsunfall"/>
                            <chapter start="00:26:22.000" title="Wer heult, hat recht"/>
                            <chapter start="00:36:30.000" title="Europawahl, Weltraumfahrstuhl, MLPD"/>
                            <chapter start="01:15:28.000" title="Erfindungen"/>
                            <chapter start="01:38:55.000" title="Salbungen"/>
                            <chapter start="01:43:03.000" title="Zach Anner"/>
                            <chapter start="02:01:43.000" title="Geschenke 1"/>
                            <chapter start="02:08:32.000" title="Modem-Dialup-Visualisierung"/>
                            <chapter start="02:18:25.000" title="Geschenke 2"/>
                            <chapter start="02:39:46.000" title="Archäologie und Unterwäsche"/>
                            <chapter start="02:49:22.000" title="Verkehr"/>
                            <chapter start="02:56:53.000" title="Geschenke 3"/>
                            <chapter start="03:07:55.000" title="Hörerinnengrillen"/>
                            <chapter start="03:12:58.000" title="Outro"/>
                        </chapters>
                        <content></content>
                
                        <credit>
                            <person>
                                <name>Tim Pritlove</name>
                                <email>tim@pritlove.de</email>
                                <role>speaker</role>
                            </person>
                        </credit>
                    </item>                    
        }
    </podcast>
        
return
    $convertToPodlove
    
    
    