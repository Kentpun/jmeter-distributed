#!/usr/bin/env bash
# Script created to launch Jmeter tests with csv data files directly from the current terminal without accessing the jmeter master pod.
# It requires that you supply the path to the directory with jmx file and csv files
# Directory structure of jmx with csv supposed to be:
# _test_name_/
# _test_name_/_test_name_.jmx
# _test_name_/test_data1.csv
# _test_name_/test_data2.csv
# i.e. jmx file name have to be the same as directory name.
# After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=$(pwd)

# Get namesapce variable
tenant="jmeter"

jmx_dir=$1
jmx_file=`find $jmx_dir -type f -name "*.jmx" -exec basename \{} .jmx \;`

echo "${jmx_file}"

if [ ! -d "$jmx_dir" ];
then
    echo "Test script dir was not found"
    echo "Kindly check and input the correct file path"
    exit
fi

# Get Master pod details

printf "Copy %s to master\n" "${jmx_file}"

master_pod=$(kubectl get po -n "$tenant" | grep master | awk '{print $1}')

kubectl cp $jmx_dir/"${jmx_file}.jmx" -n "$tenant" "$master_pod":/

# Get slaves

printf "Get number of slaves\n"

slave_pods=($(kubectl get po -n "$tenant" | grep slave | awk '{print $1}'))

# for array iteration
slavesnum=${#slave_pods[@]}

# for split command suffix and seq generator
slavedigits="${#slavesnum}"

printf "Number of slaves is %s\n" "${slavesnum}"

# Split and upload csv files
csv_files=`find $jmx_dir -type f -name "*.csv"`
for csvfilefull in $csv_files

  do

  csvfile="${csvfilefull##*/}"
  echo $csvfile
  printf "Processing %s file..\n" "$csvfile"

  # split --suffix-length="${slavedigits}" --additional-suffix=.csv -d --number="l/${slavesnum}" "${jmx_dir}/${csvfile}" "$jmx_dir"/

  j=0
  for i in $(seq -f "%0${slavedigits}g" 0 $((slavesnum-1)))
  do
    printf "Copy %s to %s on %s\n" "${csvfile}" "${i}.csv" "${slave_pods[j]}"
    kubectl -n "$tenant" cp "${jmx_dir}"/"${csvfile}" "${slave_pods[j]}":/"${i}.csv"
    kubectl -n "$tenant" exec "${slave_pods[j]}" -- mv -v /"${i}.csv" /"${csvfile}"

    let j=j+1
  done # for i in "${slave_pods[@]}"

done # for csvfile in "${jmx_dir}/*.csv"

## Echo Starting Jmeter load test

kubectl exec -ti -n "$tenant" "$master_pod" -- /bin/bash /load_test "/${jmx_file}.jmx"
