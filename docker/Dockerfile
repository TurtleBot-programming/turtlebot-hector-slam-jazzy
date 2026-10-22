# TurtleBot 4 Hector SLAM dashboard: ROS 2 Jazzy, Hector SLAM (patched), Nav2,
# the tb4_hector_slam package and the web UI, all pre-built.
# Build context is the repository root:  docker build -f docker/Dockerfile -t tb4-hector-slam .
FROM osrf/ros:jazzy-desktop

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-jazzy-nav2-bringup \
        ros-jazzy-turtlebot4-msgs \
        ros-jazzy-turtlebot4-description \
        ros-jazzy-irobot-create-msgs \
        ros-jazzy-tf-transformations \
        ros-jazzy-xacro \
        ros-jazzy-rmw-cyclonedds-cpp \
        ros-jazzy-rmw-fastrtps-cpp \
        python3-aiohttp python3-numpy iputils-ping iproute2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ws
COPY hector_slam src/hector_slam
COPY turtlebot_hector_slam/tb4_hector_slam src/tb4_hector_slam
RUN . /opt/ros/jazzy/setup.sh \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release --event-handlers console_direct- \
    && rm -rf build log

COPY app /app
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PORT=8080 DATA_DIR=/data
VOLUME /data
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3", "/app/server.py"]
