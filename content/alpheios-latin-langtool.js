/*
 * @fileoverview Latin extension of Alph.LanguageTool class
 * @version $Id: alpheios-latin-langtool.js 439 2008-03-27 00:26:41Z BridgetAlmas $
 * 
 * Copyright 2008 Cantus Foundation
 * http://alpheios.net
 * 
 * Uses Whitaker's WORDS Latin-English Dictionary Program
 * http://users.erols.com/whitaker/words.htm
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
 * @class  Alph.LanguageToolSet.latin extends {@link Alph.LanguageTool} to define 
 * Latin-specific functionality for the alpheios extension.
 * 
 * @constructor 
 * @param {String} a_language  the source language for this instance
 * @param {Properties} a_properties additional properties to set as private members of 
 *                                  the object (accessor methods will be dynamically created)
 * @see Alph.LanguageTool
 */
Alph.LanguageToolSet.latin = function(a_lang, props) 
{ 
    Alph.LanguageTool.call(this,a_lang,{});
};

/**
 * @ignore
 */
Alph.LanguageToolSet.latin.prototype = new Alph.LanguageTool();

/**
 * Flag to indicate that this class extends Alph.LanguageTool.
 * (Shouldn't be necessary but because they are not packaged in the same extension
 * the instanceof operator won't work.)
 * @type boolean
 */
Alph.LanguageToolSet.latin.implementsAlphLanguageTool = true;

/**
 *  Mapping table which maps the part of speech or mood
 *  to the key name for producing the inflection table
 *  Format is:
 *      pofs or mood: { keys: [array of inflectable table keys]
 *                      links: [array of other links] } 
 */
Alph.LanguageToolSet.latin.INFLECTION_MAP = 
{     noun: { keys: ['noun'], links: [] },
      // link verb participles to both verb and adjective inflection tables
      adjective: { keys: ['adjective'], links: [] },
      verb_participle: { keys: ['verb_participle','adjective'], links: ['verb'] },
      supine: { keys: ['verb_supine'], links: ['verb'] },
      infinitive: { keys: ['verb_infinitive'], links: [] },
      imperative: { keys: ['verb_imperative'], links: [] },
      gerundive: { keys: ['verb_gerundive'],links: [] },
      verb_irregular: { keys: ['verb_irregular'],links: []},
      verb: { keys: ['verb'], links: [] }
};

Alph.LanguageToolSet.latin.IRREG_VERBS =
[
    // irregular verbs (Whitaker hdwd)
    'eo, ire, ivi(ii), itus',
    'fero, ferre, tuli, latus',
    'sum, esse, fui, futurus',
    'possum, posse, potui, -',
    'volo, velle, volui, -',
    'nolo, nolle, nolui, -',
    'malo, malle, malui, -'
];

/**
 * Latin-specific implementation of {@link Alph.LanguageTool#getInflectionTable}.
 * @param {Node} a_node the node containing the target word 
 * @param {String} a_params optional requested parameters 
 * @return the parameters object for the inflection window
 */
