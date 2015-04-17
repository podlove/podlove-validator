package org.podlove;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;

import java.util.List;
import java.util.Map;

/**
 * Created by windauer on 14.04.15.
 */
public class PodloveModule extends AbstractInternalModule {

    public final static String NAMESPACE_URI = "http://podlove.org/ns/PodloveModule";
    public final static String PREFIX = "podlove";
    public final static String DESCRIPTION = "A module for performing http head request with 'followRedirect=false'";
    public final static String RELEASED_IN_VERSION = "eXist-2.2";

    private final static FunctionDef[] functions = {
            new FunctionDef(HttpFunction.signature, HttpFunction.class),
            new FunctionDef(ImageAnalyzerFunction.signature, ImageAnalyzerFunction.class)
    };

    public PodloveModule(Map<String, List<? extends Object>> parameters) {
        super(functions, parameters);
    }

    @Override
    public String getNamespaceURI() {
        return NAMESPACE_URI;
    }

    @Override
    public String getDefaultPrefix() {
        return PREFIX;
    }

    @Override
    public String getDescription() {
        return DESCRIPTION;
    }

    @Override
    public String getReleaseVersion() {
        return RELEASED_IN_VERSION;
    }
}
