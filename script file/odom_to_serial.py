#!/usr/bin/env python3
import rospy
import os
from geometry_msgs.msg import PoseStamped

class OdomToSerial:
    def __init__(self):
        os.system('stty -F /dev/ttyS0 115200 cs8 -cstopb -parenb')
        try:
            self.ser_fd = os.open('/dev/ttyS0', os.O_RDWR | os.O_NOCTTY)
            rospy.loginfo("Serial port opened: /dev/ttyS0")
        except Exception as e:
            rospy.logerr("Failed to open serial port: %s", e)
            return
        self.sub = rospy.Subscriber('/baton/stereo3/odom_relo', PoseStamped, self.callback)
        rospy.loginfo("Waiting for odom data...")

    def callback(self, msg):
        secs = msg.header.stamp.secs
        x = msg.pose.position.x
        y = msg.pose.position.y
        z = msg.pose.position.z
        qx = msg.pose.orientation.x
        qy = msg.pose.orientation.y
        qz = msg.pose.orientation.z
        qw = msg.pose.orientation.w

        data = "SECS  {}\n".format(secs)
        data += "POS   {:.4f}  {:.4f}  {:.4f}\n".format(x, y, z)
        data += "ORI   {:.4f}  {:.4f}  {:.4f}  {:.4f}\n".format(qx, qy, qz, qw)
        data += "END\n"

        try:
            os.write(self.ser_fd, data.encode())
            rospy.loginfo("Sent: %s", data.strip().replace('\n', ' '))
        except Exception as e:
            rospy.logerr("Send failed: %s", e)

    def __del__(self):
        if hasattr(self, 'ser_fd'):
            os.close(self.ser_fd)

if __name__ == '__main__':
    rospy.init_node('odom_to_serial')
    node = OdomToSerial()
    rospy.spin()
