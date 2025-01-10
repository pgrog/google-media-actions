<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:media="http://search.yahoo.com/mrss/" 
                xmlns:pl="http://xml.theplatform.com/data/object" 
                xmlns:jString="http://xml.apache.org/xslt/java/java.lang.String" 
                xmlns:a="http://www.w3.org/2005/Atom" exclude-result-prefixes="java" 
                xmlns:rte="http://rte.ie/player/program" 
                xmlns:plprogram="http://xml.theplatform.com/entertainment/data/Program" 
                xmlns:plprogramavailability="http://xml.theplatform.com/entertainment/data/ProgramAvailability" 
                xmlns:dcterms="http://purl.org/dc/terms/" 
                xmlns:gCalendar="http://xml.apache.org/xslt/java/java.util.GregorianCalendar" 
                xmlns:tz="http://xml.apache.org/xslt/java/java.util.TimeZone" 
                xmlns:sdf="http://xml.apache.org/xslt/java/java.text.SimpleDateFormat" 
                xmlns:date="http://xml.apache.org/xslt/java/java.util.Date"
    >
    <!--
         This example takes Media RSS and generates JSON output. The XSLT uses some XSL Java
         extensions to create native Java objects that can convert RSS dates to JavaScript's millisecond values. 
         
         We're outputting JSON, so be sure to change the the MIME type setting for the adapter to application/json.
    -->
    <xsl:output method="text" version="1.0" encoding="utf-8" />
    <!-- 
         Since this is JSON output, we need to read the tpIsLastSegment parameter to make sure
         we maintain the proper insertion of commas between JSON array elements. 
    -->
    <xsl:param name="tpIsLastSegment" />
    <!--
         Support jsonp callback/context, the standard callback/context parameters don't work here
         Usage: <baseFeedUrl>?adapterParams=callback%3DmyCallback%26context%3DmyContext
    -->
    <xsl:param name="callback" />
    <xsl:param name="context" />
    <xsl:template match="/">
        <xsl:if test="$callback and not($callback = '')">
            <xsl:value-of select="$callback" />
            <xsl:text>(</xsl:text>
        </xsl:if>
        <!--
             We still need to include the stream marker. It won't be part of the output.
        -->
        <xsl:text>{"@context": "http://schema.org",</xsl:text>
        <xsl:text>"@type": "DataFeed",</xsl:text>
        <xsl:text>"dateModified": "</xsl:text><xsl:apply-templates select="a:feed/a:updated" mode="json-encode"/>",
        <xsl:text>"dataFeedElement":[</xsl:text>
        <xsl:text>&lt;thePlatformFeedMarker/></xsl:text>
        <xsl:for-each select="a:feed/a:entry">

                    
                    <xsl:text>{</xsl:text>
                    <!--
                         Add as many of the standard properties as you need. 
                    -->
                    <xsl:text>"@context": [
                "http://schema.org",{"@language": "en"}
                ],</xsl:text>
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode'">
                            <xsl:text>"@type": "TVEpisode",</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'movie'">
                            <xsl:text>"@type": "Movie",</xsl:text>
                        </xsl:when>
                    </xsl:choose>    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'series'">
                            <xsl:text>"@type": "TVSeries",</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode'">
                            <xsl:text>"@id":"</xsl:text>
                            <xsl:call-template name="encodeTitle">
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                                <xsl:with-param name="type" select="'series'"/>
                            </xsl:call-template>/<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>?epguid=<xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>
                            <xsl:text>",</xsl:text>
                            
                            <xsl:text>"url":"</xsl:text>
                            <xsl:call-template name="encodeTitle">
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                                <xsl:with-param name="type" select="'series'"/>
                            </xsl:call-template>/<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>?epguid=<xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>
                            <xsl:text>",</xsl:text>
                            
                            <xsl:text>"name":"</xsl:text>
                            <xsl:choose>
                                <xsl:when test="plprogram:description != ''">
                                    <xsl:apply-templates select="plprogram:description" mode="json-encode" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="plprogram:tvSeasonNumber != ''">
                                            <xsl:text>Episode </xsl:text>
                                            <xsl:apply-templates select="plprogram:tvSeasonEpisodeNumber" mode="json-encode"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- <xsl:apply-templates select="rte:broadcastDate" mode="json-encode"/> -->
                                            <xsl:call-template name="formatTime">
                                                <xsl:with-param name="txTime" select="rte:broadcastDate" mode="json-encode"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>",</xsl:text>
                            
                            <xsl:text>"episodeNumber":</xsl:text><xsl:apply-templates select="plprogram:tvSeasonEpisodeNumber" mode="json-encode"/>
                            <xsl:text>,</xsl:text>
                            
                        </xsl:when>
                    </xsl:choose> 
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'movie'">
                            <xsl:text>"@id":"</xsl:text>
                            <xsl:call-template name="encodeTitle">
                                <xsl:with-param name="type" select="'movie'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template>/<xsl:call-template name="returnMpxId">
                                <xsl:with-param name="url" select="a:link/@href" mode="json-encode" />
                            </xsl:call-template>
                            
                            <xsl:text>",</xsl:text>
                            <xsl:text>"url":"</xsl:text>
                            <xsl:call-template name="encodeTitle">
                                <xsl:with-param name="type" select="'movie'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template>/<xsl:call-template name="returnMpxId">
                                <xsl:with-param name="url" select="a:link/@href" mode="json-encode" />
                            </xsl:call-template>
                            
                            <xsl:text>",</xsl:text>
                            <xsl:text>"name":"</xsl:text><xsl:apply-templates select="plprogram:longTitle" mode="json-encode"/>",
                        </xsl:when>
                    </xsl:choose> 
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'series'">
                            <xsl:text>"@id":"</xsl:text>
                            <xsl:call-template name="encodeTitle">
                                <xsl:with-param name="title" select="a:title" mode="json-encode" />
                                <xsl:with-param name="type" select="'series'"/>
                            </xsl:call-template>/<xsl:apply-templates select="a:guid" mode="json-encode"/><xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>
                            <xsl:text>",</xsl:text>
                            
                            <xsl:text>"url":"</xsl:text>
                            <xsl:call-template name="encodeTitle">
                                <xsl:with-param name="title" select="a:title" mode="json-encode" />
                                <xsl:with-param name="type" select="'series'"/>
                            </xsl:call-template>/<xsl:apply-templates select="a:guid" mode="json-encode"/><xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>
                            <xsl:text>",</xsl:text>
                            
                            <xsl:text>"name":"</xsl:text>
                            <xsl:apply-templates select="a:title" mode="json-encode" />
                            <xsl:text>",</xsl:text>
                        </xsl:when>
                    </xsl:choose> 
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode'">
                            <xsl:variable name="seasonNumber">
                                <xsl:choose>
                                    <xsl:when test="normalize-space(plprogram:tvSeasonNumber) != ''">
                                        <xsl:value-of select="plprogram:tvSeasonNumber"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="plprogram:year"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:if test="plprogram:tvSeasonNumber!=''">
                                <xsl:text>  "partOfSeason": {
                    "@type": "TVSeason",
                    "@id": "</xsl:text>
                                <xsl:call-template name="encodeTitle">
                                    <xsl:with-param name="type" select="'series'"/>
                                    <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                                </xsl:call-template>/<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>?seasonguid=<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>_<xsl:value-of select="format-number($seasonNumber,'00')"/>",
                                <xsl:text>"seasonNumber":</xsl:text><xsl:value-of select="$seasonNumber"/>
                                },
                            </xsl:if>
                            <xsl:if test="plprogram:tvSeasonNumber=''">
                                <xsl:text>  "partOfSeason": {
                    "@type": "TVSeason",
                    "@id": "</xsl:text>
                                <xsl:call-template name="encodeTitle">
                                    <xsl:with-param name="type" select="'series'"/>
                                    <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                                </xsl:call-template>/<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>?season=1",
                                <xsl:text>"seasonNumber":1</xsl:text>
                                },
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose> 
                    
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode'">
                            <xsl:text>  "partOfSeries": {
                "@type": "TVSeries",
                "@id": "</xsl:text>
                            <xsl:call-template name="encodeTitle">
                                <xsl:with-param name="type" select="'series'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />       
                            </xsl:call-template>/<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>",
                            
                            <xsl:text>"name":"</xsl:text><xsl:apply-templates select="plprogram:longTitle" mode="json-encode"/>"
                            },
                        </xsl:when>
                    </xsl:choose> 
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode'">
                            "potentialAction": {
                            "@type": "WatchAction",
                            "target": [
                            {
                            "@type": "EntryPoint",
                            "urlTemplate":"<xsl:call-template name="encodeTitleAndroidTv">
                                <xsl:with-param name="type" select="'series'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template>/<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>?epguid=<xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>/play",
                            "inLanguage": "en",
                            "actionPlatform": [
                            "http://schema.org/AndroidTVPlatform"
                            ]
                            },
                            {
                            "@type": "EntryPoint",
                            "urlTemplate":"<xsl:call-template name="encodeTitle">
                                <xsl:with-param name="type" select="'series'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template>/<xsl:apply-templates select="rte:relatedProgramGuid" mode="json-encode"/>?epguid=<xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>/play",
                            "inLanguage": "en",
                            "actionPlatform": [
                            "http://schema.org/DesktopWebPlatform",
                            "http://schema.org/MobileWebPlatform",
                            "http://schema.org/AndroidPlatform",
                            "http://schema.org/IOSPlatform"
                            ]
                            }
                            ],
                            "actionAccessibilityRequirement": {
                            "@type": "ActionAccessSpecification",
                            "category": "free",
                            "availabilityStarts":"<xsl:call-template name="returnStart">
                                <xsl:with-param name="dateString" select="plprogramavailability:media/dcterms:valid" mode="json-encode" />
                            </xsl:call-template>",
                            "availabilityEnds": "<xsl:call-template name="returnEnd">
                                <xsl:with-param name="dateString" select="plprogramavailability:media/dcterms:valid" mode="json-encode" />
                            </xsl:call-template>",
                            "eligibleRegion": [
                            {
                            "@type": "Country",
                            "name": "IE"
                            }
                            ]
                            }
                            },
                            
                        </xsl:when>
                    </xsl:choose> 
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'series'">
                            "potentialAction": {
                            "@type": "WatchAction",
                            "target": [
                            {
                            "@type": "EntryPoint",
                            "urlTemplate":"<xsl:call-template name="encodeTitleAndroidTv">
                                <xsl:with-param name="type" select="'series'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template><xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>/play",
                            "inLanguage": "en",
                            "actionPlatform": [
                            "http://schema.org/AndroidTVPlatform"
                            ]
                            },
                            {
                            "@type": "EntryPoint",
                            "urlTemplate":"<xsl:call-template name="encodeTitle">
                                <xsl:with-param name="type" select="'series'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template><xsl:call-template name="guidFormat">
                                <xsl:with-param name="id" select="a:id" mode="json-encode" />
                            </xsl:call-template>/play",
                            "inLanguage": "en",
                            "actionPlatform": [
                            "http://schema.org/DesktopWebPlatform",
                            "http://schema.org/MobileWebPlatform",
                            "http://schema.org/AndroidPlatform",
                            "http://schema.org/IOSPlatform"
                            ]
                            }
                            ],
                            "actionAccessibilityRequirement": {
                            "@type": "ActionAccessSpecification",
                            "category": "free",
                            "availabilityStarts":"<xsl:call-template name="returnStart">
                                <xsl:with-param name="dateString" select="plprogramavailability:media/dcterms:valid" mode="json-encode" />
                            </xsl:call-template>",
                            "availabilityEnds": "<xsl:call-template name="returnEnd">
                                <xsl:with-param name="dateString" select="plprogramavailability:media/dcterms:valid" mode="json-encode" />
                            </xsl:call-template>",
                            "eligibleRegion": [
                            {
                            "@type": "Country",
                            "name": "IE"
                            }
                            ]
                            }
                            },
                            
                        </xsl:when>
                    </xsl:choose> 
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'movie'">
                            "potentialAction": {
                            "@type": "WatchAction",
                            "target": [
                            {
                            "@type": "EntryPoint",
                            "urlTemplate":"<xsl:call-template name="encodeTitleAndroidTv">
                                <xsl:with-param name="type" select="'movie'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template>/<xsl:call-template name="returnMpxId">
                                <xsl:with-param name="url" select="a:link/@href" mode="json-encode" />
                            </xsl:call-template>/play",
                            "inLanguage": "en",
                            "actionPlatform": [
                            "http://schema.org/AndroidTVPlatform"
                            ]
                            },
                            {
                            "@type": "EntryPoint",
                            "urlTemplate":"<xsl:call-template name="encodeTitle">
                                <xsl:with-param name="type" select="'movie'"/>
                                <xsl:with-param name="title" select="plprogram:longTitle" mode="json-encode" />
                            </xsl:call-template>/<xsl:call-template name="returnMpxId">
                                <xsl:with-param name="url" select="a:link/@href" mode="json-encode" />
                            </xsl:call-template>/play",
                            "inLanguage": "en",
                            "actionPlatform": [
                            "http://schema.org/DesktopWebPlatform",
                            "http://schema.org/MobileWebPlatform",
                            "http://schema.org/AndroidPlatform",
                            "http://schema.org/IOSPlatform"
                            ]
                            }
                            ],
                            
                            "actionAccessibilityRequirement": {
                            "@type": "ActionAccessSpecification",
                            "category": "free",
                            "availabilityStarts":"<xsl:call-template name="returnStart">
                                <xsl:with-param name="dateString" select="plprogramavailability:media/dcterms:valid" mode="json-encode" />
                            </xsl:call-template>",
                            "availabilityEnds": "<xsl:call-template name="returnEnd">
                                <xsl:with-param name="dateString" select="plprogramavailability:media/dcterms:valid" mode="json-encode" />
                            </xsl:call-template>",
                            "eligibleRegion": [
                            {
                            "@type": "Country",
                            "name": "IE"
                            }
                            ]
                            }
                            },
                        </xsl:when>
                    </xsl:choose> 
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode' or plprogram:programType = 'movie'">
                            <xsl:text>"duration":"</xsl:text><xsl:call-template name="returnDuration">
                                <xsl:with-param name="inputDuration" select="plprogram:runtime" mode="json-encode" />
                            </xsl:call-template>",
                        </xsl:when>
                    </xsl:choose> 
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode' or plprogram:programType = 'movie'">
                            <xsl:text>"description":"</xsl:text>
                            <xsl:apply-templates select="plprogram:longDescription" mode="json-encode" />
                            <xsl:text>",</xsl:text>
                        </xsl:when>
                    </xsl:choose>             
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'series'">
                            <xsl:text>"description":"</xsl:text>
                            <xsl:apply-templates select="a:summary" mode="json-encode" />
                            <xsl:text>",</xsl:text>
                        </xsl:when>
                    </xsl:choose>   
                    <xsl:variable name="mpxTitle" select="a:title"/>
                    
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'episode'">
                            
                            
                            "image": [
                            
                            {
                            "@context": "http://schema.org",
                            "@type": "ImageObject",
                            "name": "<xsl:value-of select="$mpxTitle" /> episodic 16:9",
                            "contentUrl": "<xsl:call-template name="imageFormat">
                                <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                            </xsl:call-template>",
                            "additionalProperty": [
                            {
                            "@type": "PropertyValue",
                            "name": "contentAttributes",
                            "value": ["iconic","poster", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                            }
                            ]
                            },
                            
                            {
                            "@context": "http://schema.org",
                            "@type": "ImageObject",
                            "name": "<xsl:value-of select="$mpxTitle" /> episodic 2:3",
                            "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                <xsl:with-param name="width" select="'1000'"/>
                                <xsl:with-param name="height" select="'1500'"/>
                                <xsl:with-param name="gravity" select="'auto'"/>
                                <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                            </xsl:call-template>",
                            "additionalProperty": [
                            {
                            "@type": "PropertyValue",
                            "name": "contentAttributes",
                            "value": ["iconic","poster", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                            }
                            ]
                            },
                            
                            {
                            "@context": "http://schema.org",
                            "@type": "ImageObject",
                            "name": "<xsl:value-of select="$mpxTitle" /> episodic 4:3",
                            "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                <xsl:with-param name="width" select="'800'"/>
                                <xsl:with-param name="height" select="'600'"/>
                                <xsl:with-param name="gravity" select="'top'"/>
                                <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                            </xsl:call-template>",
                            "additionalProperty": [
                            {
                            "@type": "PropertyValue",
                            "name": "contentAttributes",
                            "value": ["iconic","poster", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                            }
                            ]
                            }                     
                            ]
                            
                        </xsl:when>
                    </xsl:choose> 
                    
                    
                    
                    <xsl:choose>
                        <xsl:when test="plprogram:programType = 'series' or plprogram:programType = 'movie'">
                            
                            
                            "image": [
                            
                            <xsl:if test="rte:thumbnails/rte:key= 'title card'">
                                
                                {
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> image with logo 16:9",
                                "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                    <xsl:with-param name="width" select="'3840'"/>
                                    <xsl:with-param name="height" select="'2160'"/>
                                    <xsl:with-param name="gravity" select="'top'"/>
                                    <xsl:with-param name="image" select="rte:thumbnails[rte:key='title card']/rte:value" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["iconic","poster", "centered", "smallFormat", "largeFormat", "hasTitle", "hasLogo"]
                                }
                                ]
                                }
                                
                                
                            </xsl:if>
                            <xsl:if test="not(rte:thumbnails/rte:key= 'title card')">
                                
                                {
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> 16:9",
                                "contentUrl": "<xsl:call-template name="imageFormat">
                                    <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["iconic","poster", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                                }
                                ]
                                }
                            </xsl:if>
                            <xsl:if test="rte:thumbnails/rte:key= 'master_boxart'">
                                
                                ,{
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> image with logo 2:3",
                                "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                    <xsl:with-param name="width" select="'1000'"/>
                                    <xsl:with-param name="height" select="'1500'"/>
                                    <xsl:with-param name="gravity" select="'top'"/>
                                    <xsl:with-param name="image" select="rte:thumbnails[rte:key='master_boxart']/rte:value" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["iconic","poster", "centered", "smallFormat", "largeFormat", "hasTitle", "hasLogo"]
                                }
                                ]
                                }
                                
                                ,{
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> image with logo 3:4",
                                "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                    <xsl:with-param name="width" select="'600'"/>
                                    <xsl:with-param name="height" select="'800'"/>
                                    <xsl:with-param name="gravity" select="'top'"/>
                                    <xsl:with-param name="image" select="rte:thumbnails[rte:key='master_boxart']/rte:value" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["iconic","poster", "centered", "smallFormat", "largeFormat", "hasTitle", "hasLogo"]
                                }
                                ]
                                }
                                
                            </xsl:if>
                            <xsl:if test="not(rte:thumbnails/rte:key= 'master_boxart')">
                                
                                ,{
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> 2:3",
                                "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                    <xsl:with-param name="width" select="'1000'"/>
                                    <xsl:with-param name="height" select="'1500'"/>
                                    <xsl:with-param name="gravity" select="'auto'"/>
                                    <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["iconic","poster", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                                }
                                ]
                                }
                                
                                ,{
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> 3:4",
                                "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                    <xsl:with-param name="width" select="'600'"/>
                                    <xsl:with-param name="height" select="'800'"/>
                                    <xsl:with-param name="gravity" select="'top'"/>
                                    <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["iconic","poster", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                                }
                                ]
                                }
                                
                            </xsl:if>
                            
                            <xsl:if test="rte:thumbnails/rte:key= 'show_logo'">
                                
                                ,{
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> logo 1:1",
                                "contentUrl": "<xsl:call-template name="imageFormatCropPng">
                                    <xsl:with-param name="width" select="'600'"/>
                                    <xsl:with-param name="height" select="'600'"/>
                                    <xsl:with-param name="gravity" select="'top'"/>
                                    <xsl:with-param name="image" select="rte:thumbnails[rte:key='show_logo']/rte:value" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["logo", "hasTitle", "hasLogo", "noMatte", "centered", "transparentBackground", "forLightBackground", "forDarkBackground", "smallFormat", "largeFormat"]
                                }
                                ]
                                }
                                
                                ,{
                                "@context": "http://schema.org",
                                "@type": "ImageObject",
                                "name": "<xsl:value-of select="$mpxTitle" /> logo 9:5",
                                "contentUrl": "<xsl:call-template name="imageFormatCropPng">
                                    <xsl:with-param name="width" select="'1800'"/>
                                    <xsl:with-param name="height" select="'1000'"/>
                                    <xsl:with-param name="gravity" select="'top'"/>
                                    <xsl:with-param name="image" select="rte:thumbnails[rte:key='show_logo']/rte:value" mode="json-encode" />
                                </xsl:call-template>",
                                "additionalProperty": [
                                {
                                "@type": "PropertyValue",
                                "name": "contentAttributes",
                                "value": ["logo", "hasTitle", "hasLogo", "noMatte", "centered", "transparentBackground", "forLightBackground", "forDarkBackground", "smallFormat", "largeFormat"]
                                }
                                ]
                                }
                                
                            </xsl:if>
                            ,{
                            "@context": "http://schema.org",
                            "@type": "ImageObject",
                            "name": "<xsl:value-of select="$mpxTitle" /> 4:3",
                            "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                <xsl:with-param name="width" select="'800'"/>
                                <xsl:with-param name="height" select="'600'"/>
                                <xsl:with-param name="gravity" select="'top'"/>
                                <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                            </xsl:call-template>",
                            "additionalProperty": [
                            {
                            "@type": "PropertyValue",
                            "name": "contentAttributes",
                            "value": ["iconic","poster", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                            }
                            ]
                            },
                            
                            {
                            "@context": "http://schema.org",
                            "@type": "ImageObject",
                            "name": "<xsl:value-of select="$mpxTitle" /> 16:19 background",
                            "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                <xsl:with-param name="width" select="'3840'"/>
                                <xsl:with-param name="height" select="'2160'"/>
                                <xsl:with-param name="gravity" select="'top'"/>
                                <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                            </xsl:call-template>",
                            "additionalProperty": [
                            {
                            "@type": "PropertyValue",
                            "name": "contentAttributes",
                            "value": ["iconic", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                            }
                            ]
                            },
                            {
                            "@context": "http://schema.org",
                            "@type": "ImageObject",
                            "name": "<xsl:value-of select="$mpxTitle" /> 2:3 background",
                            "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                <xsl:with-param name="width" select="'1000'"/>
                                <xsl:with-param name="height" select="'1500'"/>
                                <xsl:with-param name="gravity" select="'top'"/>
                                <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                            </xsl:call-template>",
                            "additionalProperty": [
                            {
                            "@type": "PropertyValue",
                            "name": "contentAttributes",
                            "value": ["iconic", "background", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                            }
                            ]
                            }
                            <xsl:choose>
                                <xsl:when test="plprogram:programType = 'series'">
                                    ,{
                                    "@context": "http://schema.org",
                                    "@type": "ImageObject",
                                    "name": "<xsl:value-of select="$mpxTitle" /> 1:1",
                                    "contentUrl": "<xsl:call-template name="imageFormatCrop">
                                        <xsl:with-param name="width" select="'600'"/>
                                        <xsl:with-param name="height" select="'600'"/>
                                        <xsl:with-param name="gravity" select="'top'"/>
                                        <xsl:with-param name="image" select="rte:defaultThumbnail" mode="json-encode" />
                                    </xsl:call-template>",
                                    "additionalProperty": [
                                    {
                                    "@type": "PropertyValue",
                                    "name": "contentAttributes",
                                    "value": ["iconic", "poster", "centered", "smallFormat", "largeFormat", "noTitle", "noLogo"]
                                    }
                                    ]
                                    }
                                    
                                </xsl:when>
                            </xsl:choose> 
                            
                            ]
                            
                        </xsl:when>
                    </xsl:choose>
                    
                    
                    <xsl:text>}</xsl:text>

            
            <!-- Here we'll check to see if we're processing the last media of the last segment,
                 and if so we'll leave off the comma. Otherwise it gets inserted to separate this 
                 object from the next one in the JSON array. -->
            <xsl:if test="position()!=last() or $tpIsLastSegment='false'">
                <xsl:text>,</xsl:text>
            </xsl:if>

        </xsl:for-each>
        <!--
             And close out the marker after processing the items in the feed.
        -->
        <xsl:text>&lt;thePlatformFeedMarker/></xsl:text>
        <xsl:text>]}</xsl:text>
        
        <xsl:if test="$callback and not($callback = '')">
            <xsl:if test="$context and not($context = '')">
                <xsl:text>,"</xsl:text>
                <xsl:call-template name="json-encode">
                    <xsl:with-param name="text" select="$context" />
                </xsl:call-template>
                <xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- This can be called with apply-templates or call-template w/ the text param -->
    <xsl:template match="*" name="json-encode" mode="json-encode">
        <xsl:param name="text" />
        <xsl:variable name="s">
            <xsl:choose>
                <xsl:when test="$text and not($text = '')">
                    <xsl:value-of select="$text" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doublequote">"</xsl:variable>
        <xsl:variable name="j1" select="jString:new($s)" />
        <xsl:variable name="s1" select="jString:replaceAll($j1, '\\', '\\\\')" />
        <xsl:variable name="j2" select="jString:new($s1)" />
        <xsl:variable name="s2" select="jString:replaceAll($j2, $doublequote, concat('\\', $doublequote))" />
        <xsl:variable name="j3" select="jString:new($s2)" />
        <xsl:variable name="s3" select="jString:replaceAll($j3, '/', '\\/')" />
        <xsl:variable name="j4" select="jString:new($s3)" />
        <xsl:variable name="s4" select="jString:replaceAll($j4, '\n', '\\n')" />
        <xsl:variable name="j5" select="jString:new($s4)" />
        <xsl:variable name="s5" select="jString:replaceAll($j5, '\r', '\\r')" />
        <xsl:variable name="j6" select="jString:new($s5)" />
        <xsl:variable name="s6" select="jString:replaceAll($j6, '\f', '\\f')" />
        <xsl:variable name="j7" select="jString:new($s6)" />
        <xsl:variable name="s7" select="jString:replaceAll($j7, '\t', '\\t')" />
        <!--
             <xsl:variable name="j8" select="jString:new($s7)"/>
             <xsl:variable name="s8" select="jString:replaceAll($j8, '[\b]', '\\b')" />
        -->
        <xsl:value-of select="$s7" />
    </xsl:template>
    <xsl:template name="imageFormat">
        <xsl:param name="image" />
        <xsl:variable name="formattedImage" select="concat(substring-before($image,'.jpg'),'-2160.jpg')" />
        <xsl:value-of select="$formattedImage" />
    </xsl:template>
    <xsl:template name="imageFormatCrop">
        <xsl:param name="image" />
        <xsl:param name="height" />
        <xsl:param name="width" />
        <xsl:param name="gravity" />
        <xsl:variable name ="newImagehost" select="concat('https://rte.ie/pg-image-test/',substring-after($image,'https://img.rasset.ie/'))"/>
        <xsl:variable name="dimensions" select="concat(concat(concat(concat(concat(concat(concat('-x',$width),'-y'),$height),'.jpg'),'?'),'g='),$gravity)"/>
        <xsl:variable name="formattedImage" select="concat(substring-before($newImagehost,'.jpg'),$dimensions)" />
        <xsl:value-of select="$formattedImage" />
    </xsl:template>
    <xsl:template name="imageFormatCropPng">
        <xsl:param name="image" />
        <xsl:param name="height" />
        <xsl:param name="width" />
        <xsl:param name="gravity" />
        <xsl:variable name ="newImagehost" select="concat(substring-before(concat('https://rte.ie/pg-image-test/',substring-after($image,'https://img.rasset.ie/')),'-full.png'),'.png')"/>
        <xsl:variable name="dimensions" select="concat(concat(concat(concat(concat(concat(concat('-x',$width),'-y'),$height),'.png'),'?'),'g='),$gravity)"/>
        <xsl:variable name="formattedImage" select="concat(substring-before($newImagehost,'.png'),$dimensions)" />
        <xsl:value-of select="$formattedImage" />
    </xsl:template>
    <xsl:template name="availEnd">
        <xsl:param name="availTime" />
        <xsl:variable name="pattern">yyyy-MM-dd'T'HH:mm:ss'Z'</xsl:variable>
        <xsl:variable name="format" select="sdf:new($pattern)" />
        <xsl:variable name="dateString" select="substring-before(substring-after($availTime,'end='),';scheme=W3C-DTF')" />
        <xsl:variable name="parsedDate" select="sdf:parse($format, $dateString)" />
        <xsl:variable name="calendar" select="gCalendar:new()" />
        <xsl:value-of select="gCalendar:setTime($calendar, $parsedDate)" />
        <xsl:value-of select="gCalendar:getTimeInMillis($calendar)" />
    </xsl:template>
    <xsl:template name="formatTime">
        <xsl:param name="txTime" />
        <xsl:variable name="pattern">yyyy-MM-dd'T'HH:mm:ss'Z'</xsl:variable>
        <xsl:variable name="displayPattern">EEE, dd MMM</xsl:variable>
        <xsl:variable name="format" select="sdf:new($pattern)" />
        <xsl:variable name="displayFormat" select="sdf:new($displayPattern)" />
        <xsl:variable name="parsedDate" select="sdf:parse($format, $txTime)" />
        <xsl:value-of select="sdf:format($displayFormat, $parsedDate)" />
    </xsl:template> 
    <xsl:template name="guidFormat">
        <xsl:param name="id" />
        <xsl:variable name="formattedGuid" select="substring-after($id,'guid:')" />
        <xsl:value-of select="$formattedGuid" />
    </xsl:template>
    <xsl:template name="encodeTitle">
        <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
        <xsl:variable name="chars" select="'!*;:@=+$,/?%#&amp;'"/>
        <xsl:param name="title" />
        <xsl:param name="type" />
        <xsl:variable name="formattedTitle" select="concat(translate($title, ' ', '-'), '')" />
        <xsl:variable name="cleanedTitle" select="translate($formattedTitle, $chars, '')"/>
        <xsl:value-of select="concat('https://www.rte.ie/player/',$type,'/',translate($cleanedTitle, $uppercase, $lowercase))" />
    </xsl:template>
    <xsl:template name="encodeTitleAndroidTv">
        <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
        <xsl:variable name="chars" select="'!*;:@=+$,/?%#&amp;'"/>
        <xsl:param name="title" />
        <xsl:param name="type" />
        <xsl:variable name="formattedTitle" select="concat(translate($title, ' ', '-'), '')" />
        <xsl:variable name="cleanedTitle" select="translate($formattedTitle, $chars, '')"/>
        <xsl:value-of select="concat('https://www.rte.ie/rpng-static/ctv/androidTV/',$type,'/',translate($cleanedTitle, $uppercase, $lowercase))" />
    </xsl:template>
    <xsl:template name="returnMpxId">
        <xsl:param name="url"/>
        <!-- Check if there is another slash after the current segment -->
        <xsl:choose>
            <xsl:when test="contains($url, '/')">
                <!-- Recursively call this template, removing the first segment of the URL -->
                <xsl:call-template name="returnMpxId">
                    <xsl:with-param name="url" select="substring-after($url, '/')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- If no more slashes, this is the last segment -->
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="returnStart">
        <xsl:param name="dateString" />
        <xsl:variable name="startDatePart" select="substring-after($dateString, 'start=')"/>
        <xsl:variable name="startDate" select="substring-before($startDatePart, ';')"/>
        <xsl:value-of select="$startDate" />
    </xsl:template>
    <xsl:template name="returnEnd">
        <xsl:param name="dateString" />
        <xsl:variable name="endDatePart" select="substring-after($dateString, 'end=')"/>
        <xsl:variable name="endDate" select="substring-before($endDatePart, ';')"/>
        <xsl:value-of select="$endDate" />
    </xsl:template>
    <xsl:template name="returnDuration">
        <xsl:param name="inputDuration" />
        <xsl:variable name="totalSeconds" select="number($inputDuration)"/>
        <xsl:variable name="hours" select="floor($totalSeconds div 3600)"/>
        <xsl:variable name="minutes" select="floor(($totalSeconds mod 3600) div 60)"/>
        <xsl:value-of select="concat('PT',format-number($hours,'00'),'H',format-number($minutes,'00'),'M')"/>
    </xsl:template>
</xsl:stylesheet>