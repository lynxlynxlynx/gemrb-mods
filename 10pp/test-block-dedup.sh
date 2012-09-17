#!/bin/bash

failed=0
inspect=$1
function check_test () {
  if [[ $1 != $2 ]]; then
    let failed+=1
    echo failed
	[[ $inspect ]] && diff -su <(echo "$2") <(echo "$1") | less
  else
    echo ok
  fi
}

# trivial longlongshort block case
echo -n "1. Checking trivial triple case ... "
in=$(echo -e '1\n2\n3\n\n4\n5\n\n4\n5\n\n4\n5\n\n6' | awk -f block-dedup.awk)
expected=$(echo -e '1\n2\n3\n\n4\n5\n\n6')
check_test "$in" "$expected"

# trivial shortlonglong block case
echo -n "2. Checking trivial triple case ... "
in=$(echo -e '1\n\n4\n5\n\n4\n5\n\n4\n5\n\n6' | awk -f block-dedup.awk)
expected=$(echo -e '1\n\n4\n5\n\n6')
check_test "$in" "$expected"

# eat yourself - test for false positives
echo -n "3. Eating our own dogfood ... "
in=$(awk -f block-dedup.awk block-dedup.awk)
expected=$(cat block-dedup.awk)
check_test "$in" "$expected"

echo
if [[ $failed != 0 ]]; then
  echo "Some ($failed) tests have failed!"
  exit 1
else
  echo "All tests passed"
fi

