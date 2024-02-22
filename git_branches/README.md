# remove_old_branches.sh

this script deletes git branches which are older than the number of months passed to the script - remote and locally

### mandatory parameter:
-m, number of months the branches will deleted before

### optional parameter with a value
-b, branch or branches that should not be deleted (master branch is default and does not have to be specified)

if you want to protect more than one branch - put them in quotation marks:

-b "feature_branch1 topic_branch2"

### optional parameter without a value
-d, performs a dry run and only echoes what would be deleted

-h, prints a help section

## Examples
deleting all branches older than 6 months
```
./remove_old_branches -m 6 
```

deleting all branches older than 12 months except branch_foo and branch_bar (and master)
```
./remove_old_branches -m 12 -b "branch_foo branch_bar" 
```

showing all branches older than 15 months that would be deleted
```
./remove_old_branches -m 15 -d 
```
