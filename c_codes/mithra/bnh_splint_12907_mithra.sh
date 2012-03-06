#!/bin/sh
#
# Script to build sharable library:
#
#    File Name: bnh_splint
#    User: winter@mithra
#    IDL Version: 6.2 (linux x86_64)
#    Memory Bits: 64
#    File Bits: 64
#    Date: Thu Jun 22 18:49:24 2006
#

# Script options
DO_CLEANUP=1
SHOW_ALL_OUTPUT=1

# Convenient handles for the various files
UNIQSTR="_12907_mithra"
UNIQUE_NAME="bnh_splint_12907_mithra"
REAL_NAME="bnh_splint"
SRC_DIR="/disk/hl2/data/winter/data1/PATC/c_codes/mithra"
RES_DIR="/disk/hl2/data/winter/data1/PATC/c_codes/mithra"

EXPORT_FILE="$UNIQUE_NAME.export"
OUT_FILE="$UNIQUE_NAME.out"
OUT_FILE_TMP="$UNIQUE_NAME.out.$$"
SH_FILE="$UNIQUE_NAME.sh"
RES_FILE="$RES_DIR/$REAL_NAME.so"
RES_FILE_TMP="$RES_DIR/$UNIQUE_NAME.so"


# Locate the dirname command and use it to find our location
# relative to the calling process
UDIR=
for DIR in /bin /usr/5bin; do
  if [ -f $DIR/dirname ]; then
    UDIR=`$DIR/dirname "$0"`
    break
  fi
done

# If all else fails, its likely that awk(1) is in the path
if [ "$UDIR" = "" ]; then
  UDIR=`echo "$0" | awk -F\/ '{if(NF==1)
  printf(".\n");else{for(i=1;i<NF;i++){if(i>1)printf("%s","/"); printf("%s",$i);}printf("\n")}}'`
fi

# If we end up with nothing, change it to '.'. Otherwise, cd with
# no argument will move us to the users login directory
if [ "$UDIR" = "" ]; then
  UDIR=.
fi

# Move to the location with the files
cd "$UDIR"

# Any error messages get redirected to a file that can be examined
# later by the user, should there be any problems with the compiler or
# linker, or in their setup. Place a comment at the start of that file
# explaining what is going on
echo "########################################################################
#
# Error output from building library
#
#    File Name: $REAL_NAME
#    User: winter@mithra
#    IDL Version: 6.2 (linux x86_64)
#    Memory Bits: 64
#    File Bits: 64
#    Date: Thu Jun 22 18:49:24 2006
#
# Unix IDL executes $SH_FILE to
# build the sharable library. Any errors produced in that process
# are redirected to this file. In reading this file, please be
# aware that some loaders, such as the Solaris ld(1), will produce
# errors for symbols not resolved while building the library. Such
# errors are normal, as a sharable library usually cannot be
# completely resolved until runtime, and are normally not a
# cause for concern. The missing symbols are resolved at runtime
# when IDL loads the library.
#
# Any output resulting from this process appears after the next line
########################################################################" > "$OUT_FILE"


# The loader can produce errors that we may or may not want
# the user to see, as explained above. To avoid losing important
# debugging information, we capture all output in a scratch file.
# If the target fails to build, we copy the scratch file to stdout
# and the user sees it. It is always added to the tail of the# error log file.

# This variable is used to decide if each step below succeeds or not
STATUS=1


# Compile: bnh_splint.c
if [ $STATUS = 1 ]; then
  echo "% gcc  -fPIC -I\"/usr/local/rsi/idl/external/include\" -c -m64 -D_REENTRANT \"$SRC_DIR/bnh_splint.c\" -o \"bnh_splint$UNIQSTR.o\"" > "$OUT_FILE_TMP"
 
  gcc  -fPIC -I"/usr/local/rsi/idl/external/include" -c -m64 -D_REENTRANT "$SRC_DIR/bnh_splint.c" -o "bnh_splint$UNIQSTR.o" >> "$OUT_FILE_TMP" 2>&1
  if [ ! -f "bnh_splint$UNIQSTR.o" ]; then
    STATUS=0
  fi
fi


# Link the sharable library
if [ $STATUS = 1 ]; then
  echo "% ld -shared -o \"$RES_FILE_TMP\" \"bnh_splint$UNIQSTR.o\" " >> "$OUT_FILE_TMP"
 
  ld -shared -o "$RES_FILE_TMP" "bnh_splint$UNIQSTR.o"  >> "$OUT_FILE_TMP" 2>&1
fi


# Add the cc and ld output to the error log
cat "$OUT_FILE_TMP" >> "$OUT_FILE"

# Did the library fail to build? Send the error output to stdout so
# the user can see what happened. Otherwise, rename to its real name.
# Since file renaming is an atomic operation relative to other
# processes, concurrent IDLs will always find either a complete library,
# or none at all. Either path leads to a deterministic resolution.
if [ -f "$RES_FILE_TMP" ]; then
  chmod a+rx "$RES_FILE_TMP"
  mv -f "$RES_FILE_TMP" "$RES_FILE"
  if [ $SHOW_ALL_OUTPUT = "1" ]; then
    cat "$OUT_FILE_TMP"
  fi
else
  cat "$OUT_FILE_TMP"
fi

# Remove the temporary error log
rm -f "$OUT_FILE_TMP"

# If requested, remove all intermediate generated files, including
# this script.
if [ $DO_CLEANUP = "1" ]; then
  rm -f "$EXPORT_FILE" "$OUT_FILE" "$SH_FILE"
  rm -f bnh_splint$UNIQSTR.o
fi
exit 0
