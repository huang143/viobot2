#!/bin/bash
# ============================================
# Viobot2 重定位脚本
# 功能：加载地图 → 开启重定位 → 串口发送数据
make 
# 版本：ROS1 版本
# ============================================

CONFIG_FILE="/root/Baton/install/share/baton/config/sys.yaml"

echo "=========================================="
echo "        Viobot2 重定位脚本"
echo "=========================================="

# 1. 检查地图文件
echo ""
echo "[1/7] 检查地图文件..."
MAP_PATH=$(grep "pose_graph_save_path:" $CONFIG_FILE | awk '{print $2}')
MAP_DIR="$MAP_PATH/result/sparse/0"

if [ -f "$MAP_DIR/cameras.bin" ] && [ -f "$MAP_DIR/images.bin" ] && [ -f "$MAP_DIR/points3D.bin" ]; then
    echo "✓ 地图文件完整"
    echo "  路径: $MAP_DIR"
    echo ""
    echo "  地图信息："
    ls -lh $MAP_DIR/cameras.bin | awk '{print "    cameras.bin: " $5}'
    ls -lh $MAP_DIR/images.bin | awk '{print "    images.bin:  " $5}'
    ls -lh $MAP_DIR/points3D.bin | awk '{print "    points3D.bin: " $5}'
else
    echo "✗ 地图文件不完整！"
    echo "  需要以下文件:"
    echo "    $MAP_DIR/cameras.bin"
    echo "    $MAP_DIR/images.bin"
    echo "    $MAP_DIR/points3D.bin"
    echo ""
    echo "  请先运行建图脚本: ./build_map.sh"
    exit 1
fi

# 2. 配置重定位参数
echo ""
echo "[2/7] 配置重定位参数..."
sed -i 's/relocalization: false/relocalization: true/' $CONFIG_FILE
sed -i 's/load_previous_pose_graph: false/load_previous_pose_graph: true/' $CONFIG_FILE
echo "✓ relocalization = true"
echo "✓ load_previous_pose_graph = true"
echo "（record_flag 会自动保持为 false）"

# 3. 设置环境并清理旧进程
echo ""
echo "[3/7] 准备环境..."
source /root/Baton/install/setup.bash
pkill -f "stereo3" 2>/dev/null
sleep 2
echo "✓ 环境已准备"

# 4. 启动 stereo3 节点
echo ""
echo "[4/7] 启动 stereo3 节点..."
/root/Baton/install/lib/stereo3/stereo3 &
STEREO3_PID=$!
echo "✓ stereo3 已启动，PID: $STEREO3_PID"

# 5. 等待节点就绪
echo ""
echo "[5/7] 等待节点就绪..."
sleep 5

# 检查节点是否运行
if ! rosnode list 2>/dev/null | grep -q "stereo3"; then
    echo "✗ stereo3 节点启动失败"
    kill $STEREO3_PID 2>/dev/null
    exit 1
fi
echo "✓ stereo3 节点运行正常"

# 6. 发送启动指令
echo ""
echo "[6/7] 发送启动指令..."
rostopic pub -1 /baton/stereo3_ctrl system_ctrl/algo_ctrl \
    "{header: {seq: 0, stamp: {secs: 0, nsecs: 0}, frame_id: ''}, algo_enable: true, algo_reboot: false, algo_reset: false}" \
    2>/dev/null
echo "✓ 启动指令已发送"

# 等待重定位话题发布
echo "  等待重定位话题..."
for i in {1..15}; do
    if rostopic list 2>/dev/null | grep -q "/baton/stereo3/odom_relo"; then
        echo "✓ 重定位话题已发布"
        break
    fi
    sleep 1
    if [ $i -eq 15 ]; then
        echo "✗ 重定位话题未发布"
        echo "  可能原因：地图不匹配或设备未运动"
        echo "  请确认设备在已建图区域内运动"
        kill $STEREO3_PID 2>/dev/null
        exit 1
    fi
done

# 7. 启动串口转发
echo ""
echo "[7/7] 启动串口转发..."
sudo chmod 666 /dev/ttyS0 2>/dev/null

cd /home
if [ -f "odom_to_serial.py" ]; then
    echo "✓ 开始发送定位数据到串口..."
    echo ""
    echo "=========================================="
    echo "    重定位运行中，按 Ctrl+C 停止"
    echo "=========================================="
    echo ""
    python3 odom_to_serial.py
else
    echo "✗ 未找到 odom_to_serial.py"
    echo "  请确保串口转发程序在: /home/odom_to_serial.py"
    kill $STEREO3_PID 2>/dev/null
    exit 1
fi

# 清理
echo ""
echo "正在清理..."
kill $STEREO3_PID 2>/dev/null
echo "重定位已停止"
