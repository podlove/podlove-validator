xquery version "3.0";


import module namespace config="http://podlove.org/podlove-validator/config" at "config.xqm";
import module namespace schematron="http://podlove.org/podlove-validator/schematron" at "schematron.xqm";

declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xi="http://www.w3.org/2001/XInclude";
declare namespace iso="http://purl.oclc.org/dsdl/schematron" ;
declare namespace relax="http://relaxng.org/ns/structure/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace dtll="http://www.jenitennison.com/datatypes";
declare namespace nvdl="http://purl.oclc.org/dsdl/nvdl";
declare namespace schold="http://www.ascc.net/xml/schematron";
declare namespace crdl="http://purl.oclc.org/dsdl/crepdl/ns/structure/1.0";
declare namespace xslt="http://www.w3.org/1999/XSL/Transform";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace sch-check="http://www.schematron.com/namespace/sch-check";
declare namespace dsdl="http://www.schematron.com/namespace/dsdl";

declare option exist:serialize "method=html media-type=text/html";


let $feed := doc($config:app-root || "/test/nsfw1.xml")

return 
  (: transform:transform($grammar, $dsdl-01-include, $params):)
    schematron:xsl($feed)
