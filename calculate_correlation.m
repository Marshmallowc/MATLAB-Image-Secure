function corr_val = calculate_correlation(img1, img2)
    % 计算图像相关性
    % 输入: img1, img2 - 两幅图像
    % 输出: corr_val - 相关系数
    
    % 检查输入参数
    if nargin < 2
        error('需要两个输入图像');
    end
    
    % 检查图像尺寸
    if ~isequal(size(img1), size(img2))
        error('图像尺寸不匹配: img1 (%dx%d) vs img2 (%dx%d)', ...
              size(img1, 1), size(img1, 2), size(img2, 1), size(img2, 2));
    end
    
    % 检查图像是否为空
    if isempty(img1) || isempty(img2)
        error('输入图像不能为空 in calculate_correlation.m');
    end
    
    % 转换为双精度并展平
    img1_vec = double(img1(:));
    img2_vec = double(img2(:));
    
    % 检查是否有足够的数据点
    if length(img1_vec) < 2
        warning('图像像素数量太少，无法计算相关性');
        corr_val = NaN;
        return;
    end
    
    % 检查是否为常数图像（方差为0）
    if var(img1_vec) == 0 || var(img2_vec) == 0
        warning('其中一幅图像为常数图像，相关性设为0');
        corr_val = 0;
        return;
    end
    
    % 计算相关性
    try
        corr_matrix = corrcoef(img1_vec, img2_vec);
        if size(corr_matrix, 1) >= 2 && size(corr_matrix, 2) >= 2
            corr_val = corr_matrix(1, 2);
        else
            corr_val = NaN;
        end
    catch ME
        warning('相关性计算失败: %s', ME.message);
        corr_val = NaN;
    end
    
    % 处理NaN值
    if isnan(corr_val)
        warning('相关性计算结果为NaN，设为0');
        corr_val = 0;
    end
end
