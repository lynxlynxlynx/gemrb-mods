#!/bin/awk
#
# This script deduplicates consecutive blank separated blocks
#
# trivial test cases:
#  echo -e '1\n2\n3\n\n4\n5\n\n4\n5\n\n4\n5\n\n6' | awk -f block-dedup.awk
#  echo -e '1\n\n4\n5\n\n4\n5\n\n4\n5\n\n6' | awk -f block-dedup.awk

function dumpArray (ar) {
  # manually unroll, since awk does not guarantee preserved order
  for (v=0; v < length(ar); v++) print ar[v]
}

function areArraysEqual (ar1, ar2) {
  if (length(ar2) != length(ar1)) {
    return 0;
  } else {
    for (v in ar2) {
      if (ar2[v] != ar1[v]) {
        return 0;
      }
    }
  }
  return 1;
}

function copyArray (src, dest) {
  for (v in src) {
    dest[v] = src[v];
  }
}

BEGIN {
  i=blocks=0; a[0]=b[0]=c[0]=-1;
}

# read non-empty lines
! /^\s*$/ {
  a[i++]=$0;
}

/^\s*$/ {
  i=0; blocks++; same=1;
  # make a block copy if there isn't one already
  # if there is, determine whether they are the same
  if (length(b) == 1 && b[0] == -1) {
    copyArray(a, b);
  } else {
    same = areArraysEqual(a, b);
  }

  if (same) {
#     delete a;
  } else {
    dumpArray(b)
    print # prints a blank (== $0)
    dumpArray(a)
    # reinit the copy for later comparisons
    delete c;
    copyArray(a, c);
    delete b;
    copyArray(a, b);
  }
  delete a;
}

# print the rest in case there was no terminating newline
# ...while trying not to introduce duplicate blocks
END {
  if (! areArraysEqual(b, c)) {
    dumpArray(b)
    if (c[0] != -1) dumpArray(c)
  }
  print ""
  dumpArray(a)
}
