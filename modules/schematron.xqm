xquery version "3.0";

module namespace schematron="http://podlove.org/podlove-validator/schematron";
import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";

declare namespace psc="http://podlove.org/simple-chapters";
declare namespace fh="http://purl.org/syndication/history/1.0";
declare namespace feedburner="http://rssnamespace.org/feedburner/ext/1.0";
declare namespace itunes="http://www.itunes.com/dtds/podcast-1.0.dtd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace content="http://purl.org/rss/1.0/modules/content/";

declare function schematron:report($feed as item()){
    let $grammar :=    doc($config:app-root || "/resources/schematron/podlove-ascc.xml")
    return 
      validation:jing-report($feed, $grammar)    
};

declare function schematron:xsl($feed as item()) {
    
    let $xsltroot := $config:app-root || "/resources/xsl/"
    let $dsdlinclude := doc($xsltroot || "iso_dsdl_include.xsl")
    let $iso-abstract := doc($xsltroot || "iso_abstract_expand.xsl")
    let $iso-svrl-for-xslt2 := doc($xsltroot || "iso_svrl_for_xslt2.xsl")


    let $grammar := doc($config:app-root || "/resources/schematron/podlove.xml")
    
    (: transform:transform($grammar, $dsdl-01-include, $params):)
    let $doc1 := transform:transform($grammar, $dsdlinclude, ())
    let $doc2 := transform:transform($doc1, $iso-abstract, ())
    let $doc3 := transform:transform($doc2, $iso-svrl-for-xslt2, ()) 
    let $result := transform:transform($feed, $doc3, ())
    return 
        $result
};
