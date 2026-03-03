#!/usr/bin/env python3
import rospy
from geometry_msgs.msg import TwistStamped, TwistWithCovarianceStamped

class VelocityBridge:
    def __init__(self):
        rospy.init_node('velocity_bridge')
        rospy.loginfo("VelocityBridge: Node starting...")
        
        self.pub = rospy.Publisher('/kc1400/velocity_with_cov', TwistWithCovarianceStamped, queue_size=10)
        rospy.Subscriber('/kc1400/velocity', TwistStamped, self.cb)
        
        # Set a reasonable covariance for velocity (vx, vy)
        self.covariance = [0.0] * 36
        self.covariance[0] = 0.1  # Variance in x velocity
        self.covariance[7] = 0.1  # Variance in y velocity
        
        rospy.loginfo("VelocityBridge: Subscribed to /kc1400/velocity")

    def cb(self, msg):
        # rospy.loginfo_throttle(1.0, "VelocityBridge: Received msg with timestamp %s" % msg.header.stamp)
        out = TwistWithCovarianceStamped()
        out.header = msg.header
        out.twist.twist = msg.twist
        out.twist.covariance = self.covariance
        self.pub.publish(out)

if __name__ == '__main__':
    VelocityBridge()
    rospy.spin()
