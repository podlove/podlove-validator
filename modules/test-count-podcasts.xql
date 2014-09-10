xquery version "3.0";

import module namespace config="http://podlove.org/podlove-matrix/config" at "config.xqm";

count(collection($config:podcast-root)/*[1])
