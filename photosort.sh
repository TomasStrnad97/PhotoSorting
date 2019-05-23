#!/bin/dash


usage() {
    echo ""
    echo "Usage: photosort [OPTIONS] [DIRECTORY]"
    echo "Sorts photos into directories by the date of creation"
    echo ""
    echo "Default directory is current directory"
    echo "With no options sorts by months and days"
    echo "OPTIONS:"
    echo "   --help          prints usage"
    echo "   -h, --hours     sorts by hours"
    echo "   -d, --days      sorts by days"
    echo "   -m, --months    sorts by months"
    echo "   -y  --years     sorts by years"
    echo "   --prefix=PREF   adds PREF as a name prefix to each image"
    echo ""
}

OPTS=""
newDir=""
while [ "$#" -gt 0 ]; do
    case "$1" in 
        --help) usage; exit 0;;
        -h | --hours)OPTS="${OPTS},4";;
        -d | --days)OPTS="${OPTS},3";;
        -m | --months)OPTS="${OPTS},2";;
        -y | --years)OPTS="${OPTS},1";;
	--prefix=*) PREF=`echo "$1" | cut -d '=' -f2`;; 
	-*) usage; exit 1;; 
        *) if [ -z "$newDir" ];then
	       newDir="$1"
	   else
	       usage; exit 1;
           fi
    esac
    shift
done
    

if [ -z "$OPTS" ]; then
    OPTS=",2,3"
fi  
OPTS=`echo "$OPTS" |sed -e 's/,/-f/'`

if [ -n "$newDir" ]; then
    if ! cd "$newDir"; then
        echo "photosort '$newDir': no such directory"
        exit 1
    fi
fi

temp=`ls -p | grep -v /`
for file in $temp; do
    if file "$file" |grep -qE 'image|bitmap'; then
        date=`exiftool -s -s -s -CreateDate "$file" | tr ' ' ':' `
        DIR=`echo $date | cut -d ':' $OPTS | tr ':' '/'`
        mkdir -p "$DIR"
	mv $file ${DIR}/${PREF}$file
    fi
done
