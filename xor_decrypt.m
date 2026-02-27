function decrypted_img = xor_decrypt(encrypted_image, key)
    % XOR解密算法（XOR运算的逆运算就是自身）
    % 输入: encrypted_image - 加密图像, key - 解密密钥
    % 输出: decrypted_img - 解密后的图像
    
    % 输入验证
    if isempty(encrypted_image)
        error('加密图像不能为空');
    end
    
    if nargin < 2 || isempty(key)
        error('需要提供解密密钥');
    end
    
    % XOR加密和解密使用相同的操作
    decrypted_img = xor_encrypt(encrypted_image, key);
end

