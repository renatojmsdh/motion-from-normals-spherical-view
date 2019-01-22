function T = SE3(x)

A = [ppv(x(4:6)) x(1:3); 0 0 0 0];

%T = expm(A);
T = expmdemo1(A);
