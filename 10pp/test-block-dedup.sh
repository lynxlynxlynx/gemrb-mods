#!/bin/bash

failed=0
inspect=$1
function check_test () {
  local diff=$(diff -swu <(echo "$2") <(echo "$1"))
  local rc=$(wc -l <<< "$diff")
  if (( $rc > 1 )); then
    let failed+=1
    echo failed
	[[ $inspect ]] && less <<< "$diff"
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

echo -n "4. Eating our own dogfood ... "
in=$(awk -f block-dedup.awk test-block-dedup.sh)
expected=$(cat test-block-dedup.sh)
check_test "$in" "$expected"

echo -n "5. Eating our own dogfood ... "
in=$(awk -f block-dedup.awk doc-*)
expected=$(cat doc-*)
check_test "$in" "$expected"

echo -n "6. Eating our own dogfood ... "
in=$(awk -f block-dedup.awk trigger-iwd2.ids)
expected=$(cat trigger-iwd2.ids)
check_test "$in" "$expected"

echo
if [[ $failed != 0 ]]; then
  echo "Some ($failed) tests have failed!"
  exit 1
else
  echo "All tests passed"
fi

