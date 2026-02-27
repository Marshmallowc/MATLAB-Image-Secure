function enhanced_analysis_gui()
    % 增强的图像加密算法分析界面
    % 提供更丰富和有意义的可视化分析
    
    % 获取全局变量
    global original_image encrypted_image_xor encrypted_image_scramble encrypted_image_arnold
    global decrypted_image_xor decrypted_image_scramble decrypted_image_arnold
    
    % 创建主分析窗口
    main_fig = figure('Name', '增强图像加密算法分析系统', 'NumberTitle', 'off', ...
                     'Position', [50, 50, 1800, 1000], ...
                     'Resize', 'off', 'MenuBar', 'none', 'ToolBar', 'figure');
    
    set(main_fig, 'Color', [0.95, 0.95, 0.95]);
    
    % 创建标题
    title_text = uicontrol('Style', 'text', 'String', '图像加密算法性能分析与对比 - 增强版', ...
                          'Position', [600, 950, 600, 40], ...
                          'FontSize', 18, 'FontWeight', 'bold', ...
                          'BackgroundColor', [0.95, 0.95, 0.95], ...
                          'ForegroundColor', [0.1, 0.1, 0.7]);
    
    % 创建选项卡组
    tab_group = uitabgroup('Parent', main_fig, 'Position', [0.01, 0.02, 0.98, 0.92]);
    
    % 选项卡1: 图像对比与直方图分析
    comparison_tab = uitab(tab_group, 'Title', '图像对比与分析', 'BackgroundColor', [0.96, 0.96, 0.96]);
    create_image_comparison(comparison_tab);
    
    % 选项卡2: 空间域分析
    spatial_tab = uitab(tab_group, 'Title', '空间域分析', 'BackgroundColor', [0.96, 0.96, 0.96]);
    create_spatial_analysis(spatial_tab);
    
    % 选项卡3: 频域分析
    frequency_tab = uitab(tab_group, 'Title', '频域分析', 'BackgroundColor', [0.96, 0.96, 0.96]);
    create_frequency_analysis(frequency_tab);
    
    % 选项卡4: 统计特性分析
    statistics_tab = uitab(tab_group, 'Title', '统计特性分析', 'BackgroundColor', [0.96, 0.96, 0.96]);
    create_statistics_analysis(statistics_tab);
    
    % 选项卡5: 3D可视化
    visualization_tab = uitab(tab_group, 'Title', '3D可视化', 'BackgroundColor', [0.96, 0.96, 0.96]);
    create_3d_visualization(visualization_tab);
    
    % 选项卡6: 算法性能对比
    performance_tab = uitab(tab_group, 'Title', '算法性能评估', 'BackgroundColor', [0.96, 0.96, 0.96]);
    create_performance_comparison(performance_tab);
    
    % 导出函数
    function export_tab_image(tab_parent, tab_name)
        % 导出当前选项卡的图片
        % 创建保存对话框
        default_filename = [tab_name, '_', datestr(now, 'yyyymmdd_HHMMSS')];
        [filename, pathname] = uiputfile(...
            {'*.png', 'PNG图片 (*.png)'; ...
             '*.jpg', 'JPEG图片 (*.jpg)'; ...
             '*.pdf', 'PDF文件 (*.pdf)'; ...
             '*.fig', 'MATLAB Figure (*.fig)'}, ...
            '保存分析结果图片', ...
            default_filename);
        
        if isequal(filename, 0) || isequal(pathname, 0)
            return; % 用户取消
        end
        
        full_path = fullfile(pathname, filename);
        
        % 获取选项卡中的所有axes对象
        all_axes = findobj(tab_parent, 'Type', 'axes');
        
        if isempty(all_axes)
            msgbox('当前选项卡没有可导出的内容', '提示', 'warn');
            return;
        end
        
        % 创建临时figure用于导出
        temp_fig = figure('Visible', 'off', 'Position', main_fig.Position, ...
                         'Color', 'white', 'PaperPositionMode', 'auto');
        
        % 复制所有axes到临时figure
        num_axes = length(all_axes);
        for i = 1:num_axes
            ax = all_axes(i);
            % 获取原始位置（相对于选项卡）
            orig_pos = ax.Position;
            % 复制axes及其所有子对象
            new_ax = copyobj(ax, temp_fig);
            % 保持原始位置（相对于figure）
            new_ax.Position = orig_pos;
            new_ax.Units = 'normalized';
        end
        
        % 保存图片
        [~, ~, ext] = fileparts(filename);
        try
            switch lower(ext)
                case '.png'
                    print(temp_fig, '-dpng', '-r300', full_path);
                case '.jpg'
                    print(temp_fig, '-djpeg', '-r300', full_path);
                case '.pdf'
                    print(temp_fig, '-dpdf', '-painters', full_path);
                case '.fig'
                    savefig(temp_fig, full_path);
            end
            
            close(temp_fig);
            
            % 显示成功消息
            msgbox(sprintf('图片已成功保存到:\n%s', full_path), '导出成功', 'help');
        catch ME
            close(temp_fig);
            msgbox(sprintf('导出失败: %s', ME.message), '错误', 'error');
        end
    end
    
    function create_image_comparison(parent)
        % 创建图像对比和直方图分析
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先在主界面导入图像并进行加密操作', ...
                     'Position', [600, 400, 400, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.96, 0.96, 0.96]);
            return;
        end
        
        % 上半部分：图像显示
        % 原始图像
        axes1 = axes('Parent', parent, 'Position', [0.05, 0.55, 0.2, 0.35]);
        imshow(original_image);
        title('原始图像', 'FontSize', 12, 'FontWeight', 'bold');
        
        % XOR加密图像
        if ~isempty(encrypted_image_xor)
            axes2 = axes('Parent', parent, 'Position', [0.275, 0.55, 0.2, 0.35]);
            imshow(encrypted_image_xor);
            title('XOR加密', 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        % 置乱加密图像
        if ~isempty(encrypted_image_scramble)
            axes3 = axes('Parent', parent, 'Position', [0.5, 0.55, 0.2, 0.35]);
            imshow(encrypted_image_scramble);
            title('置乱加密', 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        % Arnold变换图像
        if ~isempty(encrypted_image_arnold)
            axes4 = axes('Parent', parent, 'Position', [0.725, 0.55, 0.2, 0.35]);
            imshow(encrypted_image_arnold);
            title('Arnold变换', 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        % 下半部分：直方图分析
        % 说明文字
        uicontrol('Parent', parent, 'Style', 'text', ...
                 'String', '直方图分析 (注意：置乱和Arnold变换保持像素值分布不变，这是正常现象)', ...
                 'Position', [50, 480, 800, 25], ...
                 'FontSize', 11, 'FontWeight', 'bold', ...
                 'BackgroundColor', [0.96, 0.96, 0.96], ...
                 'ForegroundColor', [0.8, 0.2, 0.2]);
        
        % 原始图像直方图
        axes5 = axes('Parent', parent, 'Position', [0.05, 0.1, 0.2, 0.35]);
        [counts1, centers1] = imhist(original_image);
        bar(centers1, counts1, 'FaceColor', [0.3, 0.6, 0.9], 'EdgeColor', 'none');
        title('原始图像直方图', 'FontSize', 10);
        xlabel('灰度值'); ylabel('频次');
        grid on; axis tight;
        
        % XOR加密直方图
        if ~isempty(encrypted_image_xor)
            axes6 = axes('Parent', parent, 'Position', [0.275, 0.1, 0.2, 0.35]);
            [counts2, centers2] = imhist(encrypted_image_xor);
            bar(centers2, counts2, 'FaceColor', [0.9, 0.4, 0.2], 'EdgeColor', 'none');
            title('XOR加密直方图', 'FontSize', 10);
            xlabel('灰度值'); ylabel('频次');
            grid on; axis tight;
        end
        
        % 置乱加密直方图
        if ~isempty(encrypted_image_scramble)
            axes7 = axes('Parent', parent, 'Position', [0.5, 0.1, 0.2, 0.35]);
            [counts3, centers3] = imhist(encrypted_image_scramble);
            bar(centers3, counts3, 'FaceColor', [0.2, 0.8, 0.4], 'EdgeColor', 'none');
            title('置乱加密直方图', 'FontSize', 10);
            xlabel('灰度值'); ylabel('频次');
            grid on; axis tight;
        end
        
        % Arnold变换直方图
        if ~isempty(encrypted_image_arnold)
            axes8 = axes('Parent', parent, 'Position', [0.725, 0.1, 0.2, 0.35]);
            [counts4, centers4] = imhist(encrypted_image_arnold);
            bar(centers4, counts4, 'FaceColor', [0.8, 0.2, 0.8], 'EdgeColor', 'none');
            title('Arnold变换直方图', 'FontSize', 10);
            xlabel('灰度值'); ylabel('频次');
            grid on; axis tight;
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '图像对比与分析'));
    end
    
    function create_spatial_analysis(parent)
        % 创建空间域分析
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [600, 400, 400, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.96, 0.96, 0.96]);
            return;
        end
        
        % 像素差异分析
        axes1 = axes('Parent', parent, 'Position', [0.05, 0.6, 0.4, 0.35]);
        
        % 计算像素差异
        algorithms = {};
        pixel_diffs = [];
        
        if ~isempty(encrypted_image_xor)
            diff_xor = abs(double(original_image) - double(encrypted_image_xor));
            algorithms{end+1} = 'XOR';
            pixel_diffs(end+1) = mean(diff_xor(:));
        end
        
        if ~isempty(encrypted_image_scramble)
            diff_scramble = abs(double(original_image) - double(encrypted_image_scramble));
            algorithms{end+1} = '置乱';
            pixel_diffs(end+1) = mean(diff_scramble(:));
        end
        
        if ~isempty(encrypted_image_arnold)
            diff_arnold = abs(double(original_image) - double(encrypted_image_arnold));
            algorithms{end+1} = 'Arnold';
            pixel_diffs(end+1) = mean(diff_arnold(:));
        end
        
        if ~isempty(pixel_diffs)
            bar(pixel_diffs, 'FaceColor', [0.4, 0.7, 0.9]);
            set(gca, 'XTickLabel', algorithms);
            title('平均像素差异 (数值越大加密效果越好)', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('平均差异值');
            grid on;
            
            % 添加数值标签
            for i = 1:length(pixel_diffs)
                text(i, pixel_diffs(i) + max(pixel_diffs)*0.02, ...
                     sprintf('%.2f', pixel_diffs(i)), ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            end
        end
        
        % 局部方差分析
        axes2 = axes('Parent', parent, 'Position', [0.55, 0.6, 0.4, 0.35]);
        
        % 计算局部方差（8x8窗口）
        window_size = 8;
        [rows, cols] = size(original_image);
        
        orig_vars = [];
        for i = 1:window_size:rows-window_size+1
            for j = 1:window_size:cols-window_size+1
                block = original_image(i:i+window_size-1, j:j+window_size-1);
                orig_vars(end+1) = var(double(block(:)));
            end
        end
        
        local_vars = [];
        var_labels = {};
        
        if ~isempty(encrypted_image_xor)
            xor_vars = [];
            for i = 1:window_size:rows-window_size+1
                for j = 1:window_size:cols-window_size+1
                    block = encrypted_image_xor(i:i+window_size-1, j:j+window_size-1);
                    xor_vars(end+1) = var(double(block(:)));
                end
            end
            local_vars(end+1) = mean(xor_vars);
            var_labels{end+1} = 'XOR';
        end
        
        if ~isempty(encrypted_image_scramble)
            scramble_vars = [];
            for i = 1:window_size:rows-window_size+1
                for j = 1:window_size:cols-window_size+1
                    block = encrypted_image_scramble(i:i+window_size-1, j:j+window_size-1);
                    scramble_vars(end+1) = var(double(block(:)));
                end
            end
            local_vars(end+1) = mean(scramble_vars);
            var_labels{end+1} = '置乱';
        end
        
        if ~isempty(encrypted_image_arnold)
            arnold_vars = [];
            for i = 1:window_size:rows-window_size+1
                for j = 1:window_size:cols-window_size+1
                    block = encrypted_image_arnold(i:i+window_size-1, j:j+window_size-1);
                    arnold_vars(end+1) = var(double(block(:)));
                end
            end
            local_vars(end+1) = mean(arnold_vars);
            var_labels{end+1} = 'Arnold';
        end
        
        % 添加原始图像的局部方差作为对比
        local_vars = [mean(orig_vars), local_vars];
        var_labels = ['原始', var_labels];
        
        if ~isempty(local_vars)
            bar(local_vars, 'FaceColor', [0.9, 0.5, 0.3]);
            set(gca, 'XTickLabel', var_labels);
            title('局部方差分析 (8x8窗口)', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('平均局部方差');
            grid on;
            
            % 添加数值标签
            for i = 1:length(local_vars)
                text(i, local_vars(i) + max(local_vars)*0.02, ...
                     sprintf('%.1f', local_vars(i)), ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            end
        end
        
        % 相邻像素相关性分析
        axes3 = axes('Parent', parent, 'Position', [0.05, 0.1, 0.9, 0.35]);
        
        correlation_data = [];
        corr_labels = {};
        
        % 计算水平相关性
        if ~isempty(encrypted_image_xor)
            h_corr_orig = calculate_adjacent_correlation(original_image, 'horizontal');
            h_corr_xor = calculate_adjacent_correlation(encrypted_image_xor, 'horizontal');
            correlation_data = [correlation_data; h_corr_orig, h_corr_xor];
            corr_labels{end+1} = 'XOR水平';
        end
        
        if ~isempty(encrypted_image_scramble)
            h_corr_scramble = calculate_adjacent_correlation(encrypted_image_scramble, 'horizontal');
            correlation_data = [correlation_data; h_corr_orig, h_corr_scramble];
            corr_labels{end+1} = '置乱水平';
        end
        
        if ~isempty(encrypted_image_arnold)
            h_corr_arnold = calculate_adjacent_correlation(encrypted_image_arnold, 'horizontal');
            correlation_data = [correlation_data; h_corr_orig, h_corr_arnold];
            corr_labels{end+1} = 'Arnold水平';
        end
        
        if ~isempty(correlation_data)
            bar_data = [correlation_data(:,1), correlation_data(:,2)];
            bar(bar_data);
            set(gca, 'XTickLabel', corr_labels);
            title('相邻像素相关性对比 (蓝色=原始，橙色=加密)', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('相关系数');
            legend('原始图像', '加密图像', 'Location', 'best');
            grid on;
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '空间域分析'));
    end
    
    function create_frequency_analysis(parent)
        % 创建频域分析
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [600, 400, 400, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.96, 0.96, 0.96]);
            return;
        end
        
        % 计算FFT频谱
        orig_fft = fft2(double(original_image));
        orig_spectrum = log(1 + abs(fftshift(orig_fft)));
        
        % 原始图像频谱
        axes1 = axes('Parent', parent, 'Position', [0.05, 0.55, 0.2, 0.35]);
        imagesc(orig_spectrum); colormap(axes1, 'hot'); axis image;
        title('原始频谱', 'FontSize', 10);
        
        % XOR加密频谱
        if ~isempty(encrypted_image_xor)
            axes2 = axes('Parent', parent, 'Position', [0.275, 0.55, 0.2, 0.35]);
            xor_fft = fft2(double(encrypted_image_xor));
            xor_spectrum = log(1 + abs(fftshift(xor_fft)));
            imagesc(xor_spectrum); colormap(axes2, 'hot'); axis image;
            title('XOR频谱', 'FontSize', 10);
        end
        
        % 置乱加密频谱
        if ~isempty(encrypted_image_scramble)
            axes3 = axes('Parent', parent, 'Position', [0.5, 0.55, 0.2, 0.35]);
            scramble_fft = fft2(double(encrypted_image_scramble));
            scramble_spectrum = log(1 + abs(fftshift(scramble_fft)));
            imagesc(scramble_spectrum); colormap(axes3, 'hot'); axis image;
            title('置乱频谱', 'FontSize', 10);
        end
        
        % Arnold变换频谱
        if ~isempty(encrypted_image_arnold)
            axes4 = axes('Parent', parent, 'Position', [0.725, 0.55, 0.2, 0.35]);
            arnold_fft = fft2(double(encrypted_image_arnold));
            arnold_spectrum = log(1 + abs(fftshift(arnold_fft)));
            imagesc(arnold_spectrum); colormap(axes4, 'hot'); axis image;
            title('Arnold频谱', 'FontSize', 10);
        end
        
        % 频域能量分布分析
        axes5 = axes('Parent', parent, 'Position', [0.1, 0.1, 0.8, 0.35]);
        
        energy_data = [];
        energy_labels = {};
        
        % 计算频域能量分布
        orig_energy = sum(abs(orig_fft(:)).^2);
        
        if ~isempty(encrypted_image_xor)
            xor_energy = sum(abs(xor_fft(:)).^2);
            energy_data(end+1) = xor_energy / orig_energy;
            energy_labels{end+1} = 'XOR';
        end
        
        if ~isempty(encrypted_image_scramble)
            scramble_energy = sum(abs(scramble_fft(:)).^2);
            energy_data(end+1) = scramble_energy / orig_energy;
            energy_labels{end+1} = '置乱';
        end
        
        if ~isempty(encrypted_image_arnold)
            arnold_energy = sum(abs(arnold_fft(:)).^2);
            energy_data(end+1) = arnold_energy / orig_energy;
            energy_labels{end+1} = 'Arnold';
        end
        
        if ~isempty(energy_data)
            bar(energy_data, 'FaceColor', [0.6, 0.3, 0.8]);
            set(gca, 'XTickLabel', energy_labels);
            title('频域能量保持度 (理想值=1.0)', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('能量比率');
            grid on;
            
            % 添加参考线
            hold on;
            plot([0.5, length(energy_data)+0.5], [1, 1], 'r--', 'LineWidth', 2);
            text(length(energy_data)/2, 1.05, '理想值', 'HorizontalAlignment', 'center', ...
                 'FontWeight', 'bold', 'Color', 'red');
            
            % 添加数值标签
            for i = 1:length(energy_data)
                text(i, energy_data(i) + 0.02, sprintf('%.3f', energy_data(i)), ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            end
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '频域分析'));
    end
    
    function create_statistics_analysis(parent)
        % 创建统计特性分析
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [600, 400, 400, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.96, 0.96, 0.96]);
            return;
        end
        
        % 计算统计指标
        [orig_mean, orig_std, orig_entropy] = calculate_stats(original_image);
        
        stats_data = [];
        stats_labels = {};
        
        % 创建统计数据表格
        table_data = {'图像类型', '均值', '标准差', '信息熵', 'PSNR(dB)', 'MSE'};
        table_data = [table_data; {'原始图像', sprintf('%.2f', orig_mean), ...
                      sprintf('%.2f', orig_std), sprintf('%.4f', orig_entropy), '-', '-'}];
        
        if ~isempty(encrypted_image_xor)
            [xor_mean, xor_std, xor_entropy] = calculate_stats(encrypted_image_xor);
            xor_psnr = calculate_psnr(original_image, encrypted_image_xor);
            xor_mse = calculate_mse(original_image, encrypted_image_xor);
            table_data = [table_data; {'XOR加密', sprintf('%.2f', xor_mean), ...
                          sprintf('%.2f', xor_std), sprintf('%.4f', xor_entropy), ...
                          sprintf('%.2f', xor_psnr), sprintf('%.2f', xor_mse)}];
        end
        
        if ~isempty(encrypted_image_scramble)
            [scramble_mean, scramble_std, scramble_entropy] = calculate_stats(encrypted_image_scramble);
            scramble_psnr = calculate_psnr(original_image, encrypted_image_scramble);
            scramble_mse = calculate_mse(original_image, encrypted_image_scramble);
            table_data = [table_data; {'置乱加密', sprintf('%.2f', scramble_mean), ...
                          sprintf('%.2f', scramble_std), sprintf('%.4f', scramble_entropy), ...
                          sprintf('%.2f', scramble_psnr), sprintf('%.2f', scramble_mse)}];
        end
        
        if ~isempty(encrypted_image_arnold)
            [arnold_mean, arnold_std, arnold_entropy] = calculate_stats(encrypted_image_arnold);
            arnold_psnr = calculate_psnr(original_image, encrypted_image_arnold);
            arnold_mse = calculate_mse(original_image, encrypted_image_arnold);
            table_data = [table_data; {'Arnold变换', sprintf('%.2f', arnold_mean), ...
                          sprintf('%.2f', arnold_std), sprintf('%.4f', arnold_entropy), ...
                          sprintf('%.2f', arnold_psnr), sprintf('%.2f', arnold_mse)}];
        end
        
        % 创建表格
        table_pos = [0.05, 0.7, 0.9, 0.25];
        uitable('Parent', parent, 'Data', table_data(2:end,:), ...
                'ColumnName', table_data(1,:), ...
                'Position', table_pos .* [1800, 900, 1800, 900], ...
                'FontSize', 10, 'RowName', []);
        
        % 信息熵对比图
        axes1 = axes('Parent', parent, 'Position', [0.1, 0.4, 0.35, 0.25]);
        
        entropy_values = [orig_entropy];
        entropy_labels = {'原始'};
        
        if ~isempty(encrypted_image_xor)
            entropy_values(end+1) = xor_entropy;
            entropy_labels{end+1} = 'XOR';
        end
        
        if ~isempty(encrypted_image_scramble)
            entropy_values(end+1) = scramble_entropy;
            entropy_labels{end+1} = '置乱';
        end
        
        if ~isempty(encrypted_image_arnold)
            entropy_values(end+1) = arnold_entropy;
            entropy_labels{end+1} = 'Arnold';
        end
        
        bar(entropy_values, 'FaceColor', [0.2, 0.8, 0.6]);
        set(gca, 'XTickLabel', entropy_labels);
        title('信息熵对比 (值越大随机性越好)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('信息熵');
        grid on;
        
        % 添加理想值参考线
        hold on;
        plot([0.5, length(entropy_values)+0.5], [8, 8], 'r--', 'LineWidth', 2);
        text(length(entropy_values)/2, 8.1, '理想值(8.0)', 'HorizontalAlignment', 'center', ...
             'FontWeight', 'bold', 'Color', 'red');
        
        % PSNR对比图
        axes2 = axes('Parent', parent, 'Position', [0.55, 0.4, 0.35, 0.25]);
        
        psnr_values = [];
        psnr_labels = {};
        
        if ~isempty(encrypted_image_xor)
            psnr_values(end+1) = xor_psnr;
            psnr_labels{end+1} = 'XOR';
        end
        
        if ~isempty(encrypted_image_scramble)
            psnr_values(end+1) = scramble_psnr;
            psnr_labels{end+1} = '置乱';
        end
        
        if ~isempty(encrypted_image_arnold)
            psnr_values(end+1) = arnold_psnr;
            psnr_labels{end+1} = 'Arnold';
        end
        
        if ~isempty(psnr_values)
            bar(psnr_values, 'FaceColor', [0.8, 0.4, 0.2]);
            set(gca, 'XTickLabel', psnr_labels);
            title('PSNR对比 (值越小加密效果越好)', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('PSNR (dB)');
            grid on;
            
            % 添加数值标签
            for i = 1:length(psnr_values)
                text(i, psnr_values(i) + max(psnr_values)*0.02, ...
                     sprintf('%.1f', psnr_values(i)), ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            end
        end
        
        % 综合安全性评分
        axes3 = axes('Parent', parent, 'Position', [0.1, 0.05, 0.8, 0.25]);
        
        security_scores = [];
        security_labels = {};
        
        if ~isempty(encrypted_image_xor)
            % 综合评分：信息熵权重40%，PSNR权重30%，相关性权重30%
            corr_score = (1 - abs(calculate_correlation(original_image, encrypted_image_xor))) * 100;
            entropy_score = (xor_entropy / 8.0) * 100;
            psnr_score = max(0, (50 - xor_psnr) / 50 * 100); % PSNR越小越好
            
            xor_score = 0.4 * entropy_score + 0.3 * psnr_score + 0.3 * corr_score;
            security_scores(end+1) = xor_score;
            security_labels{end+1} = 'XOR';
        end
        
        if ~isempty(encrypted_image_scramble)
            corr_score = (1 - abs(calculate_correlation(original_image, encrypted_image_scramble))) * 100;
            entropy_score = (scramble_entropy / 8.0) * 100;
            psnr_score = max(0, (50 - scramble_psnr) / 50 * 100);
            
            scramble_score = 0.4 * entropy_score + 0.3 * psnr_score + 0.3 * corr_score;
            security_scores(end+1) = scramble_score;
            security_labels{end+1} = '置乱';
        end
        
        if ~isempty(encrypted_image_arnold)
            corr_score = (1 - abs(calculate_correlation(original_image, encrypted_image_arnold))) * 100;
            entropy_score = (arnold_entropy / 8.0) * 100;
            psnr_score = max(0, (50 - arnold_psnr) / 50 * 100);
            
            arnold_score = 0.4 * entropy_score + 0.3 * psnr_score + 0.3 * corr_score;
            security_scores(end+1) = arnold_score;
            security_labels{end+1} = 'Arnold';
        end
        
        if ~isempty(security_scores)
            colors = [0.9, 0.3, 0.3; 0.3, 0.9, 0.3; 0.3, 0.3, 0.9];
            bar_handle = bar(security_scores);
            if length(security_scores) <= size(colors, 1)
                bar_handle.FaceColor = 'flat';
                bar_handle.CData = colors(1:length(security_scores), :);
            end
            
            set(gca, 'XTickLabel', security_labels);
            title('综合安全性评分 (满分100分)', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('安全性评分');
            ylim([0, 100]);
            grid on;
            
            % 添加评分等级线
            hold on;
            plot([0.5, length(security_scores)+0.5], [80, 80], 'g--', 'LineWidth', 2);
            plot([0.5, length(security_scores)+0.5], [60, 60], 'y--', 'LineWidth', 2);
            plot([0.5, length(security_scores)+0.5], [40, 40], 'r--', 'LineWidth', 2);
            
            % 添加数值标签
            for i = 1:length(security_scores)
                text(i, security_scores(i) + 2, sprintf('%.1f', security_scores(i)), ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            end
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '统计特性分析'));
    end
    
    function create_3d_visualization(parent)
        % 创建3D可视化
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [600, 400, 400, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.96, 0.96, 0.96]);
            return;
        end
        
        % 3D灰度曲面图
        [rows, cols] = size(original_image);
        
        % 为了性能，对大图像进行降采样
        if rows > 100 || cols > 100
            scale_factor = min(100/rows, 100/cols);
            small_orig = imresize(original_image, scale_factor);
        else
            small_orig = original_image;
        end
        
        [small_rows, small_cols] = size(small_orig);
        [X, Y] = meshgrid(1:small_cols, 1:small_rows);
        
        % 原始图像3D视图
        axes1 = axes('Parent', parent, 'Position', [0.05, 0.55, 0.4, 0.4]);
        surf(X, Y, double(small_orig), 'EdgeColor', 'none');
        colormap(axes1, 'gray');
        title('原始图像 3D视图');
        xlabel('X'); ylabel('Y'); zlabel('灰度值');
        view(45, 30);
        
        % 加密图像3D视图（选择第一个可用的加密图像）
        encrypted_for_3d = [];
        encrypted_title = '';
        
        if ~isempty(encrypted_image_xor)
            encrypted_for_3d = encrypted_image_xor;
            encrypted_title = 'XOR加密 3D视图';
        elseif ~isempty(encrypted_image_scramble)
            encrypted_for_3d = encrypted_image_scramble;
            encrypted_title = '置乱加密 3D视图';
        elseif ~isempty(encrypted_image_arnold)
            encrypted_for_3d = encrypted_image_arnold;
            encrypted_title = 'Arnold变换 3D视图';
        end
        
        if ~isempty(encrypted_for_3d)
            if rows > 100 || cols > 100
                small_enc = imresize(encrypted_for_3d, scale_factor);
            else
                small_enc = encrypted_for_3d;
            end
            
            axes2 = axes('Parent', parent, 'Position', [0.55, 0.55, 0.4, 0.4]);
            surf(X, Y, double(small_enc), 'EdgeColor', 'none');
            colormap(axes2, 'hot');
            title(encrypted_title);
            xlabel('X'); ylabel('Y'); zlabel('灰度值');
            view(45, 30);
        end
        
        % 差异3D视图
        if ~isempty(encrypted_for_3d)
            diff_img = abs(double(small_orig) - double(small_enc));
            
            axes3 = axes('Parent', parent, 'Position', [0.25, 0.05, 0.4, 0.4]);
            surf(X, Y, diff_img, 'EdgeColor', 'none');
            colormap(axes3, 'jet');
            title('差异图 3D视图');
            xlabel('X'); ylabel('Y'); zlabel('差异值');
            view(45, 30);
            colorbar;
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '3D可视化'));
    end
    
    function create_performance_comparison(parent)
        % 创建性能对比分析
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [600, 400, 400, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.96, 0.96, 0.96]);
            return;
        end
        
        % 雷达图
        axes1 = axes('Parent', parent, 'Position', [0.1, 0.4, 0.8, 0.55]);
        
        % 定义评估维度
        dimensions = {'信息熵', '低相关性', '高PSNR差异', '频域变化', '空间复杂度'};
        num_dims = length(dimensions);
        
        % 计算各算法在各维度的得分
        algorithms = {};
        scores = [];
        
        if ~isempty(encrypted_image_xor)
            algorithms{end+1} = 'XOR加密';
            xor_scores = calculate_algorithm_scores(original_image, encrypted_image_xor);
            scores = [scores; xor_scores];
        end
        
        if ~isempty(encrypted_image_scramble)
            algorithms{end+1} = '置乱加密';
            scramble_scores = calculate_algorithm_scores(original_image, encrypted_image_scramble);
            scores = [scores; scramble_scores];
        end
        
        if ~isempty(encrypted_image_arnold)
            algorithms{end+1} = 'Arnold变换';
            arnold_scores = calculate_algorithm_scores(original_image, encrypted_image_arnold);
            scores = [scores; arnold_scores];
        end
        
        % 绘制雷达图（使用传统plot方法）
        if ~isempty(scores)
            theta = linspace(0, 2*pi, num_dims+1);
            colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
            
            hold on;
            for i = 1:size(scores, 1)
                score_circle = [scores(i, :), scores(i, 1)]; % 闭合图形
                
                % 转换为笛卡尔坐标
                x = score_circle .* cos(theta);
                y = score_circle .* sin(theta);
                
                plot(x, y, 'LineWidth', 2, 'Color', colors(i, :), ...
                     'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', colors(i, :));
            end
            
            % 绘制网格线
            for r = 20:20:100
                grid_x = r .* cos(theta);
                grid_y = r .* sin(theta);
                plot(grid_x, grid_y, '--', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
            end
            
            % 绘制径向线
            for i = 1:num_dims
                line([0, 100*cos(theta(i))], [0, 100*sin(theta(i))], ...
                     'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.5);
                
                % 添加标签
                text(110*cos(theta(i)), 110*sin(theta(i)), dimensions{i}, ...
                     'HorizontalAlignment', 'center', 'FontSize', 10);
            end
            
            axis equal;
            xlim([-120, 120]);
            ylim([-120, 120]);
            title('算法性能雷达图对比', 'FontSize', 14, 'FontWeight', 'bold');
            legend(algorithms, 'Location', 'bestoutside');
            grid off; % 关闭默认网格，使用自定义网格
        end
        
        % 综合性能排名表
        if ~isempty(scores)
            % 计算综合得分
            total_scores = mean(scores, 2);
            [sorted_scores, sort_idx] = sort(total_scores, 'descend');
            
            ranking_data = {};
            for i = 1:length(sort_idx)
                idx = sort_idx(i);
                ranking_data{i, 1} = i; % 排名
                ranking_data{i, 2} = algorithms{idx}; % 算法名称
                ranking_data{i, 3} = sprintf('%.1f', sorted_scores(i)); % 综合得分
                
                % 各维度得分
                for j = 1:num_dims
                    ranking_data{i, 3+j} = sprintf('%.1f', scores(idx, j));
                end
            end
            
            % 创建表格
            column_names = ['排名', '算法', '综合得分', dimensions];
            table_pos = [0.1, 0.05, 0.8, 0.25];
            uitable('Parent', parent, 'Data', ranking_data, ...
                    'ColumnName', column_names, ...
                    'Position', table_pos .* [1800, 900, 1800, 900], ...
                    'FontSize', 10, 'RowName', []);
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '算法性能评估'));
    end
    
    % 辅助函数
    function [mean_val, std_val, entropy_val] = calculate_stats(image)
        image = double(image);
        mean_val = mean(image(:));
        std_val = std(image(:));
        entropy_val = calculate_entropy(uint8(image));
    end
    
    function corr_val = calculate_adjacent_correlation(image, direction)
        % 计算相邻像素相关性
        image = double(image);
        [rows, cols] = size(image);
        
        if strcmp(direction, 'horizontal')
            x = image(:, 1:end-1);
            y = image(:, 2:end);
        else % vertical
            x = image(1:end-1, :);
            y = image(2:end, :);
        end
        
        x = x(:);
        y = y(:);
        corr_matrix = corrcoef(x, y);
        corr_val = corr_matrix(1, 2);
    end
    
    function scores = calculate_algorithm_scores(orig_img, enc_img)
        % 计算算法在各维度的得分（0-100分）
        
        % 1. 信息熵得分
        orig_entropy = calculate_entropy(orig_img);
        enc_entropy = calculate_entropy(enc_img);
        entropy_score = (enc_entropy / 8.0) * 100;
        
        % 2. 低相关性得分
        correlation = abs(calculate_correlation(orig_img, enc_img));
        correlation_score = (1 - correlation) * 100;
        
        % 3. PSNR差异得分
        psnr_val = calculate_psnr(orig_img, enc_img);
        psnr_score = max(0, min(100, (50 - psnr_val) / 50 * 100));
        
        % 4. 频域变化得分
        orig_fft = fft2(double(orig_img));
        enc_fft = fft2(double(enc_img));
        freq_diff = mean(abs(abs(orig_fft(:)) - abs(enc_fft(:))));
        freq_score = min(100, freq_diff / 10); % 归一化到0-100
        
        % 5. 空间复杂度得分（局部方差变化）
        orig_var = var(double(orig_img(:)));
        enc_var = var(double(enc_img(:)));
        spatial_score = min(100, abs(enc_var - orig_var) / orig_var * 100);
        
        scores = [entropy_score, correlation_score, psnr_score, freq_score, spatial_score];
    end
end
