function inverse_img = inverse_arnold_transform(image)
    % Arnold逆变换核心函数
    % 使用正确的模逆元计算，避免浮点数精度问题
    % 输入: image - 输入图像
    % 输出: inverse_img - 逆变换后的图像
    
    % 输入验证
    if isempty(image)
        error('输入图像不能为空');
    end
    
    [N, M] = size(image);
    if N ~= M
        error('Arnold逆变换要求正方形图像');
    end
    
    if N < 2
        inverse_img = image;
        return;
    end
    
    inverse_img = zeros(N, N, 'uint8');
    
    % Arnold变换矩阵参数: [a, b; c, d] = [1, 1; 1, 2]
    % 逆矩阵在模N运算下: [d, -b; -c, a] = [2, N-1; N-1, 1]
    % 因为 det = 1*2 - 1*1 = 1，所以逆矩阵就是伴随矩阵
    
    % 使用整数模运算，避免浮点数误差
    a = 1; b = 1; c = 1; d = 2;
    
    % 逆矩阵系数（模N运算）
    inv_a = d;      % = 2
    inv_b = mod(-b, N);  % = N-1
    inv_c = mod(-c, N);  % = N-1
    inv_d = a;      % = 1
    
    % 优化：使用向量化操作提高性能
    % 创建坐标网格
    [I, J] = meshgrid(1:N, 1:N);
    I = I(:);
    J = J(:);
    
    % 计算逆变换后的坐标（模N运算）
    % 注意：Arnold变换的逆变换公式
    % new_i = mod(inv_a*(i-1) + inv_b*(j-1), N) + 1
    % new_j = mod(inv_c*(i-1) + inv_d*(j-1), N) + 1
    new_I = mod(inv_a * (I - 1) + inv_b * (J - 1), N) + 1;
    new_J = mod(inv_c * (I - 1) + inv_d * (J - 1), N) + 1;
    
    % 使用线性索引进行像素映射
    source_idx = sub2ind([N, N], I, J);
    target_idx = sub2ind([N, N], new_I, new_J);
    
    % 执行逆变换映射
    inverse_img(target_idx) = image(source_idx);
end

