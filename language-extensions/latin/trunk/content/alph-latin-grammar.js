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
Alph.LatinGrammar = {
    
   
    BASE_URL: Alph.BrowserUtils.getContentUrl('latin') + '/grammar/',

    /**
     * initialize the table of contents
     */
    tocInit: function() {
        var toc_doc = Alph.$("#alph-grammar-toc").get(0).contentDocument;
        
        // Add a click handler to the links in the toc: they set the 
        // src of the alph-latin-grammar-content iframe
        Alph.$("a",toc_doc).click(Alph.LatinGrammar.tocClickHandler);
    
        // hide the subcontents of the toc headings
        Alph.$("div.contents",toc_doc).css("display","none");
        Alph.$("h4.contents",toc_doc).css("display","none");

        
        // Add a click handler to the main toc headings
        Alph.$("h2.contents",toc_doc).click(Alph.LatinGrammar.tocheadClickHandler);
        Alph.$("h2.contents",toc_doc).addClass("contents-closed");

        
    },
    
    /**
     * tocClickHandler
     * Click handler for links in the toc frame. Set the src
     * of the alph-latin-grammar-content browser.
     */
    tocClickHandler: function(e)
    {
        var toc_doc = Alph.$("#alph-grammar-toc").get(0).contentDocument;
        var href = Alph.$(this).attr("href");        
        // if the target of the link isn't found in the toc itself, look for it in the content
        if (href.indexOf('#') == 0 && Alph.$("a[name='"+href+"']").length==0)
        {
            var href_target = Alph.TeiGrammar.d_indexFile.findData(href.substring(1));
            if (href_target)
            {
                // if multiple matches found, exact match should be 1st
                var exact_match = href_target.split(/\n/)[0];
                href_target = exact_match.split(Alph.TeiGrammar.d_indexFile.getSeparator(),2)[1];
                Alph.$("#alph-grammar-content").attr("src",
                    Alph.LatinGrammar.BASE_URL +
                    href_target + href
                );
                //TODO we need to do a reload here - if you follow
                // a link from the target and they try to re-access the original
                // toc link, it doesn't work
            }
        }
        Alph.$('.highlighted',toc_doc).removeClass('highlighted');
        Alph.$(this).addClass('highlighted');
        return true;
    },
    
    /**
     * contentClickHandler
     * Click handler to redirect anchor links in source content to the
     * appropriate target file of the chunked grammar
     */
    contentClickHandler: function(e)
    {
        var href = Alph.$(this).attr("href");
        if (href.indexOf('#') == 0 && Alph.$("a[name='"+href+"']").length==0)            
        {
            var href_target = Alph.TeiGrammar.d_indexFile.findData(href.substring(1));
            if (href_target)
            {
                // if multiple matches found, exact match should be 1st
                var exact_match = href_target.split(/\n/)[0];
                href_target = exact_match.split(Alph.TeiGrammar.d_indexFile.getSeparator(),2)[1];
                Alph.$(this).attr("href", 
                    Alph.LatinGrammar.BASE_URL + 
                    href_target + href);
            }
        } 
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
      
    }    
}


