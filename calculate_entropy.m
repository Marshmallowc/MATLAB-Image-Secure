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





