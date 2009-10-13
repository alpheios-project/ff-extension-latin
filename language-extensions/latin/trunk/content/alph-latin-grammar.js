/**
 * @fileoverview Javascript functions for the Latin Grammar Window
 * $Id$
 * 
 * Copyright 2008-2009 Cantus Foundation
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

/**
 * @class Latin Grammar window functionality
 */
Alph.Grammar = {
    
   
    BASE_URL: Alph.BrowserUtils.getContentUrl('latin') + '/grammar/',

    /**
     * logger for the window
     * @type Log4Moz.Logger
     * @static
     */
    s_logger: Alph.BrowserUtils.getLogger('Alpheios.Grammar'), 
    
    /**
     * onLoad 
     * load handler for the grammar window
     */
    onLoad: function() {
        var toc_doc = Alph.$("#alph-latin-grammar-toc").get(0).contentDocument;
        var content_browser = Alph.$("#alph-latin-grammar-content");
        
        // Add a handler to main grammar content browser window 
        // which adds a click handler to the links in the grammar
        // content document whenever a new document is loaded
        document.getElementById("alph-latin-grammar-content")
            .addEventListener(
                "DOMContentLoaded",
                function() 
                {
                    Alph.$("a",this.contentDocument)
                        .click(Alph.Grammar.contentClickHandler);
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
            if (typeof params.updateArgsCallback == 'undefined')
            {
                params.updateArgsCallback =
                    function(a_args)
                        {
                            Alph.Grammar.setStartHref(a_args);
                        }
            }
            this.setStartHref(params);            
        }
        
        // Add a click handler to the links in the toc: they set the 
        // src of the alph-latin-grammar-content iframe
        Alph.$("a",toc_doc).click(Alph.Grammar.tocClickHandler);
    
        // hide the subcontents of the toc headings
        Alph.$("div.contents",toc_doc).css("display","none");
        Alph.$("h4.contents",toc_doc).css("display","none");

        
        // Add a click handler to the main toc headings
        Alph.$("h2.contents",toc_doc).click(Alph.Grammar.tocheadClickHandler);
        Alph.$("h2.contents",toc_doc).addClass("contents-closed");

        
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
        var toc_doc = Alph.$("#alph-latin-grammar-toc").get(0).contentDocument;
        var href = Alph.$(this).attr("href");
        var href_target = Alph.Grammar.lookupAnchor(href.substring(1));
        if (href.indexOf('#') == 0 &&
            Alph.$("a[name='"+href+"']").length==0 &&
            typeof href_target != "undefined"
            )
        {
            Alph.$("#alph-latin-grammar-content").attr("src",
                Alph.Grammar.BASE_URL +
                href_target + href
            );
            //TODO we need to do a reload here - if you follow
            // a link from the target and they try to re-access the original
            // toc link, it doesn't work
        }
        Alph.$('.highlighted',toc_doc).removeClass('highlighted');
        Alph.$(this).addClass('highlighted');
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
        var next_h4 = Alph.$(this).next("h4.contents");
        var next_div = Alph.$(this).nextAll("div.contents").slice(0,1);
        if (Alph.$(next_h4).css('display') == 'block' ||
            Alph.$(next_div).css('display') == 'block')
        {
            Alph.$(next_h4).css("display", "none")
            Alph.$(next_div).css("display", "none")
            Alph.$(this).removeClass("contents-open");
            Alph.$(this).addClass("contents-closed");
        }
        else
        {
            Alph.$(next_h4).css("display", "block")
            Alph.$(next_div).css("display", "block")
            Alph.$(this).removeClass("contents-closed");
            Alph.$(this).addClass("contents-open");
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
        var href = Alph.$(this).attr("href");
        var href_target = 
            Alph.Grammar.lookupAnchor(href.substring(1));
        if (href.indexOf('#') == 0 &&
            Alph.$("a[name='"+href+"']").length==0 &&
            typeof href_target != "undefined"
            )
        {
            this.s_logger.debug("Resetting href to " + 
                Alph.Grammar.BASE_URL + 
                href_target + href);
            Alph.$(this).attr("href", 
                Alph.Grammar.BASE_URL + 
                href_target + href);
        } 
        return true;
    },

    /**
     * lookupAnchor
     *   Arguments:
     *      href: an anchor name referenced in url
     *   Returns: a string containing the filename
     *            which contains that anchor
     */
    lookupAnchor: function(href)
    {
        var anchor_map = this.getAnchorMap();
        
        var target;
        if (anchor_map[href] != null)
        {
            target = anchor_map[href][0];
        }
        return target;
    },
    
    /**
     * loadAnchorMap
     * Reads the anchor map file from the file system
     * this maps named anchors to the file in which
     * the anchor is found.
     * Returns the anchor_map object
     */
    loadAnchorMap: function()
    {
        var file_contents = Alph.BrowserUtils.readFile(this.BASE_URL + "anchor_map");
        var anchor_map;
        try 
        {
            eval("anchor_map=" + file_contents);
        } 
        catch(exception)
        {
            this.s_logger.error("Could not process grammar anchor_map: " + exception);
            this.s_logger.error(file_contents);
        }
        
        return anchor_map;
    },
    
    /**
     * getAnchorMap
     * Retrieves the anchor map from the browser's alpheios object
     * Calls loadAnchorMap to load it if it hasn't already been
     * initialized.
     */
    getAnchorMap: function() 
    {
        // if we're running directly in the chrome
        // i.e. for testing, just load and return the anchor map
        if (opener == null) 
        {
            return this.loadAnchorMap();
        }
        var bro = opener.Alph.Main.getCurrentBrowser();
        if (typeof bro.alpheios.latin == "undefined" ||
            typeof bro.alpheios.latin.grammar_anchor_map == "undefined")
        {
            
            // make sure the latin namespace in the alpheios object
            // has been defined
            if (typeof bro.alpheios.latin == "undefined")
            {
                bro.alpheios.latin = {};            
            }
            bro.alpheios.latin.grammar_anchor_map = this.loadAnchorMap();
        }
    
        return bro.alpheios.latin.grammar_anchor_map; 
    },
    
    /**
     * setStartHref - set the location for the content window
     * Arguments:
     *  params: object containing a target_href property 
     *          which specifies the name of the target anchor in the 
     *          grammar
     */
    setStartHref: function(params)
     {
        // pick up the original target href for the grammar from the
        // window arguments
        // otherwise set it to the preface
        // and reset the contents of the grammar content browser
        var start_href = 
                params != null && params.target_href ? 
                params.target_href  : 
                'preface';
        
        var start_href_target = Alph.Grammar.lookupAnchor(start_href);
        if (typeof start_href_target != "undefined")
        {
            Alph.$("#alph-latin-grammar-content").attr("src", 
                Alph.Grammar.BASE_URL + 
                start_href_target + 
                "#" + start_href
            );
        }
     }
}


