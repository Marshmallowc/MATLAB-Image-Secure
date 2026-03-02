try
    disp('Debug started');
    img_path = 'sample_images/checkerboard_256x256.png';
    original_image = imread(img_path);
    if size(original_image, 3) == 3
        original_image = rgb2gray(original_image);
    end
    disp(['Image size: ', num2str(size(original_image))]);
    
    arnold_iters = 5;
    key = 12345678;
    
    disp('L1');
    enc_L1 = arnold_encrypt(original_image, arnold_iters);
    disp(['L1 size: ', num2str(size(enc_L1))]);
    
    disp('L2');
    enc_L2_tmp = arnold_encrypt(original_image, arnold_iters);
    enc_L2 = xor_encrypt(enc_L2_tmp, key);
    disp(['L2 size: ', num2str(size(enc_L2))]);
    
    disp('L3');
    enc_L3_tmp1 = arnold_encrypt(original_image, arnold_iters);
    enc_L3_tmp2 = xor_encrypt(enc_L3_tmp1, key);
    [enc_L3, ~] = scramble_encrypt(enc_L3_tmp2);
    disp('Done');
catch ME
    disp(['ERROR: ', ME.message]);
    for i=1:length(ME.stack)
        disp([ME.stack(i).file, ' : ', num2str(ME.stack(i).line)]);
    end
end
exit;
