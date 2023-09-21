CREATE OR REPLACE FUNCTION length_formatted_text(geometry geometry, metric boolean) RETURNS text AS
$$
SELECT CASE
		WHEN ST_IsValid(geometry) 
			THEN CASE
				WHEN metric = true THEN ROUND((ST_Length(geometry)/1000)::numeric,2)::text
				WHEN metric = false THEN ROUND((ST_Length(geometry)/1609.344)::numeric,2)::text
				END
	END;
$$ LANGUAGE SQL IMMUTABLE
                STRICT
                PARALLEL SAFE;
                
CREATE OR REPLACE FUNCTION length_text(geometry geometry) RETURNS text AS
$$
SELECT CASE
		WHEN ST_IsValid(geometry) 
			THEN TRUNC(ST_Length(geometry))::text
	END;
$$ LANGUAGE SQL IMMUTABLE
                STRICT
                PARALLEL SAFE;


-- Delete ways that are part of a relation
DELETE FROM osm_hiking_biking_linestring
WHERE osm_id IN (SELECT way_id FROM osm_hiking_biking_relation);

-- Precalculate lengths for all geometries
ALTER TABLE osm_hiking_biking_linestring ADD COLUMN IF NOT EXISTS length_mi text;
ALTER TABLE osm_hiking_biking_linestring ADD COLUMN IF NOT EXISTS length_km text;
ALTER TABLE osm_hiking_biking_linestring ADD COLUMN IF NOT EXISTS length_m text;
UPDATE osm_hiking_biking_linestring SET length_mi = length_formatted_text(geometry, false), length_km = length_formatted_text(geometry, true), length_m = length_text(geometry);

ALTER TABLE osm_hiking_biking_relation ADD COLUMN IF NOT EXISTS length_mi text;
ALTER TABLE osm_hiking_biking_relation ADD COLUMN IF NOT EXISTS length_km text;
ALTER TABLE osm_hiking_biking_relation ADD COLUMN IF NOT EXISTS length_m text;
UPDATE osm_hiking_biking_relation SET length_mi = length_formatted_text(geometry, false), length_km = length_formatted_text(geometry, true), length_m = length_text(geometry);

-- Function for layer query
CREATE OR REPLACE FUNCTION layer_hiking_biking(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, 
	osmcsymbol text,
	osmcsymbol_way_color text,
	osmcsymbol_background text,
	osmcsymbol_foreground text,
	osmcsymbol_foreground2 text,
	osmcsymbol_text text,
	osmcsymbol_text_color text,
	route text, 
	network text,
	length_m text,
	length_mi text,
	length_km text) AS $$
    	
    SELECT geometry, 
    NULLIF(osmcsymbol, ''),
    NULLIF(SPLIT_PART(osmcsymbol,':', 1), '') AS osmcsymbol_way_color,
	NULLIF(SPLIT_PART(osmcsymbol,':', 2), '') AS osmcsymbol_background,
	NULLIF(SPLIT_PART(osmcsymbol,':', 3), '') AS osmcsymbol_foreground,
	NULLIF(SPLIT_PART(osmcsymbol,':', 4), '') AS osmcsymbol_foreground2,
	NULLIF(SPLIT_PART(osmcsymbol,':', 5), '') AS osmcsymbol_text,
	NULLIF(SPLIT_PART(osmcsymbol,':', 6), '') AS osmcsymbol_text_color,
    NULLIF(route, ''), 
    NULLIF(network, ''),
   	length_m,
   	length_mi,
   	length_km
    FROM osm_hiking_biking_relation
    WHERE zoom_level >= 14 AND geometry && bbox
    UNION ALL
    
    SELECT geometry, 
    NULLIF(osmcsymbol, ''),
    NULLIF(SPLIT_PART(osmcsymbol,':', 1), '') AS osmcsymbol_way_color,
	NULLIF(SPLIT_PART(osmcsymbol,':', 2), '') AS osmcsymbol_background,
	NULLIF(SPLIT_PART(osmcsymbol,':', 3), '') AS osmcsymbol_foreground,
	NULLIF(SPLIT_PART(osmcsymbol,':', 4), '') AS osmcsymbol_foreground2,
	NULLIF(SPLIT_PART(osmcsymbol,':', 5), '') AS osmcsymbol_text,
	NULLIF(SPLIT_PART(osmcsymbol,':', 6), '') AS osmcsymbol_text_color,
    NULLIF(route, ''), 
    NULLIF(network, ''),
   	length_m,
   	length_mi,
   	length_km
    FROM osm_hiking_biking_linestring
    WHERE zoom_level >= 14 AND geometry && bbox 
    
$$ LANGUAGE SQL IMMUTABLE;
