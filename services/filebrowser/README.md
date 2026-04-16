# File Browser

A simple WebUI File Explorer

### Repo

[https://github.com/filebrowser/filebrowser](https://github.com/filebrowser/filebrowser)

### Website

[https://filebrowser.org/](https://filebrowser.org/)

## Guide

If running this as an LXC, remember to before hand pass the directory/directories as mount points.

Since I only use this to explore files and save them, never to write them, I passed the `:ro` flag to the [docker-compose.yml](./docker-compose.yml).

Upon first login, use the default credentials:

- user: `admin`
- password: randomly generated, use `docker logs filebrowser` to view it (IT ONLY SHOWS IT ONCE)
