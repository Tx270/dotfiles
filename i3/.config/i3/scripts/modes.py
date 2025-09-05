#!/home/tx27/.config/.venv/bin/python
import os
import i3ipc
import sys
import subprocess

def already_running():
    try:
        current_pid = os.getpid()
        script_path = os.path.abspath(__file__)
        result = subprocess.run(
            ["pgrep", "-fx", f"python {script_path}"],
            stdout=subprocess.PIPE,
            text=True
        )
        for pid in result.stdout.strip().split():
            if pid and int(pid) != current_pid:
                return True
        return False
    except Exception as e:
        return False

if already_running():
    print("Script is already running, exiting.")
    sys.exit(0)

i3 = i3ipc.Connection()
home = os.environ["HOME"]
mode_file = os.path.join(home, ".config", "mode")

border_size = 2

def get_mode():
    try:
        return open(mode_file).read().strip()
    except FileNotFoundError:
        return "default"

def apply_mode_settings():
    global border_size
    mode = get_mode()

    if mode == "showy":
        i3.command("gaps inner all set 4")
        i3.command("gaps outer all set 3")
        border_size = 3
    elif mode == "focus":
        i3.command("gaps inner all set 0")
        i3.command("gaps outer all set 0")
        border_size = 2
    else:
        border_size = 2

def update_window_borders():
    tree = i3.get_tree()
    for ws in i3.get_workspaces():
        workspace = tree.find_named(ws.name)[0]
        windows = [w for w in workspace.leaves()]

        if len(windows) == 1:
            windows[0].command("border none")
        else:
            for win in windows:
                win.command(f"border pixel {border_size}")

def on_change(i3, e):
    apply_mode_settings()
    update_window_borders()

apply_mode_settings()
update_window_borders()

i3.on("window::new", on_change)
i3.on("window::close", on_change)
i3.on("workspace::focus", on_change)

i3.main()

