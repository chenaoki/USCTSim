sim_path = 'sim_016/';
num_trial = 50;
num_cycle = 10;
r_max = 150;
r_min = 50;
c_max = 200;
center = 512;
base_md = 1000;
base_ss = 1500;

load('param_sample.mat');
load('medium_sample.mat');

% turn off movie record
param.io.save_movie = 0;

for trial = 1: num_trial
    trial_name = strcat('trial_', num2str(trial, '%03d'));
    trial_path = strcat(sim_path, trial_name);
    trial_path = strcat(trial_path, '/');
    param.source.point_map = 1: 16 : 256;
    
    ss(:,:) = mean(mean(medium.sound_speed));
    md(:,:) = mean(mean(medium.density));
    % random cycle: density map
    for i = 1: num_cycle
        r = randi([r_min r_max], 1, 1);
        cx = randi([center-c_max, center + c_max], 1, 1);
        cy = randi([center-c_max, center + c_max], 1, 1);
        for dx = -r : r 
            tmp = int16(sqrt(r*r - dx*dx));
            for dy = -tmp : tmp
                x = cx + dx;
                y = cy + dy;
                md(x, y) = md(x, y) + base_md * 0.2;
            end
        end
    end
    medium.density = md;
    
    % random cycle: sound speed map
    for i = 1: num_cycle
        r = randi([r_min r_max], 1, 1);
        cx = randi([center-c_max, center + c_max], 1, 1);
        cy = randi([center-c_max, center + c_max], 1, 1);
        
        for dx = -r : r 
            tmp = int16(sqrt(r*r - dx*dx));
            for dy = -tmp : tmp
                x = cx + dx;
                y = cy + dy;
                ss(x, y) = ss(x, y) + base_ss * 0.2;
            end
        end
    end
    medium.sound_speed = ss;
%     % visualization
%     figure;
%     % set(gca,'position',[500,500,500,500]);
%     x0 = 10;
%     y0 = 10;
%     width = 1000;
%     height = 400;
%     set(gcf,'units','points','position',[x0,y0,width,height]);
%     subplot(1,2,1);
%     imagesc(medium.density);
%     subplot(1,2,2);
%     imagesc(medium.sound_speed);
    
    % run simulation 
    simulate_usct(param, medium, trial_path);
    
end


