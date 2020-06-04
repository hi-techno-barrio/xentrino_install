

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
sudo cp files/49-teensy.rules /etc/udev/rules.d/

ROSDISTRO="$(rosversion -d)"
BASE=$1
SENSOR=$2
ARCH="$(uname -m)"
echo $ARCH                                                                                                 
if [ "$3" != "test" ]
    then
        if [ "$*" == "" ]
            then
                echo "No arguments provided"
                echo
                echo "Example: $ ./install.sh 2wd xv11"
                echo
                exit 1
                
        elif [[ "$1" != "2wd" && "$1" != "4wd" && "$1" != "mecanum" && "$1" != "ackermann" ]]
            then
                echo "Invalid linorobot base: $1"
                echo
                echo "Valid Options:"
                echo "2wd"
                echo "4wd"
                echo "ackermann"
                echo "mecanum"
                echo
                exit 1
                
        elif [[ "$2" != "xv11" && "$2" != "rplidar" && "$2" != "ydlidar" && "$2" != "hokuyo" && "$2" != "kinect" && "$2" != "realsense" ]]
            then
                echo "Invalid linorobot sensor: $2"
                echo
                echo "Valid Options:"
                echo "hokuyo"
                echo "kinect"
                echo "lms1xx"
                echo "realsense"
                echo "rplidar"
                echo "xv11"
                echo "ydlidar"
                echo
                exit 1        
        elif [[ "$ARCH" != "x86_64" && "$2" == "realsense" ]]
            then
                echo "Intel Realsense R200 is not supported in $ARCH architecture."
                exit 1

        fi
        echo
        echo -n "You are installing ROS-$ROSDISTRO Linorobot for $BASE base with a $SENSOR sensor. Enter [y] to continue. " 
        read reply
        if [[ "$reply" != "y" && "$reply" != "Y" ]]
            then
                echo "Wrong input. Exiting now"
                exit 1
        fi
fi

sudo apt-get update
sudo apt-get install -y \
avahi-daemon \
openssh-server \
python-setuptools \
python-dev \
build-essential \
python-gudev

sudo easy_install pip
sudo python2.7 -m pip install -U platformio
sudo rm -rf $HOME/.platformio/
source /opt/ros/$ROSDISTRO/setup.bash

cd $HOME
mkdir -p xentrinobot_ws/src
cd $HOME/xentrinobot_ws/src
catkin_init_workspace

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

if [[ "$3" == "test" ]]
    then
        sudo apt-get install -y \
        ros-$ROSDISTRO-xv-11-laser-driver \
        ros-$ROSDISTRO-rplidar-ros \
        ros-$ROSDISTRO-urg-node \
        ros-$ROSDISTRO-lms1xx \
        ros-$ROSDISTRO-freenect-launch \
        ros-$ROSDISTRO-depthimage-to-laserscan \
        ros-$ROSDISTRO-rviz \
        ros-$ROSDISTRO-teb-local-planner 

        cd $HOME/xentrinobot_ws/src
        git clone https://github.com/EAIBOT/ydlidar.git

else
    if [[ "$SENSOR" == "hokuyo" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-urg-node
            hokuyoip=
            echo ""
            echo -n "Input your hokuyo IP. Press Enter to skip (Serial Based LIDAR): "
            read hokuyoip
            echo "export LIDARIP=$hokuyoip" >> $HOME/.bashrc

    elif [[ "$SENSOR" == "kinect" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-freenect-launch
            sudo apt-get install -y ros-$ROSDISTRO-depthimage-to-laserscan
            
    elif [[ "$SENSOR" == "lms1xx" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-lms1xx
            echo ""
            echo -n "Input your LMS1xx IP: "
            read lms1xxip
            echo "export LIDARIP=$lms1xxip" >> $HOME/.bashrc

    elif [[ "$SENSOR" == "realsense" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-realsense-camera
            sudo apt-get install -y ros-$ROSDISTRO-depthimage-to-laserscan

    elif [[ "$SENSOR" == "rplidar" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-rplidar-ros

    elif [[ "$SENSOR" == "xv11" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-xv-11-laser-driver

    elif [[ "$SENSOR" == "ydlidar" ]]
        then
            cd $HOME/xentrinobot_ws/src
            git clone https://github.com/EAIBOT/ydlidar.git
    fi

    if [[ "$BASE" == "ackermann" ]]
        then
            sudo apt-get install -y ros-$ROSDISTRO-teb-local-planner
    fi
fi

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
echo "INSTALLATION DONE!"
echo
