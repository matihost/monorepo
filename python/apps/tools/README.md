# Tools

Contains CLI Python made tools:

* `automount-cifs` - to mount home's router NAS disk automatically (or any SAMBA/CIFS 1 endpoint)
* `extract-stem` - to extract selected instrument tracks (stems), like guitar and vocals only, from a recording into MP3
* `setup-opendns` - to publish periodically home's network public IP to OpenDNS

## Usage

```bash
# install as root, do not use --user installation
# so that scripts will be in /usr/local/bin accessible by root
# scripts does not require to run with sudo, but they switch internally to root so that global installation is desired

sudo pip3 install 'git+https://github.com/matihost/monorepo.git#egg=tools&subdirectory=python/apps/tools'

# enable OpenDNS public IP sync for OpenDNS Home1 labeled network for particular user
setup-opendns -u opendns@user.com -p password Home1
```

### Extract Stems

Extracts selected instrument tracks (stems) from a video or audio recording into MP3 file.

Audio is taken out of the recording losslessly, split into stems with
[Demucs](https://github.com/adefossez/demucs) `htdemucs_6s` AI model,
and only the requested stems are mixed into the resulting MP3, so the remaining
instruments are silent.

Defaults: `guitar` and `vocals` are extracted (so drums, bass and the rest are muted)
and the result loudness is normalized to -14 LUFS, as extracted stems are quiet
compared to the full mix. Use `--no-normalize` to keep original levels.

Requirements:

* `ffmpeg` and `ffprobe` in PATH - `sudo apt-get install -y ffmpeg`
* on the first run Demucs with PyTorch is installed automatically into a dedicated
  virtual env (`~/.venv/demucs` by default), which downloads several GB.
  It is kept out of this project dependencies on purpose and reused on later runs.
* NVIDIA GPU is used when available, otherwise CPU, which is much slower.
  Upon CUDA out of memory error the tool retries on CPU automatically.

```bash
# guitar + vocals, normalized, written next to the input as Recording_vocals-guitar.mp3
extract-stem ~/Downloads/Recording.mp4

# single stem only, available stems: drums, bass, other, vocals, guitar, piano
extract-stem -s guitar ~/Downloads/Recording.mp4

# any combination of stems mixed into one MP3
extract-stem -s guitar vocals piano ~/Downloads/Recording.mp4

# keep original loudness instead of normalizing to -14 LUFS
extract-stem --no-normalize ~/Downloads/Recording.mp4

# custom output file and bitrate
extract-stem -o ~/Music/solo.mp3 -b 192k ~/Downloads/Recording.mp4

# better separation quality, N times slower
extract-stem --shifts 5 ~/Downloads/Recording.mp4

# save also remaining instruments (drums, bass, other, piano) as Recording_..._rest.mp3
extract-stem --keep-rest ~/Downloads/Recording.mp4

# force CPU, or lower GPU memory usage when CUDA runs out of memory
extract-stem -d cpu ~/Downloads/Recording.mp4
extract-stem --segment 5 ~/Downloads/Recording.mp4
```

Stem separation is not perfect - expect some bleed of other instruments and mild
artifacts, especially when the extracted instruments overlap others in the mix.

## Develop

```bash
# init Poetry build system, install dependencies (single time)
make init

# run tool
make run-automount-cifs
make run-setup-opendns
make run-extract-stem INPUT=~/Downloads/Recording.mp4 STEMS="guitar vocals"

# run tests
make tests

# update dependencies
make update

# lint entire source code
make lint
# install this module as root, so that command are visible for everyone
make install

# uninstall
make uninstall

# install into local user ~/.venv
# apps switching to root internally may stop working
make install-user

# uninstall from local user ~/.venv
make uninstall-user

# prepare build
make build

# clean .venv, requires make init to start develop again
make clean
```

### Debug in VSCode

```bash
# Ensure you are not under custom Virtual Env (poetry detects its and use this VEnv instead creating one within application directory .venv)

echo $VIRTUAL_ENV
python -m site
# and lack of deactivate script
```

* Select Run and Debug on the left pane, if you haven't have *Python: Remote Attach* option available, click Settings and add [Run and Debug configuration](https://code.visualstudio.com/docs/python/debugging):

  ```json
  {
    "version": "0.2.0",
    "configurations": [
      {
        "name": "Python: Remote Attach",
        "type": "debugpy",
        "request": "attach",
        "connect": {
          "host": "localhost",
          "port": 5678
        },
        "justMyCode": false
      }
    ]
  }
  ```

* Select Python in VS Code to use VEnv .*venv/bin/python* Python interpreter:

  * Ctrl+Shift+P 'Python: Select interpreter'
  * Select at workspace level
  * Select project *.venv/bin/python* from your project directory

* Run app in debug mode

  ```bash
  # debug tool
  make debug-automount-cifs
  # or
  make debug-setup-open-dns
  # or
  make debug-extract-stem INPUT=~/Downloads/Recording.mp4
  ```

* Select breakpoint in the code

* Select Run and Debug on the left pane and run Python debugger.
