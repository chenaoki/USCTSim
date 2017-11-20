function simulate_usct(param, dst_path)

    if ~exist(dst_path, 'dir')
        mkdir(dst_path);
    end
    save([dst_path, '\param'], 'param')
    
    % Create grid with time array
    kgrid = makeGrid(param.grid.Nx, param.grid.dx, param.grid.Ny, param.grid.dy);
    dt1=1/param.sensor.freq;
    [ta2,dt2] = makeTime(kgrid, param.medium.sound_speed, [], param.t_end);
    if dt2<dt1         % select higher sampling rate
        kgrid.dt = dt2;
        kgrid.t_array=ta2;
    else
        kgrid.dt = dt1;
        kgrid.t_array=0:dt1:param.t_end;
    end
    save([dst_path,'\kgrid.mat'],'kgrid');
    
    % Define source wave form
    source_wave = create_waveform( param.source.waveform, kgrid.t_array, kgrid.dt);
    save([dst_path,'\sourse_wave.mat'],'source_wave');
    
    % Define sensors
    ringplace = makeCartCircle(param.ringarray.radius, param.ringarray.num_points);
    sensor.mask=ringplace;
    [mask_points, ringpos2scanpos, ~]=cart2grid(kgrid, ringplace); % from xy coodinate to pixel index
    sensor.record = {'p'}; % define the acoustic parameters to record
    save([dst_path,'\sensor.mat'],'sensor');

    % Source loop
    num_step = length(param.source.point_map);
    rfdata=zeros(length(kgrid.t_array), param.ringarray.num_points, num_step); 
    for step=1:num_step
        
        disp(['Step ',num2str(step),'/',num2str(num_step)])
        
        save_path = [dst_path, '\step', num2str(step, '%03d')];
        if ~exist(save_path, 'dir')
            mkdir(save_path);
        end
        
        % Define source wave
        points = param.source.point_map(:,step);
        source.p_mask = mask_points;
        source.p = zeros(param.ringarray.num_points, length(kgrid.t_array));
        for i=1:length(points)
            if points(i) > 0
                source.p( ringpos2scanpos( points(i) ), : ) = source_wave;
            end
        end
        save([save_path,'\source.mat'],'source');
        
        % Run the simulation
        input_args = {
            'RecordMovie', param.io.save_movie, ...
            'MovieType', 'image', ...
            'MovieName', [save_path, '\out'], ...
            'DataCast','gpuArray-double',...
            'PlotScale',[-0.1 0.1]
        };
        sensor_data = (kspaceFirstOrder2D(...
            kgrid, param.medium, source, sensor,...
            input_args{:}...
        )).';
        rfdata(:,:,step)=gather(sensor_data.p).';

        % Plot the simulated sensor data
        figure;
        imagesc(sensor_data.p.',[-0.1 0.1]);
        xlabel('Sensor Position');
        ylabel('Time Step');
        colorbar;
        saveas(gcf, [save_path, '\rf'], 'png')
        close all

    end
        
    save([dst_path,'\rfdata.mat'],'rfdata', '-v7.3');
    
end