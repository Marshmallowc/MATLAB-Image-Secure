function transformed_img = arnold_transform(image)
    % Arnold变换核心函数
    % 使用向量化操作优化性能
    % 输入: image - 输入图像
    % 输出: transformed_img - 变换后的图像
    
    % 输入验证
    if isempty(image)
        error('输入图像不能为空');
    end
    
    [N, M] = size(image);
    if N ~= M
        error('Arnold变换要求正方形图像');
    end
    
    if N < 2
        transformed_img = image;
        return;
    end
    
    transformed_img = zeros(N, N, 'uint8');
    
    % Arnold变换矩阵参数: [a, b; c, d] = [1, 1; 1, 2]
    a = 1; b = 1; c = 1; d = 2;
    
    % 优化：使用向量化操作提高性能
    % 创建坐标网格
    [I, J] = meshgrid(1:N, 1:N);
    I = I(:);
    J = J(:);
    
    % 计算变换后的坐标（模N运算）
    % Arnold变换公式: 
    % new_i = mod(a*(i-1) + b*(j-1), N) + 1
    % new_j = mod(c*(i-1) + d*(j-1), N) + 1
    new_I = mod(a * (I - 1) + b * (J - 1), N) + 1;
    new_J = mod(c * (I - 1) + d * (J - 1), N) + 1;
    
    % 使用线性索引进行像素映射
    source_idx = sub2ind([N, N], I, J);
    target_idx = sub2ind([N, N], new_I, new_J);
    
    % 执行变换映射
    transformed_img(target_idx) = image(source_idx);
end

