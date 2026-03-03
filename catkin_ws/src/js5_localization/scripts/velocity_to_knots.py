#!/usr/bin/env python3
import rospy
import math
from geometry_msgs.msg import TwistStamped
from std_msgs.msg import Float64

KNOTS_PER_MPS = 1.94384449

class VelocityToKnots:
    def __init__(self):
        rospy.init_node("velocity_to_knots")

        self.pub = rospy.Publisher(
            "/kc1400/speed_knots",
            Float64,
            queue_size=10
        )

        rospy.Subscriber(
            "/kc1400/velocity",
            TwistStamped,
            self.cb
        )

    def cb(self, msg):
        vx = msg.twist.linear.x
        vy = msg.twist.linear.y
        vz = msg.twist.linear.z

        speed_mps = math.sqrt(vx*vx + vy*vy + vz*vz)
        speed_knots = speed_mps * KNOTS_PER_MPS

        self.pub.publish(speed_knots)

if __name__ == "__main__":
    VelocityToKnots()
    rospy.spin()
