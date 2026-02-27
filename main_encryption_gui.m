function main_encryption_gui()
    % 基于MATLAB的图像加解密系统主界面
    % 功能：图像加密、解密、可视化分析
    
    % 创建主窗口
    fig = figure('Name', '图像加解密系统', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1400, 850], ...
                 'Resize', 'off', 'MenuBar', 'none', 'ToolBar', 'none');
    
    % 全局变量
    global original_image encrypted_image_xor encrypted_image_scramble encrypted_image_arnold
    global decrypted_image_xor decrypted_image_scramble decrypted_image_arnold
    global encryption_key scramble_sequence arnold_iterations current_encryption_algorithm
    
    % 初始化变量
    original_image = [];
    encrypted_image_xor = [];
    encrypted_image_scramble = [];
    encrypted_image_arnold = [];
    decrypted_image_xor = [];
    decrypted_image_scramble = [];
    decrypted_image_arnold = [];
    encryption_key = randi([1, 255], 1, 1); % 随机密钥
    scramble_sequence = [];
    arnold_iterations = 5;
    current_encryption_algorithm = ''; % 记录当前显示的加密算法
    
    % 设置背景色
    set(fig, 'Color', [0.95, 0.95, 0.95]);
    
    % 创建标题 - 调整位置避免被遮挡
    title_text = uicontrol('Style', 'text', 'String', '基于MATLAB的图像加解密系统', ...
                          'Position', [450, 800, 500, 40], ...
                          'FontSize', 18, 'FontWeight', 'bold', ...
                          'BackgroundColor', [0.95, 0.95, 0.95], ...
                          'ForegroundColor', [0.2, 0.2, 0.8]);
    
    % 左侧控制面板 - 调整位置给标题让出空间，添加滚动条
    control_panel = uipanel('Title', '控制面板', 'FontSize', 12, 'FontWeight', 'bold', ...
                           'Position', [0.02, 0.02, 0.25, 0.85], ...
                           'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % 创建滚动面板用于控制面板内容（初始使用归一化单位）
    control_scroll_panel = uipanel('Parent', control_panel, ...
                                  'Position', [0.02, 0.02, 0.96, 0.96], ...
                                  'BackgroundColor', [0.9, 0.9, 0.9], ...
                                  'BorderType', 'none');
    
    % 图像导入按钮
    import_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                          'String', '导入图像', 'Position', [20, 620, 120, 40], ...
                          'FontSize', 12, 'FontWeight', 'bold', ...
                          'BackgroundColor', [0.3, 0.7, 0.3], ...
                          'ForegroundColor', 'white', ...
                          'Callback', @import_image);
    
    % 加密算法选择
    algorithm_text = uicontrol('Parent', control_scroll_panel, 'Style', 'text', ...
                              'String', '选择加密算法:', 'Position', [20, 570, 120, 25], ...
                              'FontSize', 11, 'FontWeight', 'bold', ...
                              'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % 算法选择按钮组
    xor_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                       'String', 'XOR加密', 'Position', [20, 530, 120, 35], ...
                       'FontSize', 10, 'BackgroundColor', [0.2, 0.6, 0.8], ...
                       'ForegroundColor', 'white', ...
                       'Callback', @(~,~) encrypt_image('xor'));
    
    scramble_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                            'String', '置乱加密', 'Position', [20, 490, 120, 35], ...
                            'FontSize', 10, 'BackgroundColor', [0.8, 0.4, 0.2], ...
                            'ForegroundColor', 'white', ...
                            'Callback', @(~,~) encrypt_image('scramble'));
    
    arnold_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                          'String', 'Arnold变换', 'Position', [20, 450, 120, 35], ...
                          'FontSize', 10, 'BackgroundColor', [0.6, 0.2, 0.8], ...
                          'ForegroundColor', 'white', ...
                          'Callback', @(~,~) encrypt_image('arnold'));
    
    % 解密按钮组
    decrypt_text = uicontrol('Parent', control_scroll_panel, 'Style', 'text', ...
                            'String', '解密操作:', 'Position', [20, 410, 120, 25], ...
                            'FontSize', 11, 'FontWeight', 'bold', ...
                            'BackgroundColor', [0.9, 0.9, 0.9]);
    
    decrypt_xor_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                               'String', '解密XOR', 'Position', [20, 370, 120, 35], ...
                               'FontSize', 10, 'BackgroundColor', [0.2, 0.6, 0.8], ...
                               'ForegroundColor', 'white', ...
                               'Callback', @(~,~) decrypt_image('xor'));
    
    decrypt_scramble_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                                    'String', '解密置乱', 'Position', [20, 330, 120, 35], ...
                                    'FontSize', 10, 'BackgroundColor', [0.8, 0.4, 0.2], ...
                                    'ForegroundColor', 'white', ...
                                    'Callback', @(~,~) decrypt_image('scramble'));
    
    decrypt_arnold_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                                  'String', '解密Arnold', 'Position', [20, 290, 120, 35], ...
                                  'FontSize', 10, 'BackgroundColor', [0.6, 0.2, 0.8], ...
                                  'ForegroundColor', 'white', ...
                                  'Callback', @(~,~) decrypt_image('arnold'));
    
    % 基础分析按钮  
    analysis_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                            'String', '基础分析', 'Position', [20, 255, 120, 30], ...
                            'FontSize', 10, 'FontWeight', 'bold', ...
                            'BackgroundColor', [0.8, 0.2, 0.2], ...
                            'ForegroundColor', 'white', ...
                            'Callback', @show_analysis);
    
    % 增强分析按钮
    enhanced_analysis_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                                    'String', '增强分析', 'Position', [20, 220, 120, 30], ...
                                    'FontSize', 10, 'FontWeight', 'bold', ...
                                    'BackgroundColor', [0.2, 0.7, 0.9], ...
                                    'ForegroundColor', 'white', ...
                                    'Callback', @(~,~) enhanced_analysis_gui());
    
    % 保存结果按钮
    save_btn = uicontrol('Parent', control_scroll_panel, 'Style', 'pushbutton', ...
                        'String', '保存结果', 'Position', [20, 140, 120, 40], ...
                        'FontSize', 12, 'FontWeight', 'bold', ...
                        'BackgroundColor', [0.5, 0.5, 0.5], ...
                        'ForegroundColor', 'white', ...
                        'Callback', @save_results);
    
    % 参数设置面板（使用相对位置，位于底部）
    param_panel = uipanel('Parent', control_scroll_panel, 'Title', '参数设置', ...
                         'Position', [0.05, 0.02, 0.9, 0.15], ...
                         'FontSize', 10, 'FontWeight', 'bold');
    
    % 设置滚动功能：在所有控件创建后，计算内容高度并设置滚动
    drawnow; % 确保所有控件都已绘制
    panel_pos = getpixelposition(control_panel);
    panel_width = panel_pos(3);
    panel_height = panel_pos(4);
    visible_height = panel_height - 35; % 减去标题栏高度
    
    % 获取滚动面板内所有子控件，找到最高和最低的位置
    % 注意：按钮使用像素位置，Y坐标从上到下（0在顶部）
    % 导入按钮Y=620，参数面板在底部（相对位置0.02）
    % 为了确保所有内容可见，计算最大Y值
    children = get(control_scroll_panel, 'Children');
    max_y = 0;
    min_y = inf;
    
    for i = 1:length(children)
        try
            % 获取相对于滚动面板的位置
            child_pos = getpixelposition(children(i), true);
            scroll_panel_abs_pos = getpixelposition(control_scroll_panel, true);
            
            % 计算相对于滚动面板的位置
            child_relative_y = child_pos(2) - scroll_panel_abs_pos(2) + child_pos(4);
            child_relative_bottom = child_pos(2) - scroll_panel_abs_pos(2);
            
            max_y = max(max_y, child_relative_y);
            min_y = min(min_y, child_relative_bottom);
        catch
            % 如果无法获取位置，使用已知的按钮位置
            % 导入按钮Y=620，高度40，所以顶部在620
            % 参数面板在底部，假设在Y=50左右
            max_y = max(max_y, 660); % 导入按钮底部
            min_y = min(min_y, 0);   % 参数面板顶部（相对位置0.02转换为像素约50）
        end
    end
    
    % 计算内容总高度（加上一些边距）
    % 从已知按钮位置：导入按钮Y=620，参数面板在底部
    % 为了安全，设置总高度为700像素
    if isfinite(min_y) && isfinite(max_y) && max_y > min_y
        content_total_height = max_y - min_y + 40; % 加上上下边距
    else
        % 使用已知的最大Y值（导入按钮底部660）+ 边距
        content_total_height = 700; % 默认值，确保包含所有内容
    end
    
    % 设置滚动面板的高度（使用像素单位）
    scroll_panel_pos = getpixelposition(control_scroll_panel, true);
    set(control_scroll_panel, 'Units', 'pixels');
    current_scroll_pos = get(control_scroll_panel, 'Position');
    current_scroll_pos(4) = content_total_height; % 设置高度
    set(control_scroll_panel, 'Position', current_scroll_pos);
    
    % 计算滚动范围
    scroll_range = max(0, content_total_height - visible_height);
    
    % 添加滚动条到控制面板（如果内容超出可见区域）
    if scroll_range > 0
        control_slider = uicontrol('Parent', control_panel, 'Style', 'slider', ...
                                  'Units', 'pixels', ...
                                  'Position', [panel_width-20, 5, 15, panel_height-10], ...
                                  'Min', 0, 'Max', scroll_range, 'Value', scroll_range, ...
                                  'Callback', @scroll_control_panel);
    else
        control_slider = [];
    end
    
    % Arnold迭代次数设置
    arnold_text = uicontrol('Parent', param_panel, 'Style', 'text', ...
                           'String', 'Arnold迭代次数:', 'Position', [5, 45, 90, 20], ...
                           'FontSize', 9, 'BackgroundColor', [0.9, 0.9, 0.9]);
    
    arnold_edit = uicontrol('Parent', param_panel, 'Style', 'edit', ...
                           'String', '5', 'Position', [100, 45, 40, 20], ...
                           'FontSize', 9, 'Callback', @update_arnold_iterations);
    
    % 密钥显示
    key_text = uicontrol('Parent', param_panel, 'Style', 'text', ...
                        'String', ['当前密钥: ', num2str(encryption_key)], ...
                        'Position', [5, 20, 135, 20], 'FontSize', 9, ...
                        'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % 图像显示区域 - 调整位置给标题让出空间
    % 原始图像
    original_panel = uipanel('Title', '原始图像', 'FontSize', 12, 'FontWeight', 'bold', ...
                            'Position', [0.3, 0.47, 0.32, 0.4], ...
                            'BackgroundColor', [0.95, 0.95, 0.95]);
    original_axes = axes('Parent', original_panel, 'Position', [0.1, 0.1, 0.8, 0.8]);
    axis(original_axes, 'off');
    
    % 加密图像
    encrypted_panel = uipanel('Title', '加密图像', 'FontSize', 12, 'FontWeight', 'bold', ...
                             'Position', [0.65, 0.47, 0.32, 0.4], ...
                             'BackgroundColor', [0.95, 0.95, 0.95]);
    encrypted_axes = axes('Parent', encrypted_panel, 'Position', [0.1, 0.1, 0.8, 0.8]);
    axis(encrypted_axes, 'off');
    
    % 解密图像
    decrypted_panel = uipanel('Title', '解密图像', 'FontSize', 12, 'FontWeight', 'bold', ...
                             'Position', [0.3, 0.02, 0.32, 0.4], ...
                             'BackgroundColor', [0.95, 0.95, 0.95]);
    decrypted_axes = axes('Parent', decrypted_panel, 'Position', [0.1, 0.1, 0.8, 0.8]);
    axis(decrypted_axes, 'off');
    
    % 状态信息面板
    status_panel = uipanel('Title', '状态信息', 'FontSize', 12, 'FontWeight', 'bold', ...
                          'Position', [0.65, 0.02, 0.32, 0.4], ...
                          'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % 使用可滚动的文本框显示状态信息
    status_text = uicontrol('Parent', status_panel, 'Style', 'listbox', ...
                           'String', {'欢迎使用图像加解密系统！请先导入图像。'}, ...
                           'Position', [10, 10, 430, 280], ...
                           'FontSize', 11, 'HorizontalAlignment', 'left', ...
                           'BackgroundColor', 'white', ...
                           'Max', 2, 'Min', 0);
    
    % 回调函数
    function import_image(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif', ...
            '图像文件 (*.jpg, *.jpeg, *.png, *.bmp, *.tif)'}, '选择图像文件');
        
        if filename ~= 0
            try
                original_image = imread(fullfile(pathname, filename));
                
                % 转换为灰度图像（如果是彩色的）
                if size(original_image, 3) == 3
                    original_image = rgb2gray(original_image);
                end
                
                % 显示原始图像
                axes(original_axes);
                imshow(original_image);
                title('原始图像', 'FontSize', 10);
                
                % 更新状态
                update_status(['成功导入图像: ', filename, char(10), ...
                              '图像尺寸: ', num2str(size(original_image, 1)), ...
                              ' x ', num2str(size(original_image, 2))]);
                
                % 清空之前的加密解密结果
                axes(encrypted_axes); cla; axis off;
                axes(decrypted_axes); cla; axis off;
                
                % 清空所有加密图像变量（重要：防止使用旧数据）
                encrypted_image_xor = [];
                encrypted_image_scramble = [];
                encrypted_image_arnold = [];
                decrypted_image_xor = [];
                decrypted_image_scramble = [];
                decrypted_image_arnold = [];
                scramble_sequence = [];
                current_encryption_algorithm = ''; % 重置当前加密算法标记
                
            catch ME
                update_status(['图像导入失败: ', ME.message]);
            end
        end
    end

    function encrypt_image(algorithm)
        if isempty(original_image)
            update_status('请先导入图像！');
            return;
        end
        
        try
            switch algorithm
                case 'xor'
                    encrypted_image_xor = xor_encrypt(original_image, encryption_key);
                    current_encrypted = encrypted_image_xor;
                    algorithm_name = 'XOR加密';
                    current_encryption_algorithm = 'xor'; % 记录当前加密算法
                    
                case 'scramble'
                    [encrypted_image_scramble, scramble_sequence] = scramble_encrypt(original_image);
                    current_encrypted = encrypted_image_scramble;
                    algorithm_name = '置乱加密';
                    current_encryption_algorithm = 'scramble'; % 记录当前加密算法
                    
                case 'arnold'
                    encrypted_image_arnold = arnold_encrypt(original_image, arnold_iterations);
                    current_encrypted = encrypted_image_arnold;
                    algorithm_name = 'Arnold变换';
                    current_encryption_algorithm = 'arnold'; % 记录当前加密算法
            end
            
            % 显示加密图像
            axes(encrypted_axes);
            imshow(current_encrypted);
            title([algorithm_name, ' - 加密结果'], 'FontSize', 10);
            
            % 更新状态
            update_status([algorithm_name, '加密完成！', char(10), ...
                          '加密时间: ', datestr(now, 'HH:MM:SS')]);
            
        catch ME
            update_status(['加密失败: ', ME.message]);
        end
    end

    function decrypt_image(algorithm)
        try
            % 验证：确保当前显示的加密图像与要解密的算法匹配
            if ~isempty(current_encryption_algorithm) && ~strcmp(current_encryption_algorithm, algorithm)
                algorithm_names = struct('xor', 'XOR', 'scramble', '置乱', 'arnold', 'Arnold');
                current_name = algorithm_names.(current_encryption_algorithm);
                target_name = algorithm_names.(algorithm);
                update_status(['错误：当前显示的加密图像是', current_name, '加密的结果，不能使用', target_name, '解密！', char(10), ...
                              '请先使用', target_name, '算法进行加密，然后再解密。']);
                return;
            end
            
            switch algorithm
                case 'xor'
                    if isempty(encrypted_image_xor)
                        update_status('请先进行XOR加密！');
                        return;
                    end
                    decrypted_image_xor = xor_decrypt(encrypted_image_xor, encryption_key);
                    current_decrypted = decrypted_image_xor;
                    algorithm_name = 'XOR解密';
                    
                case 'scramble'
                    if isempty(encrypted_image_scramble)
                        update_status('请先进行置乱加密！');
                        return;
                    end
                    decrypted_image_scramble = scramble_decrypt(encrypted_image_scramble, scramble_sequence);
                    current_decrypted = decrypted_image_scramble;
                    algorithm_name = '置乱解密';
                    
                case 'arnold'
                    if isempty(encrypted_image_arnold)
                        update_status('请先进行Arnold变换加密！');
                        return;
                    end
                    decrypted_image_arnold = arnold_decrypt(encrypted_image_arnold, arnold_iterations);
                    current_decrypted = decrypted_image_arnold;
                    algorithm_name = 'Arnold逆变换';
            end
            
            % 显示解密图像
            axes(decrypted_axes);
            imshow(current_decrypted);
            title([algorithm_name, ' - 解密结果'], 'FontSize', 10);
            
            % 计算解密质量
            if ~isempty(original_image)
                mse_val = calculate_mse(original_image, current_decrypted);
                psnr_val = calculate_psnr(original_image, current_decrypted);
                update_status([algorithm_name, '完成！', char(10), ...
                              'MSE: ', num2str(mse_val, '%.4f'), char(10), ...
                              'PSNR: ', num2str(psnr_val, '%.2f'), ' dB']);
            else
                update_status([algorithm_name, '完成！']);
            end
            
        catch ME
            update_status(['解密失败: ', ME.message]);
        end
    end

    function show_analysis(~, ~)
        if isempty(original_image)
            update_status('请先导入图像进行加密解密操作！');
            return;
        end
        
        % 创建分析窗口
        analysis_gui();
    end

    function save_results(~, ~)
        if isempty(original_image)
            update_status('没有可保存的结果！');
            return;
        end
        
        % 创建保存目录
        save_dir = 'encryption_results';
        if ~exist(save_dir, 'dir')
            mkdir(save_dir);
        end
        
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        
        try
            % 保存原始图像
            imwrite(original_image, fullfile(save_dir, ['original_', timestamp, '.png']));
            
            % 保存加密图像
            if ~isempty(encrypted_image_xor)
                imwrite(encrypted_image_xor, fullfile(save_dir, ['encrypted_xor_', timestamp, '.png']));
            end
            if ~isempty(encrypted_image_scramble)
                imwrite(encrypted_image_scramble, fullfile(save_dir, ['encrypted_scramble_', timestamp, '.png']));
            end
            if ~isempty(encrypted_image_arnold)
                imwrite(encrypted_image_arnold, fullfile(save_dir, ['encrypted_arnold_', timestamp, '.png']));
            end
            
            % 保存解密图像
            if ~isempty(decrypted_image_xor)
                imwrite(decrypted_image_xor, fullfile(save_dir, ['decrypted_xor_', timestamp, '.png']));
            end
            if ~isempty(decrypted_image_scramble)
                imwrite(decrypted_image_scramble, fullfile(save_dir, ['decrypted_scramble_', timestamp, '.png']));
            end
            if ~isempty(decrypted_image_arnold)
                imwrite(decrypted_image_arnold, fullfile(save_dir, ['decrypted_arnold_', timestamp, '.png']));
            end
            
            update_status(['结果已保存到: ', save_dir, char(10), ...
                          '时间戳: ', timestamp]);
            
        catch ME
            update_status(['保存失败: ', ME.message]);
        end
    end

    function update_arnold_iterations(src, ~)
        try
            new_iterations = str2double(get(src, 'String'));
            if isnan(new_iterations) || new_iterations <= 0
                set(src, 'String', num2str(arnold_iterations));
                update_status('Arnold迭代次数必须为正整数！');
            else
                arnold_iterations = round(new_iterations);
                set(src, 'String', num2str(arnold_iterations));
                update_status(['Arnold迭代次数已更新为: ', num2str(arnold_iterations)]);
            end
        catch
            set(src, 'String', num2str(arnold_iterations));
            update_status('输入无效，已恢复原值');
        end
    end

    function update_status(message)
        current_time = datestr(now, 'HH:MM:SS');
        new_message = ['[', current_time, '] ', message];
        
        current_text = get(status_text, 'String');
        if ischar(current_text)
            current_text = {current_text};
        end
        
        % 保持最近的10条消息
        if length(current_text) >= 10
            current_text = current_text(2:end);
        end
        
        current_text{end+1} = new_message;
        set(status_text, 'String', current_text);
        
        % 自动滚动到底部
        drawnow;
        
        % 为listbox设置自动滚动到最新消息
        if length(current_text) > 1
            set(status_text, 'Value', length(current_text));
        end
    end
    
    function scroll_control_panel(src, ~)
        % 控制面板滚动回调函数
        if isempty(control_slider)
            return;
        end
        
        slider_value = get(src, 'Value');
        slider_max = get(src, 'Max');
        
        % 计算滚动位置
        % slider_value从0到Max，对应内容从底部到顶部
        % 当slider在Max时，显示顶部内容（Y=2）
        % 当slider在0时，显示底部内容（Y需要向上移动）
        if slider_max > 0
            % 计算新的Y位置（像素）
            % slider_value=Max时，Y=2（顶部）
            % slider_value=0时，Y=2-scroll_range（底部）
            y_offset = slider_max - slider_value;
            new_y = 2 + y_offset;
            
            % 更新滚动面板位置（使用像素单位）
            current_pos = get(control_scroll_panel, 'Position');
            current_pos(2) = new_y;
            set(control_scroll_panel, 'Position', current_pos);
        end
    end

end
