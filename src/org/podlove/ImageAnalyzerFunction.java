package org.podlove;

import org.exist.dom.QName;
import org.exist.memtree.MemTreeBuilder;
import org.exist.xquery.*;
import org.exist.xquery.value.*;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;

/**
 * Created by windauer on 17.04.15.
 */

public class ImageAnalyzerFunction extends BasicFunction {

    public final static FunctionSignature signature =
            new FunctionSignature(
                    new QName( "analyze", PodloveModule.NAMESPACE_URI, PodloveModule.PREFIX ),
                    "A useless example function. It just echoes the input parameters.",
                    new SequenceType[] {
                            new FunctionParameterSequenceType("text",
                                    Type.ANY_URI,
                                    Cardinality.EXACTLY_ONE,
                                    "URL of the image to analyze")
                    },
                    new FunctionReturnSequenceType( Type.ITEM, Cardinality.EXACTLY_ONE, "the XML body content" )
            );

    public ImageAnalyzerFunction( XQueryContext context,FunctionSignature signature  ){
        super( context, signature );
    }


    public Sequence eval( Sequence[] args, Sequence contextSequence ) throws XPathException {
        // is argument the empty sequence?
        if( args[0].isEmpty() ) {
            return( Sequence.EMPTY_SEQUENCE );
        }
        String url = args[0].getStringValue();
        InputStream is = null;
        ArrayList<String> error = new ArrayList();
        // iterate through the argument sequence and echo each item
        try {
            is = new URL(url).openStream();
        }
        catch (IOException e) {
            error.add(e.getLocalizedMessage());
        }
        SimpleImageInfo imageInfo = null;
        try {
            imageInfo = new SimpleImageInfo(is);
        } catch (IOException e) {
            error.add(e.getLocalizedMessage());
        }
        if(error.size() > 0){
            return
                    renderErrorMessage(error,url);
        }else {
            return
                    renderResult(imageInfo,url);
        }
    }

    private Sequence renderResult(SimpleImageInfo imageInfo, String url) {
        String mimeType = imageInfo.getMimeType();
        int width = imageInfo.getWidth();
        int height = imageInfo.getHeight();

        final MemTreeBuilder builder = context.getDocumentBuilder();
        builder.startDocument();
        builder.startElement(new QName("response", PodloveModule.NAMESPACE_URI, PodloveModule.PREFIX), null);
        builder.addAttribute(new QName("statusCode", null, null), "200");
        builder.addAttribute(new QName("url", null, null), url);
        builder.addAttribute(new QName("width", null, null), String.valueOf(width));
        builder.addAttribute(new QName("height", null, null), String.valueOf(height));
        builder.addAttribute(new QName("mimeType", null, null), mimeType);
        builder.endElement();
        builder.endDocument();
        return
                (NodeValue)builder.getDocument().getDocumentElement();
    }

    private Sequence renderErrorMessage(ArrayList<String> errors, String url) {
        final MemTreeBuilder builder = context.getDocumentBuilder();
        builder.startDocument();
        builder.startElement(new QName("response", PodloveModule.NAMESPACE_URI, PodloveModule.PREFIX), null);
        builder.addAttribute(new QName("url", null, null), url);

        for(String error : errors){
            builder.startElement(new QName("response", PodloveModule.NAMESPACE_URI, PodloveModule.PREFIX),null);
            builder.characters(error);
            builder.endElement();
        }
        builder.endElement();
        builder.endDocument();
        return
                (NodeValue)builder.getDocument().getDocumentElement();
    }

}
