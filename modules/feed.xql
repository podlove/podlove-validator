xquery version "3.0";

import module namespace config="http://podlove.org/podlove-matrix/config" at "config.xqm";

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

declare function local:http-download($file-url as xs:string, $collection as xs:string) as item()* {
    let $request := <http:request href="{$file-url}" method="GET"/>
    let $response := http:send-request($request)
    let $head := $response[1]
    
    (: These sample responses from EXPath HTTP client reveals where the response code, media-type, and filename can be found: 
    
        <http:response xmlns:http="http://expath.org/ns/http-client" status="200"  message="OK">
            <http:header name="connection"  value="close"/>
            <http:header name="transfer-encoding"  value="chunked"/>
            <http:header name="content-type"  value="application/zip"/>
            <http:header name="content-disposition"  value="attachment; filename=xqjson-master.zip"/>
            <http:header name="date"  value="Sat, 06 Jul 2013 05:59:04 GMT"/>
            <http:body media-type="application/zip"/>
        </http:response>
        
        <http:response xmlns:http="http://expath.org/ns/http-client" status="200"  message="OK">
            <http:header name="date"  value="Sat, 06 Jul 2013 06:26:34 GMT"/>
            <http:header name="server"  value="GitHub.com"/>
            <http:header name="content-type"  value="text/plain; charset=utf-8"/>
            <http:header name="status"  value="200 OK"/>
            <http:header name="content-disposition"  value="inline"/>
            <http:header name="content-transfer-encoding"  value="binary"/>
            <http:header name="etag"  value=""a6782b6125583f16632fa103a828fdd6""/>
            <http:header name="vary"  value="Accept-Encoding"/>
            <http:header name="cache-control"  value="private"/>
            <http:header name="keep-alive"  value="timeout=10, max=50"/>
            <http:header name="connection"  value="Keep-Alive"/>
            <http:body media-type="text/plain"/>
        </http:response>
    :)
    
    return
        (: check to ensure the remote server indicates success :)
        if ($head/@status = '200') then
            (: try to get the filename from the content-disposition header, otherwise construct from the $file-url :)
            let $filename := 
                if (contains($head/http:header[@name='content-disposition']/@value, 'filename=')) then 
                    $head/http:header[@name='content-disposition']/@value/substring-after(., 'filename=')
                else 
                    (: use whatever comes after the final / as the file name:)
                    replace($file-url, '^.*/([^/]*)$', '$1')
            (: override the stated media type if the file is known to be .xml :)
            let $media-type := $head/http:body/@media-type
            let $mime-type := 
                if (ends-with($file-url, '.xml') and $media-type = 'text/plain') then
                    'application/xml'
                else 
                    $media-type
            (: if the file is XML and the payload is binary, we need convert the binary to string :)
            let $content-transfer-encoding := $head/http:body[@name = 'content-transfer-encoding']/@value
            let $body := $response[2]
            let $file := 
                if (ends-with($file-url, '.xml') and $content-transfer-encoding = 'binary') then 
                    util:binary-to-string($body) 
                else 
                    $body
            return
                xmldb:store($collection, $filename, $file, $mime-type)
        else
            <error><message>Oops, something went wrong:</message>{$head}</error>
};


declare function local:get-feed-data($feedURI as xs:anyURI) {
        let $data :=  httpclient:get($feedURI,false(), ())
        return $data
};



let $data-root := $config:app-root || "/data/postcast"

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
                let $data := local:get-feed-data(xs:anyURI($feed/text()))
                let $name := util:uuid($feed/text()) || ".xml"
                let $stored := xmldb:store($data-root, $name, $data)
                    return <stored dir="{$data-root}" resource="{$name}"/>
        }
</result>

