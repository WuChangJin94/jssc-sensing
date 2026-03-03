#!/usr/bin/env python3
import rospy
import math
from std_msgs.msg import Float64
from geometry_msgs.msg import TwistStamped
from sensor_msgs.msg import NavSatFix


class DataFormatter:
    def __init__(self):
        rospy.init_node("formatted_publisher_node")

        # --- Parameters ---
        self.home_lat_deg = rospy.get_param("~home_lat", 22.5027528)
        self.home_lon_deg = rospy.get_param("~home_lon", 120.326114)
        self.home_lat_rad = math.radians(self.home_lat_deg)
        self.home_lon_rad = math.radians(self.home_lon_deg)

        # --- Publishers ---
        self.pub_speed   = rospy.Publisher('/formatted_msg/speed', Float64, queue_size=10)
        self.pub_x_local = rospy.Publisher('/formatted_msg/x',     Float64, queue_size=10)
        self.pub_y_local = rospy.Publisher('/formatted_msg/y',     Float64, queue_size=10)

        # --- Subscribers ---
        rospy.Subscriber('/vel', TwistStamped, self.velocity_callback)
        rospy.Subscriber('/fix', NavSatFix, self.gps_callback)

    # GPS velocity -> speed
    def velocity_callback(self, msg: TwistStamped):
        v_east  = msg.twist.linear.x
        v_north = msg.twist.linear.y
        speed = math.hypot(v_east, v_north)
        self.pub_speed.publish(Float64(speed))

    def gps_callback(self, msg: NavSatFix):
        if msg.status.status < 0:
            return

        # Convert current GPS to x,y
        x, y = self.latlon_to_xy(msg.latitude, msg.longitude)

        # Convert home GPS to x,y
        x0, y0 = self.latlon_to_xy(self.home_lat_deg, self.home_lon_deg)

        # Local ENU offsets
        x_local = x - x0
        y_local = y - y0

        self.pub_x_local.publish(Float64(x_local))
        self.pub_y_local.publish(Float64(y_local))

    def latlon_to_xy(self, lat, lon):
        a = 6378137.0                     # WGS84 semi-major axis
        f = 1 / 298.257223563             # flattening
        lat_rad = math.radians(lat)
        lon_rad = math.radians(lon)

        e2 = (2 * f - f ** 2)
        N = a / math.sqrt(1 - e2 * (math.sin(lat_rad) ** 2))

        # approximate projection
        x = N * (lon_rad - 0.0)
        s = math.sqrt(e2)
        t = math.sqrt(1 + math.tan(lat_rad)**2)
        y = N * math.log(
            math.tan(math.pi / 4 + lat_rad / 2) *
            ((1 - s * math.sin(lat_rad)) / (1 + s * math.sin(lat_rad))) ** (s / 2.0)
        )

        return x, y

    def run(self):
        rospy.spin()


if __name__ == '__main__':
    formatter = DataFormatter()
    formatter.run()
