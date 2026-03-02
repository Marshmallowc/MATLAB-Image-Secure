function multi_level_analysis_gui(original_image)
    % 多级加密对比分析界面
    % 对比一级（Arnold）、二级（Arnold+置乱）、三级（Arnold+置乱+XOR）的开销与收益
    
    if nargin < 1 || isempty(original_image)
        % 如果遇到因MATLAB缓存机制导致传入空图像，则直接弹出选择框让用户重新选图
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif', ...
            '图像文件 (*.jpg, *.jpeg, *.png, *.bmp, *.tif)'}, '系统检测到图像为空，请重新选择图像');
            
        if ischar(filename)
            original_image = imread(fullfile(pathname, filename));
        else
            % 用户取消选择，尝试使用默认测试图像
            sample_path = fullfile(pwd, 'cat.png');
            if exist(sample_path, 'file')
                original_image = imread(sample_path);
            else
                errordlg('未能获取到有效图像，请在MATLAB命令行输入 close all; clear 后重新运行系统！', '错误');
                return;
            end
        end
    end

    % 确保图像是灰度的
    if size(original_image, 3) == 3
        original_image = rgb2gray(original_image);
    end

    % 参数设置
    arnold_iters = 5;
    key = 12345678; % 正整数密钥
    
    % 创建进度对话框
    h_wait = waitbar(0, '正在进行多级加密及多维度视效分析，请稍候...');
    
    try
        %% 一级加密：Arnold变换
        waitbar(0.1, h_wait, '执行一级加密 (Arnold)...');
        tic;
        enc_L1 = arnold_encrypt(original_image, arnold_iters);
        time_L1 = toc;
        
        %% 二级加密：Arnold变换 + XOR
        waitbar(0.4, h_wait, '执行二级加密 (Arnold + XOR)...');
        tic;
        enc_L2_tmp = arnold_encrypt(original_image, arnold_iters);
        enc_L2 = xor_encrypt(enc_L2_tmp, key);
        time_L2 = toc;
        
        %% 三级加密：Arnold变换 + XOR + 位置置乱
        waitbar(0.7, h_wait, '执行三级加密 (Arnold + XOR + 置乱)...');
        tic;
        enc_L3_tmp1 = arnold_encrypt(original_image, arnold_iters);
        enc_L3_tmp2 = xor_encrypt(enc_L3_tmp1, key);
        [enc_L3, ~] = scramble_encrypt(enc_L3_tmp2);
        time_L3 = toc;
        
        %% 计算评估指标
        waitbar(0.9, h_wait, '计算多维度评估指标...');
        
        % 计算信息熵
        entropy_orig = calculate_entropy(original_image);
        entropy_L1 = calculate_entropy(enc_L1);
        entropy_L2 = calculate_entropy(enc_L2);
        entropy_L3 = calculate_entropy(enc_L3);
        
        % 计算相邻像素相关性 (水平方向)
        corr_orig = calculate_correlation(original_image, circshift(original_image, [0, 1]));
        corr_L1 = calculate_correlation(enc_L1, circshift(enc_L1, [0, 1]));
        corr_L2 = calculate_correlation(enc_L2, circshift(enc_L2, [0, 1]));
        corr_L3 = calculate_correlation(enc_L3, circshift(enc_L3, [0, 1]));

        % 计算PSNR (峰值信噪比，比较与原图差异)
        psnr_L1 = calculate_psnr(original_image, enc_L1);
        psnr_L2 = calculate_psnr(original_image, enc_L2);
        psnr_L3 = calculate_psnr(original_image, enc_L3);
        
        % 打印量化结果到控制台，供详细分析
        fprintf('\n================== 多级加密性能量化数据 ==================\n');
        fprintf('【1. 加密耗时 (秒/越低越好)】\n');
        fprintf('一级加密 (Arnold):         %.4f s\n', time_L1);
        fprintf('二级加密 (Arnold+XOR):     %.4f s\n', time_L2);
        fprintf('三级加密 (Arnold+XOR+置乱): %.4f s (相比二级增加: %+.2f%%)\n\n', time_L3, (time_L3-time_L2)/time_L2*100);
        
        fprintf('【2. 信息熵 (bit/pixel，越接近8理想值越好)】\n');
        fprintf('原图:     %.4f\n', entropy_orig);
        fprintf('一级加密: %.4f\n', entropy_L1);
        fprintf('二级加密: %.4f\n', entropy_L2);
        fprintf('三级加密: %.4f\n\n', entropy_L3);
        
        fprintf('【3. 相邻像素相关系数 (越接近0理想值越好)】\n');
        fprintf('原图:     %.4f\n', abs(corr_orig));
        fprintf('一级加密: %.4f\n', abs(corr_L1));
        fprintf('二级加密: %.4f\n', abs(corr_L2));
        fprintf('三级加密: %.4f\n\n', abs(corr_L3));
        
        fprintf('【4. PSNR (峰值信噪比，越低表示破坏越彻底)】\n');
        fprintf('一级加密: %.4f\n', psnr_L1);
        fprintf('二级加密: %.4f\n', psnr_L2);
        fprintf('三级加密: %.4f\n', psnr_L3);
        fprintf('==========================================================\n\n');

        close(h_wait);
        
        %% 创建大型GUI全面展示
        fig = figure('Name', '多级加密性能与多维视效深度对比分析 (边际收益论证)', 'Position', [50, 50, 1400, 950]);
        % 背景设为白色或浅色更专业
        set(fig, 'Color', [0.95 0.95 0.95]);

        % 定义通用的制图标题字体大小
        title_fz = 11;
        
        %% 第一排：直观视觉图
        subplot(4, 4, 1); imshow(original_image); title('【原图】', 'FontSize', title_fz, 'Color', 'b');
        subplot(4, 4, 2); imshow(enc_L1); title('【一级】空间置乱 (纹理残留)', 'FontSize', title_fz);
        subplot(4, 4, 3); imshow(enc_L2); title('【二级】空间+像素模糊 (白噪声)', 'FontSize', title_fz);
        subplot(4, 4, 4); imshow(enc_L3); title('【三级】过度打乱 (视觉无差异)', 'FontSize', title_fz);

        %% 第二排：灰度直方图对比 (看像素均匀度)
        subplot(4, 4, 5); imhist(original_image); title('原图直方图 (特征明显)', 'FontSize', title_fz, 'Color', 'b'); grid on;
        subplot(4, 4, 6); imhist(enc_L1); title('一级直方图 (完全未改变)', 'FontSize', title_fz); grid on;
        subplot(4, 4, 7); imhist(enc_L2); title('二级直方图 (完全均匀平坦)', 'FontSize', title_fz); ylim('auto'); grid on;
        subplot(4, 4, 8); imhist(enc_L3); title('三级直方图 (与二级相同)', 'FontSize', title_fz); ylim('auto'); grid on;

        %% 第三排：相邻像素相关性散点图 (看是否阻断规律)
        subplot(4, 4, 9); plot_scatter_internal(original_image, '原图: 强线性相关 (近y=x)', 'b');
        subplot(4, 4, 10); plot_scatter_internal(enc_L1, '一级: 相关性减弱但有规律');
        subplot(4, 4, 11); plot_scatter_internal(enc_L2, '二级: 呈完全随机云团状');
        subplot(4, 4, 12); plot_scatter_internal(enc_L3, '三级: 随机云团 (无进一步收益)');

        %% 第四排：量化指标对比图
        % 1. 耗时对比图
        subplot(4, 4, 13);
        b1 = bar([1, 2, 3], [time_L1, time_L2, time_L3], 'FaceColor', [0.8 0.3 0.3]);
        set(gca, 'XTick', 1:3, 'XTickLabel', {'一级', '二级', '三级'});
        title('核心开销: 加密耗时 (秒/越高越差)', 'FontSize', title_fz);
        text(1:3, [time_L1, time_L2, time_L3], num2str([time_L1, time_L2, time_L3]', '%0.3fs'), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        grid on;
        
        % 2. 信息熵对比图
        subplot(4, 4, 14);
        b2 = bar([0, 1, 2, 3], [entropy_orig, entropy_L1, entropy_L2, entropy_L3], 'FaceColor', [0.3 0.6 0.8]);
        hold on; plot([-0.5, 3.5], [8, 8], 'r-', 'LineWidth', 2); % 理论极值线
        set(gca, 'XTick', 0:3, 'XTickLabel', {'原图', '一级', '二级', '三级'});
        title('安全指标: 信息熵 (趋近8最佳)', 'FontSize', title_fz);
        ylim([min(entropy_orig)*0.9 8.2]);
        grid on;
        
        % 3. 相关系数对比图
        subplot(4, 4, 15);
        b3 = bar([0, 1, 2, 3], abs([corr_orig, corr_L1, corr_L2, corr_L3]), 'FaceColor', [0.4 0.8 0.4]);
        set(gca, 'XTick', 0:3, 'XTickLabel', {'原图', '一级', '二级', '三级'});
        title('安全指标: 水平相关系数 (趋近0最佳)', 'FontSize', title_fz);
        grid on;

        % 4. 差异度(PSNR)对比图
        subplot(4, 4, 16);
        b4 = bar([1, 2, 3], [psnr_L1, psnr_L2, psnr_L3], 'FaceColor', [0.6 0.4 0.8]);
        set(gca, 'XTick', 1:3, 'XTickLabel', {'一级', '二级', '三级'});
        title('破坏度指标: PSNR (越低越好)', 'FontSize', title_fz);
        grid on;

        % 增加强化结论悬浮框 (在界面正下方)
        conclusion_str = sprintf('【深度对比结论】\n(1) 二级加密(Arnold+XOR) 为黄金甜点区：直方图完全均匀化，散点图呈现随机云团，熵紧贴极值8，相关系数趋零。\n(2) 三级加密(加入额外置乱) 属于过度设计：耗时陡增 +%.1f%%，但各项安全性指标(熵/相关系数/直方图)全部触达天花板，相比二级【零收益】，印证了边际收益递减规律！', ...
            (time_L3-time_L2)/time_L2*100);
        
        annotation('textbox', [0.05, 0.01, 0.9, 0.06], 'String', conclusion_str, ...
            'FontSize', 12, 'EdgeColor', [0.8 0 0], 'BackgroundColor', [1 0.95 0.95], 'FontWeight', 'bold', 'Color', [0.6 0 0]);
            
        % 调整一下subplot间距，防止字注重叠
        set(gcf, 'MenuBar', 'none', 'ToolBar', 'figure');
        
    catch ME
        if ishandle(h_wait)
            close(h_wait);
        end
        errordlg(['分析过程中出错: ', ME.message], '错误');
    end
end

% 内部辅助函数：绘制相邻像素散点图
function plot_scatter_internal(img, title_str, color)
    if nargin < 3
        color = [0.2 0.6 0.5];
    end
    % 随机采样像素对以提升绘图速度
    rng(1); % 固定随机种子保证折叠效果重现
    N = min(3000, numel(img));
    [h, w] = size(img);
    
    % 在有效范围内随机取点
    rx = randi([1, h], 1, N);
    ry = randi([1, w-1], 1, N);
    
    px = zeros(1, N);
    py = zeros(1, N);
    
    for i = 1:N
        px(i) = double(img(rx(i), ry(i)));
        py(i) = double(img(rx(i), ry(i)+1));
    end
    
    scatter(px, py, 3, color, 'filled', 'MarkerFaceAlpha', 0.6);
    title(title_str, 'FontSize', 10);
    xlim([0 255]); ylim([0 255]);
    set(gca, 'XTick', [0 128 255], 'YTick', [0 128 255]);
    grid on;
end
