xquery version "3.0";

import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

 
let $schema := doc($config:app-root || '/test/podlove.xsd')
let $xml-valid := doc($config:app-root || '/test/nsfw1.xml')

return
    <DemoValidation timestamp="{current-dateTime()}" schema="{document-uri($schema)}">
        <Validate uri="{document-uri($xml-valid)}">
        {
            validation:validate-report($xml-valid, $schema)
        }
        </Validate>
    </DemoValidation>
