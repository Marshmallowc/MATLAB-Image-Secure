% 图像处理工具函数集
% 提供额外的图像处理和分析功能

function processed_img = enhance_image_contrast(image, factor)
    % 增强图像对比度
    % 输入: image - 输入图像, factor - 增强因子(默认1.5)
    % 输出: processed_img - 处理后的图像
    
    if nargin < 2
        factor = 1.5;
    end
    
    image = double(image);
    mean_val = mean(image(:));
    
    processed_img = (image - mean_val) * factor + mean_val;
    processed_img = uint8(max(0, min(255, processed_img)));
end

function processed_img = add_noise(image, noise_type, noise_level)
    % 为图像添加噪声
    % 输入: image - 输入图像, noise_type - 噪声类型, noise_level - 噪声水平
    % 输出: processed_img - 添加噪声后的图像
    
    if nargin < 2
        noise_type = 'gaussian';
    end
    if nargin < 3
        noise_level = 0.1;
    end
    
    image = double(image) / 255;
    
    switch lower(noise_type)
        case 'gaussian'
            noise = randn(size(image)) * noise_level;
            processed_img = image + noise;
            
        case 'salt_pepper'
            processed_img = image;
            % 椒盐噪声
            salt_pepper_mask = rand(size(image)) < noise_level;
            salt_mask = rand(size(image)) < 0.5;
            
            processed_img(salt_pepper_mask & salt_mask) = 1;
            processed_img(salt_pepper_mask & ~salt_mask) = 0;
            
        case 'uniform'
            noise = (rand(size(image)) - 0.5) * 2 * noise_level;
            processed_img = image + noise;
            
        otherwise
            error('不支持的噪声类型');
    end
    
    processed_img = uint8(max(0, min(1, processed_img)) * 255);
end

function filtered_img = apply_filter(image, filter_type, filter_size)
    % 应用滤波器
    % 输入: image - 输入图像, filter_type - 滤波器类型, filter_size - 滤波器大小
    % 输出: filtered_img - 滤波后的图像
    
    if nargin < 2
        filter_type = 'gaussian';
    end
    if nargin < 3
        filter_size = 5;
    end
    
    switch lower(filter_type)
        case 'gaussian'
            sigma = filter_size / 6;
            h = fspecial('gaussian', filter_size, sigma);
            filtered_img = imfilter(image, h, 'replicate');
            
        case 'median'
            filtered_img = medfilt2(image, [filter_size, filter_size]);
            
        case 'average'
            h = fspecial('average', filter_size);
            filtered_img = imfilter(image, h, 'replicate');
            
        case 'laplacian'
            h = fspecial('laplacian');
            filtered_img = imfilter(image, h, 'replicate');
            filtered_img = uint8(abs(filtered_img));
            
        case 'sobel'
            h = fspecial('sobel');
            filtered_img = imfilter(image, h, 'replicate');
            filtered_img = uint8(abs(filtered_img));
            
        otherwise
            error('不支持的滤波器类型');
    end
end

function resized_img = smart_resize(image, target_size, method)
    % 智能图像缩放
    % 输入: image - 输入图像, target_size - 目标尺寸[height, width], method - 缩放方法
    % 输出: resized_img - 缩放后的图像
    
    if nargin < 3
        method = 'bilinear';
    end
    
    if length(target_size) == 1
        target_size = [target_size, target_size];
    end
    
    switch lower(method)
        case 'nearest'
            resized_img = imresize(image, target_size, 'nearest');
        case 'bilinear'
            resized_img = imresize(image, target_size, 'bilinear');
        case 'bicubic'
            resized_img = imresize(image, target_size, 'bicubic');
        otherwise
            resized_img = imresize(image, target_size);
    end
end

function histogram_data = calculate_histogram(image, bins)
    % 计算图像直方图
    % 输入: image - 输入图像, bins - 直方图区间数(默认256)
    % 输出: histogram_data - 直方图数据结构
    
    if nargin < 2
        bins = 256;
    end
    
    image = uint8(image);
    
    [counts, centers] = imhist(image, bins);
    probabilities = counts / sum(counts);
    
    histogram_data.counts = counts;
    histogram_data.centers = centers;
    histogram_data.probabilities = probabilities;
    histogram_data.bins = bins;
end

