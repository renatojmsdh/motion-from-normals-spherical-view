function T = load_trajectory(filename)
temp = load(filename);

T = [];

for i = 1 : size(temp,1)
    Ttemp = [reshape(temp(i,1:12),[4 3])'; 0 0 0 1];
    T = [T ;  Ttemp(:)'];
end