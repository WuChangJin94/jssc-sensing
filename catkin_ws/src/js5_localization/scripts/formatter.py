#!/usr/bin/env python3
import rospy, math
from nav_msgs.msg import Odometry
from std_msgs.msg import Float64

class Formatter:

    def __init__(self):
        rospy.loginfo("Formatter: Node starting...")
        self.pub_x = rospy.Publisher("/formatted_msg/x", Float64, queue_size=10)
        self.pub_y = rospy.Publisher("/formatted_msg/y", Float64, queue_size=10)
        self.pub_speed = rospy.Publisher("/formatted_msg/speed", Float64, queue_size=10)

        self.last_speed = 0.0
        self.MAX_SPEED = rospy.get_param("~max_speed", 5.0)
        self.alpha = rospy.get_param("~filter_alpha", 0.3)

        rospy.Subscriber("/odometry/filtered", Odometry, self.cb)
        rospy.loginfo("Formatter: Subscribed to /odometry/filtered")

    def cb(self, msg):
        # rospy.loginfo_throttle(2.0, "Formatter: Received Odom message")

        x = msg.pose.pose.position.x
        y = msg.pose.pose.position.y

        vx = msg.twist.twist.linear.x
        vy = msg.twist.twist.linear.y

        speed_raw = math.sqrt(vx*vx + vy*vy)

        # spike rejection
        if speed_raw > self.MAX_SPEED:
            rospy.logwarn("Speed spike rejected: %.2f" % speed_raw)
            return

        # low pass filter
        speed = self.alpha*speed_raw + (1-self.alpha)*self.last_speed
        self.last_speed = speed

        self.pub_x.publish(x)
        self.pub_y.publish(y)
        self.pub_speed.publish(speed)

if __name__ == "__main__":
    rospy.init_node("js5_formatter")
    Formatter()
    rospy.spin()
