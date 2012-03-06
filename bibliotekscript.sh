#!/bin/bash

# quick book scan bash script for Koha
# by anden1 (https://github.com/anden1)
#
# start by filling in the username, password and ip of your koha


koha_login_context=intranet
logoutx=1

# FILL IN YOUR KOHA USERNAME HERE!
userid=

# FILL IN YOUR KOHA PASSWORD HERE!
password=

# THE IP AND PORT OF YOUR KOHA SERVER, FOR EXAMPLE server="192.168.0.2:80"
server=

wget -O /tmp/steg0 -q --post-data=koha_login_context=$koha_login_context\&logout.x=$logoutx\&userid=$userid\&password=$password\&branch= --keep-session-cookies --save-cookies /tmp/cookies http://$server/cgi-bin/koha/mainpage.pl
op="do_search"
echo ISBN Number to search for?
read isbn
biblionumber="0"
id="13"



wget -O /tmp/steg1 --load-cookies /tmp/cookies -q http://$server/cgi-bin/koha/cataloguing/z3950_search.pl?frameworkcode= --post-data=op=$op\&isbn=$isbn\&biblionumber=$biblionumber\&id=$id
echo
cat /tmp/steg1 | grep "Preview MARC" -A 3 | tail -3 | sed s/'.*<td>'// | sed s/'<\/td>'//
importid=`cat /tmp/steg1 | grep "tr id" | sed s/"\<tr\ id\=\"row"// | awk '{ print $1 }' | sed s/\<// | sed s/\"\>//`
biblioid=`cat /tmp/steg1 | grep "form method" | awk '{ print $6 }' | sed s/'value\=\"'// | sed s/'\"\/><input'//`
steg2url="http://$server/cgi-bin/koha/`cat /tmp/steg1 | grep opener | sed s/'\.\/'/'\ '/ | awk '{ print $2 }' | sed s/'\"+biblionumber+\"'/$biblioid/ | sed s/'\"+GetThisOne;'/$importid/`"
wget -q -O /tmp/steg2 --load-cookies /tmp/cookies $steg2url
stop=0
counter=3
echo
echo Select type of book \(or cancel with CTRL + C if the above is not correct\):
echo
while [ $stop != 1 ];
do
counter2=$(( $counter2 + 1 ))
cat /tmp/steg2 | grep "tag_942_subfield_c.*\".*tabindex" -A 9999 | head -$counter | tail -1 | grep "option value" > /dev/null || stop=1
if [ $stop != 1 ]; then
printf $counter2.\ 
fi
cat /tmp/steg2 | grep "tag_942_subfield_c.*\".*tabindex" -A 9999 | head -$counter | tail -1 | grep "option value" | grep "\<option value\=\"" | sed s/'<option.*\">'// | sed s/'<\/option>'//
export eval booktype$counter2=`cat /tmp/steg2 | grep 'tag_942_subfield_c.*\".*tabindex' -A 9999 | head -$counter | tail -1 | grep "option value" | sed s/'<option.*=\"'// | sed s/'\".*'//`
counter=$(( $counter + 1 ))
done
echo
read bookchoice
choice0=\$booktype$bookchoice
eval choice=$choice0
echo $choice
