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

## Status

- [ ] Webots
- [ ] Gazebo
- [ ] Real TurtleBot 4
