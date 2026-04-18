# Viobot2 双目视觉惯性 SLAM 设备使用实践

官网： https://www.hessian-matrix.com/%e4%ba%a7%e5%93%81%e4%b8%ad%e5%bf%83/
用户手册： https://baton-doc.readthedocs.io/en/viobot2/index.html

---

## 项目简介
本项目记录了在机器人战队中使用 Viobot2 设备进行建图与定位的完整流程。Viobot2 是一款集成了双目相机和 IMU 的嵌入式 SLAM 设备，运行 Ubuntu 20.04 + ROS Noetic。

## 主要工作
- ✅ 设备环境配置与网络调试（SSH、静态 IP）
- ✅ 多场景数据采集（双目图像 + 200Hz IMU）
- ✅ 建图与回环检测（VIO 算法配置、词袋地图）
- ✅ 地图导出与可视化（MeshLab、COLMAP）
- ✅ 系统故障修复（从 ROS2 误刷恢复到 ROS1）

## 快速导航
- [环境配置与连接](./docs/01-快速开始.md)
- [数据采集](./docs/02-数据采集.md)
- [建图与回环](./docs/03-建图与回环.md)
- [地图可视化](./docs/04-地图导出与可视化.md)
- [踩坑记录（重点）](./docs/05-问题解决.md)

## 技术栈
- Linux / ROS Noetic
- 双目视觉 / IMU / VIO
- MeshLab / COLMAP
- Python / Shell Script

## 成果展示
![[Pasted image 20260327230900.png]]
*室内场景建图结果（MeshLab 可视化）*