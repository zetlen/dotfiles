for file in {.,}*; do [ -f "$file" ] && ln -s $(pwd)/"$file" ~/"$file"; done
