/**
 * @fileoverview Latin specific string conversion methods 
 * Exports a single symbol, ConvertLatin which must be imported into the namespace 
 * of the importing class.
 *
 * @version $Id$
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
 
const EXPORTED_SYMBOLS = ['ConvertLatin'];
Components.utils.import("resource://alpheios/alpheios-browser-utils.jsm");
Components.utils.import("resource://alpheios/alpheios-convert.jsm");

/**
 * @class Latin  string conversion class
 * @extends Convert
 */
ConvertLatin = function()
{
    Convert.call(this);
}

ConvertLatin.prototype = new Convert();

/**
 * latin ascii transliteration
 * @param {String} a_str the string to convert
 * @returns the converted string
 * @type {String}
 */
ConvertLatin.prototype.latinToAscii = function(a_str)
{
    // upper case A
    a_str = a_str.replace(/[\u00c0-\u00c5\u0100\u0102\u0104]/g, 'A');
    
    // lower case a
    a_str = a_str.replace(/[\u00e0-\u00e5\u0101\u0103\u0105]/g, 'a');
    
    // upper case AE
    a_str = a_str.replace(/\u00c6/g,'AE');
    
    // lowercase ae
    a_str = a_str.replace(/\u00e6/g,'AE');
    
    // upper case E
    a_str = a_str.replace(/[\u00c8-\u00cb\u0112\u0114\u0116\u0118\u011a]/g, 'E');
    
    // lower case e
    a_str = a_str.replace(/[\u00e8-\u00eb\u0113\u0115\u0117\u0119\u011b]/g, 'e');
    
    // upper case I
    a_str = a_str.replace(/[\u00cc-\u00cf\u0128\u012a\u012c\u012e\u0130]/g, 'I');
    
    // lower case i
    a_str = a_str.replace(/[\u00ec-\u00ef\u0129\u012b\u012d\u012f\u0131]/g, 'i');
    
    // upper case O
    a_str = a_str.replace(/[\u00d2-\u00d6\u014c\u014e\u0150]/g, 'O');
    
    // lower case o
    a_str = a_str.replace(/[\u00f2-\u00f6\u014d\u014f\u0151]/g, 'o');
    
    // upper case OE
    a_str = a_str.replace(/\u0152/g,'OE');
    
    // lower case oe
    a_str = a_str.replace(/\u0153/g,'oe');
    
    // upper case U
    a_str = a_str.replace(
        /[\u00d9-\u00dc\u0168\u016a\u016c\u016e\u0170\u0172]/g, 
        'U');
    
    // lower case u
    a_str = a_str.replace(
        /[\u00f9-\u00fc\u0169\u016b\u016d\u016f\u0171\u0173]/g, 
        'u');
               
    // for now, just remove anyting else that's not ASCII  
    // TODO - implement full transliteration
    this.d_uConverter.charset = 'US-ASCII';
    a_str = this.d_uConverter.ConvertFromUnicode(a_str);
    
    // just delete the '?' in the resulting conversion
    a_str.replace(/\?/,'');
    
    return a_str;
}

