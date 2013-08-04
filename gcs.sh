#!/bin/bash

# Use Google Custom Search API
# Sun Aug  4 20:04:22 BST 2013

# Requires curl and jq and PHP

# Feedback : <daren_github@REMOVEdazdaz.org>

PATH=$PATH:/bin:/usr/local/bin:/usr/bin:/usr/sbin
outputdir="/var/tmp"


trap 'my_exit; exit' SIGINT SIGQUIT

my_exit()
{
  echo "You hit Ctrl-C/Ctrl-\, now exiting..."
}

api_key="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
cx="yyyyyyyyyyyyyyyyyyyyy:yyyyyyyyyyy"

if [ $# -ne 2 ]; then
  echo "Usage: $0 search_query pagecount"
  echo ""
  echo "Each pagecount is equal to 10 output URL's from our search."
  echo ""
  echo "`basename $0` \"hotels asia -china\" 5"
  echo ""
  exit 1
fi

search_query_from_user=${1}
page_count_from_user=${2}

# Encode the search query
search_query=$(php -r "echo rawurlencode('$search_query_from_user');")

# Maximum of 10 URL's returned per search/page, so page 2 has URL 21 to 30
let "url_start = $page_count_from_user * 10"
declare -a array
array=($(seq 1 10 $url_start))

element=0
loop=1
while [ $element -le $((${#array[@]} - 1)) ]
do
  start_num=${array[$element]}		# URL start position
  curl "https://www.googleapis.com/customsearch/v1?key=${api_key}&cx=${cx}&q=${search_query}&filter=1&start=${start_num}&num=10&alt=json" > $outputdir/search${loop}.json
  element=$((element + 1))
  loop=$((loop + 1))
done


for filecount in `seq 1 $page_count_from_user`;
 do
  echo $filecount
  jq '.items[].link' $outputdir/search${filecount}.json | awk '{print substr($0, 2, length() - 2)}'
 done

