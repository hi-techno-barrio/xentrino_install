

#!/usr/bin/env bash

set -e
echo "#####################################################################"
echo "#                Hi-Techno Barrio                                   #" 
echo "#                ROS Philippines                                    #"
echo "#####################################################################"
set -e

ARCH=$(uname -i)
RELEASE=$(lsb_release -c -s)

if [ $RELEASE == "trusty" ]
    then
        ROSDISTRO=indigo

elif [ $RELEASE == "xenial" ]
    then
        ROSDISTRO=kinetic
       
elif [ $RELEASE == "bionic" ]
    then
        ROSDISTRO=melodic       
else
    echo "There's no ROS Distro compatible for your platform"
    exit 1
fi

echo Installing ros-$ROSDISTRO

sudo apt update
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
sudo apt -y update
sudo apt -y install dpkg

if [ $ARCH == "x86_64" ]
    then
        sudo apt -y install ros-$ROSDISTRO-desktop-full
        echo "Installing ROS-$ROSDISTRO Full Desktop Version"
else  
    sudo apt -y install ros-$ROSDISTRO-ros-base
    echo "Installing ROS-$ROSDISTRO Barebones"
fi

source /opt/ros/$ROSDISTRO/setup.bash
echo "source /opt/ros/$ROSDISTRO/setup.bash" >> ~/.bashrc
source ~/.bashrc 

sudo apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
sudo `which rosdep` init
rosdep update
rosdep install --default-yes --from-paths . --ignore-src --rosdistro $ROSDISTRO

echo ""
echo "ROS $(rosversion -d) Installation Done!"

source /opt/ros/$(dir /opt/ros)/setup.bash
ROSDISTRO="$(rosversion -d)"

sudo apt-get update
sudo apt-get install -y \
avahi-daemon \
openssh-server \
python-setuptools \
python-dev \
build-essential 

echo ""
echo "ROS $(rosversion -d) Installing python-udev !"
RELEASE=$(lsb_release -c -s)
if [ $RELEASE == "melodic" ]
    then
    git clone https://github.com/nzjrs/python-gudev.git
    cd python-gudev
     sudo apt install libtool-bin
    sudo apt install python-gobject-2-dev
    ./autogen.sh 
     make
     sudo make instal
elif [ $RELEASE == "xenial" ]
   
    then
     python-gudev
else
    echo "Please check other python-udev installation method."
    exit 1
fi     


sudo easy_install pip
sudo python2.7 -m pip install -U platformio
sudo rm -rf $HOME/.platformio/
source /opt/ros/$ROSDISTRO/setup.bash

sudo apt-get install -y \
ros-$ROSDISTRO-roslint \
ros-$ROSDISTRO-rosserial \
ros-$ROSDISTRO-rosserial-arduino \
ros-$ROSDISTRO-imu-filter-madgwick \
ros-$ROSDISTRO-gmapping \
ros-$ROSDISTRO-map-server \
ros-$ROSDISTRO-navigation \
ros-$ROSDISTRO-robot-localization \
ros-$ROSDISTRO-tf2 \
ros-$ROSDISTRO-tf2-ros 

echo " Creating Worlkspace for ROS $(rosversion -d)!"
cd $HOME
mkdir -p xentrinobot_ws/src
cd $HOME/xentrinobot_ws/src
catkin_init_workspace

cd $HOME/xentrinobot_ws/src
mkdir  $HOME/xentrinobot_ws/src/xentrinobot
cd $HOME/xentrinobot_ws/src/xentrinobot
TRAVIS_BRANCH="echo $TRAVIS_BRANCH"
if [ "$TRAVIS_BRANCH" = "devel" ]; then git checkout devel; fi

mkdir  $HOME/xentrinobot_ws/src/xentrinobot/teensy/firmware
cd $HOME/xentrinobot_ws/src/xentrinobot/teensy/firmware
export PLATFORMIO_CI_SRC=$PWD/src/Xentrino-ROS.ino

echo "source $HOME/linorobot_ws/devel/setup.bash" >> $HOME/.bashrc
echo "export XENTRINOLIDAR=$SENSOR" >> $HOME/.bashrc
echo "export XENTRINOBASE=$BASE" >> $HOME/.bashrc
source $HOME/.bashrc

cd $HOME/xentrinobot_ws
catkin_make

echo
echo "ROS WORKSPACE DONE!"
echo
