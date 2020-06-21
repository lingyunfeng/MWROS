function [] = Draw_China_GIS(Radar_Longitude,Radar_Latitude, Display_Range,GISOptions) 
%function [] = Draw_China_GIS(Radar_Longitude,Radar_Latitude,
%Display_Range,Options) 
%�����й��ĳ��е�GIS����
%����ߣ�CJJ
%���ʱ�䣺2014��3��5��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global ChinaMap;  %��ChinaMap�趨Ϊȫ�ֱ�����������ֻ��Ҫ���ļ��ж�ȡһ�μ��ɣ����Դ���Լʱ��
if isempty(ChinaMap)
    load ChinaMap  %����ChinaMap.mat �����ļ�����GenerateMyMap.m���ɵ�
end

%������Ǽ��ϵ�����Ϣ�Ĵ���
Display_Range_Lon=Display_Range/1e3/50;  %�����״�����̣������γ�ȵ������Ƕ��ٶ� �����ǵ�����������γ�����Ӷ����٣���������ѡ���˾���1�ȱ�ʾ50km�����˽ϴ������

%1.�Ȼ��Ƴ���
if GISOptions.City
    %1.1�Ƚ����еľ�γ�Ȼ��㵽�״�ķ�λ�;��룬����CJJ��д�ľ�γ��->������ת������
    [TargetAzimuth,TargetDistance,TargetElevation] =LonToPolar(Radar_Longitude,Radar_Latitude, 0, ChinaMap.City.Long,  ChinaMap.City.Lat,0 );
    City.x=TargetDistance .* cosd(90 -TargetAzimuth ) .*cosd(TargetElevation) /1e3; %���㵽km
    City.y=TargetDistance .* sind(90 -TargetAzimuth ) .*cosd(TargetElevation) /1e3;

    %1.2ѡ������״�����ʾ���̷�Χ֮�ڵĳ���
    if GISOptions.SmallCity
        city_select_index= find( (abs(City.x)< Display_Range/1e3) & (abs(City.y)< Display_Range/1e3)   )  ;  %ע�⣺����Ҫ�� & ��������&&
    else
        %�������Ҫ��ʾС���У���ѡȡClass=4�ĳ���
        city_select_index= find( (ChinaMap.City.Class~=4) &  (abs(City.x)< Display_Range/1e3) & (abs(City.y)< Display_Range/1e3)   )  ;  %ע�⣺����Ҫ�� & ��������&&
    end
    city_select.x=City.x(city_select_index);
    city_select.y=City.y(city_select_index);
    city_select.Name=ChinaMap.City.Name(city_select_index);
    city_select.Class=ChinaMap.City.Class(city_select_index);

    %1.3�������к�С����λ�úܽӽ�����С����ȥ��
    big_city_select_index=find( (city_select.Class~=4)  )  ;   %�ȰѴ�����ҳ���
    distance_threshold=Display_Range/1e3  /10;  %�ھ����������٣��Ͳ�����ʾС������ ����ʾ���̵�1/10
    for ii=big_city_select_index
        for jj=1:length(city_select.Name)  %�������еĳ���
            if city_select.Class(jj) ~=4 , continue; end
            dx= city_select.x(ii) - city_select.x(jj);
            dy= city_select.y(ii) - city_select.y(jj);
            if (( abs(dx)<distance_threshold) && (abs(dy)<distance_threshold))
                city_select.x(jj)=NaN;
                city_select.y(jj)=NaN;
            end
        end
    end

    %1.4 ���������ֻ�����ͼ��
    hold on
    for ii=1:length(city_select.Name)
        if ((city_select.Class(ii)==1) ||(city_select.Class(ii)==2))
            text(city_select.x(ii),city_select.y(ii),city_select.Name(ii),'fontsize',10) ;
        elseif city_select.Class(ii)==3
            text(city_select.x(ii),city_select.y(ii),city_select.Name(ii),'fontsize',8) ;
        else
            text(city_select.x(ii),city_select.y(ii),city_select.Name(ii),'fontsize',6) ;
        end
    end

end

