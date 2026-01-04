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


import os
import sys
import time

import numpy as np
from scipy.spatial.transform import Rotation as R

# Add RLinf root directory to Python path
from rlinf.envs.realworld.franka.franka_controller import FrankaController


def main():
    print("=" * 60)
    print("DEBUG: Starting test_controller")
    print("=" * 60)

    robot_ip = os.environ.get("FRANKA_ROBOT_IP", None)
    print(f"DEBUG: FRANKA_ROBOT_IP = {robot_ip}")

    assert robot_ip is not None, "Please set the FRANKA_ROBOT_IP environment variable."

    print(f"DEBUG: Launching controller with robot_ip={robot_ip}")
    controller = FrankaController.launch_controller(robot_ip=robot_ip)
    print("DEBUG: Controller launched successfully")

    print("DEBUG: Waiting for robot to be ready...")
    start_time = time.time()
    check_count = 0
    while not controller.is_robot_up().wait()[0]:
        check_count += 1
        elapsed = time.time() - start_time
        print(f"DEBUG: Check #{check_count}, elapsed={elapsed:.1f}s - robot not ready yet")
        time.sleep(0.5)
        if elapsed > 30:
            print(
                f"WARNING: Waited {elapsed} seconds for Franka robot to be ready."
            )

    print(f"DEBUG: Robot is ready! (took {time.time() - start_time:.1f}s)")
    print("=" * 60)
    print("Robot is ready. Available commands:")
    print("  getpos       - Get current TCP pose (quaternion)")
    print("  getpos_euler - Get current TCP pose (euler angles)")
    print("  q            - Quit")
    print("=" * 60)

    while True:
        try:
            cmd_str = input("Please input cmd:")
            if cmd_str == "q":
                break
            elif cmd_str == "getpos":
                print(controller.get_state().wait()[0].tcp_pose)
            elif cmd_str == "getpos_euler":
                tcp_pose = controller.get_state().wait()[0].tcp_pose
                r = R.from_quat(tcp_pose[3:].copy())
                euler = r.as_euler("xyz")
                print(np.concatenate([tcp_pose[:3], euler]))
            else:
                print(f"Unknown cmd: {cmd_str}")
        except KeyboardInterrupt:
            break
        time.sleep(1.0)


if __name__ == "__main__":
    main()
