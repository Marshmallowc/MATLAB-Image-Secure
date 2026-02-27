function analysis_gui()
    % 图像加密算法分析界面
    % 提供详细的可视化数据分析和算法对比
    
    % 获取全局变量
    global original_image encrypted_image_xor encrypted_image_scramble encrypted_image_arnold
    global decrypted_image_xor decrypted_image_scramble decrypted_image_arnold
    
    % 创建分析窗口
    analysis_fig = figure('Name', '加密算法数据分析', 'NumberTitle', 'off', ...
                         'Position', [200, 100, 1600, 900], ...
                         'Resize', 'off', 'MenuBar', 'none', 'ToolBar', 'none');
    
    set(analysis_fig, 'Color', [0.94, 0.94, 0.94]);
    
    % 创建标题
    title_text = uicontrol('Style', 'text', 'String', '图像加密算法性能分析与对比', ...
                          'Position', [600, 850, 400, 35], ...
                          'FontSize', 16, 'FontWeight', 'bold', ...
                          'BackgroundColor', [0.94, 0.94, 0.94], ...
                          'ForegroundColor', [0.2, 0.2, 0.8]);
    
    % 创建选项卡
    tab_group = uitabgroup('Parent', analysis_fig, 'Position', [0.02, 0.02, 0.96, 0.9]);
    
    % 选项卡1: 直方图分析
    histogram_tab = uitab(tab_group, 'Title', '直方图分析', 'BackgroundColor', [0.95, 0.95, 0.95]);
    create_histogram_analysis(histogram_tab);
    
    % 选项卡2: 相关性分析
    correlation_tab = uitab(tab_group, 'Title', '相关性分析', 'BackgroundColor', [0.95, 0.95, 0.95]);
    create_correlation_analysis(correlation_tab);
    
    % 选项卡3: 加密质量评估
    quality_tab = uitab(tab_group, 'Title', '加密质量评估', 'BackgroundColor', [0.95, 0.95, 0.95]);
    create_quality_assessment(quality_tab);
    
    % 选项卡4: 算法性能对比
    comparison_tab = uitab(tab_group, 'Title', '算法性能对比', 'BackgroundColor', [0.95, 0.95, 0.95]);
    create_algorithm_comparison(comparison_tab);
    
    % 选项卡5: 3D可视化
    visualization_tab = uitab(tab_group, 'Title', '3D可视化', 'BackgroundColor', [0.95, 0.95, 0.95]);
    create_3d_visualization(visualization_tab);
    
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
        temp_fig = figure('Visible', 'off', 'Position', analysis_fig.Position, ...
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
    
    function create_histogram_analysis(parent)
        % 创建直方图分析界面
        
        % 原始图像直方图
        subplot_pos1 = [0.05, 0.55, 0.4, 0.35];
        axes1 = axes('Parent', parent, 'Position', subplot_pos1);
        if ~isempty(original_image)
            axes(axes1); % 激活axes1
            imhist(original_image);
            title('原始图像直方图', 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('灰度值');
            ylabel('像素数量');
            grid on;
        end
        
        % XOR加密图像直方图
        subplot_pos2 = [0.55, 0.55, 0.4, 0.35];
        axes2 = axes('Parent', parent, 'Position', subplot_pos2);
        if ~isempty(encrypted_image_xor)
            axes(axes2); % 激活axes2
            imhist(encrypted_image_xor);
            title('XOR加密图像直方图', 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('灰度值');
            ylabel('像素数量');
            grid on;
        end
        
        % 置乱加密图像直方图
        subplot_pos3 = [0.05, 0.1, 0.4, 0.35];
        axes3 = axes('Parent', parent, 'Position', subplot_pos3);
        if ~isempty(encrypted_image_scramble)
            axes(axes3); % 激活axes3
            imhist(encrypted_image_scramble);
            title('置乱加密图像直方图', 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('灰度值');
            ylabel('像素数量');
            grid on;
        else
            axes(axes3); % 激活axes3
            axis off;
            text(0.5, 0.5, '请先进行置乱加密', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 12, 'Color', [0.5, 0.5, 0.5]);
            title('置乱加密图像直方图', 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        % Arnold变换图像直方图
        subplot_pos4 = [0.55, 0.1, 0.4, 0.35];
        axes4 = axes('Parent', parent, 'Position', subplot_pos4);
        if ~isempty(encrypted_image_arnold)
            axes(axes4); % 激活axes4
            imhist(encrypted_image_arnold);
            title('Arnold变换图像直方图', 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('灰度值');
            ylabel('像素数量');
            grid on;
        else
            axes(axes4); % 激活axes4
            axis off;
            text(0.5, 0.5, '请先进行Arnold变换加密', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 12, 'Color', [0.5, 0.5, 0.5]);
            title('Arnold变换图像直方图', 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '直方图分析'));
    end
    
    function create_correlation_analysis(parent)
        % 创建相关性分析界面
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [400, 400, 300, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.95, 0.95, 0.95]);
            return;
        end
        
        % 计算相关性数据
        correlations = [];
        algorithm_names = {};
        
        if ~isempty(encrypted_image_xor)
            corr_xor = calculate_correlation(original_image, encrypted_image_xor);
            correlations = [correlations, abs(corr_xor)];
            algorithm_names{end+1} = 'XOR加密';
        end
        
        if ~isempty(encrypted_image_scramble)
            corr_scramble = calculate_correlation(original_image, encrypted_image_scramble);
            correlations = [correlations, abs(corr_scramble)];
            algorithm_names{end+1} = '置乱加密';
        end
        
        if ~isempty(encrypted_image_arnold)
            corr_arnold = calculate_correlation(original_image, encrypted_image_arnold);
            correlations = [correlations, abs(corr_arnold)];
            algorithm_names{end+1} = 'Arnold变换';
        end
        
        % 绘制相关性柱状图
        if ~isempty(correlations)
            subplot_pos1 = [0.1, 0.6, 0.8, 0.3];
            axes1 = axes('Parent', parent, 'Position', subplot_pos1);
            bar(correlations, 'FaceColor', [0.2, 0.6, 0.8]);
            set(gca, 'XTickLabel', algorithm_names);
            title('原始图像与加密图像的相关性分析', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel('相关系数绝对值');
            grid on;
            
            % 添加数值标签
            for i = 1:length(correlations)
                text(i, correlations(i) + 0.01, sprintf('%.4f', correlations(i)), ...
                     'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
            end
        end
        
        % 创建相关性散点图
        if ~isempty(encrypted_image_xor)
            subplot_pos2 = [0.05, 0.05, 0.25, 0.45];
            axes2 = axes('Parent', parent, 'Position', subplot_pos2);
            
            % 随机采样像素点进行散点图绘制（避免过于密集）
            sample_indices = randperm(numel(original_image), min(5000, numel(original_image)));
            orig_sample = double(original_image(sample_indices));
            xor_sample = double(encrypted_image_xor(sample_indices));
            
            h = scatter(orig_sample, xor_sample, 1, 'filled');
            h.MarkerFaceAlpha = 0.5;
            title('XOR加密散点图', 'FontSize', 11);
            xlabel('原始像素值');
            ylabel('加密像素值');
            grid on;
        end
        
        if ~isempty(encrypted_image_scramble)
            subplot_pos3 = [0.35, 0.05, 0.25, 0.45];
            axes3 = axes('Parent', parent, 'Position', subplot_pos3);
            
            sample_indices = randperm(numel(original_image), min(5000, numel(original_image)));
            orig_sample = double(original_image(sample_indices));
            scramble_sample = double(encrypted_image_scramble(sample_indices));
            
            h = scatter(orig_sample, scramble_sample, 1, 'filled');
            h.MarkerFaceAlpha = 0.5;
            title('置乱加密散点图', 'FontSize', 11);
            xlabel('原始像素值');
            ylabel('加密像素值');
            grid on;
        end
        
        if ~isempty(encrypted_image_arnold)
            subplot_pos4 = [0.65, 0.05, 0.25, 0.45];
            axes4 = axes('Parent', parent, 'Position', subplot_pos4);
            
            sample_indices = randperm(numel(original_image), min(5000, numel(original_image)));
            orig_sample = double(original_image(sample_indices));
            arnold_sample = double(encrypted_image_arnold(sample_indices));
            
            h = scatter(orig_sample, arnold_sample, 1, 'filled');
            h.MarkerFaceAlpha = 0.5;
            title('Arnold变换散点图', 'FontSize', 11);
            xlabel('原始像素值');
            ylabel('加密像素值');
            grid on;
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '相关性分析'));
    end
    
    function create_quality_assessment(parent)
        % 创建加密质量评估界面
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [400, 400, 300, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.95, 0.95, 0.95]);
            return;
        end
        
        % 计算各种质量指标
        quality_data = [];
        metric_names = {};
        algorithm_names = {};
        
        % 计算原始图像熵（所有算法都需要）
        entropy_orig = calculate_entropy(original_image);
        
        if ~isempty(encrypted_image_xor)
            % XOR加密质量指标
            entropy_xor = calculate_entropy(encrypted_image_xor);
            corr_xor = abs(calculate_correlation(original_image, encrypted_image_xor));
            
            quality_data = [quality_data; entropy_orig, entropy_xor, corr_xor];
            algorithm_names{end+1} = 'XOR加密';
            
            if ~isempty(decrypted_image_xor)
                mse_xor = calculate_mse(original_image, decrypted_image_xor);
                psnr_xor = calculate_psnr(original_image, decrypted_image_xor);
                quality_data(end, 4:5) = [mse_xor, psnr_xor];
            end
        end
        
        if ~isempty(encrypted_image_scramble)
            % 置乱加密质量指标
            entropy_scramble = calculate_entropy(encrypted_image_scramble);
            corr_scramble = abs(calculate_correlation(original_image, encrypted_image_scramble));
            
            % 确保新行有5列（与quality_data的列数一致）
            if isempty(quality_data)
                quality_data = [entropy_orig, entropy_scramble, corr_scramble, NaN, NaN];
            else
                % 获取当前列数
                num_cols = size(quality_data, 2);
                new_row = [entropy_orig, entropy_scramble, corr_scramble];
                % 如果当前有5列，添加NaN填充；否则只添加3列
                if num_cols == 5
                    new_row = [new_row, NaN, NaN];
                end
                quality_data = [quality_data; new_row];
            end
            algorithm_names{end+1} = '置乱加密';
            
            if ~isempty(decrypted_image_scramble)
                mse_scramble = calculate_mse(original_image, decrypted_image_scramble);
                psnr_scramble = calculate_psnr(original_image, decrypted_image_scramble);
                quality_data(end, 4:5) = [mse_scramble, psnr_scramble];
            end
        end
        
        if ~isempty(encrypted_image_arnold)
            % Arnold变换质量指标
            entropy_arnold = calculate_entropy(encrypted_image_arnold);
            corr_arnold = abs(calculate_correlation(original_image, encrypted_image_arnold));
            
            % 确保新行有5列（与quality_data的列数一致）
            if isempty(quality_data)
                quality_data = [entropy_orig, entropy_arnold, corr_arnold, NaN, NaN];
            else
                % 获取当前列数
                num_cols = size(quality_data, 2);
                new_row = [entropy_orig, entropy_arnold, corr_arnold];
                % 如果当前有5列，添加NaN填充；否则只添加3列
                if num_cols == 5
                    new_row = [new_row, NaN, NaN];
                end
                quality_data = [quality_data; new_row];
            end
            algorithm_names{end+1} = 'Arnold变换';
            
            if ~isempty(decrypted_image_arnold)
                mse_arnold = calculate_mse(original_image, decrypted_image_arnold);
                psnr_arnold = calculate_psnr(original_image, decrypted_image_arnold);
                quality_data(end, 4:5) = [mse_arnold, psnr_arnold];
            end
        end
        
        metric_names = {'原始熵', '加密熵', '相关性', 'MSE', 'PSNR'};
        
        % 创建质量指标表格
        if ~isempty(quality_data)
            % 创建表格数据
            table_data = cell(size(quality_data, 1), size(quality_data, 2) + 1);
            table_data(:, 1) = algorithm_names';
            for i = 1:size(quality_data, 1)
                for j = 1:size(quality_data, 2)
                    if j <= 3 || (j > 3 && quality_data(i, j) ~= 0)
                        table_data{i, j+1} = sprintf('%.4f', quality_data(i, j));
                    else
                        table_data{i, j+1} = 'N/A';
                    end
                end
            end
            
            column_names = ['算法', metric_names];
            
            % 创建表格
            table_pos = [0.1, 0.7, 0.8, 0.25];
            quality_table = uitable('Parent', parent, 'Data', table_data, ...
                                   'ColumnName', column_names, ...
                                   'Position', table_pos, ...
                                   'FontSize', 11, ...
                                   'ColumnWidth', {120, 80, 80, 80, 80, 80});
            
            % 绘制质量指标雷达图
            if size(quality_data, 1) >= 1
                subplot_pos1 = [0.1, 0.35, 0.35, 0.3];
                axes1 = axes('Parent', parent, 'Position', subplot_pos1);
                
                % 标准化数据用于雷达图
                normalized_data = quality_data(:, 1:3);
                % 对相关性取反（越小越好）
                normalized_data(:, 3) = 1 - normalized_data(:, 3);
                % 标准化到0-1范围
                for j = 1:size(normalized_data, 2)
                    col_data = normalized_data(:, j);
                    if max(col_data) ~= min(col_data)
                        normalized_data(:, j) = (col_data - min(col_data)) / (max(col_data) - min(col_data));
                    end
                end
                
                % 绘制雷达图
                angles = linspace(0, 2*pi, size(normalized_data, 2) + 1);
                colors = {'r', 'g', 'b'};
                
                hold on;
                for i = 1:size(normalized_data, 1)
                    data_point = [normalized_data(i, :), normalized_data(i, 1)];
                    polar_x = data_point .* cos(angles);
                    polar_y = data_point .* sin(angles);
                    plot(polar_x, polar_y, ['-o', colors{mod(i-1, 3)+1}], ...
                         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', algorithm_names{i});
                end
                
                % 绘制网格
                for r = 0.2:0.2:1
                    circle_x = r * cos(linspace(0, 2*pi, 100));
                    circle_y = r * sin(linspace(0, 2*pi, 100));
                    h_grid = plot(circle_x, circle_y, '--', 'Color', [0.7, 0.7, 0.7]); % 使用浅灰色模拟透明度
                    h_grid.HandleVisibility = 'off'; % 不在图例中显示网格线
                end
                
                axis equal;
                xlim([-1.2, 1.2]);
                ylim([-1.2, 1.2]);
                title('加密算法质量雷达图', 'FontSize', 12, 'FontWeight', 'bold');
                legend('Location', 'best');
                grid on;
            end
            
            % 绘制熵值对比图
            subplot_pos2 = [0.55, 0.35, 0.35, 0.3];
            axes2 = axes('Parent', parent, 'Position', subplot_pos2);
            
            entropy_comparison = quality_data(:, 1:2);
            bar_handles = bar(entropy_comparison);
            set(gca, 'XTickLabel', algorithm_names);
            title('信息熵对比', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('信息熵');
            % 使用DisplayName属性设置图例，避免句柄数量不匹配
            % 处理bar返回数组或标量对象的情况
            if numel(bar_handles) >= 2
                % bar返回数组，每个元素对应一列
                set(bar_handles(1), 'DisplayName', '原始图像');
                set(bar_handles(2), 'DisplayName', '加密图像');
            elseif numel(bar_handles) == 1 && isprop(bar_handles, 'Children') && numel(bar_handles.Children) >= 2
                % bar返回标量容器对象，访问子对象
                set(bar_handles.Children(1), 'DisplayName', '原始图像');
                set(bar_handles.Children(2), 'DisplayName', '加密图像');
            end
            legend('Location', 'best');
            grid on;
            
            % 添加数值标签
            for i = 1:size(entropy_comparison, 1)
                for j = 1:size(entropy_comparison, 2)
                    text(i + (j-1.5)*0.3, entropy_comparison(i, j) + 0.1, ...
                         sprintf('%.3f', entropy_comparison(i, j)), ...
                         'HorizontalAlignment', 'center', 'FontSize', 9);
                end
            end
        end
        
        % 添加评估说明
        info_text = sprintf(['质量评估说明:\n\n', ...
                           '• 信息熵: 越接近8越好，表示图像信息分布越均匀\n', ...
                           '• 相关性: 越接近0越好，表示加密效果越强\n', ...
                           '• MSE: 越接近0越好，表示解密质量越高\n', ...
                           '• PSNR: 越大越好，表示解密质量越高']);
        
        uicontrol('Parent', parent, 'Style', 'text', 'String', info_text, ...
                 'Position', [50, 50, 400, 200], 'FontSize', 10, ...
                 'HorizontalAlignment', 'left', 'BackgroundColor', [0.95, 0.95, 0.95], ...
                 'Max', 2, 'Min', 0);
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '加密质量评估'));
    end
    
    function create_algorithm_comparison(parent)
        % 创建算法性能对比界面
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [400, 400, 300, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.95, 0.95, 0.95]);
            return;
        end
        
        % 性能测试
        algorithms = {'XOR', '置乱', 'Arnold'};
        encryption_times = [];
        decryption_times = [];
        security_scores = [];
        
        % 测试XOR加密
        if ~isempty(encrypted_image_xor)
            tic; xor_encrypt(original_image, 123); enc_time_xor = toc;
            tic; xor_decrypt(encrypted_image_xor, 123); dec_time_xor = toc;
            
            encryption_times = [encryption_times, enc_time_xor];
            decryption_times = [decryption_times, dec_time_xor];
            
            % 安全性评分（基于熵和相关性）
            entropy_score = calculate_entropy(encrypted_image_xor) / 8 * 50;
            corr_score = (1 - abs(calculate_correlation(original_image, encrypted_image_xor))) * 50;
            security_scores = [security_scores, entropy_score + corr_score];
        end
        
        % 测试置乱加密
        if ~isempty(encrypted_image_scramble)
            tic; scramble_encrypt(original_image); enc_time_scramble = toc;
            tic; scramble_decrypt(encrypted_image_scramble, randperm(numel(original_image))); dec_time_scramble = toc;
            
            encryption_times = [encryption_times, enc_time_scramble];
            decryption_times = [decryption_times, dec_time_scramble];
            
            entropy_score = calculate_entropy(encrypted_image_scramble) / 8 * 50;
            corr_score = (1 - abs(calculate_correlation(original_image, encrypted_image_scramble))) * 50;
            security_scores = [security_scores, entropy_score + corr_score];
        end
        
        % 测试Arnold变换
        if ~isempty(encrypted_image_arnold)
            tic; arnold_encrypt(original_image, 5); enc_time_arnold = toc;
            tic; arnold_decrypt(encrypted_image_arnold, 5); dec_time_arnold = toc;
            
            encryption_times = [encryption_times, enc_time_arnold];
            decryption_times = [decryption_times, dec_time_arnold];
            
            entropy_score = calculate_entropy(encrypted_image_arnold) / 8 * 50;
            corr_score = (1 - abs(calculate_correlation(original_image, encrypted_image_arnold))) * 50;
            security_scores = [security_scores, entropy_score + corr_score];
        end
        
        % 绘制性能对比图
        if ~isempty(encryption_times)
            % 加密时间对比
            subplot_pos1 = [0.05, 0.6, 0.4, 0.35];
            axes1 = axes('Parent', parent, 'Position', subplot_pos1);
            bar(encryption_times * 1000, 'FaceColor', [0.2, 0.8, 0.3]);
            set(gca, 'XTickLabel', algorithms(1:length(encryption_times)));
            title('加密时间对比', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('时间 (毫秒)');
            grid on;
            
            for i = 1:length(encryption_times)
                text(i, encryption_times(i) * 1000 + max(encryption_times) * 50, ...
                     sprintf('%.2f ms', encryption_times(i) * 1000), ...
                     'HorizontalAlignment', 'center', 'FontSize', 10);
            end
            
            % 解密时间对比
            subplot_pos2 = [0.55, 0.6, 0.4, 0.35];
            axes2 = axes('Parent', parent, 'Position', subplot_pos2);
            bar(decryption_times * 1000, 'FaceColor', [0.8, 0.3, 0.2]);
            set(gca, 'XTickLabel', algorithms(1:length(decryption_times)));
            title('解密时间对比', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('时间 (毫秒)');
            grid on;
            
            for i = 1:length(decryption_times)
                text(i, decryption_times(i) * 1000 + max(decryption_times) * 50, ...
                     sprintf('%.2f ms', decryption_times(i) * 1000), ...
                     'HorizontalAlignment', 'center', 'FontSize', 10);
            end
            
            % 安全性评分对比
            subplot_pos3 = [0.05, 0.15, 0.4, 0.35];
            axes3 = axes('Parent', parent, 'Position', subplot_pos3);
            bar(security_scores, 'FaceColor', [0.3, 0.2, 0.8]);
            set(gca, 'XTickLabel', algorithms(1:length(security_scores)));
            title('安全性评分对比', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('评分 (0-100)');
            grid on;
            
            for i = 1:length(security_scores)
                text(i, security_scores(i) + 2, sprintf('%.1f', security_scores(i)), ...
                     'HorizontalAlignment', 'center', 'FontSize', 10);
            end
            
            % 综合性能雷达图
            subplot_pos4 = [0.55, 0.15, 0.4, 0.35];
            axes4 = axes('Parent', parent, 'Position', subplot_pos4);
            
            % 标准化性能数据
            speed_scores = 100 ./ (encryption_times * 1000); % 速度评分（越快越好）
            speed_scores = speed_scores / max(speed_scores) * 100;
            
            performance_data = [speed_scores; security_scores];
            
            % 绘制雷达图风格的性能图
            categories = {'加密速度', '安全性'};
            angles = linspace(0, 2*pi, length(categories) + 1);
            colors = {'r', 'g', 'b'};
            
            hold on;
            for i = 1:size(performance_data, 2)
                data_point = [performance_data(:, i)', performance_data(1, i)];
                polar_x = data_point .* cos(angles) / 100;
                polar_y = data_point .* sin(angles) / 100;
                plot(polar_x, polar_y, ['-o', colors{mod(i-1, 3)+1}], ...
                     'LineWidth', 2, 'MarkerSize', 6, ...
                     'DisplayName', algorithms{i});
            end
            
            % 绘制网格
            for r = 0.2:0.2:1
                circle_x = r * cos(linspace(0, 2*pi, 100));
                circle_y = r * sin(linspace(0, 2*pi, 100));
                h = plot(circle_x, circle_y, 'k--');
                h.Color = [h.Color(1:3), 0.3]; % 设置透明度
                h.HandleVisibility = 'off'; % 不在图例中显示网格线
            end
            
            axis equal;
            xlim([-1.2, 1.2]);
            ylim([-1.2, 1.2]);
            title('算法综合性能对比', 'FontSize', 12, 'FontWeight', 'bold');
            legend('Location', 'best');
            grid on;
        end
        
        % 添加导出按钮（左上角）
        export_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
                              'String', '导出图片', 'Units', 'normalized', ...
                              'Position', [0.01, 0.95, 0.08, 0.04], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.2, 0.6, 0.9], ...
                              'ForegroundColor', 'white', ...
                              'Callback', @(~,~) export_tab_image(parent, '算法性能对比'));
    end
    
    function create_3d_visualization(parent)
        % 创建3D可视化界面
        
        if isempty(original_image)
            uicontrol('Parent', parent, 'Style', 'text', ...
                     'String', '请先导入图像并进行加密操作', ...
                     'Position', [400, 400, 300, 50], ...
                     'FontSize', 14, 'HorizontalAlignment', 'center', ...
                     'BackgroundColor', [0.95, 0.95, 0.95]);
            return;
        end
        
        % 为了3D可视化，对图像进行降采样
        downsample_factor = max(1, floor(min(size(original_image)) / 50));
        img_small = original_image(1:downsample_factor:end, 1:downsample_factor:end);
        
        % 随机采样像素点（用于散点图）
        sample_size = min(2000, numel(original_image));
        sample_indices = randperm(numel(original_image), sample_size);
        [rows, cols] = size(original_image);
        [Y, X] = ind2sub([rows, cols], sample_indices);
        Z = double(original_image(sample_indices));
        
        % 第一行：原始图像和XOR加密的3D表面图
        % 原始图像3D表面图
        subplot_pos1 = [0.02, 0.68, 0.31, 0.28];
        axes1 = axes('Parent', parent, 'Position', subplot_pos1);
        surf(double(img_small));
        title('原始图像3D表面图', 'FontSize', 11, 'FontWeight', 'bold');
        xlabel('X坐标');
        ylabel('Y坐标');
        zlabel('灰度值');
        colormap(axes1, gray);
        shading interp;
        view(45, 30);
        
        % XOR加密图像3D表面图
        if ~isempty(encrypted_image_xor)
            subplot_pos2 = [0.35, 0.68, 0.31, 0.28];
            axes2 = axes('Parent', parent, 'Position', subplot_pos2);
            enc_img_small = encrypted_image_xor(1:downsample_factor:end, 1:downsample_factor:end);
            surf(double(enc_img_small));
            title('XOR加密3D表面图', 'FontSize', 11, 'FontWeight', 'bold');
            xlabel('X坐标');
            ylabel('Y坐标');
            zlabel('灰度值');
            colormap(axes2, gray);
            shading interp;
            view(45, 30);
        else
            subplot_pos2 = [0.35, 0.68, 0.31, 0.28];
            axes2 = axes('Parent', parent, 'Position', subplot_pos2);
            axis off;
            text(0.5, 0.5, '请先进行XOR加密', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
            title('XOR加密3D表面图', 'FontSize', 11, 'FontWeight', 'bold');
        end
        
        % 置乱加密图像3D表面图
        if ~isempty(encrypted_image_scramble)
            subplot_pos3 = [0.68, 0.68, 0.31, 0.28];
            axes3 = axes('Parent', parent, 'Position', subplot_pos3);
            enc_img_small = encrypted_image_scramble(1:downsample_factor:end, 1:downsample_factor:end);
            surf(double(enc_img_small));
            title('置乱加密3D表面图', 'FontSize', 11, 'FontWeight', 'bold');
            xlabel('X坐标');
            ylabel('Y坐标');
            zlabel('灰度值');
            colormap(axes3, gray);
            shading interp;
            view(45, 30);
        else
            subplot_pos3 = [0.68, 0.68, 0.31, 0.28];
            axes3 = axes('Parent', parent, 'Position', subplot_pos3);
            axis off;
            text(0.5, 0.5, '请先进行置乱加密', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
            title('置乱加密3D表面图', 'FontSize', 11, 'FontWeight', 'bold');
        end
        
        % 第二行：Arnold变换和原始图像散点图
        % Arnold变换图像3D表面图
        if ~isempty(encrypted_image_arnold)
            subplot_pos4 = [0.02, 0.35, 0.31, 0.28];
            axes4 = axes('Parent', parent, 'Position', subplot_pos4);
            enc_img_small = encrypted_image_arnold(1:downsample_factor:end, 1:downsample_factor:end);
            surf(double(enc_img_small));
            title('Arnold变换3D表面图', 'FontSize', 11, 'FontWeight', 'bold');
            xlabel('X坐标');
            ylabel('Y坐标');
            zlabel('灰度值');
            colormap(axes4, gray);
            shading interp;
            view(45, 30);
        else
            subplot_pos4 = [0.02, 0.35, 0.31, 0.28];
            axes4 = axes('Parent', parent, 'Position', subplot_pos4);
            axis off;
            text(0.5, 0.5, '请先进行Arnold变换', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
            title('Arnold变换3D表面图', 'FontSize', 11, 'FontWeight', 'bold');
        end
        
        % 原始图像像素分布3D散点图
        subplot_pos5 = [0.35, 0.35, 0.31, 0.28];
        axes5 = axes('Parent', parent, 'Position', subplot_pos5);
        scatter3(X, Y, Z, 20, Z, 'filled');
        title('原始图像3D散点图', 'FontSize', 11, 'FontWeight', 'bold');
        xlabel('X坐标');
        ylabel('Y坐标');
        zlabel('灰度值');
        colorbar;
        grid on;
        
        % 第三行：加密图像的3D散点图
        % XOR加密图像3D散点图
        if ~isempty(encrypted_image_xor)
            subplot_pos6 = [0.68, 0.35, 0.31, 0.28];
            axes6 = axes('Parent', parent, 'Position', subplot_pos6);
            Z_enc = double(encrypted_image_xor(sample_indices));
            scatter3(X, Y, Z_enc, 20, Z_enc, 'filled');
            title('XOR加密3D散点图', 'FontSize', 11, 'FontWeight', 'bold');
            xlabel('X坐标');
            ylabel('Y坐标');
            zlabel('灰度值');
            colorbar;
            grid on;
        else
            subplot_pos6 = [0.68, 0.35, 0.31, 0.28];
            axes6 = axes('Parent', parent, 'Position', subplot_pos6);
            axis off;
            text(0.5, 0.5, '请先进行XOR加密', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
            title('XOR加密3D散点图', 'FontSize', 11, 'FontWeight', 'bold');
        end
        
        % 置乱加密图像3D散点图
        if ~isempty(encrypted_image_scramble)
            subplot_pos7 = [0.02, 0.02, 0.31, 0.28];
            axes7 = axes('Parent', parent, 'Position', subplot_pos7);
            Z_enc = double(encrypted_image_scramble(sample_indices));
            scatter3(X, Y, Z_enc, 20, Z_enc, 'filled');
            title('置乱加密3D散点图', 'FontSize', 11, 'FontWeight', 'bold');
            xlabel('X坐标');
            ylabel('Y坐标');
            zlabel('灰度值');
            colorbar;
            grid on;
        else
            subplot_pos7 = [0.02, 0.02, 0.31, 0.28];
            axes7 = axes('Parent', parent, 'Position', subplot_pos7);
            axis off;
            text(0.5, 0.5, '请先进行置乱加密', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
            title('置乱加密3D散点图', 'FontSize', 11, 'FontWeight', 'bold');
        end
        
        % Arnold变换图像3D散点图
        if ~isempty(encrypted_image_arnold)
            subplot_pos8 = [0.35, 0.02, 0.31, 0.28];
            axes8 = axes('Parent', parent, 'Position', subplot_pos8);
            Z_enc = double(encrypted_image_arnold(sample_indices));
            scatter3(X, Y, Z_enc, 20, Z_enc, 'filled');
            title('Arnold变换3D散点图', 'FontSize', 11, 'FontWeight', 'bold');
            xlabel('X坐标');
            ylabel('Y坐标');
            zlabel('灰度值');
            colorbar;
            grid on;
        else
            subplot_pos8 = [0.35, 0.02, 0.31, 0.28];
            axes8 = axes('Parent', parent, 'Position', subplot_pos8);
            axis off;
            text(0.5, 0.5, '请先进行Arnold变换', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 11, 'Color', [0.5, 0.5, 0.5]);
            title('Arnold变换3D散点图', 'FontSize', 11, 'FontWeight', 'bold');
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
end
