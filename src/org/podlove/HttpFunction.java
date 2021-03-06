package org.podlove;

import org.apache.commons.httpclient.methods.HeadMethod;
import org.exist.dom.QName;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.modules.httpclient.BaseHTTPClientFunction;
import org.exist.xquery.value.NodeValue;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceType;

import java.io.IOException;

/**
 * Created by Lars Windauer
 */

public class HttpFunction extends BaseHTTPClientFunction {

    public final static FunctionSignature signature =
        new FunctionSignature(
            new QName( "http-head", PodloveModule.NAMESPACE_URI, PodloveModule.PREFIX ),
            "Performs a HTTP HEAD request." + " This method returns the HTTP response encoded as an XML fragment, that looks as follows: <httpclient:response  xmlns:httpclient=\"http://exist-db.org/xquery/httpclient\" statusCode=\"200\"><httpclient:headers><httpclient:header name=\"name\" value=\"value\"/>...</httpclient:headers></httpclient:response>",
            new SequenceType[] { URI_PARAM, PERSIST_PARAM, REQUEST_HEADER_PARAM},
            XML_BODY_RETURN
    );

    public HttpFunction(XQueryContext context, FunctionSignature signature) {
        super(context, signature);
    }
    @Override
    public Sequence eval( Sequence[] args, Sequence contextSequence ) throws XPathException
    {
        Sequence response = null;

        // must be a URL
        if( args[0].isEmpty() ) {
            return( Sequence.EMPTY_SEQUENCE );
        }

        //get the url
        String     url            = args[0].itemAt( 0 ).getStringValue();

        //get the persist state
        boolean    persistState   = args[1].effectiveBooleanValue();

        //setup HEAD request
        HeadMethod head           = new HeadMethod( url );

        //setup HEAD Request Headers
        if( !args[2].isEmpty() ) {
            setHeaders( head, ( (NodeValue)args[2].itemAt( 0 ) ).getNode() );
        }

        head.setFollowRedirects(false);

        try { response = doRequest( context, head, persistState, null, null); }
        catch( IOException ioe ) { throw ( new XPathException( this, ioe.getMessage(), ioe ) ); }
        finally { head.releaseConnection(); }

        return( response );
    }


}
