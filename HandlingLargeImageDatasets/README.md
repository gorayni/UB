# Handling large images datasets

The problem with handling directories containing a large number of files, specially images, is their size. For instance, Apple's Preview runs out of memory and crashes trying to show all the images. In this case, is better to use a simpler image viewer like [feh](http://feh.finalrewind.org/).

## Large Image Dataset Handler Library (LIDHL)

This is Bash shell util library for handling large image datasets.

### Extracting all frames from a video

```bash
video_filepath="example.avi"
num_padding_zeros=`extract_frames "$video_filepath"`
```

### Remove frames by range

```bash
rm_frames "example" "jpg" 11159 11290 "$num_padding_zeros"
```

### Massively list files in a directory

```bash
mass_ls -lah "example*.jpg"
```

### Massively move files in a directory

```bash
mass_mv "example*.jpg" dest_directory
```

### Downloading large datasets in chunks

```bash
# Download the URL in chunks of 1 GB
chunkie_download $URL $NEW_FILENAME 1073741824

# Joining the file chunks
join_chunks $NEW_FILENAME
```