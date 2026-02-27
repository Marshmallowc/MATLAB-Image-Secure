function encrypted_img = xor_encrypt(image, key)
    % XOR加密算法
    % 输入: image - 输入图像, key - 加密密钥（整数，用于生成伪随机密钥矩阵）
    % 输出: encrypted_img - 加密后的图像
    
    % 输入验证
    if isempty(image)
        error('输入图像不能为空');
    end
    
    if nargin < 2 || isempty(key)
        key = 123; % 默认密钥
    end
    
    if ~isscalar(key) || ~isnumeric(key) || key < 0
        error('密钥必须是正整数');
    end
    
    % 确保图像为uint8类型
    image = uint8(image);
    
    % 生成密钥矩阵
    [rows, cols] = size(image);
    
    % 保存当前随机数生成器状态
    old_rng_state = rng;
    
    try
        % 使用密钥作为随机种子生成伪随机序列
        rng(key); % 设置随机种子
        key_matrix = randi([0, 255], rows, cols, 'uint8');
        
        % XOR加密
        encrypted_img = bitxor(image, key_matrix);
    catch ME
        % 恢复随机数生成器状态
        rng(old_rng_state);
        rethrow(ME);
    end
    
    % 恢复随机数生成器状态
    rng(old_rng_state);
end

