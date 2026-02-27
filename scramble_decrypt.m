function descrambled_img = scramble_decrypt(scrambled_image, sequence)
    % 置乱解密算法
    % 输入: scrambled_image - 置乱图像, sequence - 置乱序列
    % 输出: descrambled_img - 还原后的图像
    
    % 输入验证
    if isempty(scrambled_image)
        error('置乱图像不能为空');
    end
    
    if nargin < 2 || isempty(sequence)
        error('需要提供置乱序列');
    end
    
    scrambled_image = uint8(scrambled_image);
    [rows, cols] = size(scrambled_image);
    total_pixels = rows * cols;
    
    % 验证序列长度
    if length(sequence) ~= total_pixels
        error('置乱序列长度与图像像素数不匹配');
    end
    
    % 将置乱图像转换为一维向量
    scrambled_vector = reshape(scrambled_image, 1, total_pixels);
    
    % 创建逆序列（更高效的方法）
    % inverse_sequence[i] = j 表示原位置i的像素现在在位置j
    inverse_sequence = zeros(1, total_pixels);
    inverse_sequence(sequence) = 1:total_pixels;
    
    % 根据逆序列进行还原
    descrambled_vector = scrambled_vector(inverse_sequence);
    
    % 重新整形为二维图像
    descrambled_img = reshape(descrambled_vector, rows, cols);
end