%%%%%%%%%%%%%%%%%%%%
%2.�ٻ���ʡ��
if GISOptions.ProvinceBoundaries
    %2.1 �ȸ����״�ľ�γ�ȣ�Ԥ����ѡһ��
    Long_diff=abs( ChinaMap.ProvinceBoundaries.Long - Radar_Longitude);
    Lat_diff=abs( ChinaMap.ProvinceBoundaries.Lat - Radar_Latitude);
    GIS_data_select_index_first= find( isnan(Long_diff) | (    (Long_diff < Display_Range_Lon) & (Lat_diff<Display_Range_Lon) ));  %ע�⣺Ҫ��NaN�����ݱ�������ΪNaN�����ݱ�ʾһ���߶εĽ�����

    GIS_data_select_first.Long=ChinaMap.ProvinceBoundaries.Long(GIS_data_select_index_first);
    GIS_data_select_first.Lat=ChinaMap.ProvinceBoundaries.Lat(GIS_data_select_index_first);

    %2.2 ��ʡ��ľ�γ�Ȼ��㵽�״�ķ�λ�;��룬����CJJ��д�ľ�γ��->������ת������
    [TargetAzimuth,TargetDistance,TargetElevation] =LonToPolar(Radar_Longitude, Radar_Latitude, 0,GIS_data_select_first.Long,  GIS_data_select_first.Lat,0 );
    GIS_data.x=TargetDistance .* cosd(90 -TargetAzimuth ) .*cosd(TargetElevation) /1e3; %���㵽km
    GIS_data.y=TargetDistance .* sind(90 -TargetAzimuth ) .*cosd(TargetElevation) /1e3;

    %2.3ѡ������״�����ʾ���̷�Χ֮�ڵĵ�
    GIS_data_select_index= find(isnan(GIS_data.x) |  ( (abs(GIS_data.x)< Display_Range/1e3) &  (abs(GIS_data.y)< Display_Range/1e3)  )  )  ; %ע�⣺Ҫ��NaN�����ݱ�������ΪNaN�����ݱ�ʾһ���߶εĽ�����
    GIS_data_select.x=GIS_data.x(GIS_data_select_index);
    GIS_data_select.y=GIS_data.y(GIS_data_select_index);

    %2.4��ʾ��Щѡ�е��߶�
    hold on
    plot(GIS_data_select.x,GIS_data_select.y,'g-','LineWidth',1, 'Color',[0.5 0 0.5 ]);
end

%%%%%%%%%%%%%%%%%%%%
%3.�ٻ����н�
if GISOptions.CityBoundaries
    %3.1 �ȸ����״�ľ�γ�ȣ�Ԥ����ѡһ��
    Long_diff=abs( ChinaMap.CityBoundaries.Long - Radar_Longitude);
    Lat_diff=abs( ChinaMap.CityBoundaries.Lat - Radar_Latitude);
    GIS_data_select_index_first= find( isnan(Long_diff) | (    (Long_diff < Display_Range_Lon) & (Lat_diff<Display_Range_Lon) ));  %ע�⣺Ҫ��NaN�����ݱ�������ΪNaN�����ݱ�ʾһ���߶εĽ�����

    GIS_data_select_first.Long=ChinaMap.CityBoundaries.Long(GIS_data_select_index_first);
    GIS_data_select_first.Lat=ChinaMap.CityBoundaries.Lat(GIS_data_select_index_first);

    %3.2 ���н�ľ�γ�Ȼ��㵽�״�ķ�λ�;��룬����CJJ��д�ľ�γ��->������ת������
    [TargetAzimuth,TargetDistance,TargetElevation] =LonToPolar(Radar_Longitude,Radar_Latitude, 0, GIS_data_select_first.Long,  GIS_data_select_first.Lat,0 );
    GIS_data.x=TargetDistance .* cosd(90 -TargetAzimuth ) .*cosd(TargetElevation) /1e3; %���㵽km
    GIS_data.y=TargetDistance .* sind(90 -TargetAzimuth ) .*cosd(TargetElevation) /1e3;

    %3.3ѡ������״�����ʾ���̷�Χ֮�ڵĵ�
    GIS_data_select_index= find(isnan(GIS_data.x) |  ( (abs(GIS_data.x)< Display_Range/1e3) &  (abs(GIS_data.y)< Display_Range/1e3)  )  )  ; %ע�⣺Ҫ��NaN�����ݱ�������ΪNaN�����ݱ�ʾһ���߶εĽ�����
    GIS_data_select.x=GIS_data.x(GIS_data_select_index);
    GIS_data_select.y=GIS_data.y(GIS_data_select_index);

    %3.4��ʾ��Щѡ�е��߶�
    hold on
    plot(GIS_data_select.x,GIS_data_select.y,'g-','LineWidth',1, 'Color',[0.5 0.5 0.5 ]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�Ժ��п��ٱ�д���ƺ�����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TargetAzimuth,TargetDistance,TargetElevation] = LonToPolar (RadarLongitude,RadarLatitude,RadarHeight,TargetLongitude,TargetLatitude,TargetHeight)
