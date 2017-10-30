function plotSurface(input, out, grid,titleS)
% Plot 3-d surface of non-spaced data

x = input(:,1);
y = input(:,2);
xlin = linspace(min(x),max(x),grid);
ylin = linspace(min(y),max(y),grid);
[Xg,Yg] = meshgrid(xlin,ylin);

f = scatteredInterpolant(x,y,out);
Zg = f(Xg,Yg);

%Plot Desired Surface
figure
mesh(Xg,Yg,Zg)
xlabel('x'); ylabel('y'); zlabel('z');
title(titleS);