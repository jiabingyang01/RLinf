#!/bin/bash

# Source ROS Noetic environment
source /opt/ros/noetic/setup.bash

# Check if serl_franka_controllers is available
if ! rospack find serl_franka_controllers &>/dev/null; then
    echo "ERROR: serl_franka_controllers package not found in ROS_PACKAGE_PATH"
    echo "Current ROS_PACKAGE_PATH: $ROS_PACKAGE_PATH"
    echo ""
    echo "Please do ONE of the following:"
    echo "1. Source your catkin workspace: source <your_catkin_ws>/devel/setup.bash"
    echo "2. Or install franka packages following the RLinf installation guide"
    exit 1
fi

# Set FRANKA_ROBOT_IP if not set
if [ -z "$FRANKA_ROBOT_IP" ]; then
    echo "ERROR: FRANKA_ROBOT_IP environment variable is not set"
    echo "Please set it: export FRANKA_ROBOT_IP=<your_robot_ip>"
    exit 1
fi

# Add RLinf to Python path
export PYTHONPATH=/media/casia/data1/yjb/projects/VLA/RLinf:$PYTHONPATH

# Run the test controller
python /media/casia/data1/yjb/projects/VLA/RLinf/toolkits/realworld_check/test_controller.py
