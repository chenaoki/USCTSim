sim_path = 'sim_017/';
num_trial = 50;
num_cycle = 10;
num_muscle_cycle = 5;
num_fat_cycle = 5;
r_max = 80;
r_min = 20;
c_max = 100;
c_min = 10;
center = 512;
base_md = 1000;
base_ss = 1540;
water_ss = 1540;
muscle_ss = 1585;
fat_ss = 1450;

load('param_sample.mat');
load('medium_sample.mat');

% turn off movie record
param.io.save_movie = false;

for trial = 1: num_trial
    trial_name = strcat('trial_', num2str(trial, '%03d'));
    trial_path = strcat(sim_path, trial_name);
    trial_path = strcat(trial_path, '/');
    param.source.point_map = 1: 16 : 256;
    
    md = medium.density;
    ss = medium.sound_speed;
    md(:,:) = base_md;
    ss(:,:) = base_ss;

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
                ss(x, y) = fat_ss;
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
                ss(x, y) = muscle_ss;
            end
        end
        
    medium.density = md;
    medium.sound_speed = ss;
    % run simulation 
    simulate_usct(param, medium, trial_path);
    
end


