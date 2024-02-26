-- Function for layer query
CREATE OR REPLACE FUNCTION layer_cachly_pro(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, 
	historic text,
	barrier text,
	building text) AS $$
    	
    SELECT geometry, 
    NULLIF(historic, '') AS historic,
    NULLIF(barrier, '') AS barrier,
    NULLIF(building, '') AS building
    FROM osm_cachly_pro_linestring
    WHERE zoom_level >= 14 AND geometry && bbox
    
    UNION ALL
    
    SELECT geometry, 
    NULLIF(historic, '') AS historic,
    NULLIF(barrier, '') AS barrier,
    NULLIF(building, '') AS building
    FROM osm_cachly_pro_polygon
   	WHERE building = '' AND zoom_level >= 14 AND geometry && bbox
    
$$ LANGUAGE SQL IMMUTABLE;
