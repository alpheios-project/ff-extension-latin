<?xml version="1.0" encoding="UTF-8"?>

<!--
    Stylesheet for transformation verb conjugation data to HTML
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:exsl="http://exslt.org/common">
    
    <!--
        This stylesheet groups the data on 3 attributes for the rows, 
        and groups on 3 attributes for the columns.
        Grouping attributes are supplied as parameters.
        Grouping parameters are required.
        A optional verb-ending parameter can be used to identify the verb-ending
        to be indicated as 'selected' in the HTML table.     
    -->
    
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:key name="footnotes" match="footnote" use="@id"/>
                
    <!-- all parameters may be supplied in transformation -->
    <!-- row groupings --> 
    <!-- default order is Tense, Number, Person -->
    <!-- mood (required) -->
    <xsl:param name="mood" select="'imperative'"/>
    
    <xsl:param name="group1">
        <xsl:choose>
            <xsl:when test="$mood='gerundive' or $mood='supine'">
                <xsl:value-of select="'case'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'tense'"/>    
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:param>
    <xsl:param name="group2" select="'num'"/>
    <xsl:param name="group3" select="'pers'"/>
    
    <!-- column groupings -->
    <!-- default order is Voice, Conjugation -->
    <xsl:param name="group4" select="'voice'"/>
    <xsl:param name="group5" select="'conj'"/>

    <!-- the following is optional, used to select specific verb-ending(s) -->
    <xsl:param name="selected_endings" select="/.." />
    
    <!-- debug -->
    <!--xsl:param name="test_endings">
        <div class="alph-entry">
            <div class="alph-dict">
                <span class="alph-hdwd">sono, sonere, sonui, sonitus: </span>
                <span context="verb" class="alph-pofs">verb</span>
                <span context="3rd" class="alph-conj">3rd conjugation</span>
                <span class="alph-attrlist">(early, very frequent)</span>
                <span class="alph-src">[Ox.Lat.Dict.]</span>
            </div>
            <div class="alph-mean">make a noise/sound; speak/utter, emit sound; be spoken of (as); express/denote;</div>
            <div class="alph-mean">echo/resound; be heard, sound; be spoken of (as); celebrate in speech;</div>
            <div class="alph-infl-set">
                <span class="alph-term">sonit•<span class="alph-suff">u</span></span>
                <span context="supine" class="alph-pofs">(supine)</span>
                <div class="alph-infl">Singular: <span context="ablative-singular-neuter-supine" class="alph-case">ablative (n)</span></div>
            </div>
        </div>
    </xsl:param>
    <xsl:param name='selected_endings' select="exsl:node-set($test_endings)"/-->
    
    <!-- skip the enclosing html and body tags -->
    <xsl:param name="fragment" />
        
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$fragment">
                <xsl:call-template name="verbtable">
                    <xsl:with-param name="endings" select="//infl-ending-set[@mood=$mood]"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <html>
                    <head>
                        <link rel="stylesheet" type="text/css" href="alph-verb-conj-group.css"/>
                    </head>
                    <body>
                        <xsl:call-template name="verbtable">
                            <xsl:with-param name="endings" select="//infl-ending-set[@mood=$mood]"/>
                        </xsl:call-template>                     
                    </body>
                </html>                
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:template>
     
    <xsl:template name="verbtable">
        <xsl:param name="endings" />
        <table id="alph-infl-table"> <!-- start verb table -->
            <caption>
                <xsl:for-each select="$selected_endings//span[@class='alph-term']">
                    <xsl:if test="position() &gt; 1">
                        , 
                    </xsl:if>
                    <div class="alph-infl-term"><xsl:copy-of select="current()"/></div>    
                </xsl:for-each>
            </caption>
            <!-- write the colgroup elements -->
            <xsl:call-template name="colgroups">
                <xsl:with-param name="headerrow1" select="//order-item[@attname=$group4]"/>
                <xsl:with-param name="headerrow2" select="//order-item[@attname=$group5]"/>
            </xsl:call-template>        
            <!-- write the column header rows -->
            <xsl:call-template name="headers">
                <xsl:with-param name="headerrow1" select="//order-item[@attname=$group4]"/>
                <xsl:with-param name="headerrow2" select="//order-item[@attname=$group5]"/>
            </xsl:call-template>
            <!-- add the mood header row -->
            <tr id="mood" class="group1row">
                <th class="header-text always-visible" colspan="2">
                    <xsl:value-of select="$mood"/>
                    <xsl:call-template name="add-footnote">
                        <xsl:with-param name="item"
                            select="/infl-data/order-table/order-item[@attname='mood'and text()=$mood]" />
                    </xsl:call-template>                            
                </th>
                <xsl:call-template name="headerrow">
                    <xsl:with-param name="headerrow1" select="//order-item[@attname=$group4]"/>
                    <xsl:with-param name="headerrow2" select="//order-item[@attname=$group5]"/>
                </xsl:call-template>                                
            </tr>
            <!-- debugging
            <pre class="debug">
                mood: <xsl:value-of select="$mood"/>
                group1: <xsl:value-of select="$group1"/>
                group2: <xsl:value-of select="$group2"/>
                group3: <xsl:value-of select="$group3"/>
                group4: <xsl:value-of select="$group4"/>
                group5: <xsl:value-of select="$group5"/>
                <xsl:copy-of select="$selected_endings"/>
            </pre>
            -->
            <!-- gather first level row grouping:
                all attribute values for group1 attribute -->
            <xsl:variable name="firstgroup" select="$endings/@*[local-name(.)=$group1]"/>
            <!-- iterate though the items in the first group -->
            <xsl:for-each select="$firstgroup">
                <!-- lookup sort order for this attribute from order-table in the conjugation data -->
                <xsl:sort 
                    select="/infl-data/order-table/order-item[@attname=$group1 
                    and text()=current()]/@order" 
                    data-type="number"/>
                <!-- if this is the first instance of this attribute value proceed to 
                    2nd level grouping -->
                <xsl:if test="generate-id(.) = generate-id($firstgroup[.=current()])">
                    <xsl:variable name="lastgroup1" select="."/>
                    <!-- gather second level row grouping:
                        all group2 attribute values 
                        from all elements whose group1 attribute matches the current group1 value  
                    -->                    
                    <xsl:variable name="secondgroup" 
                        select="$endings/@*[local-name(.)=$group1 
                        and .=$lastgroup1]/../@*[local-name(.)=$group2]"/>                    
                    <!-- first instance of group1 row so add header row -->
                    <!-- TODO colspan should not be hardcoded -->
                    <tr id="{$lastgroup1}" class="group1row">
                        <th class="header-text always-visible" colspan="2">
                            <xsl:value-of select="$lastgroup1"/>
                            <xsl:call-template name="add-footnote">
                                <xsl:with-param name="item"
                                    select="/infl-data/order-table/order-item[@attname=$group1 
                                    and text()=$lastgroup1]" />
                            </xsl:call-template>                            
                        </th>
                        <xsl:call-template name="headerrow">
                            <xsl:with-param name="headerrow1" select="//order-item[@attname=$group4]"/>
                            <xsl:with-param name="headerrow2" select="//order-item[@attname=$group5]"/>
                        </xsl:call-template>        
                    </tr>
                    <!-- if none in 2nd group, just add the items in the first group -->                    
                    <xsl:if test="count($secondgroup) = 0">
                        <tr class="data-row">
                            <th class="emptyheader" colspan="2">&#160;</th>
                            <xsl:for-each select="$endings/@*[local-name(.)=$group1 and .=$lastgroup1]/..">
                                <xsl:variable name="selected">
                                    <xsl:call-template name="check_infl_sets">
                                        <xsl:with-param name="current_data" select="." />
                                    </xsl:call-template>
                                </xsl:variable>                                
                                <xsl:call-template name="ending-cell">
                                    <xsl:with-param name="verb-endings" select="infl-ending"/>
                                    <xsl:with-param name="selected" select="$selected"/>
                                </xsl:call-template>                                    
                            </xsl:for-each>
                        </tr>
                    </xsl:if>                                         
                    
                    <!-- iterate through the items in the second group -->
                    <xsl:for-each select="$secondgroup">
                        <xsl:sort select="/infl-data/order-table/order-item[@attname=$group2 
                            and text()=current()]/@order" data-type="number"/>
                        <!-- if this the first instance of this attribute value proceed
                            to 3rd level grouping -->
                        <xsl:if test="generate-id(.) = generate-id($secondgroup[.=current()])">
                            <xsl:variable name="lastgroup2" select="."/>
                            <!-- gather third level row grouping:
                                all group3 attribute values from:
                                all elements whose group1 attribute matches the current group1 value
                                and whose group2 attribute matches the current group2 values
                            -->   
                            <xsl:variable name="thirdgroup" 
                                select="$endings/@*[local-name(.)=$group1 
                                and .=$lastgroup1]/../@*[local-name(.)=$group2 
                                and . = $lastgroup2]/../@*[local-name(.)=$group3]"/>
                            

                            <xsl:if test="count($thirdgroup) = 0">
                                <!-- if none in 3rd group, just add the items in the 2nd group -->
                                <xsl:for-each select="$endings/@*[local-name(.)=$group1 
                                        and .=$lastgroup1]/../@*[local-name(.)=$group2 
                                        and . = $lastgroup2]/..">
                                    <th class="group2header header-text">
                                         <xsl:value-of select="$lastgroup2"/>
                                         <xsl:call-template name="add-footnote">
                                         <xsl:with-param name="item" 
                                             select="/infl-data/order-table/order-item[@attname=$group2 
                                             and text()=$lastgroup2]"/>
                                         </xsl:call-template>
                                    </th>
                                    <xsl:variable name="selected">
                                        <xsl:call-template name="check_infl_sets">
                                            <xsl:with-param name="current_data" select="." />
                                        </xsl:call-template>
                                    </xsl:variable>                                    
                                    <xsl:call-template name="ending-cell">
                                        <xsl:with-param name="verb-endings" select="infl-ending"/>
                                        <xsl:with-param name="selected" select="$selected"/>
                                    </xsl:call-template>                                    
                                </xsl:for-each>
                            </xsl:if> 
                            
                            <!-- iterate through the items in the third group -->
                            <xsl:for-each select="$thirdgroup">
                                <xsl:sort select="/infl-data/order-table/order-item[@attname=$group3 and text()=current()]/@order" 
                                    data-type="number"/>
                                <!-- start a new row to hold the data if this is the first instance of 
                                    this attribute value -->
                                <xsl:if test="generate-id(.) = generate-id($thirdgroup[.=current()])">
                                    <xsl:variable name="lastgroup3" select="."/>
                                    <xsl:variable name="row_id" select="concat($lastgroup1,$lastgroup2,$lastgroup3)"/>
                                    <tr class="data-row" id="{$row_id}"> <!-- start new row -->
                                        <xsl:choose>
                                            <xsl:when test="position()=1">
                                                <!-- add row header on left if it's the first row in 
                                                    this grouping -->
                                                <th class="group2header header-text">
                                                    <xsl:value-of select="$lastgroup2"/>
                                                    <xsl:call-template name="add-footnote">
                                                        <xsl:with-param name="item" 
                                                            select="/infl-data/order-table/order-item[@attname=$group2 
                                                            and text()=$lastgroup2]"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <th class="emptyheader">&#160;</th>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <!-- gather the actual verb-ending data in this grouping:
                                            all elements whose 
                                            - group1 attribute matches the current group1 value and
                                            - group2 attribute matches the current group2 value
                                            - group3 attribute matches the current group3 value
                                        -->
                                        <xsl:variable name="data"
                                            select="$endings/@*[local-name(.)=$group1 
                                            and .=$lastgroup1]/../@*[local-name(.)=$group2 
                                            and . = $lastgroup2]/../@*[local-name(.)=$group3 
                                            and .= $lastgroup3]/.."/>
                                        <xsl:call-template name="rowgroup">
                                            <xsl:with-param name="data" select="$data"/>
                                            <xsl:with-param name="groupheader" select="$lastgroup3"/>
                                        </xsl:call-template>
                                    </tr> 
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:for-each>                                  
                </xsl:if>
            </xsl:for-each>            
        </table> <!-- end verb table -->
    </xsl:template>
    
    <!-- template to write a group of rows of verb-ending data to the table -->
    <xsl:template name="rowgroup">
        <xsl:param name="data"/>
        <xsl:param name="groupheader"/>
        <xsl:for-each select="$data">
            <xsl:sort 
                select="/infl-data/order-table/order-item[@attname=$group4 
                    and text()=current()/@*[local-name(.)=$group4]]/@order" 
                data-type="number"/>
            <xsl:sort 
                select="/infl-data/order-table/order-item[@attname=$group5 
                    and text()=current()/@*[local-name(.)=$group5]]/@order" 
                data-type="number"/>
            <xsl:if test="position()=1">
                <!-- add the row header cell if it's the first cell in 
                    the row -->
                <th class="rowgroupheader header-text">
                    <xsl:value-of select="$groupheader"/>
                    <xsl:call-template name="add-footnote">
                        <xsl:with-param name="item" select="/infl-data/order-table/order-item[@attname=$groupheader]"/>
                    </xsl:call-template>
                </th>
            </xsl:if>
            <xsl:variable name="selected">
                <xsl:call-template name="check_infl_sets">
                    <xsl:with-param name="current_data" select="current()" />
                </xsl:call-template>
            </xsl:variable>            
            <xsl:call-template name="ending-cell">
                <xsl:with-param name="verb-endings" select="infl-ending"/>
                <xsl:with-param name="selected" select="$selected"/>
            </xsl:call-template>
        </xsl:for-each>        
    </xsl:template>
    
    <xsl:template name="ending-cell">
        <xsl:param name="verb-endings"/>
        <xsl:param name="selected"/>
        <!--div class="debug_sel"><xsl:value-of select="$selected"/></div-->
        <td>
        <xsl:for-each select="$verb-endings">
            <xsl:variable name="entries" select="count($selected_endings/div[@class='alph-entry'])"/>
                <xsl:variable name="selected-x">
                    <xsl:choose>
                        <xsl:when test="$mood = 'participle'">
                            <!-- participle: match on conj, voice and tense, mood is already filtered -->
                            <xsl:value-of select="count(
                                $selected_endings
                                [
                                (div[@class='alph-dict']/span[@class='alph-conj']/@context = current()/../@conj)
                                and
                                (div[@class='alph-infl-set']/
                                div[
                                @class='alph-infl' 
                                and (span[@class='alph-tense']/text() = current()/../@tense)
                                and (span[@class='alph-voice']/text() = current()/../@voice)
                                ])
                                ]
                                )"/>                            
                        </xsl:when>
                        <xsl:when test="$mood = 'gerundive' or $mood = 'supine'">
                            <!-- gerundive and supine match on conj and case --> 
                            <xsl:value-of select="count(
                                $selected_endings
                                [
                                (div[@class='alph-dict']/span[@class='alph-conj']/@context = current()/../@conj)
                                and
                                (div[@class='alph-infl-set']/
                                div[
                                @class='alph-infl' 
                                and (substring-before((span[@class='alph-case']/@context),'-') = current()/../@case)
                                ])
                                ]
                            )"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="count(
                                $selected_endings
                                [
                                (div[@class='alph-dict']/span[@class='alph-conj']/@context = current()/../@conj)
                                and
                                (div[@class='alph-infl-set']/
                                div[
                                @class='alph-infl' 
                                and (span[@class='alph-tense']/text() = current()/../@tense)
                                and (span[@class='alph-voice']/text() = current()/../@voice)
                                and (span[@class='alph-pers']/@context = current()/../@pers)
                                and (span[@class='alph-num']/@context = current()/../@num)
                                ])
                                ]
                                )"/>
                        </xsl:otherwise>
                    </xsl:choose> 
            </xsl:variable>
            <xsl:variable name="selected_class">
                <!-- if this ending matches the one supplied in the template params
                    then add a 'selected' class to the data element -->
                <xsl:if test="$selected &gt; 0">selected</xsl:if>    
            </xsl:variable>
            <xsl:variable name="notfirst">
                <xsl:if test="position() &gt; 1">notfirst</xsl:if>
            </xsl:variable>
            <span class="ending {@type} {$selected_class} {$notfirst}">
                <xsl:value-of select="."/>
            </span>
            <xsl:call-template name="add-footnote">
                <xsl:with-param name="item" select="."/>
            </xsl:call-template>
        </xsl:for-each>    
        </td>
    </xsl:template>
    
    <!-- template to produce header rows for the table columns -->    
    <xsl:template name="headers">
        <xsl:param name="headerrow1"/>
        <xsl:param name="headerrow2"/>
        <xsl:variable name="row2count" select="count($headerrow2)"/> 
        <tr id="headerrow1">
            <th colspan="2" class="always-visible">
                <span class="header-text"><xsl:value-of select="$group4"/></span>    
                <xsl:call-template name="stem-header">
                    <xsl:with-param name="header" select="$group4"/>
                </xsl:call-template>                
            </th>        
            <xsl:for-each select="$headerrow1">
                <xsl:sort select="@order" data-type="number"/>
                <xsl:variable name="colspan" 
                    select="$row2count"/>
                    <th colspan="{$colspan}">
                        <span class="header-text"><xsl:value-of select="."/></span>
                        <xsl:apply-templates select="."/>                       
                    </th>
            </xsl:for-each>            
        </tr>
        <tr id="headerrow2">
            <th colspan="2" class="always-visible">
                <span class="header-text"><xsl:value-of select="$group5"/></span>
                <xsl:call-template name="stem-header">
                    <xsl:with-param name="header" select="$group5"/>
                </xsl:call-template>                
            </th>        
            <xsl:for-each select="$headerrow1">
                <xsl:sort select="@order" data-type="number"/>               
                <xsl:for-each select="$headerrow2">
                    <xsl:sort select="@order" data-type="number"/>
                     <th>
                         <span class="header-text" ><xsl:value-of select="."/></span>
                         <xsl:apply-templates select="."/>                        
                     </th>        
                </xsl:for-each>
            </xsl:for-each>
        </tr>
    </xsl:template>
    
    <!-- template to produce header for stem header row -->
    <xsl:template name="stem-header">
        <xsl:param name="header"/>
        <xsl:if test="$header='conj'">
            <br/><span class="header-text">stem</span>
        </xsl:if>
    </xsl:template>
    
    <!-- template to produce data for stem header row -->
    <xsl:template name="stem-data" match="order-item[@attname='conj']">        
        <br/>
        <xsl:variable name="thisconj" select="text()"/>
        <xsl:value-of select="/infl-data/stem-table/stem[@conj=$thisconj]"/>
        <xsl:call-template name="add-footnote">
            <xsl:with-param name="item" select="."/>
        </xsl:call-template>                
    </xsl:template>
    
    <xsl:template name="no-sub" match="order-item">
        <xsl:call-template name="add-footnote">
            <xsl:with-param name="item" select="."/>
        </xsl:call-template>        
    </xsl:template>
    
    <!-- template to produce colgroups for the table columns -->
    <xsl:template name="colgroups">
        <xsl:param name="headerrow1"/>
        <xsl:param name="headerrow2"/>
        <xsl:variable name="row2count" select="count($headerrow2)"/>
        <colgroup class="leftheader">
            <col realIndex="0"/>
            <col realIndex="1"/>
        </colgroup>
        <xsl:for-each select="$headerrow1">
            <xsl:variable name="row1pos" select="position()-1"/>            
            <colgroup class="header1">              
                <xsl:for-each select="$headerrow2">
                    <xsl:variable name="row2pos" select="position()-1"/>
                    <xsl:variable name="index" 
                            select="($row1pos * $row2count) + position() + 1"/>
                        <col class="header3col" realIndex="{$index}" 
                            row1pos="{$row1pos}"
                            row2pos="{$row2pos}"/>
                </xsl:for-each>
            </colgroup>
        </xsl:for-each>       
    </xsl:template>
    
    <xsl:template name="headerrow">
        <xsl:param name="headerrow1"/>
        <xsl:param name="headerrow2"/>
        <xsl:variable name="row2count" select="count($headerrow2)"/>
        <xsl:for-each select="$headerrow1">
                <xsl:for-each select="$headerrow2">
                    <td>&#160;</td>
                </xsl:for-each>
        </xsl:for-each>       
    </xsl:template>
    
    <xsl:template name="add-footnote">
        <xsl:param name="item"/>
        <xsl:if test="$item/@footnote">
            <a href="#{$item/@footnote}" class="footnote"><xsl:value-of select="substring-after($item/@footnote,'-')"/></a>
            <span class="footnote-text"><xsl:value-of select="key('footnotes',$item/@footnote)"/></span>    
        </xsl:if>
    </xsl:template>    
    
    <xsl:template name="check_infl_sets">
        <xsl:param name="current_data"/>
        <xsl:variable name="matches">
            <xsl:for-each select="$selected_endings//div[@class='alph-infl-set' and 
                ../div[@class='alph-dict']/span[(@class='alph-conj') and (@context = $current_data/@conj)]]
                ">
                <xsl:for-each select="div[@class='alph-infl']">
                    <xsl:call-template name="find_infl_match">
                        <xsl:with-param name="current_data" select="$current_data"/>
                        <xsl:with-param name="filtered_data" select="(.)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>    
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($matches,'1')">
                1
            </xsl:when>
            <xsl:otherwise>
                0
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="find_infl_match">
        <xsl:param name="current_data"/>
        <xsl:param name="filtered_data"/>
        <xsl:param name="att_pos" select="0"/>
        <xsl:variable name="num_atts" select="count($current_data/@*)"/>
        <xsl:choose> 
            <xsl:when test="$att_pos = $num_atts">
                <!-- if we have tested all the possible attributes return the match count-->
                <xsl:value-of select="count($filtered_data)"/>
            </xsl:when>
            <xsl:when test="($att_pos &lt; $num_atts) and $filtered_data">
                <!-- variables are: voice, mood, tense, num, person, and case -->
                <!-- only try match if current conjugation data element has the attribute -->
                <xsl:for-each select="$current_data/@*">
                    <xsl:if test="position() = $att_pos + 1">
                        <xsl:variable name="att_name" select="name()"/>
                        <xsl:choose>
                            <xsl:when test="$att_name = 'conj' or ($mood = 'supine' and ($att_name = 'voice' or $att_name='mood'))">
                                <!-- TODO gerundives and participles still not accounted for -->
                                <!-- just advance the counter for the ones we're skipping -->
                                <xsl:call-template name="find_infl_match">
                                    <xsl:with-param name="current_data" select="$current_data"/>
                                    <xsl:with-param name="filtered_data" 
                                        select="$filtered_data"/>
                                    <xsl:with-param name="att_pos" select="$att_pos+1"/>                           
                                </xsl:call-template>                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="class_name">
                                    <xsl:value-of select="concat('alph-',$att_name)"/>        
                                </xsl:variable>
                                <xsl:variable name="latest_data"
                                    select="$filtered_data[
                                    ((span[@class=$class_name]/text() = $current_data/@*[local-name(.)=$att_name])
                                    or
                                    (span[@class=$class_name]/@context = $current_data/@*[local-name(.)=$att_name])
                                    or
                                    
                                    ($att_name='case' and substring-before(span[@class=$class_name]/@context,'-') = $current_data/@*[local-name(.)=$att_name])
                                 )]"/>
                                <xsl:call-template name="find_infl_match">
                                    <xsl:with-param name="current_data" select="$current_data"/>
                                    <xsl:with-param name="filtered_data" 
                                        select="$latest_data"/>
                                    <xsl:with-param name="att_pos" select="$att_pos+1"/>                           
                                </xsl:call-template>                                
                            </xsl:otherwise>
                        </xsl:choose>                                        
                    </xsl:if>
                </xsl:for-each>                
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
</xsl:stylesheet>