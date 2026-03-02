function [scrambled_img, sequence] = scramble_encrypt(image, seed)
    % 置乱加密算法
    % 输入: image - 输入图像, seed - 随机种子(可选)
    % 输出: scrambled_img - 置乱后的图像, sequence - 置乱序列
    
    % 输入验证
    if isempty(image)
        error('输入图像不能为空 in scramble_encrypt.m');
    end
    
    image = uint8(image);
    [rows, cols] = size(image);
    
    total_pixels = rows * cols;
    
    % 如果提供了种子，使用固定种子；否则使用基于图像内容的确定性种子
    if nargin >= 2 && ~isempty(seed)
        rng(seed);
    else
        % 使用基于图像内容的确定性种子，确保相同图像产生相同置乱
        % 但不同图像产生不同置乱
        image_hash = sum(double(image(:)));
        rng(mod(image_hash, 2^31));
    end
    
    % 生成随机置乱序列
    sequence = randperm(total_pixels);
    
    % 将图像转换为一维向量
    img_vector = reshape(image, 1, total_pixels);
    
    % 根据序列进行置乱
    scrambled_vector = img_vector(sequence);
    
    % 重新整形为二维图像
    scrambled_img = reshape(scrambled_vector, rows, cols);
end
