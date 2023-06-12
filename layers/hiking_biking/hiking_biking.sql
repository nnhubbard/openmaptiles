CREATE OR REPLACE FUNCTION layer_hiking_biking(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, 
	name text,
	name_alt text,
	name_en text,
	name_de text,
	osmcsymbol text,
	osmcsymbol_way_color text,
	osmcsymbol_background text,
	osmcsymbol_foreground text,
	osmcsymbol_foreground2 text,
	osmcsymbol_text text,
	osmcsymbol_text_color text,
	route text, 
	network text) AS $$
    	
    SELECT geometry, 
    CASE WHEN length(name) > 15 THEN osml10n_street_abbrev_all(name) ELSE NULLIF(name, '') END AS "name",
    CASE WHEN length(name_alt) > 15 THEN osml10n_street_abbrev_all(name_alt) ELSE NULLIF(name_alt, '') END AS "name_alt",
    CASE WHEN length(name_en) > 15 THEN osml10n_street_abbrev_en(name_en) ELSE NULLIF(name_en, '') END AS "name_en",
    CASE WHEN length(name_de) > 15 THEN osml10n_street_abbrev_de(name_de) ELSE NULLIF(name_de, '') END AS "name_de",
    NULLIF(osmcsymbol, ''),
    NULLIF(SPLIT_PART(osmcsymbol,':', 1), '') AS osmcsymbol_way_color,
	NULLIF(SPLIT_PART(osmcsymbol,':', 2), '') AS osmcsymbol_background,
	NULLIF(SPLIT_PART(osmcsymbol,':', 3), '') AS osmcsymbol_foreground,
	NULLIF(SPLIT_PART(osmcsymbol,':', 4), '') AS osmcsymbol_foreground2,
	NULLIF(SPLIT_PART(osmcsymbol,':', 5), '') AS osmcsymbol_text,
	NULLIF(SPLIT_PART(osmcsymbol,':', 6), '') AS osmcsymbol_text_color,
    NULLIF(route, ''), 
    NULLIF(network, '')
    FROM osm_hiking_biking_relation
    WHERE zoom_level >= 14 AND geometry && bbox
    UNION ALL
    
    SELECT geometry, 
    CASE WHEN length(name) > 15 THEN osml10n_street_abbrev_all(name) ELSE NULLIF(name, '') END AS "name",
    CASE WHEN length(name_alt) > 15 THEN osml10n_street_abbrev_all(name_alt) ELSE NULLIF(name_alt, '') END AS "name_alt",
    CASE WHEN length(name_en) > 15 THEN osml10n_street_abbrev_en(name_en) ELSE NULLIF(name_en, '') END AS "name_en",
    CASE WHEN length(name_de) > 15 THEN osml10n_street_abbrev_de(name_de) ELSE NULLIF(name_de, '') END AS "name_de",
    NULLIF(osmcsymbol, ''),
    NULLIF(SPLIT_PART(osmcsymbol,':', 1), '') AS osmcsymbol_way_color,
	NULLIF(SPLIT_PART(osmcsymbol,':', 2), '') AS osmcsymbol_background,
	NULLIF(SPLIT_PART(osmcsymbol,':', 3), '') AS osmcsymbol_foreground,
	NULLIF(SPLIT_PART(osmcsymbol,':', 4), '') AS osmcsymbol_foreground2,
	NULLIF(SPLIT_PART(osmcsymbol,':', 5), '') AS osmcsymbol_text,
	NULLIF(SPLIT_PART(osmcsymbol,':', 6), '') AS osmcsymbol_text_color,
    NULLIF(route, ''), 
    NULLIF(network, '')
    FROM osm_hiking_biking_linestring
    WHERE zoom_level >= 14 
    	AND geometry && bbox 
    	AND osmcsymbol = '' OR osmcsymbol IS NULL
    
$$ LANGUAGE SQL IMMUTABLE;
