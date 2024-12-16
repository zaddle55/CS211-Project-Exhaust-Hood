import tkinter as tk
import arcade
from tkinter import ttk
from datetime import datetime
from time import sleep
from threading import Thread
import random
import serial
import time

# 配置串口参数
serial_port = 'COM4'  # 串口名称
baud_rate = 9600      # 波特率
audio = arcade.load_sound("error.mp3")

# 检测可用串口
import serial.tools.list_ports
ports = serial.tools.list_ports.comports()
print("可用串口：")
for port, desc, hwid in sorted(ports):
    print(f"{port}: {desc} [{hwid}]")

ser = None
for port, desc, hwid in sorted(ports):
    try:
        ser = serial.Serial(serial_port, baud_rate, timeout=0.1)
        break
    except serial.SerialException:
        pass

if ser.is_open:
    print(f"串口 {serial_port} 已打开, 波特率 {baud_rate}")

def get_status_name(status):
    status_names = {
        0: "关机",
        1: "待机",
        2: "待机菜单",
        3: "自清洁模式",
        4: "风力一级档位",
        5: "风力二级档位",
        6: "风力三级档位",
        7: "飓风强制待机",
        8: "高级设置模式",
        9: "关机 (手势)",
        10: "待机 (手势)",
        11: "时间设置",
    }
    return status_names.get(status, "未知状态")

bg_color = "beige"

# 更新函数
def update(status, disp_state_o, set_state_c, set_position, aval, light, alert, sys_time, work_time, timer, alert_time, check_time, input, notes):
    # 设置背景颜色
    bg_color = "misty rose" if alert else "beige"

    root.config(bg=bg_color)

    # 更新系统时间显示
    sys_time_label.config(text=f"系统时间: {sys_time}")
    sys_time_label.config(bg=bg_color)


    # 更新进度条
    # 手势开关等待时间
    print("timer: ", timer)
    gest = timer
    if status != 9 and status != 10:
        gest = 0
    gesture_time_label.config(text=f"手势开关等待时间 ({gest}/{check_time})")
    gesture_time_label.config(bg=bg_color)
    gesture_progress['value'] = (gest / check_time) * 100 if check_time > 0 else 0

    # 工作时间
    work_time_string = f"{work_time//3600}:{(work_time%3600)//60}:{work_time%60}"
    alert_time_string = f"{alert_time//3600}:{(alert_time%3600)//60}:{alert_time%60}"
    work_time_label.config(text=f"工作时间 ({work_time_string}/{alert_time_string})")
    work_time_label.config(bg=bg_color)
    work_progress['value'] = (work_time / alert_time) * 100 if alert_time > 0 else 0

    # 更新左栏的状态
    status_label.config(text=f"{get_status_name(status)}")
    status_label.config(bg=bg_color)
    aval_label.config(text=f"三档位可用: {'是' if aval else '否'}")
    aval_label.config(bg=bg_color)
    light_label.config(text=f"照明: {'开启' if light else '关闭'}")
    light_label.config(bg=bg_color)

    time_set_str = "关闭"
    if set_position == 1:
        time_set_str = "秒"
    elif set_position == 2:
        time_set_str = "分"
    elif set_position == 3:
        time_set_str = "时"
    time_set_label.config(text=f"时间设置当前位: {time_set_str}")
    time_set_label.config(bg=bg_color)

    set_state_string = "无"
    if set_state_c == 1:
        set_state_string = "请选择"
    if set_state_c == 2:
        set_state_string = "最大工作时间"
    if set_state_c == 3:
        set_state_string = "手势检查时间"
    _set_label.config(text=f"高级设置当前项: {set_state_string}")
    _set_label.config(bg=bg_color)

    disp_state_o_string = "无"
    if disp_state_o == 0:
        disp_state_o_string = "系统时间"
    if disp_state_o == 1:
        disp_state_o_string = "最大工作时间"
    if disp_state_o == 2:
        disp_state_o_string = "累计工作时间"
    if disp_state_o == 3:
        disp_state_o_string = "手势检查时间"
    if disp_state_o == 4:
        disp_state_o_string = "倒计时"
    disp_state_label.config(text=f"七段数码管显示状态: {disp_state_o_string}")
    disp_state_label.config(bg=bg_color)

    work_lim = 0
    cur_work_tim = 0
    if(status == 3):
        cur_work_tim = timer
        work_lim = 180
    elif(status == 6 or status == 7):
        cur_work_tim = timer
        work_lim = 60

    timer_label.config(text=f"当前工作进度条 ({cur_work_tim} / {work_lim})")
    timer_label.config(bg=bg_color)
    cur_progress['value'] = (cur_work_tim / work_lim) * 100 if work_lim > 0 else 0

    notes_text.config(state=tk.NORMAL)
    notes_text.delete(1.0, tk.END)
    notes_text.insert(tk.END, notes)
    notes_text.config(state=tk.DISABLED)
    notes_text.config(bg=bg_color)

    # 更新按钮
    button_states = get_button_states(status, input, aval, set_state_c, disp_state_o)
    for i, btn in enumerate(buttons):
        state = button_states[i]
        if state == 1:
            btn.config(bg="lightgreen")
        elif state == 0:
            btn.config(bg="lightcoral")
        elif state == 2:
            btn.config(bg="gray")