%���ڴ�������ľ�γ�ȼ�����Եķ�λ�����롢����
%ע�⣺���������õĹ�ʽ�Ǿ��Ծ�ȷ�ģ��Ǿ�����֤�ġ��μ����״����顷
%ע�⣺��������У��״��λ�ñ����ǵ������ݣ���Ŀ���λ��������һά����
%����ߣ�CJJ
%���ʱ�䣺2014.3.4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����������ķ�Χ�����ж�
if ( (RadarLongitude > 180) || (RadarLongitude < -180))
    disp('�״�ľ���ֵ�����˷�Χ��Ҫ����-180~180֮�䣩');
    return;
end

if (( RadarLatitude > 90) || (RadarLatitude < -90))
    disp('�״��γ��ֵ�����˷�Χ��Ҫ����-90~90֮�䣩');
    return;
end

if (any(TargetLongitude > 180) || any(TargetLongitude < -180))
    disp ('Ŀ��ľ���ֵ�����˷�Χ��Ҫ����-180~180֮�䣩');
    return;
end

if (any(TargetLatitude > 90) || any(TargetLatitude < -90))
    disp ('Ŀ���γ��ֵ�����˷�Χ��Ҫ����-90~90֮�䣩');
    return;
end

%�ȶ������ĵ�����
a = 6378137.0; %���򳤰뾶����WGS-84����ϵ����λ����
b = a * (1 - 1 / 298.257223563);%  ����̰뾶����λ����
e = sqrt((a * a - b * b) / (a * a)); % ����ƫ����

B0 = RadarLatitude * pi / 180.0;   %�״��ڿռ��������е�λ�� γ��
L0 = RadarLongitude * pi / 180.0;  %�״��ڿռ��������е�λ�� ����
H0 = RadarHeight;  %�״��ڿռ��������е�λ�� �߶�

N0 = a / sqrt(1 - e * e * sin(B0) * sin(B0)); %�״�����λ�õ�î�����ʰ뾶

X0 = (N0 + H0) * cos(B0) * cos(L0);     %�״��ڿռ�ֱ������ϵ�е�λ��
Y0 = (N0 + H0) * cos(B0) * sin(L0);   %�״��ڿռ�ֱ������ϵ�е�λ��
Z0 = (N0 * (1 - e * e) + H0) * sin(B0);   %�״��ڿռ�ֱ������ϵ�е�λ��


B1 = TargetLatitude * pi / 180.0;    %Ŀ���ڿռ��������е�λ�� γ��
L1 = TargetLongitude * pi / 180.0; %Ŀ���ڿռ��������е�λ�� ����
H1 = TargetHeight;  %Ŀ���ڿռ��������е�λ�� �߶�

N1 = a ./ sqrt(1 - e * e .* sin(B1) .* sin(B1)); %Ŀ������λ�õ�î�����ʰ뾶

X1 = (N1 + H1) .* cos(B1) .* cos(L1);    %Ŀ���ڿռ�ֱ������ϵ�е�λ��
Y1 = (N1 + H1) .* cos(B1) .* sin(L1);   %Ŀ���ڿռ�ֱ������ϵ�е�λ��
Z1 = (N1 .* (1 - e * e) + H1) .* sin(B1);    %Ŀ���ڿռ�ֱ������ϵ�е�λ��


%�����״���Ŀ��֮������
dX = X1 - X0;
dY = Y1 - Y0;
dZ = Z1 - Z0;

%��������任�����ռ�ֱ������ϵ�任Ϊ���״�����λ�õľֲ�ֱ������ϵ
%ת������Ϊ��������ز���ѧ����48ҳ
X = (-sin(B0) * cos(L0) * dX) + (-sin(B0) * sin(L0) * dY) + (cos(B0) * dZ);
Y = (-sin(L0) * dX) + (cos(L0) * dY);
Z = (cos(B0) * cos(L0) * dX) + (cos(B0) * sin(L0) * dY) + (sin(B0) * dZ);

TargetDistance = sqrt(X .* X + Y .* Y + Z .* Z); %����Ŀ��������״��ֱ�߾��루�ף�
TargetAzimuth = atan2(Y, X) / pi * 180.0; %����Ŀ��������״�ķ�λ���ȣ�
TargetElevation = atan2(Z, sqrt(X .* X + Y .* Y)) / pi * 180.0;  %����Ŀ��������״�����ǣ��ȣ�

%����Ҫ����λת�����״�����ϵ�еķ�λ
TargetAzimuth=mod(TargetAzimuth,360);





