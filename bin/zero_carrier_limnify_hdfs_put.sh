#!/bin/bash
set -e

# cd into tmpdir
tmpdir=$(mktemp --directory)
cd "${tmpdir}"

# Quick and dirty script to
# limnify zero_carrier_country data stored in HDFS
# This limn data be stored back into HDFS.

limn_name=pageviews_by_zero_carrier

# TODO: create deb for limnpy and install.
limnify=/home/otto/scr/limnify/bin/limnify 

# cat all zero_carrier_country output files into sort and limnify
hadoop fs -cat /wmf/public/webrequest/zero_carrier_country/20*/*/*/* | sort |

# pivot on carrier (2nd column)
${limnify}                                            \
  --delim "\t"                                        \
  --header Date Carrier Country Pageviews             \
  --datefmt "%Y-%m-%d_%H"                             \
  --valcol Pageviews                                  \
  --name "Pageviews by Wikipedia Zero Carriers"       \
  --id "${limn_name}"                                 \
  --datecol Date                                      \
  --pivot &&

# put the limn directories into HDFS
hadoop fs -rm -f -r /wmf/public/webrequest/zero_carrier_country/_limn/${limn_name} &&
hadoop fs -mkdir -p /wmf/public/webrequest/zero_carrier_country/_limn/${limn_name} &&
hadoop fs -put ./datafiles ./datasources /wmf/public/webrequest/zero_carrier_country/_limn/${limn_name}/

# remove tmpdir
cd -
rm -r "${tmpdir}"
