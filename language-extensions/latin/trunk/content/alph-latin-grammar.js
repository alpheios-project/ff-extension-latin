/*
 * Javascript functions for the Latin Grammar Window
 * $Id$
 * 
 * Copyright 2008 Cantus Foundation
 * http://alpheios.net
 * 
 * This file is part of Alpheios.
 * 
 * Alpheios is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Alpheios is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// initialize the Alph namespace
if (typeof Alph == "undefined") {
    Alph = {};
}

Alph.grammar = {
    
    BASE_URL: 'chrome://alpheios-latin/content/grammar/',

    /**
     * onLoad 
     * load handler for the grammar window
     */
    onLoad: function() {
        var toc_doc = $("#alph-latin-grammar-toc").get(0).contentDocument;
        var content_browser = $("#alph-latin-grammar-content");
        
        // Add a handler to main grammar content browser window 
        // which adds a click handler to the links in the grammar
        // content document whenever a new document is loaded
        document.getElementById("alph-latin-grammar-content")
            .addEventListener(
                "DOMContentLoaded",
                function() 
                {
                    $("a",this.contentDocument)
                        .click(Alph.grammar.contentClickHandler);
                },
                true
                );

        // check the window arguments
        var params;
        if (typeof window.arguments != "undefined")
        {
            params=window.arguments[0];   

            // add a callback to the parameters object
            // which can be called by the opener code 
            // to reload the window with new arguments
            if (typeof params.update_args_callback == 'undefined')
            {
                params.update_args_callback =
                    function(a_args)
                        {
                            Alph.grammar.set_start_href(a_args);
                        }
            }
            this.set_start_href(params);            
        }
        
        // Add a click handler to the links in the toc: they set the 
        // src of the alph-latin-grammar-content iframe
        $("a",toc_doc).click(Alph.grammar.tocClickHandler);
    
        // hide the subcontents of the toc headings
        $("div.contents",toc_doc).css("display","none");
        $("h4.contents",toc_doc).css("display","none");

        
        // Add a click handler to the main toc headings
        $("h2.contents",toc_doc).click(Alph.grammar.tocheadClickHandler);
        $("h2.contents",toc_doc).addClass("contents-closed");

        
        // if a callback function was passed in in the window
        // arguments, execute it
        if (params && typeof params.callback == 'function') {
            params.callback();
        }
    },
    
    /**
     * tocClickHandler
     * Click handler for links in the toc frame. Set the src
     * of the alph-latin-grammar-content browser.
     */
    tocClickHandler: function(e)
    {
        var toc_doc = $("#alph-latin-grammar-toc").get(0).contentDocument;
        var href = $(this).attr("href");
        var href_target = Alph.grammar.lookup_anchor(href.substring(1));
        if (href.indexOf('#') == 0 &&
            $("a[name='"+href+"']").length==0 &&
            typeof href_target != "undefined"
            )
        {
            $("#alph-latin-grammar-content").attr("src",
                Alph.grammar.BASE_URL +
                href_target + href
            );
            //TODO we need to do a reload here - if you follow
            // a link from the target and they try to re-access the original
            // toc link, it doesn't work
        }
        $('.highlighted',toc_doc).removeClass('highlighted');
        $(this).addClass('highlighted');
        return true;
    },

    /**
     * tocheadClickHandler
     * Click handler for the toc headings. hides/shows the 
     * items below that heading
     */
    tocheadClickHandler: function(e)
    {
        // hide/show the next sibling div.contents
        var next_h4 = $(this).next("h4.contents");
        var next_div = $(this).nextAll("div.contents").slice(0,1);
        if ($(next_h4).css('display') == 'block' ||
            $(next_div).css('display') == 'block')
        {
            $(next_h4).css("display", "none")
            $(next_div).css("display", "none")
            $(this).removeClass("contents-open");
            $(this).addClass("contents-closed");
        }
        else
        {
            $(next_h4).css("display", "block")
            $(next_div).css("display", "block")
            $(this).removeClass("contents-closed");
            $(this).addClass("contents-open");
        }
        
        // prevent event propagation
        return false;
      
    },
    
    /**
     * contentClickHandler
     * Click handler to redirect anchor links in source content to the
     * appropriate target file of the chunked grammar
     */
    contentClickHandler: function(e)
    {
        var href = $(this).attr("href");
        var href_target = 
            Alph.grammar.lookup_anchor(href.substring(1));
        if (href.indexOf('#') == 0 &&
            $("a[name='"+href+"']").length==0 &&
            typeof href_target != "undefined"
            )
        {
            window.opener.Alph.util.log("Resetting href to " + 
                Alph.grammar.BASE_URL + 
                href_target + href);
            $(this).attr("href", 
                Alph.grammar.BASE_URL + 
                href_target + href);
        } 
        return true;
    },

    /**
     * lookup_anchor
     *   Arguments:
     *      href: an anchor name referenced in url
     *   Returns: a string containing the filename
     *            which contains that anchor
     */
    lookup_anchor: function(href)
    {
        var anchor_map = this.get_anchor_map();
        
        var target;
        if (anchor_map[href] != null)
        {
            target = anchor_map[href][0];
        }
        return target;
    },
    
    /**
     * load_anchor_map
     * Reads the anchor map file from the file system
     * this maps named anchors to the file in which
     * the anchor is found.
     * Returns the anchor_map object
     */
    load_anchor_map: function()
    {
        window.opener.Alph.util.log("Reading latin grammar anchor map from file system");
        var io_service = 
            Components.classes["@mozilla.org/network/io-service;1"]
            .getService(Components.interfaces.nsIIOService);
        var input_stream = 
            Components.classes["@mozilla.org/scriptableinputstream;1"]
            .getService(Components.interfaces.nsIScriptableInputStream);
        var channel = io_service.newChannel(
            this.BASE_URL + "anchor_map", null, null);
        var input = channel.open();
        input_stream.init(input);
        var buffer = input_stream.read(input.available());
        input_stream.close();
        input.close();
        var anchor_map;
        try 
        {
            eval("anchor_map=" + buffer);
        } 
        catch(exception)
        {
            window.opener.Alph.util.log("Could not process grammar anchor_map: " + exception);
            window.opener.Alph.util.log(buffer);
        }
        
        return anchor_map;
    },
    
    /**
     * get_anchor_map
     * Retrieves the anchor map from the browser's alpheios object
     * Calls load_anchor_map to load it if it hasn't already been
     * initialized.
     */
    get_anchor_map: function() 
    {
        // if we're running directly in the chrome
        // i.e. for testing, just load and return the anchor map
        if (opener == null) 
        {
            return this.load_anchor_map();
        }
        var bro = opener.Alph.main.getCurrentBrowser();
        if (typeof bro.alpheios.latin == "undefined" ||
            typeof bro.alpheios.latin.grammar_anchor_map == "undefined")
        {
            
            // make sure the latin namespace in the alpheios object
            // has been defined
            if (typeof bro.alpheios.latin == "undefined")
            {
                bro.alpheios.latin = {};            
            }
            bro.alpheios.latin.grammar_anchor_map = this.load_anchor_map();
        }
    
        return bro.alpheios.latin.grammar_anchor_map; 
    },
    
    /**
     * set_start_href - set the location for the content window
     * Arguments:
     *  params: object containing a target_href property 
     *          which specifies the name of the target anchor in the 
     *          grammar
     */
    set_start_href: function(params)
     {
        // pick up the original target href for the grammar from the
        // window arguments
        // otherwise set it to the preface
        // and reset the contents of the grammar content browser
        var start_href = 
                params != null && params.target_href ? 
                params.target_href  : 
                'preface';
        
        var start_href_target = Alph.grammar.lookup_anchor(start_href);
        if (typeof start_href_target != "undefined")
        {
            $("#alph-latin-grammar-content").attr("src", 
                Alph.grammar.BASE_URL + 
                start_href_target + 
                "#" + start_href
            );
        }
     }
}


