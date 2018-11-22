sim_path = 'visualization/';
num_trial = 1;
num_cycle = 10;
num_muscle_cycle = 5;
num_fat_cycle = 5;
r_max = 80;
r_min = 20;
c_max = 100;
c_min = 10;
center = 512;

base_ss = 1540;
water_ss = 1540;
muscle_ss = 1585;
fat_ss = 1450;

base_md = 1000;
water_md = base_md * (water_ss/base_ss)
muscle_md = base_md * (muscle_ss/base_ss)
fat_md = base_md * (fat_ss/base_ss)

load('param_sample.mat');
load('medium_sample.mat');

% turn off movie record
param.io.save_movie = false;

for trial = 1: num_trial
    trial_name = strcat('trial_', num2str(trial, '%03d'));
    trial_nameSS = strcat(trial_name, 'SS');
    trial_nameMD = strcat(trial_name, 'MD');
    trial_pathSS = strcat(sim_path, trial_nameSS);
    trial_pathSS = strcat(trial_pathSS, '/');
    trial_pathMD = strcat(sim_path, trial_nameMD);
    trial_pathMD = strcat(trial_pathMD, '/');
    param.source.point_map = 1: 16 : 256;
    
    md1 = medium.density;
    ss1 = medium.sound_speed;
    md1(:,:) = base_md;
    ss1(:,:) = base_ss;

    md2 = medium.density;
    ss2 = medium.sound_speed;
    md2(:,:) = base_md;
    ss2(:,:) = base_ss;

    % fat
    for i = 1: num_fat_cycle:
        r = randi([r_min, r_max], 1, 1);
        cr = randi([c_min, c_max], 1, 1);
        cth = pi * rand([-1, 1], 1, 1);
        cx = cr * cos(cth)
        cy = cr * sin(cth)
        for dx = -r : r 
            tmp = int16(sqrt(r*r - dx*dx));
            for dy = -tmp : tmp
                x = cx + dx;
                y = cy + dy;
                ss1(x, y) = fat_ss;
                md2(x, y) = fat_md;
            end
        end
    
    % muscle
    for i = 1: num_muscle_cycle:
        r = randi([r_min, r_max], 1, 1);
        cr = randi([c_min, c_max], 1, 1);
        cth = pi * rand([-1, 1], 1, 1);
        cx = cr * cos(cth)
        cy = cr * sin(cth)
        for dx = -r : r 
            tmp = int16(sqrt(r*r - dx*dx));
            for dy = -tmp : tmp
                x = cx + dx;
                y = cy + dy;
                ss1(x, y) = muscle_ss;
                md2(x, y) = muscle_md;
            end
        end

    
    % run simulation 
    % modify Sound speed map
    medium.density = md1;
    medium.sound_speed = ss1;
    simulate_usct(param, medium, trial_pathSS);

    % modify Density map
    medium.density = md2;
    medium.sound_speed = ss2;
    simulate_usct(param, medium, trial_pathMD);
end


