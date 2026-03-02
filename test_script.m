try
    original_image = imread('sample_images/checkerboard_256x256.png');
    multi_level_analysis_gui(original_image);
    disp('Success!');
catch ME
    disp(['Error: ', ME.message]);
    for i=1:length(ME.stack)
        disp([ME.stack(i).file, ' line ', num2str(ME.stack(i).line)]);
    end
end
