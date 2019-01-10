# Dockerfile for Samsung Tizen Studio GUI
Installs the Tizen Studio IDE into a Docker container

## General Information
Under Linux, Tizen Studio will not run properly under any distribution other than Ubuntu, even if the required dependencies are installed (which is ridiculous). This Dockerfile was created as a "compatibility layer" to use Tizen Studio on non-Ubuntu Linux systems.

***If you are already using an Ubuntu or Ubuntu-based Linux distribution, you do not need to use this Dockerfile.***

**If you would prefer to install a different version of Tizen Studio using this Dockerfile, you can.** You can install (virtually) any version of Tizen Studio you want, as the dependencies are the same for each. You can make this Dockerfile download a different version by setting the T_VERSION build argument to whichever version you wish to download.

## Quick Start
Here is a recommended launch command you can use:

<pre>
docker run -d \
    --name tizen-studio-ide \
    -e DISPLAY=$DISPLAY \
    --net=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/tizen/workspace:/home/tizen/workspace \
    -v $HOME/tizen/extensions:/home/tizen/extensions \
    -v $HOME/tizen/certificates:/home/tizen/certificates \
    ubergeek77/tizen-studio-ide:2.5
</pre>

Once the container is running, enter a shell by issuing the following command (replacing the user and container names if you changed them):

`docker exec -u tizen -it tizen-studio-ide /bin/bash`

Once inside, you can start any of the binaries located in the `/home/tizen/tizen-studio/` directory:

`~/tizen-studio/ide/TizenStudio.sh`

Be sure to read the "Desktop Shortcuts" section below if you are interested in launching Tizen Studio from your application menu.

## Usage
This image runs a *graphical* application. As such, it will need access to your host's X11 server. To grant access, install "xhost" to your system if you no not already have it. Then run:

`xhost +`

This will allow the Docker container to access your system's display

When launching the container, you will need to add a few mandatory parameters. Those are:
<pre>
--net=host
-e DISPLAY=$DISPLAY
-v /tmp/.X11-unix:/tmp/.X11-unix
</pre>

To keep your project files from being deleted when the container is deleted, mount a volume for your workspace:

`-v $HOME/tizen/workspace:/home/tizen/workspace`

You may also want to mount a volume for SDK extension files:

`-v $HOME/tizen/extensions:/home/tizen/extensions`

And one for certificates:

`-v $HOME/tizen/certificates:/home/tizen/certificates`

## Tips

#### Desktop Shortcuts
---
If you want Tizen Studio to more comfortably integrate into your desktop environment, I have included some helper scripts that will install some desktop shortcuts for you.

If you want to use them, open `tizen-run-in-container.sh`, and make sure the variables at the top are correct. Then, do the same for `install_shortcuts.sh` and run it. You should be able to find Tizen Studio in your application menu and launch it from there.


#### Developing for Tizen TV 2.x and 3.x
---
For some asinine reason, Samsung has decided to completely pull support for Tizen TV 2.x and 3.x from Tizen Studio. This means that, by default, it can't be used to develop for basically every Samsung TV currently on the market right now. Even stranger is that Tizen TV is the only OS this has been done for - you can develop for every major version of Tizen for mobiles and Tizen for wearables even on Tizen Studio 3.0.

There is a (poorly written, but passable) article about how to get back the ability to deploy Tizen TV 2.x and 3.x applications using Tizen Studio 2.x, and the solution works on Tizen Studio 2.5:

https://medium.com/@ibazzva/developing-for-old-samsung-tvs-in-tizen-studio-2-x-5aa3f853db09

This is not without its problems, however. I wasn't able to get Emulator templates to install, nor was I able to install the web simulator. This means that you cannot develop for Tizen TV 2.x and 3.x unless you have a physical device to test with. If the two aforementioned features are important to you, you may have better luck with Tizen Studio 1.3:

http://blog.infernored.com/how-to-get-back-tizen-studio-1.3-and-tv-extensions-3.0

## Known Issues

#### "invalid password" for certificates (Tizen Studio 3.0 only)
---
There is a bug in Tizen Studio 3.0 rendering it basically unusable. For some reason, Tizen Studio cannot store passwords for certificates, and as a result, applications cannot be deployed to remote devices over SDB:

https://developer.tizen.org/ko/forums/sdk-ide/certificate-manager-doesnt-store-passwords?langredirect=1

This is the main reason why this Dockerfile defaults to version 2.5 of Tizen Studio.

#### "sdb command rejected exception"
---
Even after generating a valid certificate, I have run into cases where I cannot run an application on my device, despite being connected to it. I have no idea why this happens. However, the solution is pretty simple:

 - Use `docker exec -it <container-name> -u tizen /bin/bash` to get a shell into your container.
 - Run `TizenStudio.sh` from this shell. If you didn't edit any install paths, it should be located at `/home/tizen/tizen-studio/ide/TizenStudio.sh`
 - Use Tizen Studio like normal. Connect to your device, and try running an application on it. If you get the SDB error message, *close Tizen Studio* but ***do not*** close or reboot the container.
 - Start Tizen Studio again from the same shell as before.
 - *As if by magic, you can now send applications to your device...*

#### HiDPI Displays
---
Tizen Studio 2.5 works fairly well with HiDPI displays, with the exception of the Package Manager, which is extremely small. Tizen Studio 1.x does ***not*** work well on HiDPI displays at all.

I haven't included it in this Dockerfile, but [
run_scaled](https://github.com/kaueraal/run_scaled) is a very useful application to somewhat mitigate DPI issues. It may work for you if you are having scaling problems. To install it to this Docker image, gain root access to a BASH session, then run these commands:

<pre>
curl https://xpra.org/gpg.asc | apt-key add -
wget https://xpra.org/repos/xenial/xpra.list -O /etc/apt/sources.list.d/xpra.list
apt-get update && apt-get install xvfb x11-xserver-utils xpra
</pre>

Be warned that run_scaled does introduce some issues. For example, I have seen cases where killing the run_scaled session does not properly exit the previously run application, resulting in multiple processes, meaning you may need to restart the container or manually kill duplicate processes before being able to run them again. Also, Tizen applications such as the Package Manager will exit and attempt to re-run themselves before fully loading. Since they exit after being run once, and run_scaled does not have any mechanisms in place to detect when a previously-closed application attempts to run on its own, these applications will not work with run_scaled.

#### Google Chrome won't open when debugging applications
---
After setting the Chrome path in Tizen Studio under Preferences > Tizen Studio > Web > Chrome, you may find that Chrome won't open when launching a Debug web app. This is because Chrome is unable to properly launch itself with sandboxing, due to being run inside of a Docker container. I believe this could be solved by launching the Docker container with the `--privileged` flag, but this is not recommended. Since Chrome won't be used for typical browsing anyway (at least, you really shouldn't, it's a Docker container after all), you can add the `--no-sandbox` flag to Extra Parameters under Preferences > Tizen Studio > Web > Chrome.
