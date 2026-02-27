function start_encryption_system()
    % 图像加解密系统启动脚本
    % 这是系统的主入口点
    
    clc;
    clear;
    close all;
    
    fprintf('==============================================\n');
    fprintf('      基于MATLAB的图像加解密系统\n');
    fprintf('==============================================\n');
    fprintf('正在启动系统...\n');
    
    % 检查必要的工具箱
    required_toolboxes = {'Image Processing Toolbox'};
    missing_toolboxes = {};
    
    for i = 1:length(required_toolboxes)
        if ~license('test', 'image_toolbox')
            missing_toolboxes{end+1} = required_toolboxes{i};
        end
    end
    
    if ~isempty(missing_toolboxes)
        fprintf('警告: 缺少以下工具箱，部分功能可能受限:\n');
        for i = 1:length(missing_toolboxes)
            fprintf('  - %s\n', missing_toolboxes{i});
        end
        fprintf('\n');
    end
    
    % 添加当前目录到路径
    current_dir = pwd;
    addpath(current_dir);
    
    % 创建示例图像目录
    sample_dir = 'sample_images';
    if ~exist(sample_dir, 'dir')
        mkdir(sample_dir);
        fprintf('创建示例图像目录: %s\n', sample_dir);
        
        % 生成一些示例图像
        generate_sample_images(sample_dir);
    end
    
    % 创建结果保存目录
    results_dir = 'encryption_results';
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
        fprintf('创建结果保存目录: %s\n', results_dir);
    end
    
    fprintf('系统初始化完成!\n');
    fprintf('==============================================\n\n');
    
    % 显示使用说明
    show_instructions();
    
    % 启动主界面
    fprintf('正在启动主界面...\n');
    main_encryption_gui();
    
    fprintf('图像加解密系统已启动!\n');
end

function generate_sample_images(sample_dir)
    % 生成示例图像供测试使用
    
    fprintf('正在生成示例图像...\n');
    
    try
        % 生成示例图像1: 渐变图像
        [X, Y] = meshgrid(1:256, 1:256);
        gradient_img = uint8(sqrt(X.^2 + Y.^2) / sqrt(2*256^2) * 255);
        imwrite(gradient_img, fullfile(sample_dir, 'gradient_256x256.png'));
        
        % 生成示例图像2: 棋盘图像
        checkerboard_img = uint8(checkerboard(32, 4) * 255);
        imwrite(checkerboard_img, fullfile(sample_dir, 'checkerboard_256x256.png'));
        
        % 生成示例图像3: 圆形图案
        [X, Y] = meshgrid(-128:127, -128:127);
        circle_img = uint8((sqrt(X.^2 + Y.^2) < 80) * 255);
        imwrite(circle_img, fullfile(sample_dir, 'circle_256x256.png'));
        
        % 生成示例图像4: 正弦波图案
        [X, Y] = meshgrid(1:256, 1:256);
        sine_img = uint8((sin(X/10) + sin(Y/10) + 2) / 4 * 255);
        imwrite(sine_img, fullfile(sample_dir, 'sine_pattern_256x256.png'));
        
        % 生成示例图像5: 随机噪声图像
        noise_img = uint8(rand(256, 256) * 255);
        imwrite(noise_img, fullfile(sample_dir, 'random_noise_256x256.png'));
        
        fprintf('成功生成 %d 张示例图像\n', 5);
        
    catch ME
        fprintf('生成示例图像时出错: %s\n', ME.message);
    end
end

function show_instructions()
    % 显示系统使用说明
    
    fprintf('==============================================\n');
    fprintf('                使用说明\n');
    fprintf('==============================================\n');
    fprintf('1. 导入图像:\n');
    fprintf('   - 点击"导入图像"按钮选择图像文件\n');
    fprintf('   - 支持格式: JPG, PNG, BMP, TIF\n');
    fprintf('   - 彩色图像将自动转换为灰度图像\n\n');
    
    fprintf('2. 加密操作:\n');
    fprintf('   - XOR加密: 使用异或运算进行加密\n');
    fprintf('   - 置乱加密: 使用像素位置置乱进行加密\n');
    fprintf('   - Arnold变换: 使用Arnold猫脸变换进行加密\n\n');
    
    fprintf('3. 解密操作:\n');
    fprintf('   - 必须先进行对应的加密操作\n');
    fprintf('   - 点击相应的解密按钮进行解密\n\n');
    
    fprintf('4. 数据分析:\n');
    fprintf('   - 点击"数据分析"按钮查看详细分析\n');
    fprintf('   - 包含直方图、相关性、质量评估等\n\n');
    
    fprintf('5. 保存结果:\n');
    fprintf('   - 点击"保存结果"按钮保存所有图像\n');
    fprintf('   - 结果保存在 encryption_results 目录\n\n');
    
    fprintf('6. 参数设置:\n');
    fprintf('   - 可以调整Arnold变换的迭代次数\n');
    fprintf('   - 系统会自动生成随机密钥\n\n');
    
    fprintf('==============================================\n\n');
end
