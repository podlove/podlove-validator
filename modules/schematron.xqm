xquery version "3.0";

module namespace schematron="http://podlove.org/podlove-matrix/schematron";
import module namespace config="http://podlove.org/podlove-matrix/config" at "config.xqm";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

declare function schematron:report($feed as item()){
    let $grammar :=    doc($config:app-root || "/resources/schematron/podlove.xml")
    return 
      validation:jing-report($feed, $grammar)    
};


