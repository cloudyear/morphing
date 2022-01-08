clear all close all

%原图~目标图
%图片读入到矩阵
originG = imread('img0.png');
targetG = imread('img1.png');


%图片特征点，我是存到txt里面然后读取
originT =  load('doodles.txt');
targetT =  load('doodleapes.txt');
num = size(originT, 1);
%三角剖分
TRI = delaunay(originT(: , 1), originT(: , 2));
%中间图的特征点
medT = zeros(num, 2);

P = 0.1 : 0.05 : 0.9;
for j = 1: 17
    %求出中间图特征点位置
    for i = 1: num
        medT(i, 1) = P(j)*(targetT(i, 1) - originT(i, 1)) + originT(i, 1);
        medT(i, 2) = P(j)*(targetT(i, 2) - originT(i, 2)) + originT(i, 2);
    end
    %先弄一个全零矩阵，用来存中间图每个像素点像素值
    medG = zeros(300, 300, 3);
    for x = 1: 300
        for y = 1: 300
            for k = 1: size(TRI, 1)
                mX = medT(TRI(k, :), 1);  %某个三角形3个定点的x值
                mY = medT(TRI(k, :), 2);
		%判断点是否在三角形内
                [IN, ON] = inpolygon(x, y, mX, mY);
                if ON == 1 || IN == 1
                    m0 = [mX, mY, ones(3, 1)]';
                    m1 = [originT(TRI(k, :), 1), originT(TRI(k, :), 2), ones(3, 1)]';  %向原图转换
                    tran1 = m1 * m0^-1;
                    pos1 = tran1 * [x; y; 1];
                    m2 = [targetT(TRI(k, :), 1), targetT(TRI(k, :), 2), ones(3, 1)]';  %向目标图转换
                    tran2 = m2 * m0^-1;
                    pos2 = tran2 * [x; y; 1];
                    
                    medG(x, y, :) = (1-P(j)) * originG(round(pos1(1,1)), round(pos1(2,1)), :) + P(j) * targetG(round(pos2(1,1)), round(pos2(2,1)), :);
                    break;
                end
            end
        end
    end
    
    %画图
    filename = ['./out/', num2str(j), '.jpg'];
    imwrite(uint8(medG), filename, 'jpg');
end
