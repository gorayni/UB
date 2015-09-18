Informative segmentation creation
=================================


Contents
---

- **referencer.py** outputs the informative frames per segment for each dataset.
- **toMovies.sh** creates a movie for each dataset by creating temporary directories and symbolic links using ffmpeg.
- **toWeb.sh** creates web site pages from the output of the *referencer.py* script. It uses the file *template.html* as template for each page site.

How to use it
---

Just go to the main directory and execute the following:

```sh
python referencer.py > images.csv
./toMovie.sh images.csv
python toWeb.py
```

(last update 16/09/15)