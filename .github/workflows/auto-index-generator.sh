#!/bin/bash
bash << 'EOF' | tee -a ./docs/index.md
#!/bin/bash

export KH_SITE_URL="https://hepapi.github.io/knowledge-hub/"
printf "## Table of Contents\n\n"

# find all directories in the docs folder and iterate over them
find ./docs -maxdepth 1 -type d | while read -r dir_path; do 
    dir_name=${dir_path#./docs/} # remove ./docs/ from the beginning of the filepath

    if [[ $dir_name == .* ]]; then
        continue # skip directories starting with .
    fi

    printf "\n**%s**\n\n" "$dir_name"

    # find all markdown files in the directory and iterate over them
    find "./docs/$dir_name" -type f -name "*.md" | while read -r filepath; do 
        file=${filepath#./docs/} # remove ./docs/ from the beginning of the filepath
        file_url="${file%.md}/" # remove .md from the end of the filepath and add a trailing slash
        md_header=$(grep -m 1 -E '^#+ ' "$filepath") # read the first header line in each md file
        md_header=$(echo "$md_header" | sed 's/^#*//') # removing hashtags from the beginning of the variable
        title="${md_header#"${md_header%%[![:space:]]*}"}"
        printf "    - [%s](%s%s)\n" "${title:-$file}" "$KH_SITE_URL" "$file_url"
    done
done
EOF