function msk = skinColorTh(x)

r=x(:,:,1);
g=x(:,:,2);
b=x(:,:,3);
[k1,k2,k3] = size(x);
x=double(x);

msk = zeros(size(x,1),size(x,2));
parfor i=1:k1
    for j=1:k2
        r=x(i,j,1);
        g=x(i,j,2);
        b=x(i,j,3);
        m=max([r g b]);
        
        n=min([r g b]);
        
        if  ((r>95)&&(g>40)&&(b>20)&&((m-n)>15)&&(abs(r-g)>15)&&(r>g)&&(r>b))
            msk(i,j)=1;
        else
            msk(i,j)=0;
        end
    end
end

