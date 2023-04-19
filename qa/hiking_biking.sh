#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

layerid="hiking_biking"
z=14

SQL=$(docker run --rm -v $(pwd):/tileset openmaptiles/openmaptiles-tools generate-sqlquery layers/${layerid}/${layerid}.yaml $z ) 

SQLCODE=$(cat <<-END
SELECT 
name, osmcsymbol, length_m
FROM  
( $SQL ) as t
WHERE osmcsymbol IS NULL
ORDER BY name ASC;
;
END
)


# echo "\`\`\`sql"
# echo "$SQLCODE"
# echo "\`\`\`"

docker-compose run --rm openmaptiles-tools psql.sh -q -P pager=off -P border=2 -P footer=off -P null='(null)' -c "$SQLCODE"
     
