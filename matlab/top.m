clear all;

% Constants
%%% ONLY MODIFIY THESE %%%
f = @(s) 1./(1+exp(-s));
fp = @(s) exp(s)./(exp(s)+1).^2;
wmax = 1;
wmin = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%

nu = 9;
nh = 20; 
ny = 1;
Qn = 4;
Qm = 4;
epochs = 1000;

% Setup the training vectors
%   {    Network Inputs        } Expected output 
T = [-1 -1  1 -1 -1  1 -1 -1  1  1;...
      1  1  1 -1 -1 -1 -1 -1 -1  1;...
      1  1  1  1  1 -1  1 -1 -1  1;...
      1  1  1 -1  1  1 -1 -1  1  1;...
      1 -1 -1  1 -1 -1  1 -1 -1  1;...
     -1 -1 -1 -1 -1 -1  1  1  1  1;...
     -1 -1  1 -1  1  1  1  1  1  1;...
      1 -1 -1  1  1 -1  1  1  1  1;...
      1  1  1  1  1  1  1  1  1  0;...
     -1 -1 -1 -1 -1 -1 -1 -1 -1  0;...
      0  0  0  0  0  0  0  0  0  0;...
      1  1  1  1 -1  1  1  1  1  0;...
     -1 -1 -1 -1  1 -1 -1 -1 -1  0;...
     -1 -1 -1 -1  0 -1 -1 -1 -1  0;...
      1  1  1  1  0  1  1  1  1  0;...
      0  0  0  0 -1  0  0  0  0  0;...
      0  0  0  0  1  0  0  0  0  0;...

     % Added these to get better results
     -1  0  0 -1  0  0 -1  0  0  1;...
      0 -1  0  0 -1  0  0 -1  0  1;...
      0  0 -1  0  0 -1  0  0 -1  1;...
     -1 -1 -1  0  0  0  0  0  0  1;...
      0  0  0 -1 -1 -1  0  0  0  1;...
      0  0  0  0  0  0 -1 -1 -1  1;...
      0  1  1  0  1  1  0  1  1  1;...
      1  0  1  1  0  1  1  0  1  1;...
      0  0  1  0  0  1  0  0  1  1;...
      0  0  0  1  1  1  1  1  1  1;...
      1  1  1  0  0  0  1  1  1  1;...
      1  1  1  1  1  1  0  0  0  1;...
      1  1  1  1  1  1  1  1  1  0;...
     -1 -1 -1 -1 -1 -1 -1 -1 -1  0;...
      0  0  0  0  0  0  0  0  0  0;...
      1  1  1  1 -1  1  1  1  1  0;...
     -1 -1 -1 -1  1 -1 -1 -1 -1  0;...
     -1 -1 -1 -1  0 -1 -1 -1 -1  0;...
      1  1  1  1  0  1  1  1  1  0;...
      0  0  0  0 -1  0  0  0  0  0;...
      0  0  0  0  1  0  0  0  0  0];

T = T';
T = T(:,randperm(size(T,2)));

% Create a new network
n = nnnew(nu,nh,ny,f,fp,wmax,wmin);

% Train the network
[n traininfo] = nnrbp(n,T,T,epochs);

% Plot the learning curve
plot(1:epochs,mean(traininfo{1}'));
xlabel('Epoch');
ylabel('MSE');
title('Training Error vs. Training Epoch (iteration)');

OldW = n.A.*n.W;
counter = 1;

for i = 1:1+nu+nh+ny
    for j = 1:1+nu+nh+ny
        a = OldW(i,j);
        if (a < 0)
            pos = 1;
        else 
            pos = 0;
        end
        d2b_num = fix(rem(fix(a)*pow2(-(Qn-1):0),2));
        d2b_dec = fix(rem( rem(a,1)*pow2(1:Qm),2));
        if (pos == 1)
            for x = 1:Qn
                if (d2b_num(x) == 0)
                    d2b_num(x) = 1;
                else 
                    d2b_num(x) = 0;
                end
                
                if (d2b_dec(x) == 0)
                    d2b_dec(x) = 1;
                else
                    d2b_dec(x) = 0;
                end
            end
        end
        s1 = num2str(pos);
        for QnnCounter = 1:length(d2b_num)
            s2 = num2str(d2b_num(1,QnnCounter));
            s1 = strcat(s1,s2);
        end
        for QmmCounter = 1:length(d2b_dec)
            s2 = num2str(d2b_num(1,QmmCounter));
            s1 = strcat(s1,s2);
        end
        s1 = string(s1);
        FinalW(counter,1) = s1;
        counter = counter + 1;
    end
end

% Write the weight matrix
%dlmwrite('W.dat',FinalW);
fileID = fopen('W.dat','wt');
for (total = 1:31*31)
    fprintf(fileID, '%s\n', FinalW(total));
end
fclose(fileID);

% Try it out on the images
files = {'test1.txt' 'test2.txt' 'test3.txt' 'test4.txt'};
figure;
for file=1:4,
  imin = load(files{file});
  imin = (imin-mean(imin(:)))*75/std(imin(:))+128;
  imin = 2.0*(imin/255.0-0.5);
  G = im2col(imin',[3 3],'sliding');
  imout = zeros(1,size(G,2));
  for i=1:size(G,2),
    n = nneval(n,G(:,i));
    imout(i) = round(n.x(n.nx));
  end
  imout = reshape(imout,size(imin,1)-2,size(imin,2)-2)';
  subplot(4,3,(file-1)*3+1);
  imshow(mat2gray((imin+1.0)*255.0/2.0));
  title('Original');
  subplot(4,3,(file-1)*3+2);
  imshow(mat2gray((imout+1.0)*255.0/2.0));
  title('Neural Network');
  subplot(4,3,(file-1)*3+3);
  imshow(edge(mat2gray((imin+1.0)*255.0/2.0),'sobel'));
  title('Sobel');
end

