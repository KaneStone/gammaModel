function constants = awconstants(aw)
    for i = 1:length(aw)
       if aw(i) <= .05 
          constants.a1(i) = 12.37208932;
          constants.b1(i) = -0.16125516114;
          constants.c1(i) = -30.490657554;
          constants.d1(i) = -2.1133114241;
          constants.a2(i) = 13.455394705;
          constants.b2(i) = -0.1921312255;
          constants.c2(i) = -34.285174607;
          constants.d2(i) = -1.7620073078;
       elseif aw(i) > .05 && aw(i) < .85
          constants.a1(i) = 11.820654354;
          constants.b1(i) = -0.20786404244;
          constants.c1(i) = -4.807306373;
          constants.d1(i) = -5.1727540348;
          constants.a2(i) = 12.891938068;
          constants.b2(i) = -0.23233847708;
          constants.c2(i) = -6.4261237757;
          constants.d2(i) = -4.9005471319;
       else
          constants.a1(i) = -180.06541028;
          constants.b1(i) = -0.38601102592;
          constants.c1(i) = -93.317846778;
          constants.d1(i) = 273.88132245;
          constants.a2(i) = -176.95814097;
          constants.b2(i) = -0.36257048154;
          constants.c2(i) = -90.469744201;
          constants.d2(i) = 267.45509988;
       
       end
    end
end