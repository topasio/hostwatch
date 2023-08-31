#!/bin/bash

cd ~/hostwatch

source hostwatch.cfg

for target in ${targets}
do
	host=$(echo ${target} | cut -d: -f1)
	name=$(echo ${target} | cut -d: -f2)
	cur=data/${name}.cur
	last=data/${name}.last
	diff=data/${name}.diff
	touch ${cur}
	mv ${cur} ${last}
	curl -s -g -X 'GET' \
	"https://search.censys.io/api/v2/hosts/search?per_page=25&virtual_hosts=EXCLUDE&q=${host}" \
	-H 'Accept: application/json' \
	--user "$CENSYS_API_ID:$CENSYS_API_SECRET" | jq -r '.result.hits[] | .ip, .services' > ${cur}

	diff ${cur} ${last} > ${diff}
	if [ $? -eq 1 ]; then
		cat ${cur} ${diff} | mail -s "hostwatch change ${name}" ${email}
	fi
done
