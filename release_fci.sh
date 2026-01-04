#!/bin/bash
echo "Attempting to release FCI connection..."

# 1. 杀死所有可能的franka相关进程
echo "1. Stopping all franka-related processes on host..."
pkill -9 -f franka-interface
pkill -9 -f cartesian_impedance
pkill -9 -f "roslaunch.*franka"
pkill -9 -f "roslaunch.*impedance"

# 2. 在容器内也清理
echo "2. Stopping processes in container..."
pkill -9 -f "python.*franka"
pkill -9 -f roslaunch

# 3. 等待一下
sleep 2

# 4. 重启roscore
echo "3. Restarting roscore..."
pkill roscore
sleep 1
roscore &
sleep 2

echo "4. Checking if port 1883 is now accessible..."
timeout 3 bash -c 'cat < /dev/null > /dev/tcp/172.16.0.2/1883' 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Port 1883 is now accessible!"
else
    echo "✗ Port 1883 still not accessible"
    echo ""
    echo "Please manually:"
    echo "1. Go to https://172.16.0.2 in browser"
    echo "2. Settings → System → Restart Controller"
    echo "3. Wait for robot to restart (about 30 seconds)"
    echo "4. Try again"
fi
