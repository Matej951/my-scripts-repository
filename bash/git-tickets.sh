#@echo off
# Defining variables
output_folder="/path/to/folder"
release_branch="branch"
app_dir="/c/Develop/GIT/PDZ/pdz-core"
repo_starting_tag="1.2.1.9"
app1_dir="/c/Develop/GIT/PDZ/pdz-wo"
repo1_starting_tag="1.2.1.9"

# Checkout core branch and extract tickets
echo Checking out and pulling release branch
git -C $core_dir checkout $release_branch && git -C $core_dir pull || { echo "Error checking out or pulling branch on $core_dir"; exit 1; }

echo Generating app tickets
# git -C $core_dir log $core_starting_tag..HEAD --pretty=oneline --abbrev-commit --first-parent | grep OICR | grep 'Pull request' > $output_folder/core_tickets.txt
git -C $core_dir log $core_starting_tag..HEAD --pretty=oneline --abbrev-commit | grep OIPD | grep "Pull request"> $output_folder/core_tickets.txt

# Checkout wo branch and extract tickets
#echo Checking out and pulling release branch
#git -C $wo_dir checkout $release_branch && git -C $wo_dir pull || { echo "Error checking out or pulling branch on $wo_dir"; exit 1; }

echo Generating app1 tickets
#git -C $wo_dir log $wo_starting_tag..HEAD --pretty=oneline --abbrev-commit  | grep OICR | grep 'Pull request' > $output_folder/wo_tickets.txt
git -C $wo_dir log $wo_starting_tag..HEAD --pretty=oneline --abbrev-commit | grep OIPD | grep "Pull request"> $output_folder/wo_tickets.txt

# Combine tickets
echo Combining genrated tickets
cat $output_folder/core_tickets.txt $output_folder/wo_tickets.txt > $output_folder/combined_tickets.txt

# Sort and filter unique records
echo Sorting duplicates
grep -oP 'OIPD\w*-\d+' $output_folder/combined_tickets.txt | sort | uniq > $output_folder/unique_tickets_combined.txt


#sort $output_folder/combined_tickets.txt | uniq -u > $output_folder/unique_tickets_combined.txt
#sort $output_folder/combined_tickets.txt | uniq -d > $output_folder/duplicate_tickets_combined.txt

$SHELL
