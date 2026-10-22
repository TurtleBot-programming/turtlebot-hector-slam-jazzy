#!/usr/bin/env bash
# Headless TurtleBot 4 Gazebo (Harmonic) maze sim inside the `jazzy` container.
# turtlebot4_gz.launch.py always starts the GUI, which segfaults in the
# container (no GPU, no /dev/dri), so run the server and spawn the robot
# separately. Then start SLAM + Nav2 in another terminal:
#   jazzy ros2 launch tb4_hector_slam slam_nav_launch.py use_sim_time:=true explore:=true use_rviz:=false
set -eo pipefail
WORLD="${1:-maze}"
MODEL="${MODEL:-lite}"   # lite has no OAK-D: far cheaper to render in software
jazzy bash -c "export GZ_SIM_RESOURCE_PATH=\$(ros2 pkg prefix turtlebot4_description)/share:\$(ros2 pkg prefix irobot_create_description)/share:\$GZ_SIM_RESOURCE_PATH
export LIBGL_ALWAYS_SOFTWARE=1
gz sim -s -r --headless-rendering -v 3 /opt/ros/jazzy/share/turtlebot4_gz_bringup/worlds/$WORLD.sdf" &
sleep 25
jazzy ros2 run ros_gz_bridge parameter_bridge '/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock' &
jazzy ros2 launch turtlebot4_gz_bringup turtlebot4_spawn.launch.py world:="$WORLD" model:="$MODEL" rviz:=false