function similarity = calculate_ssim(img1, img2)
    % 计算结构相似性指数(SSIM)
    % 输入: img1, img2 - 两幅图像
    % 输出: similarity - SSIM值
    
    if size(img1) ~= size(img2)
        error('图像尺寸不匹配');
    end
    
    img1 = double(img1);
    img2 = double(img2);
    
    % SSIM参数
    K1 = 0.01;
    K2 = 0.03;
    L = 255; % 像素值范围
    
    C1 = (K1 * L)^2;
    C2 = (K2 * L)^2;
    
    % 计算均值
    mu1 = mean(img1(:));
    mu2 = mean(img2(:));
    
    % 计算方差和协方差
    sigma1_sq = var(img1(:));
    sigma2_sq = var(img2(:));
    sigma12 = cov(img1(:), img2(:));
    sigma12 = sigma12(1, 2);
    
    % 计算SSIM
    numerator = (2 * mu1 * mu2 + C1) * (2 * sigma12 + C2);
    denominator = (mu1^2 + mu2^2 + C1) * (sigma1_sq + sigma2_sq + C2);
    
    similarity = numerator / denominator;
end

function uniformity = calculate_uniformity(image)
    % 计算图像均匀性
    % 输入: image - 输入图像
    % 输出: uniformity - 均匀性指标
    
    hist_data = calculate_histogram(image);
    probabilities = hist_data.probabilities;
    
    % 均匀性 = 1 - 方差/最大可能方差
    variance = var(probabilities);
    max_variance = (1/256 - 1/256)^2 * 255; % 最不均匀时的方差
    
    uniformity = 1 - variance / max_variance;
end

function complexity = calculate_image_complexity(image)
    % 计算图像复杂度
    % 输入: image - 输入图像
    % 输出: complexity - 复杂度指标结构
    
    % 边缘密度
    edge_img = edge(image, 'canny');
    edge_density = sum(edge_img(:)) / numel(edge_img);
    
    % 局部方差
    local_variance = stdfilt(image).^2;
    mean_local_variance = mean(local_variance(:));
    
    % 纹理能量
    glcm = graycomatrix(image, 'Offset', [0 1; -1 1; -1 0; -1 -1]);
    props = graycoprops(glcm, 'Energy');
    texture_energy = mean(props.Energy);
    
    % 信息熵
    entropy = calculate_entropy(image);
    
    % 综合复杂度评分
    complexity_score = edge_density * 0.3 + ...
                      (mean_local_variance / 255^2) * 0.3 + ...
                      (1 - texture_energy) * 0.2 + ...
                      (entropy / 8) * 0.2;
    
    complexity.edge_density = edge_density;
    complexity.local_variance = mean_local_variance;
    complexity.texture_energy = texture_energy;
    complexity.entropy = entropy;
    complexity.overall_score = complexity_score;
end

function security_metrics = evaluate_encryption_security(original_img, encrypted_img)
    % 评估加密安全性
    % 输入: original_img - 原始图像, encrypted_img - 加密图像
    % 输出: security_metrics - 安全性指标结构
    
    % 信息熵
    entropy_original = calculate_entropy(original_img);
    entropy_encrypted = calculate_entropy(encrypted_img);
    entropy_improvement = entropy_encrypted - entropy_original;
    
    % 相关性
    correlation = abs(calculate_correlation(original_img, encrypted_img));
    
    % 直方图均匀性
    uniformity = calculate_uniformity(encrypted_img);
    
    % 像素变化率
    pixel_change_rate = sum(original_img(:) ~= encrypted_img(:)) / numel(original_img);
    
    % 局部信息熵
    block_size = 8;
    [rows, cols] = size(encrypted_img);
    local_entropies = [];
    
    for i = 1:block_size:rows-block_size+1
        for j = 1:block_size:cols-block_size+1
            block = encrypted_img(i:i+block_size-1, j:j+block_size-1);
            local_entropies(end+1) = calculate_entropy(block);
        end
    end
    
    local_entropy_variance = var(local_entropies);
    
    % 计算安全性评分 (0-100)
    entropy_score = min(100, entropy_encrypted / 8 * 100);
    correlation_score = (1 - correlation) * 100;
    uniformity_score = uniformity * 100;
    change_score = pixel_change_rate * 100;
    local_score = (1 - local_entropy_variance / max(local_entropies)^2) * 100;
    
    overall_score = (entropy_score * 0.3 + correlation_score * 0.3 + ...
                    uniformity_score * 0.2 + change_score * 0.1 + ...
                    local_score * 0.1);
    
    security_metrics.entropy_original = entropy_original;
    security_metrics.entropy_encrypted = entropy_encrypted;
    security_metrics.entropy_improvement = entropy_improvement;
    security_metrics.correlation = correlation;
    security_metrics.uniformity = uniformity;
    security_metrics.pixel_change_rate = pixel_change_rate;
    security_metrics.local_entropy_variance = local_entropy_variance;
    security_metrics.entropy_score = entropy_score;
    security_metrics.correlation_score = correlation_score;
    security_metrics.uniformity_score = uniformity_score;
    security_metrics.change_score = change_score;
    security_metrics.local_score = local_score;
    security_metrics.overall_score = overall_score;
