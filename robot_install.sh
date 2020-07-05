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