buttons = []
button_names = [
    "电源 (P)", "菜单 (Space)", "自清洁 (C)", "恢复出厂模式 (R)", "照明 (L)", 
    "一级档位 (1)", "二级档位 (2)", "三级档位 (3)", "上 (W)", "下 (S)", 
    "左 (A)", "右 (D)", "确认 (M)", "高级设置 (E)", "[查] 累计工作时间 (O)", 
    "[设/查] 最大工作时间 (V)", "[设/查] 手势检查时间 (X)", "时间设置 (N)", "手动清洁 (T)"
]
button_row = [0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,8,9,8]
button_col = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0]
num_buttons = len(button_names)

def get_button_states(status, input, gear3_aval, set_state_c, disp_state_o):
    button_states = [0] * num_buttons

    # 按钮可用性字典
    available_buttons = {
        0: [0, 10],  # 关机状态: 电源、左
        1: [0, 1, 11, 17],  # 待机状态: 电源、右、时间设置、菜单、[查] 累计工作时间、[查] 最大工作时间、[查] 手势检查时间、确认（查看时可用）
        2: [2, 5, 6, 3, 13, 18],  # 待机菜单: 自清洁、一级档位、二级档位、三级档位（可用时显示）、高级设置、手动清洁、出厂设置
        3: [],  # 自清洁模式: 所有按键不可用
        4: [1, 6],  # 风力一级档位: 菜单、二级档位
        5: [1, 5],  # 风力二级档位: 菜单、一级档位
        6: [1],  # 风力三级档位: 菜单
        7: [],  # 飓风强制待机模式: 所有按键不可用
        8: [1],  # 高级设置模式: 菜单、[设] 最大工作时间、[设] 手势检查时间、确认（设置时可用）
        9: [11],  # 开机检查状态: 右
        10: [10],  # 关机检查状态: 左
        11: [1, 8, 9, 10, 11],  # 时间设置: 上、下、左、右、菜单
    }

    available = available_buttons.get(status, [])
    if status != 0 and status != 9:
        available.extend([4])  # 不关机，照明始终可用
    if status == 1:
        if disp_state_o == 0:
            available.extend([14,15,16])
        if (disp_state_o >= 1 and disp_state_o <= 3):
            available.extend([12])


    if status == 2 and gear3_aval:
        available.extend([7])
    if status == 8:
        if set_state_c == 1:
            available.extend([15, 16])
        if set_state_c >= 2:
            available.extend([12])

    available = list(set(available))

    for i in range(num_buttons):
        if input[i] == 1:  # 被按下
            button_states[i] = 2
        elif i in available:  # 可用
            button_states[i] = 1
        else:
            button_states[i] = 0

    return button_states

# 主界面设置
root = tk.Tk()
root.geometry("1280x720")
root.title("Kitchen Exhaust Hood Control")
root.config(bg=bg_color)

# 最上方系统时间显示
sys_time_label = tk.Label(root, text="系统时间: 00:00:00", font=("Arial", 24), height=2, bg=bg_color)
sys_time_label.pack(fill=tk.X)

# 最下方进度条
gesture_time_label = tk.Label(root, text="手势开关等待时间 (0/0)", font=("Arial", 14), bg=bg_color)
gesture_time_label.pack()
gesture_progress = ttk.Progressbar(root, length=640, mode="determinate")
gesture_progress.pack()

work_time_label = tk.Label(root, text="工作时间 (0/0)", font=("Arial", 14), bg=bg_color)
work_time_label.pack()
work_progress = ttk.Progressbar(root, length=640, mode="determinate")
work_progress.pack()

# 左栏内容
left_frame = tk.Frame(root, width=960, height=540, bg=bg_color)
left_frame.pack(side=tk.LEFT, fill=tk.BOTH)

status_label = tk.Label(left_frame, text="未知状态", font=("Arial", 36), height=2, bg=bg_color)
status_label.pack(fill=tk.X)

aval_label = tk.Label(left_frame, text="三档位可用: 是", font=("Arial", 14), height=2, bg=bg_color)
aval_label.pack(fill=tk.X)

light_label = tk.Label(left_frame, text="照明: 关闭", font=("Arial", 14), height=2, bg=bg_color)
light_label.pack(fill=tk.X)

time_set_label = tk.Label(left_frame, text="时间设置当前位: 关闭", font=("Arial", 14), height=2, bg=bg_color)
time_set_label.pack(fill=tk.X)

_set_label = tk.Label(left_frame, text="高级设置当前项: 无", font=("Arial", 14), height=2, bg=bg_color)
_set_label.pack(fill=tk.X)

disp_state_label = tk.Label(left_frame, text="七段数码管显示状态: 无", font=("Arial", 14), height=2, bg=bg_color)
disp_state_label.pack(fill=tk.X)

timer_label = tk.Label(left_frame, text="当前工作进度条 (0/0)", font=("Arial", 14), bg=bg_color)
timer_label.pack(fill=tk.X)

