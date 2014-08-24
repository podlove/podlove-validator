import module namespace http = "http://expath.org/ns/http-client";
 
(: credentials :)
declare variable $username := 'guest';
declare variable $password := 'guest';
 
(: document to retrieve, and document to upload :)
declare variable $in  := '/db/tmp/in.xml';
 
(: URI of the REST interface of eXist instance :)
declare variable $rest := 'http://localhost:8080/exist/rest';
 
let $req := <http:request href="http://feedproxy.google.com/~r/raumzeit-podcast/~5/hfHTvKMz5Ew/raumzeit-zwischenruf.m4a"
                method="head"
                send-authorization="false"/>
return
  http:send-request($req)