end

function cropped_img = auto_crop(image, method)
    % 自动裁剪图像
    % 输入: image - 输入图像, method - 裁剪方法
    % 输出: cropped_img - 裁剪后的图像
    
    if nargin < 2
        method = 'content';
    end
    
    switch lower(method)
        case 'content'
            % 基于内容的智能裁剪
            % 使用边缘检测找到主要内容区域
            edge_img = edge(image, 'canny');
            
            % 找到非零像素的边界
            [rows, cols] = find(edge_img);
            if ~isempty(rows)
                min_row = max(1, min(rows) - 10);
                max_row = min(size(image, 1), max(rows) + 10);
                min_col = max(1, min(cols) - 10);
                max_col = min(size(image, 2), max(cols) + 10);
                
                cropped_img = image(min_row:max_row, min_col:max_col);
            else
                cropped_img = image;
            end
            
        case 'center'
            % 中心裁剪
            [rows, cols] = size(image);
            crop_size = min(rows, cols) * 0.8;
            
            start_row = round((rows - crop_size) / 2) + 1;
            start_col = round((cols - crop_size) / 2) + 1;
            end_row = start_row + crop_size - 1;
            end_col = start_col + crop_size - 1;
            
            cropped_img = image(start_row:end_row, start_col:end_col);
            
        otherwise
            cropped_img = image;
    end
end

function padded_img = smart_padding(image, target_size, method)
    % 智能图像填充
    % 输入: image - 输入图像, target_size - 目标尺寸, method - 填充方法
    % 输出: padded_img - 填充后的图像
    
    if nargin < 3
        method = 'reflect';
    end
    
    [rows, cols] = size(image);
    
    if length(target_size) == 1
        target_size = [target_size, target_size];
    end
    
    target_rows = target_size(1);
    target_cols = target_size(2);
    
    pad_rows = max(0, target_rows - rows);
    pad_cols = max(0, target_cols - cols);
    
    pad_top = floor(pad_rows / 2);
    pad_bottom = pad_rows - pad_top;
    pad_left = floor(pad_cols / 2);
    pad_right = pad_cols - pad_left;
    
    switch lower(method)
        case 'zeros'
            padded_img = padarray(image, [pad_top, pad_left], 0, 'pre');
            padded_img = padarray(padded_img, [pad_bottom, pad_right], 0, 'post');
            
        case 'reflect'
            padded_img = padarray(image, [pad_top, pad_left], 'symmetric', 'pre');
            padded_img = padarray(padded_img, [pad_bottom, pad_right], 'symmetric', 'post');
            
        case 'replicate'
            padded_img = padarray(image, [pad_top, pad_left], 'replicate', 'pre');
            padded_img = padarray(padded_img, [pad_bottom, pad_right], 'replicate', 'post');
            
        case 'mean'
            mean_val = mean(image(:));
            padded_img = padarray(image, [pad_top, pad_left], mean_val, 'pre');
            padded_img = padarray(padded_img, [pad_bottom, pad_right], mean_val, 'post');
            
        otherwise
            padded_img = image;
    end
    
    % 如果需要，进行裁剪以达到精确尺寸
    [curr_rows, curr_cols] = size(padded_img);
    if curr_rows > target_rows || curr_cols > target_cols
        start_row = max(1, floor((curr_rows - target_rows) / 2) + 1);
        start_col = max(1, floor((curr_cols - target_cols) / 2) + 1);
        end_row = min(curr_rows, start_row + target_rows - 1);
        end_col = min(curr_cols, start_col + target_cols - 1);
        
        padded_img = padded_img(start_row:end_row, start_col:end_col);
    end
end
