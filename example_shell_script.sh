
pwd 
if [ -z "$(ls -A . 2>/dev/null)" ]; then
    echo "null"
else
    echo "Directory is not empty."
    echo "List github repository files:"
    ls -la
fi