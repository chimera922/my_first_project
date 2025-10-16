% =========================================================================
%               MATLAB 程序：曲柄摇杆机构运动仿真
% =========================================================================

%% 1. 初始化
clear;      % 清除工作区变量
clc;        % 清除命令行窗口
close all;  % 关闭所有图形窗口

%% 2. 定义机构参数 (单位：mm)
% 必须满足格拉晓夫定理: a+d <= b+c (此处 a 为最短杆)
a = 40;     % 曲柄长度 (a)
b = 120;    % 连杆长度 (b)
c = 80;     % 摇杆长度 (c)
d = 100;    % 机架长度 (d)

% 检查格拉晓夫条件
if (a + d) > (b + c) || (max([a,b,c,d]) > d) || (min([a,b,c,d]) ~= a)
    warning('警告：连杆长度可能不满足曲柄摇杆的格拉晓夫条件！');
end

%% 3. 设置动画
% 创建图形窗口
figure('Name', '曲柄摇杆机构仿真', 'NumberTitle', 'off');
hold on; % 保持绘图，以便在同一张图上更新
grid on; % 显示网格
axis equal; % 设置等比例坐标轴，确保机构看起来不变形

% 设置坐标轴范围，确保整个机构都能显示
axis_limit = d + c + 20;
axis([-a-20, axis_limit, -a-c-20, a+c+20]);
title('曲柄摇杆机构运动仿真');
xlabel('X (mm)');
ylabel('Y (mm)');

% 定义机架的两个枢轴点
O = [0, 0];
D = [d, 0];

% 预先绘制机架和枢轴点
plot(O(1), O(2), 'sk', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); % 枢轴 O
plot(D(1), D(2), 'sk', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); % 枢轴 D
plot([O(1), D(1)], [O(2), D(2)], 'k-', 'LineWidth', 4); % 机架连线

% 初始化连杆的绘图句柄，方便后续更新
h_crank = plot(0, 0, 'r-', 'LineWidth', 2.5);   % 曲柄句柄
h_coupler = plot(0, 0, 'b-', 'LineWidth', 2.5); % 连杆句柄
h_rocker = plot(0, 0, 'g-', 'LineWidth', 2.5);  % 摇杆句柄
h_joint_A = plot(0, 0, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % 关节A
h_joint_B = plot(0, 0, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g'); % 关节B

% 添加图例
legend('枢轴', '', '机架 (d)', '曲柄 (a)', '连杆 (b)', '摇杆 (c)');

%% 4. 运动学计算与动画循环
% 定义输入角度（曲柄转角），从0到2*pi，共360步
input_angles = linspace(0, 2*pi, 360);

for i = 1:length(input_angles)
    theta2 = input_angles(i);
    
    % --- 核心计算 ---
    % 计算关节 A 的坐标
    Ax = a * cos(theta2);
    Ay = a * sin(theta2);
    
    % 计算对角线 AD 的长度 (L)
    L = sqrt((Ax - d)^2 + Ay^2);
    
    % 计算角度 alpha 和 beta
    alpha = atan2(Ay, Ax - d);
    
    % 检查 acos 的输入是否在 [-1, 1] 范围内，防止计算错误
    cos_beta_arg = (c^2 + L^2 - b^2) / (2 * c * L);
    if abs(cos_beta_arg) > 1
        disp('机构无法到达此位置，请检查连杆长度！');
        break; % 退出循环
    end
    beta = acos(cos_beta_arg);
    
    % 计算摇杆角度 theta4 (我们选择一种装配模式)
    theta4 = alpha + beta; % 或者 alpha - beta，取决于装配方式
    
    % 计算关节 B 的坐标
    Bx = d + c * cos(theta4);
    By = c * sin(theta4);
    
    % --- 更新绘图 ---
    % 更新曲柄的位置
    set(h_crank, 'XData', [O(1), Ax], 'YData', [O(2), Ay]);
    
    % 更新连杆的位置
    set(h_coupler, 'XData', [Ax, Bx], 'YData', [Ay, By]);
    
    % 更新摇杆的位置
    set(h_rocker, 'XData', [D(1), Bx], 'YData', [D(2), By]);
    
    % 更新关节 A 和 B 的位置
    set(h_joint_A, 'XData', Ax, 'YData', Ay);
    set(h_joint_B, 'XData', Bx, 'YData', By);
    
    % 更新标题以显示当前角度
    title(sprintf('曲柄摇杆机构运动仿真 (曲柄转角: %.1f°)', rad2deg(theta2)));
    
    % 暂停一小段时间以形成动画效果
    pause(0.01);
end

disp('仿真结束。');