#!/bin/bash
# Copyright 2025 The RLinf Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

die () {
    echo >&2 "$@"
    exit 1
}

usage="$(basename "$0") [-h] [-a xxx.xxx.xxx.xxx] -- Get Franka end-effector pose using ROS

where:
    -h show this help text
    -a Robot IP address (default 172.16.0.2)

Example:
    ./test_controller_ros.sh
    ./test_controller_ros.sh -a 172.16.0.2
    "

robot_ip="172.16.0.2"

while getopts ':h:a:' option; do
  case "${option}" in
    h) echo "$usage"
       exit
       ;;
    a) robot_ip=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

echo "Robot IP address: $robot_ip"
echo "Checking ROS connection to Franka..."

# Check if roscore is running
if ! pgrep -x "roscore" > /dev/null
then
    echo "roscore is not running. Starting roscore..."
    roscore &
    sleep 3
else
    echo "roscore is already running"
fi

# Check if franka_ros is available
if ! rospack find franka_ros > /dev/null 2>&1; then
    die "franka_ros not found. Please install franka_ros first."
fi

echo ""
echo "Getting end-effector pose from Franka robot..."
echo "Available commands:"
echo "  - rostopic echo /franka_state_controller/franka_states (get full robot state)"
echo "  - rostopic echo /franka_state_controller/O_T_EE (get end-effector pose matrix)"
echo ""

# Try to get the end-effector pose
echo "Attempting to read end-effector pose..."
timeout 5 rostopic echo /franka_state_controller/O_T_EE -n 1 2>/dev/null

if [ $? -ne 0 ]; then
    echo ""
    echo "Could not read end-effector pose from ROS topic."
    echo "Please make sure:"
    echo "  1. franka_control is running on the control PC"
    echo "  2. ROS_MASTER_URI is correctly set"
    echo "  3. The robot is connected and unlocked"
    echo ""
    echo "To manually check available topics, run:"
    echo "  rostopic list | grep franka"
fi
