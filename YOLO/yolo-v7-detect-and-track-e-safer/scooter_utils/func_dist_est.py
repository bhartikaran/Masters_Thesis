def get_dist(c_x,c_y, cur_center_x):
    c_x = c_x - cur_center_x
    c_y = 532 - c_y
    # Distance estimation
    j,i,h,g,f,e,d,c,b,a = -3.103492082e+01, -2.02981791e-05, 6.54262946e-01, 1.20613322e-04, 3.64400439e-07, -4.50008794e-03, 1.59938291e-10, -7.03918915e-07, -1.47357919e-09, 1.05897122e-05

    cur_dist = j+i*c_x+h*c_y+g*c_x**2+f*c_x*c_y+e*c_y**2+d*c_x**3+c*c_x**2*c_y+b*c_x*c_y**2+a*c_y**3

    # Angle estimation
    j,i,h,g,f,e,d,c,b,a = -1.092687146e+01, 5.40406570e-01, 2.56590990e-01, -9.86280336e-05, -1.34638931e-03, -1.77258979e-03, -7.44276337e-07, 5.67775683e-07, 2.80064835e-06, 3.76623178e-06

    cur_angle = j+i*c_x+h*c_y+g*c_x**2+f*c_x*c_y+e*c_y**2+d*c_x**3+c*c_x**2*c_y+b*c_x*c_y**2+a*c_y**3

    if cur_dist < 0 or cur_dist > 10 or c_y > (532-150):
        cur_dist = float('inf')
        cur_angle = float('inf')
    return cur_dist, cur_angle

