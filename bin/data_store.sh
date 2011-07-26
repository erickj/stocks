#!/bin/sh
data_dir=$1

GIT="/bin/env git"

if [ -z $data_dir ]; then
    echo "Usage: $0 <data_dir>"
    exit 1
fi

if [ ! -d $data_dir ]; then
    echo "data_dir must be a directory: received ${data_dir}"
    exit 1
fi

pushd $data_dir > /dev/null

status_lines=`/bin/env git status | /bin/env wc -l`

if [ $status_lines -gt 2 ]; then
    date=`/bin/env date "+%Y-%m-%d"`
    $GIT add .
    $GIT commit -m "data for ${date}"
fi

popd > /dev/null
