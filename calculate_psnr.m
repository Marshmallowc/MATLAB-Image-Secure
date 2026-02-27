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





