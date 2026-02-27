% 图像加密算法实现
% 注意：加密/解密算法函数已迁移到独立的函数文件中
% 
% 独立函数文件（已优化）：
% - xor_encrypt.m / xor_decrypt.m
% - scramble_encrypt.m / scramble_decrypt.m  
% - arnold_encrypt.m / arnold_decrypt.m
% - arnold_transform.m / inverse_arnold_transform.m
%
% 此文件仅保留图像质量评估函数，这些函数没有独立文件

% 图像质量评估函数
function mse_val = calculate_mse(img1, img2)
    % 计算均方误差
    % 输入: img1, img2 - 两幅图像
    % 输出: mse_val - 均方误差值
    
    if size(img1) ~= size(img2)
        error('图像尺寸不匹配');
    end
    
    img1 = double(img1);
    img2 = double(img2);
    
    mse_val = mean(mean((img1 - img2).^2));
end

function psnr_val = calculate_psnr(img1, img2)
    % 计算峰值信噪比
    % 输入: img1, img2 - 两幅图像
    % 输出: psnr_val - PSNR值（dB）
    
    mse_val = calculate_mse(img1, img2);
    
    if mse_val == 0
        psnr_val = Inf;
    else
        psnr_val = 10 * log10(255^2 / mse_val);
    end
end

function corr_val = calculate_correlation(img1, img2)
    % 计算图像相关性
    % 输入: img1, img2 - 两幅图像
    % 输出: corr_val - 相关系数
    
    if size(img1) ~= size(img2)
        error('图像尺寸不匹配');
    end
    
    img1 = double(img1(:));
    img2 = double(img2(:));
    
    corr_matrix = corrcoef(img1, img2);
    corr_val = corr_matrix(1, 2);
end

function entropy_val = calculate_entropy(image)
    % 计算图像信息熵
    % 输入: image - 输入图像
    % 输出: entropy_val - 信息熵值
    
    image = uint8(image);
    
    % 计算灰度级概率分布
    [counts, ~] = imhist(image);
    probabilities = counts / sum(counts);
    
    % 去除零概率值
    probabilities = probabilities(probabilities > 0);
    
    % 计算信息熵
    entropy_val = -sum(probabilities .* log2(probabilities));
end
