#!/usr/bin/env bash
set -euo pipefail

SESSION="sensing"

# --- defaults (override via env or args) ---
WS_SETUP="${WS_SETUP:-$HOME/jssc-sensing/catkin_ws/devel/setup.bash}"
ROS_SETUP="${ROS_SETUP:-/opt/ros/noetic/setup.bash}"

MODE="${1:-remote}"                 # local | remote
ROS_IP_VAL="${ROS_IP_VAL:-192.168.10.134}"
ROS_MASTER_IP_VAL="${ROS_MASTER_IP_VAL:-192.168.10.133}"
ROS_MASTER_URI_REMOTE="http://${ROS_MASTER_IP_VAL}:11311"
ROS_MASTER_URI_LOCAL="http://127.0.0.1:11311"

# --- sanity checks ---
if [[ ! -f "${ROS_SETUP}" ]]; then
  echo "ERROR: Missing ${ROS_SETUP}"
  return 1 2>/dev/null || exit 1
fi

if [[ ! -f "${WS_SETUP}" ]]; then
  echo "ERROR: Missing ${WS_SETUP}"
  echo "Hint: build first: cd \$HOME/jssc-sensing/catkin_ws && catkin build"
  return 1 2>/dev/null || exit 1
fi

# --- choose master settings ---
if [[ "${MODE}" == "local" ]]; then
  export ROS_MASTER_URI="${ROS_MASTER_URI_LOCAL}"
  export ROS_IP="127.0.0.1"
  echo "[MODE=local] Using local roscore: ${ROS_MASTER_URI}, ROS_IP=${ROS_IP}"
elif [[ "${MODE}" == "remote" ]]; then
  export ROS_MASTER_URI="${ROS_MASTER_URI_REMOTE}"
  export ROS_IP="${ROS_IP_VAL}"
  echo "[MODE=remote] Using remote master: ${ROS_MASTER_URI}, ROS_IP=${ROS_IP}"
else
  echo "Usage:"
  echo "  ./sensing_tmux.sh local"
  echo "  ./sensing_tmux.sh remote"
  echo ""
  echo "Env overrides (remote mode):"
  echo "  ROS_IP_VAL=192.168.10.134 ROS_MASTER_IP_VAL=192.168.10.133 ./sensing_tmux.sh remote"
  return 2 2>/dev/null || exit 2
fi

# --- helper to run in panes with proper env ---
run_in_pane() {
  local cmd="$1"
  # use bash -lc so `source` works and env is applied
  tmux send-keys -t "${SESSION}" "bash -lc 'set -e; source \"${ROS_SETUP}\"; source \"${WS_SETUP}\"; ${cmd}'" C-m
}

# --- create session if not exists ---
if tmux has-session -t "${SESSION}" 2>/dev/null; then
  echo "tmux session '${SESSION}' already exists. Attaching..."
  tmux attach -t "${SESSION}"
  exit 0
fi

# Create base session (single pane)
tmux new-session -d -s "${SESSION}" -n "sensing"

# Build 2x2 layout:
# Start: pane 0 (top-left)
# Split right -> pane 1 (top-right)
# Split down on left -> pane 2 (bottom-left)
# Split down on right -> pane 3 (bottom-right)
tmux split-window -h -t "${SESSION}:0"           # pane 1
tmux select-pane -t "${SESSION}:0.0"
tmux split-window -v -t "${SESSION}:0.0"         # pane 2
tmux select-pane -t "${SESSION}:0.1"
tmux split-window -v -t "${SESSION}:0.1"         # pane 3

# Give panes titles (tmux 3.2+ supports display-panes; titles via status is optional)
tmux select-pane -t "${SESSION}:0.0" -T "GPS"
tmux select-pane -t "${SESSION}:0.1" -T "KC1400"
tmux select-pane -t "${SESSION}:0.2" -T "JS5 Localization"
tmux select-pane -t "${SESSION}:0.3" -T "LiDAR"

# Optional: show pane borders/titles nicely
tmux set-option -t "${SESSION}" pane-border-status top
tmux set-option -t "${SESSION}" pane-border-format "#P: #{pane_title}"

# --- If local mode, start roscore in background in pane 0 before everything else ---
if [[ "${MODE}" == "local" ]]; then
  tmux send-keys -t "${SESSION}:0.0" "bash -lc 'source \"${ROS_SETUP}\"; roscore'" C-m
  # wait a moment for master to come up
  tmux send-keys -t "${SESSION}:0.0" "sleep 2" C-m
fi

# --- Launch commands in each pane ---
# pane index mapping after splits:
# 0.0 top-left, 0.1 top-right, 0.2 bottom-left, 0.3 bottom-right

tmux select-pane -t "${SESSION}:0.0"
run_in_pane "rosrun nmea_navsat_driver nmea_socket_driver _port:=5106 _device:=udp"

tmux select-pane -t "${SESSION}:0.1"
run_in_pane "roslaunch kc1400_driver kc1400_bridge.launch interface:=eno1"

tmux select-pane -t "${SESSION}:0.2"
run_in_pane "roslaunch js5_localization localization.launch"

tmux select-pane -t "${SESSION}:0.3"
run_in_pane "roslaunch velodyne_pointcloud VLP16_points_js.launch"

# Attach
tmux attach -t "${SESSION}"
