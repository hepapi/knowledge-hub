echo "| File | Contributors |"
echo "|------|--------------|"
git ls-tree -r --name-only main ./ | while read file ; do
    contributors=$(git log --follow --pretty=format:%an -- "$file" | sort | uniq)
    joined_contributor_names="${contributors//$'\n'/,}"
    # Remove leading/trailing +
    joined_contributor_names="${joined_contributor_names#,}"
    joined_contributor_names="${joined_contributor_names%,}"
    file_without_docs="${file#docs/}"
    echo "| $file_without_docs | $joined_contributor_names |"
done