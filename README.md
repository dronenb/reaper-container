# REAPER in a Container?!?

Yes, this is a PoC that you can run [REAPER](https://www.reaper.fm/) in a Docker or Podman container.

## Disclaimer
I am not associated with [Cockos Incorporated](https://www.cockos.com/) in any way, and this is not an official distribution of REAPER. I will not be providing this as a redistributable image, although you may use the files in this repository to create your own images, which will download and install REAPER during the build stage. The things in this repository are my own work, and as such are licensed according to the [LICENSE](LICENSE) in this repository.

Please [buy REAPER](https://www.reaper.fm/purchase.php) and support this amazing piece of software.

## Why

Eventually I would like to use a combination of x11vnc + noVNC to have the REAPER GUI be accessible through a web browser. Obviously this would also be possible by exposing REAPER's built-in web interface, but it is not fully featured presently. This could be useful if trying to run REAPER on a device like a Raspberry Pi, without having to run a full fledged operating system. It should be possible to share audio hardware between the host and the container using [JACK](https://jackaudio.org/) by binding `/dev/shm` or, alternatively, binding `/dev/snd` directly and using another audio system.

## How

For testing, I am using [`podman`](https://podman.io/) on macOS to build and run this container. The GUI is passed through to the host using [XQuartz](https://www.xquartz.org/) through some volume bindings. If you would like to try this out, here are the steps:

### Command Line Tools
The XCode command line tools are required for some steps. Install them with:
```
xcode-select --install
```

### Homebrew
Homebrew is necessary to install some of the prerequisites for this project. You can install it with:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### XQuartz

```
brew install --cask xquartz

# Open xaurtz
open -a XQuartz

# In XQuartz Settings GUI (cmd ,) Click "Security" tab and enable "Allow connections from network clients"

# Reboot the Mac
sudo shutdown -r now

# Assuming you're using zsh, set DISPLAY variable
echo "export DISPLAY=:0" >> ~/.zshrc
source ~/.zshrc

# Place your machines current IP address in an environment variable
export IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

# Add this IP as an authorized client
xhost +$IP
```

### Podman
```
# Initialize and start the Podman VM
podman machine init
podman machine start

# Clone this repo
git clone https://github.com/dronenb/reaper-container.git
cd reaper-container

# NOTE: You will need to change the ARCH in the Containerfile if you are not on an Apple Silicon Mac.

# Build the image
podman build -t reaper .

# Run the image. This will bind the REAPER license on the host machine to the container
podman run --rm --name reaper -e DISPLAY=$IP:0 -e XAUTHORITY=/.Xauthority --net host -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/.Xauthority:/.Xauthority -v ~/Library/"Application Support"/REAPER/reaper-license.rk:/opt/REAPER/reaper-license.rk reaper
```