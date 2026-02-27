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





