#! /bin/bash

# Check if the variable SHOW_ERRORS is set to 1
# if it is 1, comment out the css file
if [ "$SHOW_ERRORS" = 1 ]; then
    sed -i 's/div[class*="sos_lan__kotlin"] div[data-mime-type="application\/vnd.jupyter.stderr"] { display: none; }//g' /root/.jupyter/custom/custom.css
fi

jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --custom-css \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --notebook-dir=/notebooks
