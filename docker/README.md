# Dashboard in a container

One image holds ROS 2 Jazzy, the patched Hector SLAM, Nav2, the `tb4_hector_slam`
package and a web dashboard. The other computer only needs Docker; nothing has to
be built or installed there.

## On the build machine

```bash
docker/build_export.sh          # writes dist/tb4-hector-slam.tar.gz and dist/run.sh
```

Copy both files from `dist/` to the other computer (USB or `scp`).

## On the other computer

```bash
./run.sh                        # loads the image the first time, then starts the dashboard
```

Open <http://localhost:8080>. Results go to `./data/results/<session>/` next to `run.sh`;
settings are kept in `./data/settings.json`.

The container uses host networking and host IPC so ROS 2 discovery reaches the robot
exactly as a native install would. The computer must be on the robot's network, with
the robot's `ROS_DOMAIN_ID` and RMW set in the dashboard's **Settings** (the container
ignores the host's environment).

## Using the dashboard

1. **Settings**: domain id, RMW (`rmw_fastrtps_cpp` is the TurtleBot 4 default), namespace, robot IP, discovery server if the robot uses one.
2. **Run checks**: network ping, ROS discovery, `/scan` rate and QoS, `/odom`, TF (odom → base_link → lidar frame), which velocity interface the robot accepts, competing SLAM/Nav2 nodes, docked/battery. **Start** stays locked until no check fails (a result is valid for 10 minutes).
3. **Start SLAM + Nav2**: optionally with autonomous exploration. If the robot only takes `TwistStamped` on `/cmd_vel` a relay is started automatically.
4. Watch the live map, drive with the buttons or W/A/S/D, click-drag on the map to send a Nav2 goal.
5. **Evidence**: save the map, screenshots, video, rosbag, then **Export results** for a zip with maps and their statistics, trajectory CSV, check results, logs and `summary.json`.

Safety: **E-STOP** (or Esc) cancels goals and publishes zero velocity. If the lidar stream is lost while the stack runs, the dashboard does this by itself. Teleop stops when you release the key or the browser loses focus. Keep a person next to the robot.

## Without Docker (development)

```bash
source /opt/ros/jazzy/setup.bash && source install/setup.bash
DATA_DIR=./data python3 app/server.py
```
