#!/bin/bash

. ../../plugin_test_utilities.sh

mysql_admin_parameters=$script_dir/admin_login.cnf
mysql_parameters=$script_dir/plugin_login.cnf

mysql_cmd=$(which mysql 2>/dev/null)
if [ -z "$mysql_cmd" ]; then
    logerr "mysql not found"
    exit 1
fi

# Create the test database
"$mysql_cmd" --defaults-file="$mysql_admin_parameters" \
    < "$plugin_dir"/sql/create_multiple_tables.sql

if [ $? -ne 0 ]; then
    logerr "Error creating test database"
    exit 2
fi

# Set up the SQL command to fetch the results
sql_cmd="SELECT scope, type, time_stamp, label, violation_path, call_type,"
sql_cmd="$sql_cmd measurement, size_range, threshold, observed, observed_time,"
sql_cmd="$sql_cmd pid, command, file_name, group_job_id, group_job_array_index,"
sql_cmd="$sql_cmd job_id, job_array_index, submit_time, hostname, project FROM"
sql_cmd="$sql_cmd log_01 a, rule_parameters b WHERE b.rule_id ="
sql_cmd="$sql_cmd a.rule_parameters ORDER BY log_id ASC" 

export LSB_MCPU_HOSTS="host1 2 host2 2 host3 1 ${HOSTNAME%%.*} 1"
export LSB_JOBFILENAME=$plugin_dir/.lsbatch/1472658176.61902
export LSB_PROJECT_NAME=default

run_test --defaults-file="$mysql_parameters"

# Get the results
"$mysql_cmd" --defaults-file="$mysql_parameters" -ss -e "$sql_cmd" \
    >> $results_dir/results.txt

check_results

if [ -z "$KEEP_TEST_OUTPUT" ];then
    # Delete the test database regardless of test status
    "$mysql_cmd" --defaults-file="$mysql_parameters" -ss -e \
        "DROP DATABASE IF EXISTS mistral_log;" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        logerr "Unable to remove test database"
        exit 3
    fi
fi