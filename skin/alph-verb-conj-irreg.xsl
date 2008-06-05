<?xml version="1.0" encoding="UTF-8"?>

<!--
    Stylesheet for transformation of irregular verb conjugation data to HTML
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:exsl="http://exslt.org/common">
        
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:key name="footnotes" match="footnote" use="@id"/>
                
    <!-- row groupings --> 
    <!-- default order is Tense, Number, Person -->
    <xsl:param name="group1" select="'tense'"/>
    <xsl:param name="group2" select="'num'"/>
    <xsl:param name="group3" select="'person'"/>
    
    <!-- hdwd (required) -->
    <xsl:param name="hdwd"/>
    
    <!-- the following is optional, used to select specific verb-ending(s) -->
    <xsl:param name="selected_endings" select="/.." />
    
    <!-- skip the enclosing html and body tags -->
    <xsl:param name="fragment" />
    
    <!--xsl:variable name="test_endings">
        <div id="alph-text">
            <div class="alph-word">
                <div class="alph-entry">
                    <div class="alph-dict">
                        <span class="alph-hdwd">sum, esse, fui, futurus: </span>
                        <span context="verb" class="alph-pofs">verb</span>
                        <span class="alph-attrlist">(very frequent)</span>
                    </div>
                    <div class="alph-mean">be; exist; (also used to form verb perfect passive tenses) with NOM PERF PPL</div>
                    <div class="alph-infl-set">
                        <span class="alph-term">s•<span class="alph-suff">umus</span></span>
                        <div class="alph-infl">
                            <span context="1st" class="alph-pers">1st person</span>
                            <span context="plural" class="alph-num">plural;</span>
                            <span class="alph-tense">present</span>
                            <span context="indicative" class="alph-mood">indicative;</span>
                            <span class="alph-voice">active</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </xsl:variable-->
    
    <!--xsl:variable name="test_endings">
        <div class="alph-entry">
            <div class="alph-dict">
                <span class="alph-hdwd">fero, ferre, tuli, latus: </span>
                <span context="verb" class="alph-pofs">verb</span>
                <span class="alph-attrlist">(very frequent)</span>
            </div>
            <div class="alph-mean">bring, bear; tell/speak of; consider; carry off, win, receive, produce; get;</div>
            <div class="alph-infl-set">
                <span class="alph-term">fer•<span class="alph-suff">am</span></span>
                <div class="alph-infl">
                    <span context="1st" class="alph-pers">1st person</span>
                    <span context="singular" class="alph-num">singular;</span>
                    <span class="alph-tense">present</span>
                    <span context="subjunctive" class="alph-mood">subjunctive;</span>
                    <span class="alph-voice">active</span>
                </div>
                <div class="alph-infl">
                    <span context="1st" class="alph-pers">1st person</span>
                    <span context="singular" class="alph-num">singular;</span>
                    <span class="alph-tense">future</span>
                    <span context="indicative" class="alph-mood">indicative;</span>
                    <span class="alph-voice">active</span>
                </div>
            </div>
        </div>
    </xsl:variable-->
    
    <!--xsl:param name='selected_endings' select="exsl:node-set($test_endings)"/-->
        
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$fragment">
                <xsl:call-template name="verbtable">
                    <xsl:with-param name="endings" select="//conjugation[hdwd-set/hdwd/text() = string($hdwd)]/verb-conj-set"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <html>
                    <head>
                        <link rel="stylesheet" type="text/css" href="alph-verb-conj-group.css"/>
                    </head>
                    <body>
                        <xsl:call-template name="verbtable">
                            <xsl:with-param name="endings" select="//conjugation[hdwd-set/hdwd/text() = string($hdwd)]/verb-conj-set"/>
                        </xsl:call-template>                     
                    </body>
                </html>                
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:template>
     
    <xsl:template name="verbtable">
        <xsl:param name="endings" />
        <xsl:variable name="include_voice">
            <xsl:value-of select="count($endings[@voice]) &gt; 0"/>
        </xsl:variable>
        <xsl:variable name="data_cols">
            <xsl:choose>
                <xsl:when test="$include_voice = 'true'">4</xsl:when>
                <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <table id="alph-infl-table"> <!-- start verb table -->
            <caption class="hdwd">
                <xsl:value-of select="$hdwd"/>
            </caption>

            <!-- add the column groups -->            
            <xsl:call-template name="colgroups">
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>
            
            <!-- gather first level row grouping:
            all attribute values for group1 attribute -->
            <!-- first show indicative/subjunctive moods -->
            <xsl:call-template name="rowgroupings">
                <xsl:with-param name="rowgroupdata" select="$endings[@mood='indicative' or @mood='subjunctive']"/>
                <xsl:with-param name="headerdata" 
                    select="//order-item[@attname='mood' and (text()='indicative' or text()='subjunctive')]"/>
                <xsl:with-param name="data_cols" select="$data_cols"/>
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>
            <!-- Imperative -->
            <xsl:call-template name="rowgroupings">
                <xsl:with-param name="rowgroupdata" select="$endings[@mood='imperative']"/>
                <xsl:with-param name="headerdata" 
                    select="//order-item[@attname='mood' and text()='imperative']"/>
                <xsl:with-param name="data_cols" select="$data_cols"/>
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>
            
            <!--Infinitive -->
            <xsl:call-template name="rowgroupings">
                <xsl:with-param name="rowgroupdata" select="$endings[@mood='infinitive']"/>
                <xsl:with-param name="headerdata" 
                    select="//order-item[@attname='mood' and text()='infinitive']"/>
                <xsl:with-param name="data_cols" select="$data_cols"/>
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>
            

            <!-- Participle -->
            <xsl:call-template name="rowgroupings">
                <xsl:with-param name="rowgroupdata" select="$endings[@mood='participle']"/>
                <xsl:with-param name="headerdata" 
                    select="//order-item[@attname='mood' and text()='participle']"/>
                <xsl:with-param name="data_cols" select="$data_cols"/>
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>
            
            <!-- Gerundive -->
            <xsl:call-template name="rowgroupings">
                <xsl:with-param name="rowgroupdata" select="$endings[@mood='gerundive']"/>
                <xsl:with-param name="headerdata" 
                    select="//order-item[@attname='mood' and text()='gerundive']"/>
                <xsl:with-param name="data_cols" select="$data_cols"/>
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>

            <!-- Supine -->
            <xsl:call-template name="rowgroupings">
                <xsl:with-param name="rowgroupdata" select="$endings[@mood='supine']"/>
                <xsl:with-param name="headerdata" 
                    select="//order-item[@attname='mood' and text()='supine']"/>
                <xsl:with-param name="data_cols" select="$data_cols"/>
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>
                        
        </table>        
    </xsl:template>
    
    <xsl:template name="rowgroupings">
        <xsl:param name="rowgroupdata"/>
        <xsl:param name="headerdata"/>
        <xsl:param name="data_cols"/>
        <xsl:param name="include_voice"/>
        <xsl:if test="count($rowgroupdata) > 0">            
            <!-- write the column header rows -->
            <xsl:call-template name="headers">
                <xsl:with-param name="headerrow1" select="$headerdata"/>
                <xsl:with-param name="colspan" select="$data_cols div count($headerdata)"/>
                <xsl:with-param name="include_voice" select="$include_voice"/>
            </xsl:call-template>            
        </xsl:if>
        <!-- group1 order is overridden to case when it's available -->
        <xsl:variable name="group1_variable">
            <xsl:choose>
                <xsl:when test="$rowgroupdata[@case]">
                    <xsl:value-of select="'case'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$group1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="firstgroup" select="$rowgroupdata/@*[local-name(.)=$group1_variable]"/>
        <!-- iterate though the items in the first group -->
        <xsl:for-each select="$firstgroup">
            <!-- lookup sort order for this attribute from order-table in the conjugation data -->
            <xsl:sort 
                select="/conjdata/order-table/order-item[@attname=$group1_variable 
                and text()=current()]/@order" 
                data-type="number"/>
            <!-- if this is the first instance of this attribute value proceed to 
                2nd level grouping -->
            <xsl:if test="generate-id(.) = generate-id($firstgroup[.=current()])">
                <xsl:variable name="lastgroup1" select="."/>
                <!-- first instance of group1 row so add header row -->
                <!-- TODO colspan should not be hardcoded -->
                <tr id="{$lastgroup1}" class="group1row">
                    <th class="header-text always-visible" colspan="2">
                        <xsl:value-of select="$lastgroup1"/>
                        <xsl:call-template name="add-footnote">
                            <xsl:with-param name="item"
                                select="/conjdata/order-table/order-item[@attname=$group1_variable 
                                and text()=$lastgroup1]" />
                        </xsl:call-template>                            
                    </th>
                    <xsl:call-template name="emptyheader">
                        <xsl:with-param name="counter" select="$data_cols + 1"/>
                    </xsl:call-template>                                
                </tr>                     
                <!-- gather second level row grouping:
                    all group2 attribute values 
                    from all elements whose group1 attribute matches the current group1 value  
                -->
                <xsl:variable name="secondgroup" 
                    select="$rowgroupdata/@*[local-name(.)=$group1_variable 
                    and .=$lastgroup1]/../@*[local-name(.)=$group2]"/>
                
                <xsl:if test="count($secondgroup) = 0">
                    <tr class="data-row">
                        <th class="emptyheader" colspan="2">&#160;</th>
                        <xsl:variable name="data" select="$rowgroupdata/@*[local-name(.)=$group1_variable and .=$lastgroup1]/.."/>
                        <xsl:for-each select="$data">
                            <xsl:variable name="selected">
                                <xsl:call-template name="check_infl_sets">
                                    <xsl:with-param name="current_data" select="." />
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="ending-cell">
                                <xsl:with-param name="verb-endings" select="verb-conj"/>
                                <xsl:with-param name="colspan" select="$data_cols div count($data)"/>
                                <xsl:with-param name="selected" select="$selected"/>
                            </xsl:call-template>                                    
                        </xsl:for-each>
                    </tr>
                </xsl:if>                                         
                
                <!-- iterate through the items in the second group -->
                <xsl:for-each select="$secondgroup">
                    <xsl:sort select="/conjdata/order-table/order-item[@attname=$group2 
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
                            select="$rowgroupdata/@*[local-name(.)=$group1_variable 
                            and .=$lastgroup1]/../@*[local-name(.)=$group2 
                            and . = $lastgroup2]/../@*[local-name(.)=$group3]"/>
                        
                        <xsl:if test="count($thirdgroup) = 0">
                            <!-- if none in 3rd group, just add the items in the 2nd group -->
                            <xsl:variable name="data" select="$rowgroupdata/@*[local-name(.)=$group1_variable 
                                and .=$lastgroup1]/../@*[local-name(.)=$group2 
                                and . = $lastgroup2]/.."/>
                            <xsl:for-each select="$data">
                                <th class="group2header header-text">
                                    <xsl:value-of select="$lastgroup2"/>
                                    <xsl:call-template name="add-footnote">
                                        <xsl:with-param name="item" 
                                            select="/conjdata/order-table/order-item[@attname=$group2 
                                            and text()=$lastgroup2]"/>
                                    </xsl:call-template>
                                </th>                                 
                                <xsl:variable name="selected">
                                    <xsl:call-template name="check_infl_sets">
                                        <xsl:with-param name="current_data" select="." />
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:call-template name="ending-cell">
                                    <xsl:with-param name="verb-endings" select="verb-conj"/>
                                    <xsl:with-param name="colspan" select="$data_cols div count($data)"/>
                                    <xsl:with-param name="selected" select="$selected"/>
                                </xsl:call-template>                                    
                            </xsl:for-each>
                        </xsl:if> 
                        
                        <!-- iterate through the items in the third group -->
                        <xsl:for-each select="$thirdgroup">
                            <xsl:sort select="/conjdata/order-table/order-item[@attname=$group3 and text()=current()]/@order" 
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
                                                        select="/conjdata/order-table/order-item[@attname=$group2 
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
                                        select="$rowgroupdata/@*[local-name(.)=$group1_variable 
                                        and .=$lastgroup1]/../@*[local-name(.)=$group2 
                                        and . = $lastgroup2]/../@*[local-name(.)=$group3 
                                        and .= $lastgroup3]/.."/>
                                    <xsl:call-template name="rowgroup">
                                        <xsl:with-param name="data" select="$data"/>
                                        <xsl:with-param name="groupheader" select="$lastgroup3"/>
                                        <xsl:with-param name="colspan" select="$data_cols div count($data)"/>
                                    </xsl:call-template>
                                </tr> 
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>                                  
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- template to write a group of rows of verb-ending data to the table -->
    <xsl:template name="rowgroup">
        <xsl:param name="data"/>
        <xsl:param name="groupheader"/>
        <xsl:param name="colspan"/>
        <xsl:for-each select="$data">
            <xsl:sort 
                select="/conjdata/order-table/order-item[@attname='voice' 
                and text()=current()/@*[local-name(.)='voice']]/@order" 
                data-type="number"/>
            <xsl:if test="position()=1">
                <!-- add the row header cell if it's the first cell in 
                    the row -->
                <th class="rowgroupheader header-text">
                    <xsl:value-of select="$groupheader"/>
                    <xsl:call-template name="add-footnote">
                        <xsl:with-param name="item" select="/conjdata/order-table/order-item[@attname=$groupheader]"/>
                    </xsl:call-template>
                </th>
            </xsl:if>
            <xsl:variable name="selected">
                <xsl:call-template name="check_infl_sets">
                    <xsl:with-param name="current_data" select="current()" />
                </xsl:call-template>
            </xsl:variable>
            <!--div class="debug_sel"><xsl:value-of select="$selected"/></div-->
            <xsl:call-template name="ending-cell">
                <xsl:with-param name="verb-endings" select="verb-conj"/>
                <xsl:with-param name="colspan" select="$colspan"/>
                <xsl:with-param name="selected" select="$selected"/>
            </xsl:call-template>
        </xsl:for-each>        
    </xsl:template>
    
    <xsl:template name="headerrow">
        <xsl:param name="headerrow1"/>
        <xsl:for-each select="$headerrow1">
           <td>&#160;</td>
        </xsl:for-each>       
    </xsl:template>
    
    <xsl:template name="add-footnote">
        <xsl:param name="item"/>
        <xsl:if test="$item/@footnote">
            <a href="#{$item/@footnote}" class="footnote"><xsl:value-of select="substring-after($item/@footnote,'-')"/></a>
            <span class="footnote-text"><xsl:value-of select="key('footnotes',$item/@footnote)"/></span>    
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ending-cell">
        <xsl:param name="verb-endings"/>
        <xsl:param name="selected"/>
        <xsl:param name="colspan"/>
        <td>
            <xsl:for-each select="$verb-endings">
                <xsl:variable name="entries" select="count($selected_endings/div[@class='alph-entry'])"/>                    
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
        <xsl:call-template name="emptycell">
            <xsl:with-param name="counter" select="$colspan"/>
        </xsl:call-template>        
    </xsl:template>

    <!-- template to produce colgroups for the table columns -->
    <xsl:template name="colgroups">
        <xsl:param name="include_voice"/>
        <colgroup class="leftheader">
            <col realIndex="0"/>
            <col realIndex="1"/>
        </colgroup>        
        <xsl:choose>
            <xsl:when test="$include_voice = 'true'">
                <colgroup class="header1">
                    <col realIndex="2"/>
                    <col realIndex="3"/>
                </colgroup>
                <colgroup class="header1">
                    <col realIndex="4"/>
                    <col realIndex="5"/>
                </colgroup>
            </xsl:when>
            <xsl:otherwise>
                <colgroup class="header2">
                    <col realIndex="2" colspan="1"/>
                </colgroup>
                <colgroup class="header1">
                    <col realIndex="3" colspan="1"/>
                </colgroup>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="headers">
        <xsl:param name="headerrow1"/>
        <xsl:param name="include_voice"/>
        <xsl:param name="colspan"/>
        <tr id="headerrow1">
            <th colspan="2" class="always-visible">
                <span class="header-text"><xsl:value-of select="'mood'"/></span>    
            </th>        
            <xsl:choose>
                <xsl:when test="$include_voice = 'true'">
                    <xsl:for-each select="//order-item[@attname='voice']">
                        <xsl:sort select="/conjdata/order-table/order-item[@attname='voice' 
                        and text()=current()]/@voice" data-type="number"/>
                        <xsl:for-each select="$headerrow1">
                            <xsl:sort select="@order" data-type="number"/>
                            <th>
                                <span class="header-text"><xsl:value-of select="."/></span>                      
                            </th>
                        </xsl:for-each>
                        <xsl:variable name="counter" select="$colspan div 2"/>
                        <xsl:call-template name="emptyheader">
                            <xsl:with-param name="counter" select="$counter"/>
                        </xsl:call-template>                        
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$headerrow1">
                        <xsl:sort select="@order" data-type="number"/>
                        <th>
                            <span class="header-text"><xsl:value-of select="."/></span>                      
                        </th>
                    </xsl:for-each>
                    <xsl:call-template name="emptyheader">
                        <xsl:with-param name="counter" select="$colspan"/>
                    </xsl:call-template>                    
                </xsl:otherwise>
            </xsl:choose>
        </tr>
    </xsl:template>
    
    <xsl:template name="check_infl_sets">
        <xsl:param name="current_data"/>
        <xsl:variable name="matches">
            <xsl:for-each select="$selected_endings//div[@class='alph-infl-set']">
                <xsl:for-each select="div[@class='alph-infl']">
                    <xsl:call-template name="find_infl_match">
                        <xsl:with-param name="current_data" select="$current_data"/>
                        <xsl:with-param name="filtered_data" select="(.)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>    
        </xsl:variable>
        <!--xsl:value-of select="$matches"/-->
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
                <xsl:value-of select="count($filtered_data)"/>
                <!-- if we have tested all the possible attributes return the match count-->
                <!--xsl:value-of select="count($filtered_data)"/-->
                <!--xsl:if test="boolean(exsl:node-set($filtered_data))"><div class="debug_fil">blip</div></xsl:if-->
            </xsl:when>
            <xsl:when test="($att_pos &lt; $num_atts) and $filtered_data">
                <!-- variables are: voice, mood, tense, num, person, and case -->
                <!-- only try match if current conjugation data element has the attribute -->
                <xsl:for-each select="$current_data/@*">
                    <xsl:if test="position() = $att_pos + 1">
                        <xsl:variable name="att_name" select="name()"/>
                        <xsl:variable name="class_name">
                            <xsl:choose>
                                <xsl:when test="$att_name='person'">
                                    <xsl:value-of select="'alph-pers'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('alph-',$att_name)"/>        
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- TODO - this is incorrect when multiple infl elements with combination of match (e.g. see feram) -->
                        <xsl:variable name="latest_data"
                            select="$filtered_data[
                            ((span[@class=$class_name]/text() = $current_data/@*[local-name(.)=$att_name])
                            or
                             (span[@class=$class_name]/@context = $current_data/@*[local-name(.)=$att_name])
                            )
                            ]"/>
                        
                        <!--div class="debug_testrecurs">
                            Postion: <xsl:value-of select="$att_pos"/> 
                            Attribute: <xsl:value-of select="$att_name"/>
                            Class: <xsl:value-of select="$class_name"/>
                            Tense: <xsl:value-of select="$current_data/@tense"/>
                            </div-->

                        <xsl:call-template name="find_infl_match">
                            <xsl:with-param name="current_data" select="$current_data"/>
                            <xsl:with-param name="filtered_data" 
                                select="$latest_data"/>
                            <xsl:with-param name="att_pos" select="$att_pos+1"/>                           
                        </xsl:call-template>    
                    </xsl:if>
                </xsl:for-each>                
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <!-- empty cells to fill row -->
    <xsl:template name="emptycell">
        <xsl:param name="counter"/>
        <xsl:if test="$counter &gt; 1">
            <td class="emptycell">&#160;</td>
            <xsl:call-template name="emptycell">
                <xsl:with-param name="counter" select="$counter -1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- empty header cells to fill row -->
    <xsl:template name="emptyheader">
        <xsl:param name="counter"/>
        <xsl:if test="$counter &gt; 1">
            <th class="emptyheader">&#160;</th>
            <xsl:call-template name="emptyheader">
                <xsl:with-param name="counter" select="$counter -1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>