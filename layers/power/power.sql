CREATE OR REPLACE FUNCTION layer_power(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, class text) AS $$

	SELECT geometry, class FROM (
	
		SELECT geometry, class
    	FROM osm_power_linestring
    	WHERE zoom_level >= 12
    	UNION ALL 
    	
    	SELECT geometry, class
    	FROM osm_power_point
    	WHERE zoom_level >= 12
    	UNION ALL
    	
    	SELECT geometry, class
    	FROM osm_power_polygon
    	WHERE zoom_level >= 12
	
	) AS zoom_levels
	WHERE geometry && bbox;
    
$$ LANGUAGE SQL IMMUTABLE;
