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

The dashboard is the single control hub. Pick the **target** in the header: **Real robot**, **Gazebo** or **Webots**. The header's *Next:* line says what to do next. **Quick start** does everything for the chosen target in one click: start the simulator (if any), run the connection checks, undock (if docked), re-check, then start SLAM + Nav2 (+ RViz). **Stop all** cancels goals and stops SLAM + Nav2 and the simulator. Switching target is only allowed when nothing is running.

**Settings** (real robot): domain id, RMW (`rmw_fastrtps_cpp` is the TurtleBot 4 default), namespace, robot IP, discovery server if the robot uses one. The container ignores the host's ROS environment.

1. **Simulation panel** (Gazebo / Webots): choose the world and press *Start simulation*. Both run inside the container on their own ROS domain (default 42), so they can never move a real robot. Webots is the validated simulator. Gazebo: *Render = software* (default) gives a correct lidar but runs slowly; *GPU* is faster but returned a broken lidar (every beam at the minimum range) on the Intel/AMD GPU tested, and the connection checks flag this.
2. **Connection checks**: network ping, ROS discovery, `/scan` rate, QoS and sanity (a lidar returning one constant distance fails), `/odom`, TF (odom → base_link → lidar frame), which velocity interface the robot accepts, competing SLAM/Nav2 nodes, docked/battery. **Start** stays locked until no check fails (a result is valid for 10 minutes).
3. **Robot panel**: *Undock*, *Dock*, *Lidar on/off* (the TurtleBot 4 lidar driver's `start_motor`/`stop_motor` services) and *Go to start* (Nav2 goal to where mapping began). Undock/Dock are hidden for Webots (no dock there).
4. **Start SLAM + Nav2**: optionally with autonomous exploration and the RViz window (when the container has a display); Gazebo always runs headless, so you follow the map in the dashboard or RViz. If the robot only takes `TwistStamped` on `/cmd_vel` a relay is started automatically.
5. Watch the live map, drive with the buttons or W/A/S/D, click-drag on the map to send a Nav2 goal.
6. **Evidence**: save the map, screenshots, video, rosbag, then **Export results** for a zip with maps and their statistics, trajectory CSV, check results, logs and `summary.json`.

Safety: **E-STOP** (or Esc) cancels goals and publishes zero velocity. If the lidar stream is lost while the stack runs, the dashboard does this by itself. Teleop stops when you release the key or the browser loses focus. Keep a person next to the robot.

## Without Docker (development)

```bash
source /opt/ros/jazzy/setup.bash && source install/setup.bash
DATA_DIR=./data python3 app/server.py
```

## Known issues

- **Gazebo mapping works but is rough.** A headless software-rendered run built a recognisable map of the maze (`turtlebot_hector_slam/gazebo/maze_headless_run.png`), but the sim runs well below real time, so the scan rate per rotation is low: Hector smears the map where the robot turns quickly, and Nav2 (tuned for real time) often wedges the robot against a wall, where `collision_monitor` and MPPI report no valid trajectories and it spins in place. Not scored.
- **Gazebo with GPU rendering gives a broken lidar** (all 640 beams read exactly the minimum range, 0.16 m), so Hector can never build a map. Software rendering gives correct ranges (1.0 to 11.6 m in the maze) but runs at roughly 0.15x real time, so mapping is slow. Mapping in Gazebo is not scored; Webots is.
- On a fast sim the `/clock` bridge can fall behind (333 clock messages/s at the default 3 ms step), stamping scans far ahead of the clock and breaking every time-stamped TF lookup. A 10 ms physics step avoids it: `gz service -s /world/maze/set_physics --reqtype gz.msgs.Physics --reptype gz.msgs.Boolean --timeout 3000 --req "max_step_size: 0.01 real_time_factor: 1.0"`.
- After **Stop**, the helper can be slow to answer for a while on a loaded machine; saving settings restarts it.
