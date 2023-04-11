CREATE OR REPLACE FUNCTION layer_skiing(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, class text, name text, pistetype text, pistedifficulty text) AS $$
    
    SELECT geometry, 
    CASE WHEN pistetype = '' THEN class ELSE 'piste' END,
    NULLIF(name, ''), 
    NULLIF(pistetype, ''),
    NULLIF(pistedifficulty, '')
    FROM osm_skiing_linestring
    WHERE zoom_level >= 12 AND geometry && bbox
    UNION ALL
    
    SELECT geometry, class, NULL AS name, NULL AS pistetype, NULL AS pistedifficulty
    FROM osm_skiing_point
    WHERE zoom_level >= 12 AND geometry && bbox;
    
$$ LANGUAGE SQL IMMUTABLE;
