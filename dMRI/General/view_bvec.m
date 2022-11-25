function view_bvec (bvec)

bvecs = load (bvec);
figure ('position', [100 100 500 500]);
plot3 (bvecs(1,:), bvecs(2,:), bvecs(3,:), '*r');
axis ([-1 1 -1 1 -1 1]);
axis vis3d;
rotate3d