Alph.LanguageToolSet.latin.prototype.getInflectionTable = function(a_node, a_params)
{    
    var params = a_params || {};
    
    // initialize the suffix arrays
    // TODO should flip this to be a single object keys on infl_type
    params.suffixes = {};
    params.entries = {};
    params.words = {};
    
    for (var infl_type in Alph.LanguageToolSet.latin.INFLECTION_MAP )
    {
        var key = Alph.LanguageToolSet.latin.INFLECTION_MAP[infl_type].keys[0];
        params.suffixes[key] = [];
        params.entries[key] = [];
        params.words[key] = [];
    }
        
    // The word will have one more more alph-infl-set elements
    // Each alph-infl-set element should have a alph-suffix element
    // and one or more alph-infl elements.  Iterate through the alph-infl-sets
    // retrieving the alph-suffix elements which are applicable to
    // each supported part of speech
    Alph.$(".alph-infl-set",a_node).each(
        function(i)
        {
            var dict = Alph.$(this).siblings(".alph-dict");
            var word = Alph.$(this).attr("context");
            
            // check for the pofs first as a child of this element, and if not present,
            // then from the sibling dictionary entry 
            var my_pofs;
            var infl_pofs = Alph.$(".alph-pofs",this);
            if (infl_pofs.length == 0)
            {
                infl_pofs = Alph.$(".alph-pofs",dict)
            }

            // check for irregular verbs

            var dict_hdwd = Alph.$(".alph-hdwd",dict).text();
            // remove the trailing :
            dict_hdwd = dict_hdwd.replace(/\:\s*$/,'');
            Alph.util.log("hdwd for inflection set: " + dict_hdwd);

            var irregular = false;
            for (var i=0; i< Alph.LanguageToolSet.latin.IRREG_VERBS.length; i++)
            {
                if (dict_hdwd == Alph.LanguageToolSet.latin.IRREG_VERBS[i])
                {
                    // reset the context
                    params.hdwd = dict_hdwd;
                    irregular = true;
                    break;
                }
            }
            Alph.util.log("irregular:" + irregular);
            var infls = {};
                    
            // gather the moods for the verbs
            // TODO - look at handling multiple cases separately for the nouns and adjectives?
            Alph.$(".alph-infl",this).each( 
                function()
                {
                    // some verb moods (infinitive, imperative and gerundive) link to 
                    // a supplemental table rather than primary verb pofs table

                    var mood = Alph.$(".alph-mood",this).attr('context');
                    if (Alph.LanguageToolSet.latin.INFLECTION_MAP[mood])
                    {
                        infls[Alph.LanguageToolSet.latin.INFLECTION_MAP[mood].keys[0]] = Alph.$(this).get(0);
                    }
                }
            );
            if (irregular)
            {
                infls[Alph.LanguageToolSet.latin.INFLECTION_MAP['verb_irregular'].keys[0]] = Alph.$(this).get(0);
            }
            for (var pofs in Alph.LanguageToolSet.latin.INFLECTION_MAP)
            {
                var map_pofs = Alph.LanguageToolSet.latin.INFLECTION_MAP[pofs].keys[0];
                
                
                // if we couldn't find the part of speech or the part of speech
                // isn't one we support then just move on to the next part of speech
                if ( infl_pofs.length == 0 || 
                     (pofs == 'verb_irregular' && ! irregular) ||  // context pofs for irregular verbs is just 'verb'
                     (pofs != 'verb_irregular' && Alph.$(infl_pofs[0]).attr("context") != pofs)
                   )
                {
                    continue;
                }
                
                // make sure we look at at least the first inflection from
                // this inflection set. If we need to look at multiple inflections they
                // will already have been identified above.
                // this will also add in a general verb inflection for those verbs which use a supplemental table 
                if (! infls[map_pofs] ) 
                {
                    infls[map_pofs] = Alph.$(".alph-infl",this).get(0)
                }

                for (var infl_type in infls)
                {
                    
                    // if a particular pofs wasn't requested
                    // and this is the first pofs processed, set it
                    // as the default
                    if (typeof params.showpofs == 'undefined')
                    {
                        params.showpofs = infl_type;
                    }
                    params.suffixes[infl_type].push(
                        Alph.$(".alph-suff",this).get());
                        
                    params.entries[infl_type].push(
                        Alph.$(this).parent(".alph-entry").get(0));
                        
                    params.words[infl_type][word]=1;

                    // duplicate suffixes if necessary
                    var num_pofs = Alph.LanguageToolSet.latin.INFLECTION_MAP[pofs].keys.length; 
                    for (var i=1; i<num_pofs; i++)
                    {
                        var extra_pofs = Alph.LanguageToolSet.latin.INFLECTION_MAP[pofs].keys[i];
                        params.suffixes[extra_pofs].push(
                        Alph.$(".alph-suff",this).get());
                    }
                    
                    // identify the correct file and links for the inflection type
                    // being displayed
                    // TODO - this doesn't work right if multiple different possibilities
                    // of the same pofs (e.g. look at estote). Handle differently.
                    
                    if (params.showpofs == infl_type)
                    {
                        params.links = Alph.LanguageToolSet.latin.INFLECTION_MAP[pofs].links;
                        //Alph.LanguageToolSet.latin.setInflectionXSL(params,infl_type,pofs,a_node,Alph.$(this).get(0));
                    }
                    
                } // end infl-type                
            }
        }
    );
    // identify the correct xslt parameters for the requested inflection type
    if (params.showpofs)
    {
        Alph.LanguageToolSet.latin.setInflectionXSL(params,params.showpofs);
    }
    return params;
}

/**
 * Helper method to set the XML/XSLT params for the inflection table
 * @param {String} a_params the other params for the window
 * @param {String} a_infl_type the inflection type
 */
Alph.LanguageToolSet.latin.setInflectionXSL = function(a_params,a_infl_type)
{
    // TODO still need to link to big verb table
        
    a_params.xslt_params = {};
    a_params.xslt_params.fragment = 1;
    a_params.xslt_params.selected_endings = a_params.entries[a_infl_type];
    
    // get rid of the selected endings parameter if we couldn't find any
    if (typeof a_params.xslt_params.selected_endings == "undefined" 
        || a_params.xslt_params.selected_endings.length == 0)
    {
        delete a_params.xslt_params.selected_endings;
    }

    if (a_infl_type == 'verb_irregular')
    {
        a_params.xml_url = 'chrome://alpheios-latin/content/inflections/alph-verb-conj-irreg.xml';
        a_params.xslt_url = 'chrome://alpheios-latin/skin/alph-verb-conj-irreg.xsl';
        a_params.xslt_params.hdwd = a_params.hdwd;
    }
    else if ( a_infl_type.indexOf('verb_') == 0 )
    {
        a_params.xml_url = 'chrome://alpheios-latin/content/inflections/alph-verb-conj-supp.xml';
        a_params.xslt_url = 'chrome://alpheios-latin/skin/alph-verb-conj-supp.xsl';

        var mood = (a_infl_type.split(/_/))[1];
        a_params.xslt_params.mood = mood;    
                                 
    }
    else if ( a_infl_type == 'verb' )
    {
        a_params.xml_url = 'chrome://alpheios-latin/content/inflections/alph-verb-conj.xml';
        a_params.xslt_url = 'chrome://alpheios/skin/alph-verb-conj-group.xsl';        

        if (! a_params.order )
        {
            // default sort order
            a_params.order = "voice-conj-mood";
        }

        var order = a_params.order.split('-');
        if (order.length > 0)
        {
            a_params.xslt_params.group4 = order[0];
            a_params.xslt_params.group5 = order[1];
            a_params.xslt_params.group6 = order[2];
        }
    }
    else
    {
        a_params.xml_url =
            'chrome://alpheios-latin/content/inflections/alph-infl-' + a_infl_type + '.xml';
        a_params.xslt_url = 'chrome://alpheios/skin/alph-infl-substantive.xsl';
        a_params.xslt_params.strip_greek_vowel_length = false;

        // wordsxml outputs suffixes in ascii so we need to transliterate
        // the unicode in the ending tables for matching
        a_params.xslt_params.translit_ending_table_match = true;
        
        a_params.xslt_params.match_pofs = a_infl_type;

        if (a_params.order )
        {

            var order = a_params.order.split('-');
            if (order.length > 0)
            {
                a_params.xslt_params.group4 = order[0];
                a_params.xslt_params.group5 = order[1];
                a_params.xslt_params.group6 = order[2];
            }
        }

    }

}