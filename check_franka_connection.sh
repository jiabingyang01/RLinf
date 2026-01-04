#!/bin/bash
echo "========== Franka Connection Diagnostics =========="

echo -e "\n1. Basic network connectivity:"
ping -c 2 172.16.0.2

echo -e "\n2. Test FCI port 1883:"
timeout 3 bash -c 'cat < /dev/null > /dev/tcp/172.16.0.2/1883' 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Port 1883 is open"
else
    echo "✗ Port 1883 is NOT accessible"
fi

echo -e "\n3. Test web interface port 80:"
timeout 3 bash -c 'cat < /dev/null > /dev/tcp/172.16.0.2/80' 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Port 80 is open"
else
    echo "✗ Port 80 is NOT accessible"
fi

echo -e "\n4. Current environment:"
echo "Conda env: $CONDA_DEFAULT_ENV"
echo "Python: $(which python)"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

echo -e "\n5. libfranka version being used:"
ldd $(which python) | grep libfranka || echo "libfranka not linked to python"
ls -l /opt/venv/franka-*/franka_catkin_ws/libfranka/build/libfranka.so.* 2>/dev/null | grep "$(echo $LD_LIBRARY_PATH | cut -d: -f1)"

echo -e "\n6. ROS environment:"
echo "ROS_PACKAGE_PATH: $ROS_PACKAGE_PATH"
rospack find serl_franka_controllers 2>/dev/null || echo "serl_franka_controllers not found"

echo -e "\n7. Check if robot is locked/has errors:"
curl -k -s https://172.16.0.2/admin/api/robot 2>&1 | head -20 || echo "Cannot access robot API"

echo -e "\n8. Active roslaunch processes:"
ps aux | grep roslaunch | grep -v grep

echo -e "\n9. Check latest roslaunch logs:"
if [ -d ~/.ros/log/latest ]; then
    echo "Latest log directory: $(readlink -f ~/.ros/log/latest)"
    echo -e "\nController spawner errors:"
    grep -i "error\|fail\|timeout" ~/.ros/log/latest/controller_spawner*.log 2>/dev/null | tail -10
    echo -e "\nFranka control errors:"
    grep -i "error\|fail\|Could not" ~/.ros/log/latest/franka_control*.log 2>/dev/null | tail -10
fi

echo -e "\n10. Test simple franka connection:"
python3 << 'PYEOF'
import sys
sys.path.insert(0, '/opt/venv/franka-0.14.1/franka_catkin_ws/libfranka/build')
try:
    import ctypes
    lib_path = '/opt/venv/franka-0.14.1/franka_catkin_ws/libfranka/build/libfranka.so.0.14.1'
    lib = ctypes.CDLL(lib_path)
    print(f"✓ Successfully loaded libfranka from {lib_path}")
except Exception as e:
    print(f"✗ Failed to load libfranka: {e}")
PYEOF

echo -e "\n========== End Diagnostics =========="
