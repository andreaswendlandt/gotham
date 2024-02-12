#!/bin/bash
# author: andreaswendlandt
# desc: script to delete branches, remote and locally
# last modified: 20240223

print_help(){
    echo "this script deletes git branches which are older than the number of months passed to the script - remote and locally"
    echo "the following  parameter with a value is mandatory:"
    echo "-m, number of months the branches will deleted before"
    echo "this parameter with one or more values is optional:"
    echo "-b, branch or branches that should not be deleted (master branch is default and does not have to be specified)"
    echo "if you want to protect more than one branch - put them in quotation marks:"
    echo "-b \"feature_branch1 topic_branch2\""
    echo "the -d parameter performs a dry run and only echoes what would be deleted"
    echo "the -h parameter prints this help"
    echo "##########"
    echo "#examples#"
    echo "##########"
    echo "$0 -m 6 #deletes all branches older than 6 month(except master)" 
    echo "$0 -m 12 -b "branch3 branch5" #deletes all branches older than 12 month except branch3 and branch5(and master)" 
    echo "$0 -m 15 -d #shows all branches older than 15 month that would be deleted" 
    exit 1
}

if [[ ${#} -eq 0 ]]; then
    echo "error: no options passed to the script"
    print_help
fi

# default branch to skip
skip_branch="master"

while getopts "m:b:hd" opt; do
    case ${opt} in
        h) print_help;;
        m) month_before="${OPTARG}";;
	b) skip_branch_parameter=${OPTARG};;
	d) dry_run=yes;;
        *) echo "check your parameters" && print_help;;
    esac
done

check_remote_branch(){
    if git ls-remote --exit-code --heads origin refs/heads/"${1}" >/dev/null; then
        return 0
    else
        return 1
    fi
}

if [[ -z "${month_before}" ]]; then
    echo "error: no number of month given, aborting"
    print_help
fi

if [[ -n "${skip_branch_parameter}" ]]; then
    if [[ $skip_branch_parameter =~ $skip_branch ]]; then
        skip_branch=${skip_branch_parameter}
    else
        skip_branch="${skip_branch} ${skip_branch_parameter}"
    fi
fi

# shellcheck disable=SC2086
if git branch >/dev/null 2>&1; then
    git for-each-ref --sort=authordate --format '%(authordate:iso) %(align:left,25)%(refname:short)%(end)' refs/heads | while read -r line; do
        set ${line}
	if [[ ${skip_branch} =~ ${4} ]]; then
	    echo "...skipping, ${4} branch will not be processed"
	else
            branch_date=$(date -d "${1}" +%s)
            date_before=$(date -d "${month_before} month ago" "+%s")
            if [[ ${branch_date} -lt ${date_before} ]]; then
	        if [[ ${dry_run} == "yes" ]]; then
                    echo "git branch -d ${4}"
		    if check_remote_branch "${4}"; then
		        echo "git push origin --delete ${4}"
		    fi
	        else
                    git branch -d "${4}"
		    if check_remote_branch "${4}"; then
		        git push origin --delete "${4}"
		    fi
                fi
            fi
        fi
    done
else
    echo "...not a git repo, nothing to do here"
fi
