#!/bin/awk
#
# This script deduplicates consecutive blank separated blocks
#
# test cases:
#  echo -e '1\n2\n3\n\n4\n5\n\n4\n5\n\n4\n5\n\n6' | awk -f 10pp/block-dedup.awk
#  echo -e '1\n\n4\n5\n\n4\n5\n\n4\n5\n\n6' | awk -f 10pp/block-dedup.awk

BEGIN {
  i=0; a[0]=b[0]=-1;
}

/^\S\S*$/ { 
  a[i++]=$0; 
}; 

/^\s*$/ { 
  i=0; same=1;
  # make a block copy if there isn't one already
  # if there is, determine whether they are the same
  if (length(b) == 1 && b[0] == -1) {
    for (v in a) { b[v] = a[v]; }
  } else {
    if (length(b) != length(a)) {
      same = 0;
    } else {
      for (v in b) {
        if (b[v] != a[v]) { 
          same = 0;
          break;
        } 
      }
    }
  }

  if (same) {
    delete a;
  } else {
    for (v in b) print b[v];
    print # prints a blank (== $0)
    for (v in a) { print a[v]; }
    # reinit the copy for later comparisons
    delete b;
    for (v in a) { b[v] = a[v]; }
  };
  delete a;
};

END { 
    print ""
    for (v in a) print a[v] 
}
