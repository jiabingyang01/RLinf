#!/usr/bin/env python3
import sys
import os

# 设置libfranka路径
libfranka_path = '/opt/venv/franka-0.14.1/franka_catkin_ws/libfranka/build'
sys.path.insert(0, libfranka_path)
os.environ['LD_LIBRARY_PATH'] = libfranka_path + ':' + os.environ.get('LD_LIBRARY_PATH', '')

robot_ip = "172.16.0.2"

print(f"Attempting to connect to robot at {robot_ip}...")
print("This will test if FCI is accessible.\n")

try:
    # 尝试导入并连接
    import ctypes
    lib = ctypes.CDLL(f'{libfranka_path}/libfranka.so.0.14.1')
    print("✓ libfranka loaded successfully")

    # 简单的网络连接测试
    import socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(3)
    result = sock.connect_ex((robot_ip, 1883))
    sock.close()

    if result == 0:
        print(f"✓ Port 1883 is accessible")
    else:
        print(f"✗ Port 1883 is NOT accessible (error code: {result})")
        print("\nPossible reasons:")
        print("1. Robot is not unlocked")
        print("2. FCI is not enabled in robot settings")
        print("3. Another program is using the FCI connection")
        print("4. Robot is in an error state")
        print("\nPlease check:")
        print(f"- Web interface: https://{robot_ip}")
        print("- Robot should show 'white' light (ready)")
        print("- No other programs should be controlling the robot")

except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "="*60)
print("Next steps:")
print("1. Access https://172.16.0.2 in browser")
print("2. Login and unlock the robot")
print("3. Check Settings → ensure FCI is enabled")
print("4. Make sure no other programs are connected")
print("="*60)
