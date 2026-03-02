function arnold_img = arnold_encrypt(image, iterations)
    % Arnold变换加密算法
    % 输入: image - 输入图像, iterations - 迭代次数
    % 输出: arnold_img - Arnold变换后的图像
    
    % 输入验证
    if isempty(image)
        error('输入图像不能为空 in arnold_encrypt.m');
    end
    
    if nargin < 2 || isempty(iterations)
        iterations = 5;
    end
    
    if ~isscalar(iterations) || ~isnumeric(iterations) || iterations < 1
        error('迭代次数必须是正整数');
    end
    
    iterations = round(iterations);
    
    image = uint8(image);
    [rows, cols] = size(image);
    
    % 如果图像不是正方形，使用分块Arnold变换
    if rows ~= cols
        % 对于非正方形图像，按最小尺寸分块处理
        min_size = min(rows, cols);
        arnold_img = image;
        
        % 对每个正方形块应用Arnold变换
        for i = 1:min_size:rows
            for j = 1:min_size:cols
                % 计算当前块的边界
                end_i = min(i + min_size - 1, rows);
                end_j = min(j + min_size - 1, cols);
                
                % 提取当前块
                block = arnold_img(i:end_i, j:end_j);
                
                % 如果块是正方形，应用Arnold变换
                if size(block, 1) == size(block, 2)
                    for iter = 1:iterations
                        block = arnold_transform(block);
                    end
                    arnold_img(i:end_i, j:end_j) = block;
                else
                    % 对于非正方形边界块，使用像素置乱
                    [block_rows, block_cols] = size(block);
                    block_vector = reshape(block, 1, block_rows * block_cols);
                    
                    % 生成伪随机置乱序列（基于位置确定性生成）
                    rng(i * 1000 + j); % 确保可重复
                    scramble_seq = randperm(length(block_vector));
                    
                    % 应用置乱
                    for iter = 1:iterations
                        block_vector = block_vector(scramble_seq);
                    end
                    
                    arnold_img(i:end_i, j:end_j) = reshape(block_vector, block_rows, block_cols);
                end
            end
        end
    else
        % 对于正方形图像，直接应用Arnold变换
        arnold_img = image;
        for iter = 1:iterations
            arnold_img = arnold_transform(arnold_img);
        end
    end
end
