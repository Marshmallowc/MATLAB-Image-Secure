function inverse_arnold_img = arnold_decrypt(arnold_image, iterations)
    % Arnold逆变换解密算法
    % 输入: arnold_image - Arnold变换图像, iterations - 迭代次数
    % 输出: inverse_arnold_img - 逆变换后的图像
    
    % 输入验证
    if isempty(arnold_image)
        error('Arnold变换图像不能为空');
    end
    
    if nargin < 2 || isempty(iterations)
        iterations = 5;
    end
    
    if ~isscalar(iterations) || ~isnumeric(iterations) || iterations < 1
        error('迭代次数必须是正整数');
    end
    
    iterations = round(iterations);
    
    arnold_image = uint8(arnold_image);
    [rows, cols] = size(arnold_image);
    
    % 如果图像不是正方形，使用分块Arnold逆变换
    if rows ~= cols
        % 对于非正方形图像，按最小尺寸分块处理
        min_size = min(rows, cols);
        inverse_arnold_img = arnold_image;
        
        % 对每个正方形块应用Arnold逆变换
        for i = 1:min_size:rows
            for j = 1:min_size:cols
                % 计算当前块的边界
                end_i = min(i + min_size - 1, rows);
                end_j = min(j + min_size - 1, cols);
                
                % 提取当前块
                block = inverse_arnold_img(i:end_i, j:end_j);
                
                % 如果块是正方形，应用Arnold逆变换
                if size(block, 1) == size(block, 2)
                    for iter = 1:iterations
                        block = inverse_arnold_transform(block);
                    end
                    inverse_arnold_img(i:end_i, j:end_j) = block;
                else
                    % 对于非正方形边界块，使用像素逆置乱
                    [block_rows, block_cols] = size(block);
                    block_vector = reshape(block, 1, block_rows * block_cols);
                    
                    % 生成相同的伪随机置乱序列（基于位置确定性生成）
                    rng(i * 1000 + j); % 确保与加密时相同
                    scramble_seq = randperm(length(block_vector));
                    
                    % 生成逆置乱序列
                    inverse_seq = zeros(size(scramble_seq));
                    inverse_seq(scramble_seq) = 1:length(scramble_seq);
                    
                    % 应用逆置乱（反向迭代）
                    for iter = 1:iterations
                        block_vector = block_vector(inverse_seq);
                    end
                    
                    inverse_arnold_img(i:end_i, j:end_j) = reshape(block_vector, block_rows, block_cols);
                end
            end
        end
    else
        % 对于正方形图像，直接应用Arnold逆变换
        inverse_arnold_img = arnold_image;
        for iter = 1:iterations
            inverse_arnold_img = inverse_arnold_transform(inverse_arnold_img);
        end
    end
end
