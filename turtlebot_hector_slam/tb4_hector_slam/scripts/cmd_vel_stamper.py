#!/usr/bin/env python3
"""Relay plain Twist to TwistStamped.

  ros2 run tb4_hector_slam cmd_vel_stamper.py [--in cmd_vel_unstamped] [--out cmd_vel]

Nav2 here ends in /cmd_vel_unstamped (Twist). Use this if the robot only
accepts geometry_msgs/TwistStamped on /cmd_vel (see preflight_real_robot.sh).
"""
import argparse

import rclpy
from geometry_msgs.msg import Twist, TwistStamped
from rclpy.node import Node


class Stamper(Node):
    def __init__(self, src, dst):
        super().__init__('cmd_vel_stamper')
        self.pub = self.create_publisher(TwistStamped, dst, 10)
        self.create_subscription(Twist, src, self.cb, 10)

    def cb(self, msg):
        out = TwistStamped()
        out.header.stamp = self.get_clock().now().to_msg()
        out.header.frame_id = 'base_link'
        out.twist = msg
        self.pub.publish(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--in', dest='src', default='cmd_vel_unstamped')
    ap.add_argument('--out', dest='dst', default='cmd_vel')
    args, ros_args = ap.parse_known_args()
    rclpy.init(args=ros_args)
    rclpy.spin(Stamper(args.src, args.dst))


if __name__ == '__main__':
    main()
