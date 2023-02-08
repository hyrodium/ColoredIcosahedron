global_settings{assumed_gamma 1.0}

#macro smootha(a)
    #if(a>0)
        #local b=exp(-1/a);
    #else
        #local b=0;
    #end
    b
#end

#macro usmooth(a,b,s)
    smootha((2/sqrt(3))*((s-a)/(b-a)))/(smootha((2/sqrt(3))*((s-a)/(b-a)))+smootha((2/sqrt(3))*(1-(s-a)/(b-a))))
#end

#macro rotation(vec, theta)
    #local U = vec.x;
    #local V = vec.y;
    #local W = vec.z;
    #local s = sin(theta);
    #local c = cos(theta);

    #local r11 = U*U + (1-U*U)*c;
    #local r12 = U*V*(1-c) - W*s;
    #local r13 = U*W*(1-c) + V*s;

    #local r21 = U*V*(1-c) + W*s;
    #local r22 = V*V + (1-V*V)*c;
    #local r23 = V*W*(1-c) - U*s;

    #local r31 = U*W*(1-c) - V*s;
    #local r32 = V*W*(1-c) + U*s;
    #local r33 = W*W + (1-W*W)*c;

    matrix <r11, r12, r13,
            r21, r22, r23,
            r31, r32, r33,
            0  , 0  , 0  >
#end


#declare Time = 9*clock;
#declare phi = (1+sqrt(5))/2;
#declare p1 = <1,0,-phi>;
#declare p2 = <0,-phi,-1>;
#declare p3 = <-phi,-1,0>;
#declare p4 = <-phi,1,0>;
#declare p5 = <0,phi,1>;
#declare p6 = <1,0,phi>;

#declare T1 = usmooth(0,1,Time);
#declare T2 = usmooth(1,2,Time);
#declare T3 = usmooth(2,3,Time);
#declare T4 = usmooth(3,4,Time);
#declare T5 = usmooth(4,5,Time);
#declare T6 = usmooth(5,6,Time);
#declare T7 = usmooth(6,7,Time);
#declare T8 = usmooth(7,8,Time);
#declare T9 = usmooth(8,9,Time);
#declare S0 = usmooth(5,8,Time);

#declare Lng=35+180*T5+180*S0;
#declare Lat=25;
#declare Tilt=0;
#declare Pers=0.2;
#declare Zoom=0.4;
#declare LookAt=<0,0,-phi*(1-(T1+T9))>;

#macro SCS(lng,lat) <cos(radians(lat))*cos(radians(lng)),cos(radians(lat))*sin(radians(lng)),sin(radians(lat))> #end
#declare AspectRatio=image_width/image_height;
#declare Z=SCS(Lng,Lat);
#declare X=vaxis_rotate(<-sin(radians(Lng)),cos(radians(Lng)),0>,Z,Tilt);
#declare Y=vcross(Z,X);
#if(Pers)
    #declare Loc=LookAt+SCS(Lng,Lat)/(Zoom*Pers);
    camera{
        perspective
        location Loc
        right -2*X*sqrt(AspectRatio)/Zoom
        up 2*Y/(sqrt(AspectRatio)*Zoom)
        direction Z/(Zoom*Pers)
        sky Y
        look_at LookAt
    }
    light_source{
        Loc
        color rgb<1,1,1>
    }
#else
    #declare Loc=SCS(Lng,Lat);
    camera{
        orthographic
        location Loc*100
        right -2*X*sqrt(AspectRatio)/Zoom
        up 2*Y/(sqrt(AspectRatio)*Zoom)
        sky Y
        look_at LookAt
    }
    light_source{
        SCS(Lng,Lat)
        color rgb<1,1,1>
        parallel
        point_at 0
    }
#end
background{rgb<1,1,1>}

#declare N=100;
#declare r=0.08;
#declare R=(1+0.5*(T2-T8))*r;

#declare c1 = rgb<0.8,0.2,0.0>;
#declare c2 = rgb<0.2,0.8,0.0>;
#declare c_blue = rgb<0.1,0.3,1>;
#declare c_yellow = rgb<0.8,0.9,0.1>;
#declare c_white = rgb<0.8,0.8,0.8>;

#declare a=T9;
#declare b=T1;

#macro p(w)
    #if (w<1/5)
        #declare k = 5*w;
        #declare q = k*p2+(1-k)*p1;
    #elseif (w<2/5)
        #declare k = 5*w-1;
        #declare q = k*p3+(1-k)*p2;
    #elseif (w<3/5)
        #declare k = 5*w-2;
        #declare q = k*p4+(1-k)*p3;
    #elseif (w<4/5)
        #declare k = 5*w-3;
        #declare q = k*p5+(1-k)*p4;
    #else
        #declare k = 5*w-4;
        #declare q = k*p6+(1-k)*p5;
    #end
    (T2-T8)*q + (1-(T2-T8))*<cos(-2*pi*w),sin(-2*pi*w),phi*(w-1/2)*2>
#end

#declare helix = union{
    sphere_sweep {
        linear_spline
        N+1,
        #declare i=0;
        #while(i<N+1)
            p(a+i*(b-a)/N),r
            #declare i=i+1;
        #end
    }
    sphere{p(a), R}
    sphere{p(b), R}
};

#declare helix2 = union{
    object{helix}
    object{helix rotate z*180}
};
object{helix pigment{c_blue*(T2-T8)+c1*(1-(T2-T8))}}
object{helix rotate z*180 pigment{c_blue*(T2-T8)+c2*(1-(T2-T8))}}

#if (0 < T3-T7)
    object{helix2 pigment{c_blue*(1-(T3-T7))+c_yellow*(T3-T7)} rotation(<1,1,1>/sqrt(3), (T3-T7)*2*pi/3)}
#end
#if (0 < T4-T6)
    object{helix2 pigment{c_blue*(1-(T4-T6))+c_white*(T4-T6)} rotation(<1,1,1>/sqrt(3), -(T4-T6)*2*pi/3)}
#end
