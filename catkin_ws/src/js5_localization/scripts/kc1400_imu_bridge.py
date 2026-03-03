#!/usr/bin/env python3
import rospy, math
from std_msgs.msg import Float64
from sensor_msgs.msg import Imu
from tf.transformations import quaternion_from_euler

class KC1400IMU:

    def __init__(self):

        self.pub = rospy.Publisher("/kc1400/imu", Imu, queue_size=10)

        self.heading = None
        self.rot_rate = None

        rospy.Subscriber("/kc1400/heading", Float64, self.heading_cb)
        rospy.Subscriber("/kc1400/rate_of_turn", Float64, self.rate_cb)

    def heading_cb(self, msg):
        self.heading = math.pi/2 - math.radians(msg.data)
        self.publish()

    def rate_cb(self, msg):
        self.rot_rate = math.radians(msg.data)
        self.publish()

    def publish(self):

        if self.heading is None or self.rot_rate is None:
            return

        imu = Imu()
        imu.header.stamp = rospy.Time.now()
        imu.header.frame_id = "base_link"

        q = quaternion_from_euler(0,0,self.heading)
        imu.orientation.x = q[0]
        imu.orientation.y = q[1]
        imu.orientation.z = q[2]
        imu.orientation.w = q[3]

        imu.angular_velocity.z = self.rot_rate

        imu.orientation_covariance[8] = 0.05
        imu.angular_velocity_covariance[8] = 0.01

        self.pub.publish(imu)

if __name__ == "__main__":
    rospy.init_node("kc1400_imu_bridge")
    KC1400IMU()
    rospy.spin()
