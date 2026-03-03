#!/usr/bin/env python3
import rospy
import math
from nav_msgs.msg import Odometry
from geometry_msgs.msg import TwistStamped
from std_msgs.msg import Float64

class Formatter:

    def __init__(self):
        rospy.loginfo("Formatter: Node starting...")

        self.pub_x = rospy.Publisher("/formatted_msg/x", Float64, queue_size=10)
        self.pub_y = rospy.Publisher("/formatted_msg/y", Float64, queue_size=10)
        self.pub_speed = rospy.Publisher("/formatted_msg/speed", Float64, queue_size=10)

        self.last_speed = 0.0
        self.MAX_SPEED = rospy.get_param("~max_speed", 12.0)       # in m/s
        self.alpha = rospy.get_param("~filter_alpha", 0.3)

        rospy.Subscriber("/odometry/filtered", Odometry, self.cb_odom)
        rospy.Subscriber("/kc1400/velocity", TwistStamped, self.cb_vel)

        rospy.loginfo("Formatter: Subscribed to /odometry/filtered and /kc1400/velocity")

    def cb_odom(self, msg):
        x = msg.pose.pose.position.x
        y = msg.pose.pose.position.y
        self.pub_x.publish(x)
        self.pub_y.publish(y)

    def cb_vel(self, msg):
        vx = msg.twist.linear.x
        vy = msg.twist.linear.y
        vz = msg.twist.linear.z

        # Speed in m/s (same definition as your VelocityToKnots before conversion)
        speed_raw = math.sqrt(vx*vx + vy*vy + vz*vz)

        # Spike rejection
        if speed_raw > self.MAX_SPEED:
            rospy.logwarn("Speed spike rejected: %.2f m/s" % speed_raw)
            return

        # Low pass filter
        speed = self.alpha * speed_raw + (1 - self.alpha) * self.last_speed
        self.last_speed = speed

        self.pub_speed.publish(speed)

if __name__ == "__main__":
    rospy.init_node("js5_formatter")
    Formatter()
    rospy.spin()