# turtlebot-hector-slam-jazzy

Bundle for running Hector SLAM on a TurtleBot 4 under **ROS 2 Jazzy**, across three targets:

1. Webots
2. Gazebo
3. The physical TurtleBot 4 (runs Jazzy, not Humble)

## Layout

- `hector_slam/` – Hector SLAM packages (ported from the ROS 2 Humble bag)
- `turtlebot_hector_slam/` – TurtleBot 4 integration, Webots world, docs and handover notes

## Environment

Everything is built and run inside the Jazzy docker container (`jazzy` on the host drops you into it).

## Run in Webots

Webots (snap) runs on the host, the ROS 2 bridge, SLAM and Nav2 run in the `jazzy` container. Run from inside `~/ros2_jazzy_ws` (the directory the container mounts). Headless mode does not work with the snap (Qt xcb fails under xvfb), so use a real display.

```bash
turtlebot_hector_slam/webots/run_sim_docker.sh            # terminal 1: Webots + bridge
jazzy ros2 launch tb4_hector_slam slam_nav_launch.py \
    use_sim_time:=true explore:=true use_rviz:=false      # terminal 2: SLAM + Nav2 + explorer
jazzy python3 .../webots/tools/pose_logger.py pose.csv    # terminal 3 (optional)
jazzy ros2 run nav2_map_server map_saver_cli -f run       # when the explorer reports it is done
jazzy python3 .../webots/tools/evaluate_map.py run.yaml --pose-log pose.csv
```

Result of a full autonomous exploration run (`turtlebot_hector_slam/webots/results/`): wall precision 98.3 %, wall recall 96.2 %, free coverage 94.2 %, mean wall error 3.0 cm, pose RMSE 1.2 cm (max 6.6 cm) over 890 s of sim time.

## Status

- [x] Webots (SLAM + Nav2 + frontier exploration, scored against ground truth)
- [~] Gazebo: TB4 maze sim runs headless and the SLAM + Nav2 + explorer stack drives it (`turtlebot_hector_slam/gazebo/run_gz_headless.sh`), but the sim runs at about 0.25x real time with software rendering and Hector lost tracking, giving a partly corrupted map (`gazebo/maze_partial_map.png`). Not scored; needs a GPU or tuning.
- [ ] Real TurtleBot 4