cur_progress = ttk.Progressbar(left_frame, length=200, mode="determinate")
cur_progress.pack(fill=tk.X)

notes_text = tk.Text(left_frame, font=("Arial", 12), wrap=tk.WORD, height=17, bg=bg_color, bd=0)
notes_text.pack(fill=tk.BOTH)
notes_text.config(state=tk.DISABLED)

# 右栏内容
right_frame = tk.Frame(root, width=320, height=540, bg=bg_color)
right_frame.pack(side=tk.RIGHT, fill=tk.BOTH)


for i in range(num_buttons):
    btn = tk.Label(right_frame, text=button_names[i], font=("Arial", 12), bg="lightgreen", width=18, height=2, anchor='center')
    row = button_row[i]
    col = button_col[i]
    btn.grid(row=row, column=col, padx=10, pady=5)
    buttons.append(btn)


audio_cnt = 0
def upd():
    try:
        while True:
            if ser.in_waiting >= 24:
                data = ser.read(24)
                data = data[::-1]
                # data 的格式：
                # 第一个字节：前四个二进制位 status，接着1个二进制位 light，接着1个二进制位 alert
                # 第二个字节：无效信息
                # 第三个字节：无效信息
                # 第四个字节：无效信息
                # 接着4个字节系统时间，接着4个字节工作时间，接着4个字节 timer，接着4个字节 alert_time，接着4个字节 check_time
                # --------------------------------------------------------------
                # 第1字节       status(4bit)      状态信息
                #               light(1bit)       照明信号
                #               alert(1bit)       警报信号
                #               gear3_aval(1bit)  三档位可用
                #               power(1bit)       电源按下状态
                # 第2字节       set_ptr(2bit)     时间设置指针
                #               set_state_c(2bit) 高级设置状态
                #               disp_state_o(3bit) 七段数码管显示状态
                #               menu_state(1bit)   菜单按钮按下状态
                # 第3字节       left_state(1bit)  左按钮按下状态
                #               right_state(1bit) 右按钮按下状态
                #               up_state(1bit)    上按钮按下状态
                #               down_state(1bit)  下按钮按下状态
                #               无效信息(4bit)    无意义
                # 第4字节       无效信息          无意义
                # 第5-8字节     系统时间          4字节（32位），系统时间
                # 第9-12字节    工作时间          4字节（32位），工作时间
                # 第13-16字节   timer             4字节（32位），当前模式持续时间
                # 第17-20字节   alert_time        4字节（32位），警报时间
                # 第21-24字节   check_time        4字节（32位），检查时间
                print()
                cnt = 0
                for byte in data:
                    binary_str = f"{byte:08b}"
                    print(f"{binary_str}", end = ' ') 
                    cnt = cnt+1
                    if cnt % 8 == 0:
                        print()

                status = (data[0] & 0b11110000)>>4
                print("status: ", status)
                light = (data[0] & 0b00001000)>>3
                alert = (data[0] & 0b00000100)>>2
                gear3_aval = (data[0] & 0b00000010)>>1 # TODO: display this
                print("gear3_aval: ", bool(gear3_aval))
                power = (data[0] & 0b00000001)
                print("power: ", bool(power))
                sys_time_int = data[7]+(data[6]<<8)+(data[5]<<16)+(data[4]<<24)
                sys_h = sys_time_int//3600
                sys_m = (sys_time_int%3600)//60
                sys_s = sys_time_int%60
                sys_time = f"{sys_h:02}:{sys_m:02}:{sys_s:02}"
                work_time = data[11]+(data[10]<<8)+(data[9]<<16)+(data[8]<<24)
                timer = data[15]+(data[14]<<8)+(data[13]<<16)+(data[12]<<24)
                alert_time = data[19]+(data[18]<<8)+(data[17]<<16)+(data[16]<<24)
                print("alert_time: ", alert_time)
                check_time = data[23]+(data[22]<<8)+(data[21]<<16)+(data[20]<<24)
                set_position = (data[1] & 0b11000000)>>6
                set_state_c = (data[1] & 0b00110000)>>4
                disp_state_o = (data[1] & 0b00001110)>>1
                menu_state = (data[1] & 0b00000001)
                print("disp_state_o: ", disp_state_o)
                r_input = [0 for _ in range(num_buttons)]
                r_input[0] = power
                r_input[1] = menu_state
                r_input[10] = (data[2] & 0b10000000)>>7
                r_input[11] = (data[2] & 0b01000000)>>6
                r_input[8] = (data[2] & 0b00100000)>>5
                r_input[9] = (data[2] & 0b00010000)>>4
                if alert:
                    global audio_cnt
                    audio_cnt += 1
                    if audio_cnt % 11 == 1:
                        arcade.play_sound(audio,1.0,-1)
                update(status, disp_state_o, set_state_c, set_position, gear3_aval, light, alert, sys_time, work_time, timer/100, alert_time, check_time, r_input, "")
            else:
                time.sleep(0.002)

    except KeyboardInterrupt:
        print("程序中断，关闭串口连接。")
    finally:
        ser.close()  # 关闭串口连接
        print("串口已关闭。")

thread = Thread(target=upd, daemon=True)
thread.start()

root.mainloop()
