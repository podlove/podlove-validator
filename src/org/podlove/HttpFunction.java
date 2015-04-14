package org.podlove;

import org.apache.commons.httpclient.methods.HeadMethod;
import org.exist.dom.QName;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.modules.httpclient.BaseHTTPClientFunction;
import org.exist.xquery.value.*;

import java.io.IOException;

/**
 * Created by Lars Windauer
 */

public class HttpFunction extends BaseHTTPClientFunction {

    protected static final FunctionParameterSequenceType HTTP_PARAM = new FunctionParameterSequenceType( "http-params", Type.ELEMENT, Cardinality.ZERO_OR_ONE, "Any HTTP Params" );

    public final static FunctionSignature signature = new FunctionSignature(
            new QName( "head", HttpModule.NAMESPACE_URI, HttpModule.PREFIX ),
            "Performs a HTTP HEAD request." + " This method returns the HTTP response encoded as an XML fragment, that looks as follows: <httpclient:response  xmlns:httpclient=\"http://exist-db.org/xquery/httpclient\" statusCode=\"200\"><httpclient:headers><httpclient:header name=\"name\" value=\"value\"/>...</httpclient:headers></httpclient:response>",
            new SequenceType[] {
                    URI_PARAM, PERSIST_PARAM, REQUEST_HEADER_PARAM,HTTP_PARAM
            },
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
        if(args.length == 4 && !args[3].isEmpty() ) {
            head.setFollowRedirects(false);
            // head.setDoAuthentication();
            // head.setPath();
            // head.setQueryString();
        }
        try {
            //execute the request
            response = doRequest(context, head, persistState, null, null);
        }
        catch( IOException ioe ) {
            throw( new XPathException( this, ioe.getMessage(), ioe ) );
        }
        finally {
            head.releaseConnection();
        }

        return( response );
    }
}
