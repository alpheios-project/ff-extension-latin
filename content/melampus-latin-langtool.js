/*
 * @fileoverview Latin extension of MP.LanguageTool class
 * @version $Id: melampus-latin-langtool.js 439 2008-03-27 00:26:41Z BridgetAlmas $
 * 
 * Copyright 2008 Cantus Foundation
 * http://alpheios.net
 * 
 * Uses Whitaker's WORDS Latin-English Dictionary Program
 * http://users.erols.com/whitaker/words.htm
 * 
 * This file is part of Melampus.
 * 
 * Melampus is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Melampus is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @class  MP.LanguageToolSet.latin extends {@link MP.LanguageTool} to define 
 * Latin-specific functionality for the melampus extension.
 * 
 * @constructor 
 * @param {String} a_language  the source language for this instance
 * @param {Properties} a_properties additional properties to set as private members of 
 *                                  the object (accessor methods will be dynamically created)
 * @see MP.LanguageTool
 */
MP.LanguageToolSet.latin = function(a_lang, props) 
{ 
    MP.LanguageTool.call(this,a_lang,{});
};

/**
 * @ignore
 */
MP.LanguageToolSet.latin.prototype = new MP.LanguageTool();

/**
 * Flag to indicate that this class extends MP.LanguageTool.
 * (Shouldn't be necessary but because they are not packaged in the same extension
 * the instanceof operator won't work.)
 * @type boolean
 */
MP.LanguageToolSet.latin.implementsMPLanguageTool = true;

/**
 * Latin-specific implementation of {@link MP.LanguageTool#getInflectionTable}.
 * @param {Node} a_node the node containing the target word 
 * @param {String} a_params optional requested parameters 
 * @return the parameters object for the inflection window
 */
MP.LanguageToolSet.latin.prototype.getInflectionTable = function(a_node, a_params)
{    
    MP.util.log("Getting inflections table information for " + a_params.word);
    var params = a_params || {};
    params.suffixes = { noun: [],
                        adjective: [],
                        verb: [],
                        verb_participle: [],
                        verb_supine: [],
                        verb_infinitive: [],
                        verb_imperative: [],
                        verb_gerundive: []
                      };
    
    var supported_pofs = 
        { noun: ['noun'],
          verb_participle: ['verb_participle','adjective'],
          adjective: ['adjective'],
          verb: ['verb'],
          supine: ['verb_supine'],
          infinitive: ['verb_infinitive'],
          imperative: ['verb_imperative'],
          gerundive: ['verb_gerundive']
        };

        
    // The word will have one more more mp-infl-set elements
    // Each mp-infl-set element should have a mp-suffix element
    // and one or more mp-case elements.  Iterate through the mp-infl-sets
    // retrieving the mp-suffix elements which are applicable to
    // each supported case
    $(".mp-infl-set",a_node).each(
        function(i)
        {
            for (var pofs in supported_pofs)
            {
                var map_pofs = supported_pofs[pofs][0];
                
                // check for the pofs first as a child of this element, and if not present,
                // then from the sibling dictionary entry 
                var my_pofs;
                var infl_pofs = $(".mp-pofs",this);
                if (infl_pofs.length == 0)
                {
                    var dict = $(this).siblings(".mp-dict");
                    infl_pofs = $(".mp-pofs",dict)
                }
                 
                if ( infl_pofs.length > 0 && $(infl_pofs[0]).attr("context") == pofs)
                {
                    // if a particular pofs wasn't requested
                    // and this is the first pofs processed, set it
                    // as the default
                    if (typeof params.showpofs == 'undefined')
                    {
                        params.showpofs = map_pofs;
                    }
                    params.suffixes[map_pofs].push(
                        $(".mp-suff",this).get());

                    // duplicate suffixes if necessary
                    var num_pofs = supported_pofs[pofs].length; 
                    for (var i=1; i<num_pofs; i++)
                    {
                        var extra_pofs = supported_pofs[pofs][i];
                        params.suffixes[extra_pofs].push(
                        $(".mp-suff",this).get());
                    }
                    
                    // identify the correct file for the pofs
                    if (params.showpofs == map_pofs)
                    {   
                        // TODO get correct file for verb  
                        // check list of irregular verbs, and use that if applicable
                        // check if one of infinitive, imperative, gerundive, supine, participle 
                        // otherwise regular verb table
                        // verb participle -- verb conj table with link to adj declension
                        if (map_pofs.indexOf('verb') == 0)
                        {
                            params.xslt_params = {};
                            params.xslt_params.fragment = 1;
                            params.xslt_params.selected_endings = [];
                            if (pofs == 'verb_participle' || pofs == 'supine')
                            {
                                $(".mp-pofs[context=" + pofs + "]", a_node).parents(".mp-entry").each(
                                    function() 
                                    {
                                        params.xslt_params.selected_endings.push($(this).get(0));
                                    }
                                );
                            } else
                            {
                                    
                                $(".mp-pofs[context='verb']", a_node).parents(".mp-entry").each(
                                    function() 
                                    {
                                        params.xslt_params.selected_endings.push($(this).get(0));
                                    }
                                );
                            }
                            
                            if ( map_pofs.indexOf('verb_') == 0 )
                            {
                                params.xml_url = 'chrome://melampus-latin/content/inflections/mp-verb-conj-supp.xml';
                                params.xslt_url = 'chrome://melampus-latin/skin/mp-verb-conj-supp.xsl';
                                var mood = $(".mp-mood",this).attr('context') || pofs;
                                // supines and participles don't have the .mp-mood element so need to pick
                                // up from part of speech, removing the prefix verb_
                                if (mood.indexOf('_') != -1)
                                {
                                    mood = (mood.split(/_/))[1];
                                }
                                params.xslt_params.mood = mood;
                                // add the case as a sort critera for gerundive and supine
                                if (mood == 'gerundive' || mood == 'supine')
                                {
                                    params.xslt_params.group1 = 'case';
                                }                                 
                            }
                            else
                            {
                                params.xml_url = 'chrome://melampus-latin/content/inflections/mp-verb-conj.xml';
                                params.xslt_url = 'chrome://melampus/skin/mp-verb-conj-group.xsl';        
            
                                if (typeof params.order == "undefined")
                                {   
                                    // default sort order
                                    params.order = "voice-conj-mood";
                                }
                                var order = params.order.split('-');
                                if (order.length > 0)
                                {
                                    params.xslt_params.group4 = order[0];
                                    params.xslt_params.group5 = order[1];
                                    params.xslt_params.group6 = order[2];
                                }
                            }
                        }   
                    }
                }                
            }
        }
    );
    return params;
}