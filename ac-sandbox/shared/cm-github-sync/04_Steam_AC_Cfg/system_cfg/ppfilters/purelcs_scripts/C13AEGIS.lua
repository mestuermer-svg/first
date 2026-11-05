
    dofile(ac.getFolder(ac.FolderID.PPFilters).."\\purelcs_scripts\\C13AEGIS_functions.lua")

    local _l_Fov_based_LUT = {
        -- 0 FOV    1 GodrayLength  2 fovCBEadaption
            {0.5,      2,               8.0},
            {10,       2,               4.0},
            {20,       2,               2.4},
            {30,       3,               2.0},
            {40,       4,               1.8},
            {50,       5,               1.6},
            {60,       6,              1.4},
            {70,       7,              1.4},
            {80,       8,              1.4},
            {100,      8,              1.4}
            
        }

        local _l_Fov_based_result
    local _l_fovCPP = LUT:new(_l_Fov_based_LUT)

    --[[local c13_l_exposure_LUT = {
        --  exposure
            { 0.00,   0.04 },
            { 0.0001,   0.04 },
            { 0.0005,    0.045 },
            { 0.001,   0.05 },
            { 0.002,   0.065 },
            { 0.003,   0.075 },
            { 0.005,   0.078 },
            { 0.009,   0.08 },
            { 0.01,   0.09 },
            { 0.015,    0.1 },
            { 0.017,   0.12 },
            { 0.027,   0.125 },
            { 0.037,   0.128 },
            { 0.05,   0.13 },
            { 0.09,   0.17 },
            { 0.1,   0.18 },
            { 0.15,   0.19 },
            { 0.2,   0.2 }
        }

    local cbe = 0
    local c13_l_exposure_result
    local c13_l_ExposureCPP = LUT:new(c13_l_exposure_LUT)
    -- initialize with a standard day exposure]]
    

    local _l_MappingLUT = {
        {
        --[[0-preset]]1,
        --[[1-m]]0.4205,
        --[[2-mH]]0.342,
        --[[3-s]]1.3282320933,
        --[[4-sH]]1.32306,
        --[[5-g]]0.0015,
        --[[6-gH]]0.0002,
        --[[7-d]]1,
        --[[8-dH]]0.6,
        --[[9-c]]1.450135,
        --[[10-cH]]1.356,
        --[[11-t]]0.00,
        --[[12-tH]]0.00,
        --[[13-b]]0,
        --[[14-bH]]0,
        --[[15-c1]]0.0,
        --[[16-c1H]]1.4,
        --[[17-tBrightness]]0.8,
        --[[18-tBrightnessH]]1
        },
        {
            --[[0-preset]]2,
            --[[1-m]]1,
            --[[2-mH]]0.8,
            --[[3-s]]1.3,
            --[[4-sH]]1.0,
            --[[5-g]]0.00,
            --[[6-gH]]0.0,
            --[[7-d]]1,
            --[[8-dH]]1,
            --[[9-c]]1.31,
            --[[10-cH]]1.31,
            --[[11-t]]0.0,
            --[[12-tH]]0.0,
            --[[13-b]]0.0,
            --[[14-bH]]0.0,
            --[[15-c1]]-0.1,
            --[[16-c1H]]0,
            --[[17-tBrightness]]1.0,
            --[[18-tBrightnessH]]1.0
            },
        {
        --[[0-preset]]3,
            --[[1-m]]0.1387017,
            --[[2-mH]]0.5,
            --[[3-s]]1.543380933,
            --[[4-sH]]1.4,
            --[[5-g]]0.007,
            --[[6-gH]]0.002,
            --[[7-d]]1.01,
            --[[8-dH]]1,
            --[[9-c]]2.0,
            --[[10-cH]]1.66,
            --[[11-t]]0.0,
            --[[12-tH]]0.0,
            --[[13-b]]0.0,
            --[[14-bH]]0.0,
            --[[15-c1]]-0.2,
            --[[16-c1H]]1.4,
            --[[17-tBrightness]]0.8,
            --[[18-tBrightnessH]]1.2
        },
        {
            --[[0-preset]]4,
            --[[1-m]]0.8,
            --[[2-mH]]0.2,
            --[[3-s]]1.415,
            --[[4-sH]]1.415,
            --[[5-g]]0.0,
            --[[6-gH]]0.00,
            --[[7-d]]1,
            --[[8-dH]]1,
            --[[9-c]]1.7,
            --[[10-cH]]1.9,
            --[[11-t]]0.0,
            --[[12-tH]]0.0,
            --[[13-b]]0.0,
            --[[14-bH]]0.00,
            --[[15-c1]]-0.2,
            --[[16-c1H]]1.4,
            --[[17-tBrightness]]1.2,
            --[[18-tBrightnessH]]1.4
            },
        {
            --[[0-preset]]5,
            --[[1-m]]1,
            --[[2-mH]]0.8,
            --[[3-s]]1.3,
            --[[4-sH]]1.0,
            --[[5-g]]0.00,
            --[[6-gH]]0.0,
            --[[7-d]]1,
            --[[8-dH]]1,
            --[[9-c]]1.31,
            --[[10-cH]]1.31,
            --[[11-t]]0.0,
            --[[12-tH]]0.0,
            --[[13-b]]0.0,
            --[[14-bH]]0.0,
            --[[15-c1]]0,
            --[[16-c1H]]0,
            --[[17-tBrightness]]1.0,
            --[[18-tBrightnessH]]1.3
            },
            {
                --[[0-preset]]6,
                --[[1-m]]0.52405,
                --[[2-mH]]0.342,
                --[[3-s]]1.573320933,
                --[[4-sH]]1.206,
                --[[5-g]]0.0025,
                --[[6-gH]]0.0002,
                --[[7-d]]1,
                --[[8-dH]]1,
                --[[9-c]]1.7035,
                --[[10-cH]]1.356,
                --[[11-t]]0.06,
                --[[12-tH]]0.0,
                --[[13-b]]0.2,
                --[[14-bH]]0,
                --[[15-c1]]0.10,
                --[[16-c1H]]1.4,
                --[[17-tBrightness]]2,
                --[[18-tBrightnessH]]2
                }
    }

    local _l_MappingLUTResult
    local _l_MappingLUTCPP = LUT:new(_l_MappingLUT)



    local _l_colorFade_LUT = {
        -- 0 normalizedCBE    1 fadeFactor  2 redFade       3GreenFade          4BlueFade           5cgintensity   6redTint   7greentint    8bluetint  9WB
            {0,             15,               0.01,               0.015,             0.202,             1,            0,       0.0,      -0.0,         6500},
            {0.5,           15,               0.01,               0.015,             0.202,             1,            0,       0.0,      -0.0,         6500},
            {0.7,           10,                0.0,               0.012,             0.103,           1,             0,       0.0,     0.00,         6600},
            {0.9,             5,             0.00,              0.015,               0.104,           1,             0,       0.0,     0.00,         7000},
            {1,             5,             0.00,              0.015,                 0.104,             1,            0,       0.0,       0.00,     7000},
            {2,             0,             0.00,              0.0,                   0.0,                0,          0,       0.0,       0.00,      6400}
        }


            local _l_colorFade_LUT_result
            local _l_fadeCPP = LUT:new(_l_colorFade_LUT)

        
            
            local filterFade = ac.ColorCorrectionFadeRgb { color = rgb(0,0,0), effectRation = 1}
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filterFade
        
            local ColorWheel = ac.ColorCorrectionModulationRgb { color = rgb(1,1,1) }
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = ColorWheel

            local filterBias = ac.ColorCorrectionBias { value=0 }
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filterBias


            local _l_FilmStockLUT = {
                -- 0Preset    1R          2G            3B         4T          5L      6C         7Sepia 8H    9Sat   10Fr    11Fg     12Fb   13Fr   
                    {0,      1.07,       1.08,     1.0,          6800,        1,      1.02,        0.07,  0,    1,     0.1,     0.13,      0.2,   0.01    }
                }

            local _l_FilmStockLUT_result
            local _l_FilmStockCPP = LUT:new(_l_FilmStockLUT)
            local _l_FilterProfile_LUT_result
            
            --1
            local _l_neutral_LUT = {
                -- 0 normalizedCBE    1R          2G            3B         4T          5L      6C         7Sepia 8H    9Sat   10Fr    11Fg     12Fb   13Fr   
                    {0,               1,          1,           1,           6450,       1,      1,         0,     0,       1,     0,      0,      0,      0   },
                    {1,               1,          1,           1,           6650,       1.2,    1,         0,     0,       1,     0,      0,      0,      0   }
                }
            
            local _l_neutral_CPP = LUT:new(_l_neutral_LUT)

            --2
            local _l_WarmFilmicLUT = {
                -- 0 normalizedCBE    1R          2G            3B         4T          5L      6C      7Sepia  8H    9Sat   10Fr    11Fg     12Fb   13Fr   
                    {0,             0.5,      0.6,          0.92,      4200,          2,   1.01,       0,     0,     1,     0,      0.3,      0.2,   0.01   },
                    {1,             0.5,      0.6,          0.92,      4100,          2,   1.002,      0.1,   0,     1,    0.1,     0.1,      0,      0.1   },
                }
            local _l_WarmFilmic_CPP = LUT:new(_l_WarmFilmicLUT)

            --3
            local _l_cool_LUT = {
                -- 0 normalizedCBE    1R          2G            3B         4T          5L      6C         7Sepia 8H    9Sat   10Fr    11Fg     12Fb   13Fr   
                    {0,               0.97,      0.97,          0.98,    7000,         1,    1.005,      0.1,    0,      1,     0,      0,      0,      0   },
                    {1,               0.97,      0.97,          0.98,    7000,         0.95, 1.002,      0.1,    0,      1,     0,      0,      0,      0   }
                }
            
            local _l_cool_CPP = LUT:new(_l_cool_LUT)

            --4
            local _l_Csepia_LUT = {
                -- 0 normalizedCBE    1R          2G            3B         4T          5L      6C         7Sepia 8H    9Sat   10Fr    11Fg     12Fb   13Fr   
                    {0,               0.4,      0.45,          0.7,      3500,          3,   0.999,      1.3,   187,     4,     0,      0,      0,      0   }
                }
            
            local _l_Csepia_CPP = LUT:new(_l_Csepia_LUT)

            --5
            local _l_NFS_LUT = {
                -- 0 normalizedCBE    1R          2G            3B         4T          5L      6C         7Sepia     8H    9Sat   10Fr    11Fg     12Fb       13Fr   
                    {0,             0.72,       0.85,          0.9,      5700,         1.3,   1.01,          0.15,    0,  0.9,    0.31,  0.1,   0.1,     0.06},
                    {1,             0.7,       0.75,          0.8,        6700,           2,   1.0004,           0.1,     0,    0.95,    0,    0.15,   0.2,    0.015}
                }
            
            local _l_NFS_CPP = LUT:new(_l_NFS_LUT)

            local _l_WarmLUT = {
                -- 0 normalizedCBE    1R          2G            3B         4T          5L      6C      7Sepia  8H    9Sat   10Fr    11Fg     12Fb   13Fr   
                    {0,              0.98,      0.97,          0.97,      5700,        0.9,   1.01,       0,     0,     1,    0.1,      0,      0,   0.01   },
                    {1,              0.98,      0.97,          0.97,      5400,        1.6,   1.002,      0.1,   0,     1,    0.1,     0,      0,      0.1   },
                }
            local _l_Warm_CPP = LUT:new(_l_WarmLUT)

                
                            

            
            local FilmSat = ac.ColorCorrectionSaturation { value = 1 }
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = FilmSat

            local filmSepia = ac.ColorCorrectionSepiaTone { value = 0}
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filmSepia

            local filmHUE = ac.ColorCorrectionHue { hue = 0, keepLuminance = 1 }
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filmHUE


            


            local filmTint = ac.ColorCorrectionModulationRgb { color = rgb(1,1,1)}
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filmTint

                                                
            local filmContrast = ac.ColorCorrectionContrast { value = 0.99 }
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filmContrast

            local filmWB = ac.ColorCorrectionTemperature { temperature = 4500, luminance = 2 }
            ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filmWB


        local glarePreset=1
        local dashcam = false

        local milkyT=0
        local milkyB=0
        local milkyC = 0
        --local milkyS = 0

       
        --C13AEGIS GT mapping
        local tonemap_c13 = {
                     values = {
                     method = 1,
                     hsv = false,
                     a = 0,
                     z = 1,
                     c = 1.7,
                     d = 1,
                     d1 = 0,
                     m = 0.2,
                     s = 1.34,
                     b = 0.0,
                     c1 = 1.4,
                     g = 0,
                     t = -2,
                     s1 = 1.25,
                     tBrightness = 1,
                     decomp1 = 0,
                     decomp2 = 0,
                     decomp3 = 0,
                     satClamp = 0.97,
                     exposureMod = 0,
                     colordepth = 0,
                     grain = 0,
                     resx = 100,
                     resy = 100,
                     staticNoise = false,
                     

                     DisplayPeak = 470, -- multiplier based on display peak cd/m2
                     SceneLuminance= 6000, -- scene luminance - could be sampled from yebis, or from CBE - essentially having this be dynamic would allow to use tonemapping as AE
                     bias=0.7
 

                   },
           
                   shader= [[        

                   float Epsilon = 1e-10;


                   float3 HUEtoRGB(in float H)
           {
               float R = abs(H * 6 - 3) - 1;
               float G = 2 - abs(H * 6 - 2);
               float B = 2 - abs(H * 6 - 4);
               return saturate(float3(R,G,B));
           }
          float3 RGBtoHCV(float3 RGB)
          {
              // Based on work by Sam Hocevar and Emil Persson
              float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
              float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
              float C = Q.x - min(Q.w, Q.y);
              float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
              return float3(H, C, Q.x);
          }
        
        float3 RGBtoHSV(in float3 RGB)
           {
               float3 HCV = RGBtoHCV(RGB);
               float S = HCV.y / (HCV.z + Epsilon);
               return float3(HCV.x, S, HCV.z);
           }
          float3 HSVtoRGB(in float3 HSV)
           {
               float3 RGB = HUEtoRGB(HSV.x);
               return ((RGB - 1) * HSV.y + 1) * HSV.z;
           }
           float3 RGBtoHSL(in float3 RGB)
           {
               float3 HCV = RGBtoHCV(RGB);
               float L = HCV.z - HCV.y * 0.5;
               float S = HCV.y / (1 - abs(L * 2 - 1) + Epsilon);
               return float3(HCV.x, S, L);
           }
           float3 HSLtoRGB(in float3 HSL)
           {
               float3 RGB = HUEtoRGB(HSL.x);
               float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
               return (RGB - 0.5) * C + HSL.z;
           }

         

         float C13Tonemapper(float x)
        {
            //float c = 1.8;
            //float d = 1;
            //float m = 0.2;
            //float s = 1.34;
            //float b = 0.0;
            //float g = 0.005;
            x = x * tBrightness;

            float color = ((pow(abs(x+b),c) + pow(abs(x+b),c-d)*(x))+g)/(s*pow(abs(x+b),c-d)*s*pow(abs(x+b),d)+m)+t;      
            return color;      
        }
        
         float C13TonemapperMod(float x)
        {
            //float c = 1.8;
            //float d = 1;
            //float m = 0.2;
            //float s = 1.34;
            //float b = 0.0;
            //float g = 0.005;
            //x = x * tBrightness;

            float color = (pow(abs(s*(x+b)),c)+g)/(s*pow(abs(x+b),c-d)*s*pow(abs(x+b),d)+m)+t;      

           

            return color;      
        }

        float C13TonemapperSat(float x)
        {
            //float c1 = 1.2;
            float d1 = -0.57;
            float m1 = 0.52;
            float s1 = 1.21;
            float b1 = 0;
            float g1 = 0;
            

            float color = ((pow(abs(x+b1),c1) + pow(abs(x+b1),c1-d1)*(x))+g1)/(s1*pow(abs(x+b1),c1-d1)*s1*pow(abs(x+b1),d1)+m1);

            

            return saturate(color);      
        }

        

        float C13TonemapperSat2(float x)
        {
            float c2 = 1.5;
            float d1 = 1;
            float m1 = 0.88;
            float s1 = 1.23;
            float b1 = 0;
            float g1 = 0;
            

            float color = ((pow(abs(x+b1),c2) + pow(abs(x+b1),c2-d1)*(x))+g1)/(s1*pow(abs(x+b1),c2-d1)*s1*pow(abs(x+b1),d1)+m1);
            return saturate(color);      
        }

        float3 drago(float3 x){
            return ((DisplayPeak * 0.01)/log10(SceneLuminance +1)) * (log10(x+1)/(log10(2+(pow(max(0,x/SceneLuminance),(log10(bias)/log10(0.5)))*8))));
        }
        float dragoSingle(float x){
            return ((DisplayPeak * 0.01)/log10(SceneLuminance +1)) * (log10(x+1)/(log10(2+(pow(max(0,x/SceneLuminance),(log10(bias)/log10(0.5)))*8))));
        }

             
        static const float3x3 C13SpaceInput = {
            {0.9,0,0},
            {0.02,0.9,-0.01},
            {0,0.013,0.9}
        };
        static const float3x3 C13SpaceOutput = {
            {1,-0.025,-0.01},
            {-0.028,1,-0.005},
            {0,-0.022,1}
        };

        

       
      

        float3 BoostGreenAndYellowSaturation(float3 color, float saturationBoost)
        {
            saturationBoost = saturationBoost * (1-exposureMod);
            // Convert the color from RGB to HSV
            float3 hsv = RGBtoHSV(color);
        
            // Define the hue ranges for green, yellow, and grassy green
            float greenMinHue = 60.0 / 360.0; // Green starts at 60 degrees
            float yellowMinHue = 60.0 / 360.0; // Yellow starts at 60 degrees
            float yellowMaxHue = 120.0 / 360.0; // Yellow ends at 120 degrees
            float grassyGreenHue = 90.0 / 360.0; // Grassy green center
            float hueSpread = 60.0 / 360.0; // Adjust the spread of the hue bell curve
            float targetSaturation = 0.5; // Target saturation value for the saturation bell curve
            float saturationSpread = 0.4; // Adjust the spread of the saturation bell curve
        
            // Calculate the weight based on the distance from the grassy green hue
            float hueDistance = abs(hsv.x - grassyGreenHue);
            float hueWeight = exp(-(hueDistance * hueDistance) / (2.0 * hueSpread * hueSpread));
        
            // Calculate the weight based on the distance from the target saturation
            float saturationDistance = abs(hsv.y - targetSaturation);
            float saturationWeight = exp(-(saturationDistance * saturationDistance) / (2.0 * saturationSpread * saturationSpread));
        
            // Combine the weights
            float combinedWeight = hueWeight * saturationWeight;
        
            // Boost saturation for green, yellow, and grassy green hues using the combined weight
            //if (hsv.x >= greenMinHue && hsv.x <= yellowMaxHue)
            //{
                // Calculate the saturation boost based on the original saturation and the combined weight
                float originalSaturation = hsv.y;
                float boostedSaturation = originalSaturation + saturationBoost * combinedWeight;
        
                // Clamp the boosted saturation to the valid range [0, 1]
                boostedSaturation = saturate(boostedSaturation);
        
                // Apply the boosted saturation
                hsv.y = clamp(boostedSaturation,0,satClamp);
            //}
        
            // Convert the modified HSV color back to RGB
            return HSVtoRGB(hsv);
        }
        
        

        float3 BoostHighLumaSaturation(float3 color, float target, float spread, float saturationBoost)
        {
            float3 hsv = RGBtoHSV(color);
        
            
            float targetLuma = target; //0; // Target saturation value for the saturation bell curve
            float lumaSpread = spread; //0.05; // Adjust the spread of the saturation bell curve
        
                    
            // Calculate the weight based on the distance from the target saturation
            float lumaDistance = abs(hsv.z - targetLuma);
            float lumaWeight = exp(-(lumaDistance * lumaDistance) / (2.0 * lumaSpread * lumaSpread));
            lumaWeight = lumaWeight * clamp(exposureMod,0.1,1);
                    
           
                // Calculate the saturation boost based on the original saturation and the combined weight
                float originalSaturation = hsv.y;
                float boostedSaturation = originalSaturation + saturationBoost * lumaWeight;
        
                // Clamp the boosted saturation to the valid range [0, 1]
                boostedSaturation = saturate(boostedSaturation);
        
                // Apply the boosted saturation
                hsv.y = clamp(boostedSaturation,0,satClamp);
            
        
            // Convert the modified HSV color back to RGB
            return HSVtoRGB(hsv);
        }

       float quantize(float colorValue,float n)
       {
        n=15+n;
        n= n*n;
        return round(colorValue*(n/255))*(255/n);
       }

       // Function to generate random noise
       float Random(float2 seed)
       {
           return frac(sin(dot(seed.xy, float2(18.9898, 78.233))) * 43758.5453);
       }

       float Random2(float2 seed)
       {
           return frac(sin(dot(seed.xy, float2(1, 2))) * 43758.5453);
       }

       
       
       // Function to add noise to a color with increased randomness
       float3 AddNoise(float3 color, float intensity,float2 uv)
       {   

        float hue = color.x;
        float sat = color.y;
        float val = color.z;// + 0.3 * intensity;

        // Generate random noise for the current pixel with an additional offset
        float noise = Random(float2(color.xz + sin(color.z) * 0.8));
        //float noiseVal = Random(float2(uv.xy + sin(color.x) * 0.8));
        float noiseVal = Random(float2(uv.xy + sin(color.y) * 0.8));
        
        if(staticNoise){
            intensity = intensity * 10;
        }

       
           // Scale and offset the noise to match the desired intensity
           noiseVal = clamp(noiseVal * intensity - intensity * (0.6 + (0.3*(1-val))), -1,1);
           float noiseSat = clamp(noise * intensity - intensity * 0.6,-0.5,0.5);

           float newVal = val + noiseVal;
           if(newVal>1){
            newVal = val;
           }
           
           // Add noise to each channel of the color
           //return color + float3(noise, noise, noise);
           return float3(hue+noiseVal,sat+noiseVal,newVal);
           return float3(hue, saturate(sat), newVal);
           //return float3(newHue, newSat, newVal);
       }

       float3 C13Map(float3 color,float2 uv)
       {
        
        //color = BoostHighLumaSaturation(color,0,0.05,-0.05);
        //color = BoostGreenAndYellowSaturation(color,0.1);
        
       
        //color = mul(C13SpaceInput, color);
           
           if(method == 1){
            
            
           color = float3(C13Tonemapper(color.x),C13Tonemapper(color.y),C13Tonemapper(color.z)).rgb;

           //float3 colorHSV = RGBtoHSV(color);
           //float hsvZ = saturate(colorHSV.z);
           //colorHSV.y = clamp(saturate((colorHSV.y + (C13TonemapperSat(hsvZ) - saturate(hsvZ)))),0,satClamp);
           

           //color = HSVtoRGB(colorHSV);
           
           }
           if(method == 2){

           

            color = drago(color);
           }
          
           //color = mul(C13SpaceOutput,color);
           

               // Clamp to [0, 1]
           color = saturate(color);

           if (grain>0){
            float3 colorHSV = RGBtoHSV(color);
            float grainIntensity = saturate(0.2-colorHSV.z);
            //colorHSV.z = clamp(colorHSV.z,0.0,2);
            //color = HSVtoRGB(colorHSV);
            colorHSV = AddNoise(colorHSV,0.25*grain,uv);
            color = HSVtoRGB(colorHSV);
           }
           if (colordepth>0){
            float3 colorHSV = RGBtoHSV(color);
            colorHSV.x = quantize(colorHSV.x,colordepth*2);
            colorHSV.y = quantize(colorHSV.y,colordepth);
            colorHSV.z = quantize(colorHSV.z,colordepth);
            color = HSVtoRGB(colorHSV);
            }
           return color;
       }

      

       //float3 main(float3 color)
       //{
                              
        //   return C13Map(color);
       //}

       float3 tonemapping(float3 x,float2 uv){
        return C13Map(x,uv);
    }
            ]],

                   cacheKey = 0
               }

               

 
    local CSP_VERSION = ac.getPatchVersionCode()
    local satHigh = 0.98
    local satlow = 0.8
    local colorProfile = 1
    local peakReflection = 1.7
    local NightSky = 1
    local gtMapping = false
    local mapFunction = 4

    local storedNoise = 1
    local storedNoiseVal = 1
    
function init_tonemapping()
    if CSP_VERSION >= 2349 then
        if gtMapping then
            if pure.pp.setCustomRGB_UV_Tonemapping then
                pure.pp.setCustomRGB_UV_Tonemapping(tonemap_c13) 
                ac.setPpTonemapUseHdrSpace(true)
                --mapFunction = pure.script.ui.getValue("Tone mapping function")
                --ac.debug("function","inittonemapping")
            else
               ac.setPpTonemapFunction(tonemap_c13)
            end
        end
    end
end

local luaFilterLink = ac.connect{
    ac.StructItem.key('C13CartoonLink'),
    lineThickness = ac.StructItem.double(),
    Pulse = ac.StructItem.boolean(),
}



-- This is called once while AC starts
function init_pure_script()

    pure.config.set("Scene.tunnel_sunlight_dimmer",false)
    pure.config.set("Scene.tunnel_ambilight_dimmer",false)

    
   
    pure.exposure.useCBE (true)
    pure.light.setSpectrumAdaption(false)
    pure.script.setVersion(2.05)
    pure.script.setAuthor("DasCiba @C13 Automotive")
    pure.script.resetSettingsWithNewVersion()
    pure.script.ui.addSeparator()


    pure.script.ui.addSliderFloat("Minimum ambient light",0.01,0.01,1)
   -- pure.script.ui.addSliderFloat("Screen brightness calibration", 0, -2, 2)
    --pure.script.ui.addSliderFloat("Digital vibrance adjust", 0, -1, 1)

    pure.script.ui.addSeparator()
    pure.script.ui.addRadioButtons("Night Sky Preset",NightSky,"Default,Bright,Astro photography")
    
    
    pure.script.ui.addSeparator()
    --pure.script.ui.addText("Color profiles:")
    --pure.script.ui.addText("1 - Natural | 2 - AEGIS | 3 - Warm Filmic | 4 - Cool | 5 - Color Sepia | 6 - NFS | 7 - Warm")
    --pure.script.ui.addSliderInteger("Color Profile",1,1,7,"You can use the scroll wheel to cycle through presets.")
    pure.script.ui.addRadioButtons("Color Profile",colorProfile,"Neutral,AEGIS,Warm Filmic,Cool,Color Sepia,NFS,Warm")
    pure.script.ui.addSeparator()
    
    pure.script.ui.addRadioButtons("Glare style",glarePreset,"C13 AEGIS spec,GT,Gentle,Lens Flare,Le Mans,Agressive,ARCADIUM,Horizon")
    --pure.script.ui.addText("Glare Presets:")
    --pure.script.ui.addText("1 - AEGIS spec. | 2 - GT style | 3 - Gentle | 4 - Lens flare heavy | 5 - Le Mans")
    --pure.script.ui.addText("2 - GT style")
    --pure.script.ui.addText("3 - Gentle      4 - Lens flare heavy")
    --pure.script.ui.addText("4 - Lens flare heavy")
    --pure.script.ui.addText("5 - Le Mans")
    --pure.script.ui.addSliderInteger("Glare style",1,1,5,"You can use the scroll wheel to cycle through presets.")

    pure.script.ui.addSeparator()

    pure.script.ui.addText("Advanced AE Control")
    pure.script.ui.addSliderFloat("AE Target", 1, 0.050, 3.00)
    pure.script.ui.addSliderFloat("Polarizing filter strength", 0, 0.000, 1.00)
    pure.script.ui.addCheckbox("Camera Style Exposure", false, "camera like exposure behaviour - more static with rapid changes")
    pure.script.ui.addCheckbox("Photo style brightness", false, "lower peak brightness at day")
    pure.script.ui.addCheckbox("Manual photo mode", false, "Enable this to overwrite exposure and manually controll brightness with the target slider")
    pure.script.ui.addSeparator()

    pure.script.ui.addText("Screen Calibration")
    --pure.script.ui.addSliderFloat("Midpoint brightness Day", 0, -1, 1,"Acts similar to gamma, but prevents clipping. Adjust for low exposure.")
    --pure.script.ui.addSliderFloat("Midpoint brightness Night", 0, -1, 1,"Acts similar to gamma, but prevents clipping Adjust for high exposure.")
    --pure.script.ui.addSliderFloat("Minimum Exposure", 0, -2, 2)
    --pure.script.ui.addSliderFloat("Maximum Exposure", 0, -2, 2)
    
    --pure.script.ui.addSliderInteger("Glare style",0,0,2)
    pure.script.ui.addSeparator()

    
    pure.script.ui.addText("User adjustments")
    pure.script.ui.addCheckbox("Power of the sun", true, "Enable this to boost the sun's power. Increases broadcast feeling.")
    pure.script.ui.addCheckbox("GADU spec godrays", false, "In honour of my friend who has supported and pushed me with my filter work longer than anyone else in this community, this is their flavor of intense godrays.")
    pure.script.ui.addCheckbox("Reflection tweak",true,"Forces CPL. Disable to allow photo app slider use.")
    
    --pure.script.ui.addCheckbox("HighSat mode",true,"Raises base saturation and mildly compresses modulation range")
    --pure.script.ui.addSliderFloat("fresnelGamma",1,0,100)
    --pure.script.ui.addSliderFloat("nearbyfogDistance",1,0,100)
    --pure.script.ui.addSliderFloat("nearbyfogheight",1,0,200)
    --pure.script.ui.addSliderFloat("nearbyfogTransparency",1,0,100)
    --pure.script.ui.addSliderFloat("skyTurbidity",1,0,10)


    pure.script.ui.addSeparator()
    pure.script.ui.addText("Special Efects")
    pure.script.ui.addCheckbox("Impact Vision",false)
    pure.script.ui.addCheckbox("Chase cam DOF",true)
    pure.script.ui.addSliderFloat("Crash effect strength multiplier",1,0.5,2,"Boost the intensity of driving effects")
    pure.script.ui.addSliderFloat("Maximum speed blur intensity adjustment",0,-1,1,"Maximum blur at highest speed")
    pure.script.ui.addSliderFloat("Low speed limit km/h",50,30,150,"Speed without DOF")
    pure.script.ui.addSliderFloat("High speed limit km/h",200,100,400,"Speed for max DOF")
    pure.script.ui.addText("")
    pure.script.ui.addCheckbox("Auto Film Grain",false)
    --pure.script.ui.addCheckbox("Static Film Grain",false)

   
   
    --pure.exposure.cbe.setAdaptionSpeeds(10,2)

    
    
   
    
    if CSP_VERSION >= 2349 then
        pure.script.ui.addSeparator()
        gtMapping = true
        pure.script.ui.addText("Chose function to affect final look.")
        pure.script.ui.addRadioButtons("Tone mapping function",mapFunction,"C13 Curve Filmic,C13 Curve Flat,C13 Filmic+,C13 Punchy")
        --pure.script.ui.addCheckbox("Allow extreme Overbright",false,"Allow more blinding when exiting tunnels")    
        --pure.script.ui.addSliderFloat("SatClamp",0.85,0.8,0.9)
        --pure.script.ui.addSliderFloat("decomp1",0,0,0.05)
        --pure.script.ui.addSliderFloat("decomp2",0,0,0.05)
        --pure.script.ui.addSliderFloat("decomp3",0,0,0.05)
        pure.script.ui.addSeparator()
        pure.script.ui.addText("Experimental style features")
        pure.script.ui.addSliderInteger("posterize",0,0,100,"Quantizes colors for a posterized effect.")
        pure.script.ui.addSliderFloat("Fake film grain",0,0,1,"Uses noise to fake film grain")
        pure.script.ui.addSliderFloat("Outline thickness",0,0,10,"If enabled, controls thickness of outlines by C13 Cartoon lua filter")
        pure.script.ui.addSliderFloat("CG LUT intensity",0,0,1,"Adjust intensity of external LUT grading")


        --pure.script.ui.addCheckbox("Fake film grain",false)
    pure.script.ui.addCheckbox("Filmic grading",false,"Changes tonemapping to provide milky blacks at high exposure.")
    
    end
    pure.script.ui.addCheckbox("Dashcam mode",false)
   
    
    pure.script.ui.addSeparator();
    pure.script.ui.addText("Reuse of any part of this script without permission is strictly prohibited.")
    pure.script.ui.addText("Copyright C13 Automotive 2023")

    pure.script.ui.addSeparator()

    pure.script.ui.addText("Current Exposure Calculation values")
    pure.script.ui.addStateFloat("CBE Exposure", 0)
    pure.script.ui.addStateFloat("Final Exposure", 0)

    pure.script.weather.addVariable("sunLevelWeather", 1)
    pure.script.weather.setVariable("sunLevelWeather", "ScatteredClouds", 1.0)
    pure.script.weather.setVariable("sunLevelWeather", "OvercastClouds", 0.8)
    pure.script.weather.setVariable("sunLevelWeather", "BrokenClouds", 1.0)
    pure.script.weather.setVariable("sunLevelWeather", "Sand", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Dust", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Fog", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Mist", 0.8)
    pure.script.weather.setVariable("sunLevelWeather", "Haze", 0.8)
    pure.script.weather.setVariable("sunLevelWeather", "LightDrizzle", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Drizzle", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "HeavyDrizzle", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "LightRain", 0.8)
    pure.script.weather.setVariable("sunLevelWeather", "Rain", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "HeavyRain", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Tornado", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Squalls", 0.8)
    pure.script.weather.setVariable("sunLevelWeather", "HeavyThunderstorm", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Thunderstorm", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "LightThunderstorm", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "LightSnow", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Snow", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "HeavySnow", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "LightSleet", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Sleet", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "HeavySleet", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Hurricane", 0.7)
    pure.script.weather.setVariable("sunLevelWeather", "Smoke", 0.6)
    pure.script.weather.setVariable("sunLevelWeather", "Windy", 0.9)


   
    

    

   
    init_tonemapping()

    if PUREPP__set_custom_PP then
        PUREPP__set_custom_PP(false)
      end
   

     



end

local _l_tmp_hsv = hsv(0,0,0)
local _l_tmp_rgb = rgb(0,0,0)
local baseGamma = 1
local starsBright = 200
local starsExponent = 3.5
local baseSaturation = 0.8
local FinalEXP = 0.35
local normalisedCBE = 0
local normalisedCBEcrossover = 0
local baseFilmicContrast = 0.4
local filmicContrastDrop = 0.1
local normalisedYebisAE = 0
local vecZero = vec2(0,0)
local vecTemp = vec2(0,0)
local mappingfactor = 1.3
local mappingboost = 0.5
--local baseGlareThreshold = 1
--local glareThresholdBoost = 5.6
local basebloomGamma = 1.2
local bloomGammaBoost = 0.2
--local baseBias = math.clamp(1 * (1- normalisedCBE),1,0.1)
--local BiasRatio = 1000
local baseFade = 0
local redFade = 0
local greenFade = 0
local blueFade = 0
local oledTarget = 1
local emissiveBootom = 1.5
local aeCrossoverPercentage = 0.6
--local PPbrightnessBoost = 0
--local extraBlueFade = 0
--local extraGreenFade = 0
--local extraRedFade = 0
local minFade = 0
local r = 1
local g = 1
local b = 1
local yebisLow = 0.01
local yebisLowModified = 0.01
local highAmbThreshold = 0
local highCBEThreshold = 0
local extremeHighCBEThreshold = 0
local yebisHigh = 1
local ybTarget = 0.01
local ybRelativeMiddle = 0.2
local expLow = 0.045
local expHigh = 0.4 
local crossoverBoostNormalized = 0
local AEadjust = 0
local LimitsAdjust = 0
--local glareThreshold = 2
--local bloomGamma = 1.2
local ambSat = 1
local emissiveDrop = 1
local fogBlue = 0
--local cloudblue = 0
local modulatedSunLevel = 1
local clampedSunLevel = 1
local skyLevel
--local overcast
local occluded = 1
local occluded2 = 1
local cloud_shadow = 0
local cloud_coverage = 0
local cgOff = false
--local baseBrightness = 1
--local basebrightnessNight = 1.4
local godraysRatio = 0.1
local godrayAttenuationDrop = 0
local godrayGlare = 0.02
local godrayLengthRatio = 1
--local DepthMapThreshold = 0.999978840



--local redTint = 1
--local greenTint = 1
--local blueTint = 1
--local fadeStrength = 0
--local WBBase = 6500
--local ColorSatBase = 1
--local baseBrightness = 1
--local colorHueBase = 0
--local colorContrasBase = 1
local ambientAwareTarget = 1
--local filmicCBoost = 0
--local filmicMLift = 0
--local filmicSBoost = 0
local dampenedCBEold = 0
local dampenedCBEnew = 0
local polarizer = 0
local sunBoost = 1
local isPowerOfTheSun = false

local MidpointBrightness = 0
--local tonemapGammaAdjust = 0

local ambientV2 = false
local MidpointBrightnessDay = 0
local MidpointBrightnessNight = 0
local clipDrop = 0
local clipKnee = 0

local fog
local fogOrBadness
local fogXORBadness
local amb
local badness

local occlusionX1 = vec3(1,0,0)
local occlusionX_1 =vec3(-1,0,0)

local fresnelGamma = 1
local skyAmbient = 0
local sunAmbient = 0
local cloudAmbient = 1




-- This is called every frame
function update_pure_script(dt)
    --ac.useLinearColorSpace(false)

    --ISOEmulation stuff
    mappingfactor = 1.5
    mappingboost = 0.5
    --baseGlareThreshold = 1.2 
    --glareThresholdBoost = 5.6
    basebloomGamma = 1.2
    bloomGammaBoost = 0
    --baseBias = math.clamp(1 * (1- normalisedCBE),1,0.1)
    BiasRatio = 1000
    baseFade = 0
    baseFilmicContrast = 0.4
    filmicContrastDrop = 0.16
    redFade = 0
    greenFade = 0
    blueFade = 0
    oledTarget = 1 --pure.script.ui.getValue("AE Target") 
    emissiveBootom = 1.7
    PPbrightnessBoost = 0
    baseSaturation = 0.95
    minFade = 0
    baseGamma = 1.25
    aeCrossoverPercentage = 1
    r = 1
    g = 1
    b = 1
    --pure.config.set("pp.brightness",2,true)
    cgOff = false
    --baseBrightness = 1
    --basebrightnessNight = 1.4
    --filmicCBoost = 0
    --filmicMLift = 0
    --filmicSBoost = 0
    godraysRatio = 0.1
    godrayAttenuationDrop = 0
    godrayGlare = 0.02
    godrayLengthRatio = 1
    local overcast = Pure_get_Overcast()
    overcast = math.saturateN(overcast/0.8)
    --ac.debug("overcast",overcast)
    --overcast = pure.world.getCloudCoverage()
    polarizer = 1 - pure.script.ui.getValue("Polarizing filter strength")

    NightSky = pure.script.ui.getValue("Night Sky Preset")

    milkyT=0.005
    milkyB=0
    --milkyC=1.55
    --milkyC=_l_MappingLUTResult[10]
    --milkyS= 1.3180933
    
    local CameraLikeExposure = pure.script.ui.getValue("Camera Style Exposure")
    

    --MidpointBrightnessDay =pure.script.ui.getValue("Midpoint brightness Day")
    --MidpointBrightnessNight= pure.script.ui.getValue("Midpoint brightness Night")
    MidpointBrightnessDay = 0--math.clamp(pure.script.ui.getValue("Screen brightness calibration")/4,-2,0.3)
    MidpointBrightnessNight = 0--pure.script.ui.getValue("Screen brightness calibration")
    if(dashcam) then -- injecting dashcam adjustment between the reading
        MidpointBrightnessDay = 0.3
        MidpointBrightnessNight = -4
        
    end
    MidpointBrightness = math.lerp(MidpointBrightnessDay,MidpointBrightnessNight,normalisedCBEcrossover)
    
    


    luaFilterLink.lineThickness = pure.script.ui.getValue("Outline thickness")
    luaFilterLink.Pulse = not luaFilterLink.Pulse

    


    

    if(pure.script.ui.getValue("GADU spec godrays")) then
        godraysRatio = 0.53
        godrayAttenuationDrop = 5
        godrayGlare = 0.02
        godrayLengthRatio = 0.6

      


    end
    pure.config.set("shaders.sunblinding.gain",0.15,true)
    pure.config.set("shaders.sunblinding.booster",2,true)
    --pure.config.set("shaders.sunblinding.cupemap_booster",false,true)
    

    pure.config.set("fog.far.blend",math.lerp(math.lerp(pure.mod.night(0.6),1,pure.world.getHumidity()),1.5,pure.world.getRainFX_Intensity()),true)
    
    colorProfile = pure.script.ui.getValue("Color Profile")
    if (colorProfile ~= 2) then
        cgOff = true
    end


   
    
    --if pure.script.ui.getValue("HighSat mode") then
        --baseSaturation = 0.94
       
    --end
    --ac.setPpBrightness(0.75)
    glareThreshold =  1
       
                pure.pp.setCustomRGBTonemapping(tonemap_c13) 
                ac.setPpTonemapUseHdrSpace(true)
                mapFunction = pure.script.ui.getValue("Tone mapping function")
                --ac.debug("function",mapFunction)
           
       
        baseGamma =math.clamp(0.87 + 0.2 * pure.config.get("pp.gamma"),1.01,1.5)
        --ac.debug("baseGamma",baseGamma)
        ac.setPpBrightness(0.9)
        
        satHigh = 0.93
        satlow = 0.8
        --if pure.script.ui.getValue("HighSat mode") then
            baseSaturation = 0.984
            satHigh = 1.00
            satlow = 0.78
          pure.config.set("pp.luma_saturation",1.05,true)
        --end
        basebloomGamma = 1.2
        bloomGammaBoost = 0
        --glareThreshold = 0.1 
         pure.config.set("pp.brightness",1,true)
          
    



    
        
    sunBoost = pure.mod.dayCurve(1,1.2,0.5)
    sunBoost = pure.mod.dayCurve(0.3,0.32,0.5)
    sunBoost = 0.1
 
  
    --basebrightnessNight = basebrightnessNight
    --local ppDayBrightness = baseBrightness 
    --local ppNightBrightness = basebrightnessNight
    --local ppBrightness = math.lerp(ppDayBrightness,ppNightBrightness,crossoverBoostNormalized)
    --pure.config.set("pp.brightness",ppBrightness,true)

    if pure.script.ui.getValue("Photo style brightness") then
        pure.config.set("pp.brightness",math.lerp(0.8,1,normalisedCBEcrossover),true)
    end
    --if pure.script.ui.getValue("Photo style brightness") and isPowerOfTheSun then
       --pure.config.set("pp.brightness",math.lerp(1.3,1.3,math.pow(normalisedCBEcrossover,0.5)),true)
   -- end

   

    

    filterBias.value =math.lerp(0.012,0.001,normalisedCBEcrossover)
    --ac.debug("bias",filterBias.value)
    filterFade.color = rgb(0,0,0)
    filterFade.effectRatio = 0

    -- WORLD AND GENERAL PP PARAMETERS
    cloud_shadow = math.max(Pure_get_Overcast() , Pure_get_CloudShadow()) --* occlusion
    --ac.debug("cloud_shadow",cloud_shadow)
    cloud_coverage = pure.world.getCloudCoverage()
    
    
    
    
    --AE PARAMETERS
    yebisLow = 0.1 
    yebisLowModified = yebisLow + 0.3 * normalisedCBEcrossover
    yebisHigh = 0.5
    ybTarget = 0.15 - 0.1 * math.pow(normalisedCBE,2)
    ybRelativeMiddle =  0.25 + 0.05 * normalisedCBEcrossover
    --expLow = math.max(0.001, (0.03 + 0.02 * pure.script.ui.getValue("Minimum Exposure"))/sunBoost)
    expLow = 0.04 - 0.01 *highCBEThreshold
    --expHigh = 0.75 + 0.25 * pure.script.ui.getValue("Maximum Exposure")
    expHigh = 0.2
    --ac.debug("ybTarget",ybTarget)

    _l_tmp_hsv = hsv(0,0,0)
    _l_tmp_rgb = rgb(0,0,0)
    
    if NightSky < 2 then
        --starsBright = 200
        --starsExponent = 10 + 10 * pure.mod.twilight(0)
    elseif NightSky < 3 then
        starsBright = 10000
        starsExponent = 5.8 + 5 * pure.mod.twilight(0)
        pure.stellar.setStarsBrightness(starsBright * (1-pure.mod.twilight(0)))
        ac.setSkyStarsExponent(starsExponent)
    else
        starsBright = math.clamp(pure.mod.nightCurve(90000,100,0.07),0,1000) --900 * (1- pure.mod.duskdawn(0)) 
        starsExponent = 2 + 5 * pure.mod.duskdawn(0)
        pure.stellar.setStarsBrightness(starsBright * (1-pure.mod.twilight(0)))
        ac.setSkyStarsExponent(starsExponent)
        --ac.debug("stars", starsBright * (1-pure.mod.twilight(0)))
    end


    
    
   
    --pure.stellar.setStarsBrightness(starsBright * (1-pure.mod.twilight(0)))
    --ac.setSkyStarsExponent(starsExponent)
    --ac.setSkyStarsMap("CrabNebula.dds")
    --ac.debug("dirname",ac.dirname())
    

    local AEcrossover = expHigh * aeCrossoverPercentage
    --ac.debug("AEcrossover",AEcrossover)
    --local modifiedexpLow = pure.mod.dayCurve(0.015,expLow,0.1)
    local modifiedexpLow = expLow
    amb = Pure_getColor(COLORS.AMBIENT) 
    occluded2 =  pure.camera.getOcclusion() --* normalisedCBE
    --occluded2 =  math.applyLag(occluded2,ac.getCameraOcclusion(vec3(1,0,0)),0.9,dt)
    occluded = math.applyLag(occluded2, (ac.getCameraOcclusion(occlusionX1) + ac.getCameraOcclusion(occlusionX_1))/2,0.95,dt)
    occluded = math.saturateN((occluded - 0.3)/0.7)
    --ac.debug("occluded",occluded)
    --ac.debug("occluded2",occluded2)
    local amb_lum = (amb:getLuminance() * math.pow(occluded,2))
    amb_lum = (amb:getLuminance() * math.lerp(math.pow(occluded,2),1,math.saturateN(-1*normalisedYebisAE)) / sunBoost)* math.pow(occluded,2)
    --ac.debug("occluded",occluded)
    --ac.debug("amb_lum",amb_lum)
    local amblumLimit=0.5
    --if (ambientV2) then
    --    amblumLimit = 20
    --end
    local normalizedAmb_Lum_inverted = math.pow((1 - math.min(amb_lum,amblumLimit)/amblumLimit),1)
    local exp_amblumI = math.pow(normalizedAmb_Lum_inverted,2)
    --ac.debug("normalizedAmb_Lum_inverted",normalizedAmb_Lum_inverted)
    local maxcbe =  math.max(0.1,ac.getCubemap360BrightnessEstimationMaximum())
    local mincbe =  ac.getCubemap360BrightnessEstimationMinimum()
    local avgcbe = math.max(0.1,ac.getCubemap360BrightnessEstimationAverage())
    --cbe = math.clamp(math.applyLag(cbe,0.001/ac.getCubemap360BrightnessEstimationAverage()+0.0001/ac.getCubemap360BrightnessEstimationMinimum(),0.97,dt),0,1)
    --ac.debug("cbe",cbe)
    dampenedCBEnew = math.max(0,math.min(((maxcbe-avgcbe)/avgcbe),1))
    dampenedCBEnew = dampen(dampenedCBEold,dampenedCBEnew,dt)
    dampenedCBEold = dampenedCBEnew
    --ac.debug("cbeThrs",dampenedCBEold)
    highAmbThreshold = math.min(math.max(0,(amb_lum)-4)/2,1)
    highCBEThreshold =  math.applyLag(highCBEThreshold, math.min(math.max(0,maxcbe-5),1),0.98,dt)
    --highCBEThreshold = math.max(highCBEThreshold,dampenedCBEold)
    extremeHighCBEThreshold =  math.applyLag(extremeHighCBEThreshold, math.clamp((maxcbe-20)/5,0,1),0.98,dt)
    extremeHighCBEThreshold = math.max(extremeHighCBEThreshold,0)
    
    --ac.debug("highCBEThreshold",highCBEThreshold)
    --ac.debug("extremeHighCBEThreshold",extremeHighCBEThreshold)
    --ac.debug("highAmbThreshold",highAmbThreshold)
    --ac.debug("maxcbe",maxcbe)
    --ac.debug("mincbe",mincbe)
    --ac.debug("avgcbe",ac.getCubemap360BrightnessEstimationAverage())

    
    
    --weather stuff
    badness = pure.world.getBadness() * pure.mod.twilight(0)
    fog = pure.world.getFog()
    fogOrBadness = math.max(fog,badness)
    --ac.debug("fogOrBadness",fogOrBadness)
    --ac.debug("Badness",badness)
    fogXORBadness = math.clamp(1-(1 - (badness + fog)),0,1)

    
    --reading the Fov for the godray and CBE LUT
    _l_Fov_based_result = _l_fovCPP:get(pure.camera.getFOV())
    
    --adjusting AE target based on ambient light
    --ac.debug("oldeTarget",oledTarget)
    local scriptTarget = oledTarget + 1 * (pure.script.ui.getValue("AE Target")-1)
    --ac.debug("scriptTarget",scriptTarget)

    --1.44 way
    --local targetModifyAmount = math.lerp(0.1 * highCBEThreshold + (0.1)  * highAmbThreshold + 0.1 * extremeHighCBEThreshold,math.clamp(0.4 * ambientAwareTarget,0,0.2) ,normalisedCBE)
    local targetModifyAmount = 0.2 + (0.1)  * highAmbThreshold
    --new
    --local targetModifyAmount = math.lerp(math.lerp((0.1 * highCBEThreshold + 0.1 * highAmbThreshold),0.3,normalisedCBEcrossover),math.clamp(0.1 * ambientAwareTarget,-0.1,0.1),normalisedCBE)
    --ac.debug("targetModifyAmount",targetModifyAmount)
    local targetAdjust = targetModifyAmount * normalisedYebisAE
    local lowTargetBracket = scriptTarget - targetModifyAmount
    local highTargetBracket = scriptTarget + targetModifyAmount
    local target = math.clamp(scriptTarget + targetAdjust + (0.1 *fogOrBadness),lowTargetBracket,highTargetBracket)

    local amblumTargetboost = 0.8 * normalizedAmb_Lum_inverted --* (0.2 + 1 * math.clamp(normalisedYebisAE,-1,0.5))
    --ac.debug("amblumTargetboost",amblumTargetboost)
    --local occludedTargetBoost = 0.8 * (1-occluded)
    local amblumTargetNerf = -3 * normalizedAmb_Lum_inverted * math.clamp(normalisedYebisAE,-1,0)* normalisedCBE

    local badnessTargetNerf = 0.4 * (badness) --* occluded

    
    ambientAwareTarget = math.clamp(target+amblumTargetboost-amblumTargetNerf - badnessTargetNerf,0.7,3)
    --pure.exposure.cbe.setAdaptionSpeeds(10,2)
    pure.exposure.cbe.setAdaptionSpeeds(5,1)
    if CameraLikeExposure then
        ambientAwareTarget= C13_CameraExposureExternal(ambientAwareTarget,dt)
        pure.exposure.cbe.setAdaptionSpeeds(40,20)
    end

    pure.exposure.cbe.setTarget(ambientAwareTarget)
    --ac.debug("target",ambientAwareTarget)
    --ac.debug("fogOrBadness",fogOrBadness)
    --ac.debug("normalizedAmb_Lum_inverted",normalizedAmb_Lum_inverted)
    --ac.debug("exp_amblumI",exp_amblumI)
    --ac.debug("targetAdjust",targetAdjust)
    local clampedAdjust = math.clamp(targetAdjust,0,0.2)
    --baseGamma = baseGamma + clampedAdjust * (1-normalisedCBE)
    pure.exposure.cbe.setLimits(expLow, expHigh)
    ac.useCubemapBrightnessEstimation(_l_Fov_based_result[2],1,1)
   
    local CbeEXP = pure.exposure.cbe.getValue()
   
    if pure.exposure.getCalculatedValue then
        FinalEXP = pure.exposure.getCalculatedValue()
       else
       FinalEXP = pure.exposure.getValue()
       end

       --c13_l_exposure_result = c13_l_ExposureCPP:get(cbe)
       --FinalEXP = math.clamp(c13_l_exposure_result[1],0.04,0.2)
       --ac.debug("c13_l_exposure_result",c13_l_exposure_result[1])
   -- __SCRIPT__UI_setValue("CBE Exposure",CbeEXP )
   -- __SCRIPT__UI_setValue("Final Exposure", FinalEXP)

    --reading and normalising CBE
    local PureBaseCBE = FinalEXP
    local expMax =expHigh
    local expMaxCrossover = expHigh * aeCrossoverPercentage
    local expMin = modifiedexpLow
    local leveledCurr = PureBaseCBE - expMin
    local levelLimits= math.max(expMax - expMin,0.001)
    local levelLimitsCrossover= math.max(expMaxCrossover - expMin,0.001)
    normalisedCBE = math.max(0.001, math.min((leveledCurr/levelLimits ),1))
    normalisedCBEcrossover = math.max(0.001, math.min((leveledCurr/levelLimitsCrossover ),1))
    --ac.debug("normalisedCBE",normalisedCBE)
    --ac.debug("normalisedCBEcrossover",normalisedCBEcrossover)
    --ac.debug("crossoverBoostNormalized",crossoverBoostNormalized)

    --yebis AE component
    ac.setCarExposureActive(false)
    ac.setAutoExposureLimits(yebisLow,yebisHigh)
    local AeRange = 1

    if(ac.isInteriorView()) then
        AeRange = (15/pure.camera.getFOV())
        --AeRange = 0.8
        --vecTemp.x = 2*AeRange
        vecTemp.x = AeRange/0.7
        vecTemp.y = AeRange
        --vecZero.y = -0.05
    else
        AeRange = 0.6
        vecTemp.x = AeRange
        vecTemp.y = AeRange
        --vecZero.y = 0.1
    end
    if pure.camera.isTripleScreen() then
     vecTemp.x = vecTemp.x/3
    end

    ac.setAutoExposureMeasuringArea(vecZero,vecTemp)
    ac.setAutoExposureTarget(ybTarget)
    local yebisAE = ac.getAutoExposure()
    local yebisLowDistance = ybRelativeMiddle - yebisLow
    local yebisHighDistance = yebisHigh - ybRelativeMiddle
    local relativeYebis = 1
    if(yebisAE < ybRelativeMiddle) then
        relativeYebis = ((yebisAE - yebisLow) - (ybRelativeMiddle - yebisLow))/yebisLowDistance
    else
        relativeYebis = ((yebisAE - yebisLow) - (ybRelativeMiddle - yebisLow))/yebisHighDistance
    end
    --relativeYebis = math.clamp((yebisAE-yebisLow) - (ybRelativeMiddle-yebisLow),-0.5,0.5)
    normalisedYebisAE = relativeYebis/0.5
    normalisedYebisAE = relativeYebis
    --ac.debug("normalisedYebisAE",normalisedYebisAE)
    --END OF AE PARAMETERS
    --GODRAYS
    local godrays =math.max(pure.mod.dayCurve(0.5,0.45,0.5)* 5  * pure.pp.getGodraysModulator() * godrayLengthRatio,0.001 )
    --local godrays =pure.mod.dayCurve(0.5,0.45,0.5)* 5  * PURE__getGodraysModulator() * godrayLengthRatio
    ac.setGodraysLength((_l_Fov_based_result[1]) * godrays)   
    ac.setGodraysDepthMapThreshold(0.999978840)
    --ac.debug("godrays",(_l_Fov_based_result[1]) * godrays)
    --ac.setGodraysDepthMapThreshold(0.999678840)
    --ac.debug("depthth",DepthMapThreshold)
    ac.setGodraysAngleAttenuation(math.lerp(20,10,CAMfacesSUN())-godrayAttenuationDrop)
    ac.setGodraysGlareRatio(godrayGlare)

    RGBToHSV_To(_l_tmp_hsv, Pure_getColor(COLORS.LIGHTSOURCE))
    _l_tmp_hsv.v = _l_tmp_hsv.v * godraysRatio * pure.mod.day(0) 
    --ac.debug("sun_hue",_l_tmp_hsv.h)c
    HSVToRGB_To(_l_tmp_rgb, _l_tmp_hsv.h, _l_tmp_hsv.s, _l_tmp_hsv.v)
    ac.setGodraysCustomColor(_l_tmp_rgb)


    --CustomFog
    RGBToHSV_To(_l_tmp_hsv, Pure_getColor(COLORS.LIGHTSOURCE))
    _l_tmp_hsv.s = math.min(0.1,_l_tmp_hsv.s)
    _l_tmp_hsv.v = math.clamp(_l_tmp_hsv.v * 10,0,10)
    --ac.debug("sun_hue",_l_tmp_hsv.h)c
    
   
   

    --EMULATING HOW CAMERAS BLOW OUT WITH HIGH ISO
        --if(gtMapping == false) then 
       --     PURE__ExpCalc_set_BypassExposure(math.min(FinalEXP ,AEcrossover))
       -- else
       --     PURE__ExpCalc_set_BypassExposure(FinalEXP)   
       -- end

        --FinalEXP = CameraExposure(FinalEXP,dt)
        --pure.exposure.setBypass(math.min(FinalEXP ,AEcrossover))

        pure.script.ui.setValue("CBE Exposure",CbeEXP )
        pure.script.ui.setValue("Final Exposure", FinalEXP)
       
        
       
       
        AEadjust = math.max(0,FinalEXP-AEcrossover)
        LimitsAdjust = math.max(0.01,(expHigh-AEcrossover))
        crossoverBoostNormalized = AEadjust/LimitsAdjust
        _l_colorFade_LUT_result = _l_fadeCPP:get(normalisedCBEcrossover)
       
        mappingfactor = mappingfactor + mappingboost *crossoverBoostNormalized
        baseFade = _l_colorFade_LUT_result[1]
        baseFilmicContrast = baseFilmicContrast - filmicContrastDrop * crossoverBoostNormalized
        baseGamma = baseGamma + 0.2 * math.pow(normalisedCBE,2)
        --ac.debug("crossoverBoostNormalized",crossoverBoostNormalized)
    

       
    
    
    ac.setPpTonemapMappingFactor(mappingfactor)
    ac.setPpSaturation(SaturationProgressionMod(baseSaturation))
    ac.setPpTonemapFilmicContrast(baseFilmicContrast)
    if CSP_VERSION >= 2349 then

        local tonemapGammaAdjustM = math.clamp(0.4 * MidpointBrightness,-0.6,0.3)
        local tonemapGammaAdjustS = math.clamp(0.1816 * MidpointBrightness,-0.1816,0.1816)
        local tonemapGammaAdjustC = math.clamp(0.2 * MidpointBrightness,-0.2,0.2)
        local tonemapGammaAdjustG = math.clamp(0.004 * MidpointBrightness,0,0.004)
      

        _l_MappingLUTResult = _l_MappingLUTCPP:get(mapFunction)

        milkyC=_l_MappingLUTResult[10]
        milkyT = _l_MappingLUTResult[12]
        milkyB = _l_MappingLUTResult[14]
        
        if pure.script.ui.getValue("Filmic grading") then
            milkyT= _l_MappingLUTResult[12] + 0.01
            milkyB= _l_MappingLUTResult[14] + 0.01
            milkyC=_l_MappingLUTResult[10] + 0.1
            --milkyS= 1.3680933
        end
        
        --if pure.script.ui.getValue("Allow extreme Overbright") then
        --    clipDrop = 0.2 * pure.mod.sun(0)
        --    clipKnee = 2 * pure.mod.sun(0)
            
        --else
            clipDrop = 0
            clipKnee = 0
        --end
        tonemap_c13.values.exposureMod = normalisedCBEcrossover
        --if mapFunction == 1 then
        if pure.system.isCSPGammaFix() then
            tonemap_c13.values.m = math.clamp(math.lerp(_l_MappingLUTResult[1]+ 0.05,_l_MappingLUTResult[2]+0.05,normalisedCBEcrossover) - tonemapGammaAdjustM,0.02,1)
        tonemap_c13.values.s = math.lerp(_l_MappingLUTResult[3],_l_MappingLUTResult[4]-clipDrop,normalisedCBEcrossover) + tonemapGammaAdjustS
        else
        
        tonemap_c13.values.m = math.clamp(math.lerp(_l_MappingLUTResult[1],_l_MappingLUTResult[2],normalisedCBEcrossover) - tonemapGammaAdjustM,0.02,1)
        tonemap_c13.values.s = math.lerp(_l_MappingLUTResult[3],_l_MappingLUTResult[4]-clipDrop,normalisedCBEcrossover) + tonemapGammaAdjustS
        end
        --tonemap_c13.values.s = math.lerp(milkyS,1.2,normalisedCBEcrossover) + tonemapGammaAdjustS
        tonemap_c13.values.g = math.clamp(math.lerp(_l_MappingLUTResult[5],_l_MappingLUTResult[6],normalisedCBEcrossover) - tonemapGammaAdjustG,0,0.1) + 0.005 * highCBEThreshold   --math.pow(normalisedCBE,1/3) - clampedAdjust/2000 
        --ac.debug("values.g",tonemap_c13.values.g)
        --ac.debug("clampedAdjust",clampedAdjust/2000)
        tonemap_c13.values.d = math.clamp(math.lerp(_l_MappingLUTResult[7],_l_MappingLUTResult[8]+clipKnee,normalisedCBE),0,1.07)--1 - 0.99 * normalisedCBE

        
        --tonemap_c13.values.c = math.lerp(1.67 - 0.1 * normalisedCBE,1.55,normalisedCBEcrossover) + tonemapGammaAdjustC 
        tonemap_c13.values.c = math.lerp(_l_MappingLUTResult[9],milkyC,normalisedCBEcrossover) + tonemapGammaAdjustC - 0.100 * CAMfacesSUN()*pure.mod.day(0)
        
        --tonemap_c13.values.t = 0.021 - 0.018 * normalisedCBEcrossover
      
        tonemap_c13.values.t = math.lerp(_l_MappingLUTResult[11],milkyT,normalisedCBEcrossover)
        tonemap_c13.values.b= math.lerp(_l_MappingLUTResult[14],milkyB,normalisedCBEcrossover)-- - 0.002  * normalisedCBE
        tonemap_c13.values.tBrightness = math.lerp(_l_MappingLUTResult[17],_l_MappingLUTResult[18],normalisedCBEcrossover)
        --tonemap_c13.values.s1 = 1.28 - 0.03 * normalisedCBE
       -- elseif mapFunction == 2 then
        if mapFunction == 2 then
           -- tonemap_c13.values.m = math.clamp(math.lerp(0.25017,0.42,normalisedCBEcrossover) - tonemapGammaAdjustM,0.01,1)
           -- tonemap_c13.values.s = math.lerp((1.2880933),1.2-clipDrop,normalisedCBEcrossover) + tonemapGammaAdjustS
           -- tonemap_c13.values.g = 0.001
           -- tonemap_c13.values.t = 0
           -- tonemap_c13.values.c = math.lerp(1.37,1.4,normalisedCBEcrossover) + tonemapGammaAdjustC
            tonemap_c13.values.b= math.lerp(0,math.clamp(milkyB,0,0.01),normalisedCBEcrossover)-- - 0.002  * normalisedCBE
           --tonemap_c13.values.c1 = tonemap_c13.values.c1 - _l_MappingLUTResult[15]
        end
        --if mapFunction > 2 then
           tonemap_c13.values.c1 = tonemap_c13.values.c1 - _l_MappingLUTResult[15]
        --end
        

       --[[ if mapFunction == 3 then

            tonemap_c13.values.m = math.clamp(math.lerp(0.1017,0.01,normalisedCBEcrossover) - tonemapGammaAdjustM,0.01,1)
            tonemap_c13.values.s = math.lerp((1.2880933),1.38,normalisedCBEcrossover) + tonemapGammaAdjustS
            tonemap_c13.values.g =0
            tonemap_c13.values.t = 0
            tonemap_c13.values.c = math.lerp(2,3.35,normalisedCBEcrossover) + tonemapGammaAdjustC
            tonemap_c13.values.b= 0.01
            tonemap_c13.values.d = 2
            tonemap_c13.values.c1 = 1.1
            tonemap_c13.values.s1 = 1.1
            ac.setPpSaturation(0)            
        end]]

       -- tonemap_c13.values.method = mapFunction
        tonemap_c13.values.SceneLuminance = 800 - 700 * math.pow(normalisedCBE,1/4)

        --tonemap_c13.values.decomp1 = pure.script.ui.getValue("decomp1")
        --tonemap_c13.values.decomp2 = pure.script.ui.getValue("decomp2")
        --tonemap_c13.values.decomp3 = pure.script.ui.getValue("decomp3")

        --tonemap_c13.values.d1 = math.lerp(-0.6,-0.1,pure.script.ui.getValue("Vibrance"))
        --tonemap_c13.values.c1 = math.lerp(1.6,1.4,normalisedCBE) 
        --ac.debug("biasg",tonemap_c13.values.g)
        --ac.debug("biasb",tonemap_c13.values.b)
       
      

    end
    
    
    
    tonemap_c13.values.colordepth = pure.script.ui.getValue("posterize")

    if pure.script.ui.getValue("Fake film grain") == 0 and pure.script.ui.getValue("Auto Film Grain") then
        tonemap_c13.values.grain = math.max(0.2, 0.5 * normalisedCBE)
    else
        tonemap_c13.values.grain = pure.script.ui.getValue("Fake film grain")
    end

    --ac.debug("dt",dt)
    
    if dt>0.1 then
        tonemap_c13.values.staticNoise=true
    else
        tonemap_c13.values.staticNoise=false
    end

    peakReflection = math.clamp(1.5 - 0.1 * overcast + 0.3 * math.clamp(sunBoost - 1,0,1),1+0.2*polarizer,1.4+0.6*polarizer + 0.3 * math.clamp(sunBoost - 1,0,1))

    ac.setPpTonemapGamma(baseGamma)
    ac.setPpTonemapGamma(0.999)
    --ac.debug("baseGamma",baseGamma)
    
    -- glare parameters
    bloomGamma = basebloomGamma + bloomGammaBoost * normalisedCBEcrossover
    --ac.setGlareBloomLuminanceGamma(bloomGamma)
    --ac.debug("bloomGamma",bloomGamma)
    --ac.setGlareThreshold(glareThreshold)
    --ac.debug("glareThreshold",glareThreshold)
    
        --PURE LIGHTING ADJUSTMENTS
   
    pure.config.set("light.daylight_multiplier",math.lerp(sunBoost,0.3,badness),true)
    --pure.config.set("reflections.level", math.lerp(peakReflection,1.3,normalisedCBEcrossover),true)
    --pure.config.set("reflections.level", math.lerp(peakReflection,1.3,normalisedCBEcrossover),true)
    --pure.config.set("reflections.level", 0.5,true)

    
    --ambSat = math.max(pure.mod.dayCurve(1.4,0.85 + 0.2 * cloud_coverage,1),1.5*fogOrBadness)
    
    
    emissiveDrop = math.clamp(4 * normalisedCBEcrossover,0,2.5)
    emissiveBootom = 2.2
    --pure.config.set("csp_lights.emissive",math.clamp(4 - emissiveDrop,emissiveBootom,2.8),true)
    pure.config.set("csp_lights.emissive",0.05,true)
    pure.config.set("csp_lights.bounce",1.7,true)
    pure.config.set("csp_lights.displays",0.1,true)
    pure.config.set("csp_lights.true_emissive",0.2,true)

    ac.setGlowBrightness(0.5 + 0.5 * pure.world.getFog())

    --ac.debug("lightsMulti",ac.getWeatherLightsMultiplier())
    pure.config.set("Scene.emissive_adaption",false)
    --ac.setEmissiveMultiplier(0.2)
    ac.setEmissiveCameraGain(3, 20)
    --AC color corrections

    fogBlue =  0.05 * fog * occluded

    
   

    
    --base globalCG
    ColorWheel.color.r = r + _l_colorFade_LUT_result[6]
    ColorWheel.color.g = g +_l_colorFade_LUT_result[7]
    ColorWheel.color.b = math.clamp(b +_l_colorFade_LUT_result[8] + fogBlue,0.8,1.3)
    redFade = _l_colorFade_LUT_result[2]
    greenFade = _l_colorFade_LUT_result[3]
    blueFade = _l_colorFade_LUT_result[4] --+ fogBlue + cloudblue
    filterFade.color = rgb(redFade,greenFade,blueFade)
    filterFade.effectRatio  = math.max(minFade, baseFade)/1000
    ac.setPpColorGradingIntensity(_l_colorFade_LUT_result[5])

    
    if(cgOff) then
        ColorWheel.color = rgb(1,1,1)
    end
    
    
    --modulatedSunLevel = pure.script.weather.getVariable("sunLevelWeather") * 2.2
    modulatedSunLevel = pure.mod.dayCurve(0,1.2,0.2)
    if (pure.script.ui.getValue("Power of the sun") == true) then
      modulatedSunLevel = math.lerp(pure.mod.dayCurve(0,1.7,0.2),modulatedSunLevel,overcast)
    end
    pure.config.set("light.sun.level", modulatedSunLevel,true)
    --pure.config.set("light.sun.saturation", pure.mod.dayCurve(0.5,1,0.9),true)

    clampedSunLevel = math.clamp(modulatedSunLevel,0.7,1)
    skyLevel = pure.mod.dayCurve(1,0.5 + clampedSunLevel - 0.2 * overcast)


    
    
        --pure.config.set("light.advanced_ambient_light", math.clamp(pure.mod.dayCurve(1.1,0.9,0.5),0.8,1.6),true)--OG 
       
        --pure.config.set("light.advanced_ambient_light", math.clamp(pure.mod.dayCurve(1.5,0.75,0.8)- 0.7 * overcast,0.3,1.6),true)--OG 
    pure.config.set("light.ambient.hue",pure.mod.dayCurve(5,0),true)
    --pure.config.set("light.ambient.level", math.clamp(pure.mod.dayCurve(1.2,1.4,0.4),1,2.3/math.clamp(sunBoost,1,1.5)) ,true)--OG 

    --pure.config.set("light.ambient.level", pure.mod.dayCurve(2.2,2.4,0.4),true)
    pure.config.set("light.ambient.level", (pure.mod.dayCurve(0.6,0.4,0.4)*math.lerp(1,1.3,pure.world.getCloudCoverage())),true)
    

    ambSat = math.max(pure.mod.dayCurve(1.2,1.1,0.3),0.8)
    --pure.config.set("light.directional_ambient.level",pure.mod.dayCurve(0.8,1,0.5),true)
    pure.config.set("light.directional_ambient.level",pure.mod.dayCurve(math.lerp(0.3,1,overcast),math.clamp(math.lerp(0.3,0,overcast),0.2,11),0.8),true)
    pure.config.set("clouds2D.brightness",pure.mod.dayCurve(pure.mod.nightCurve(0.1,0.8,20),0.9+0.15*(1-overcast)),true)

    --pure.config.set("clouds2D.contrast",pure.mod.dayCurve(pure.mod.nightCurve(0.1 + 0.2*(1-overcast) ,1,20),1.4-math.max(0.1*pure.world.getHumidity(),0.2*pure.world.getCloudCoverage())),true)

    --pure.config.set("clouds2D.brightness",0.7,true)
    --pure.config.set("sky.level", math.lerp(pure.mod.dayCurve(pure.mod.nightCurve(1,2,20),22),0.8,math.saturateN(badness*1.5)),true)
    pure.config.set("reflections.saturation", 0.6,true)
    pure.config.set("reflections.level", 1.9,true)


    --pure.config.set("shadows.presence",math.clamp(pure.mod.dayCurve(1,0.95)+0.05*(1-fog)-0.05*(badness),0.85,1), true)

    pure.config.set("light.ambient_radiosity.level",0.7,true)
    pure.config.set("light.ambient_radiosity.saturation",math.lerp(1,1.1,pure.world.getCloudCoverage()),true)

    pure.config.set("light.ambient.saturation", ambSat, true)
     --pure.config.set("light.sun.hue",math.lerp(11,0,math.lerpInvSat(pure.stellar.getSunElevation(), 4 ,7)),true)
     --pure.config.set("light.sun.saturation",pure.mod.dayCurve(0.94,1,2),true)


     
     --ac.setSkyV2SunShapeMult(ac.SkyRegion.All,10)


    pure.config.set("nlp.lowest_ambient",1.5,true)
    pure.config.set("nlp.density",0.8,true)

   

    
    --pure.config.set("clouds2D.contrast",math.lerp(math.clamp(skyLevel + 0.2 * overcast,0,1.2 + 0.3 * overcast),0.2,pure.mod.night(0)),true)
    --pure.config.set("sky.sun_disk.level",0.1,true)
   
    pure.config.set("vao.track_exponent",1,true)
    --pure.config.set("vao.dynamic_exponent",4,true)


 

        
        --pure.config.set("light.advanced_ambient_lightV2_sky",pure.mod.dayCurve(1,1.3),true)

        skyAmbient = 0.8 - 0.2 * cloud_coverage
        sunAmbient = (modulatedSunLevel)/sunBoost  - 0.2 * cloud_coverage
        cloudAmbient = 0.6 + 0.3 * cloud_coverage

        --pure.config.set("light.advanced_ambient_lightV2_sun",sunAmbient,true)
        --pure.config.set("light.advanced_ambient_lightV2_clouds",cloudAmbient,true)
        --pure.config.set("light.advanced_ambient_lightV2_sky",skyAmbient ,true)


        
        
        
        




    --if pure.system.isCSPGammaFix() then
    --    fresnelGamma = 1.6
    --else
        fresnelGamma = 1.22
    --end
    --ac.debug("fresnelGamma",fresnelGamma)

    ApplyColorProfile(colorProfile)
    --pure.light.setLambertGamma(1.7)
    
    if(pure.script.ui.getValue("Manual photo mode"))then
        pure.exposure.setBypass(0.1)
        ac.setPpBrightness( math.pow(pure.script.ui.getValue("AE Target"),2))
        tonemap_c13.values.c = 1.6
        filterBias.value=0
    

        if __PURE_version > 0.205 then
            if(pure.script.ui.getValue("Reflection tweak"))then
            pure.camera.setCPL(0.8 * pure.script.ui.getValue("Polarizing filter strength"), 0, 90, 1)
                
                    
                    ac.setFresnelGamma(fresnelGamma)
                    --pure.config.set("reflections.level", math.lerp(peakReflection+0.5,1.4,normalisedCBEcrossover),true)
            else
                pure.camera.setCPL()
                ac.setFresnelGamma(1)
            end
            
        end
        
    else
        pure.exposure.setBypass(FinalEXP)
            if(pure.script.ui.getValue("Reflection tweak"))then
             pure.camera.setCPL(math.lerp(0.6,0.3,badness), 0, -15, 1)
                
                ac.setFresnelGamma(fresnelGamma)
                
            else
                pure.camera.setCPL()
                ac.setFresnelGamma(1)
            end

        
    end

   

    --ac.setFogAtmosphere(math.lerp(0.1,0.5,math.saturateN(pure.world.getHumidity()-pure.world.getMist())))
    pure.config.set("fog.far.exponent",0.95 + 0.5 * (1-occluded),true)
    pure.config.set("fog.near.exponent",1.5 + 0.5 * (1-occluded),true)
    pure.config.set("fog.atmosphere",math.saturateN(math.lerp(0.2,0.6,math.max(pure.world.getMist(),badness))),true)
    pure.config.set("fog.sky", math.lerp(math.saturateN(math.lerp(0.3,2,math.max(pure.world.getMist(),badness*10))),10,pure.mod.night(0)),true)
   
     dashcam = pure.script.ui.getValue("Dashcam mode")
     if dashcam then
        pure.config.set("pp.contrast",1.01,true)
     else
        pure.config.set("pp.contrast",1,true)
     end
     glarePreset = pure.script.ui.getValue("Glare style")
     --setGlare(glarePreset)
     C13_setCBEcxExternal(normalisedCBEcrossover)
     --ac.debug("normalisedCBEcrossoverInternal",normalisedCBEcrossover)
     C13_setGlareExternal(glarePreset,_l_glareStyleCPP)

   
     if pure.script.ui.getValue("Auto Film Grain") then
        filmContrast.value = math.clamp(filmContrast.value,0.98,1.01)
        filterBias.value=math.lerp(filterBias.value, 0.015,normalisedCBEcrossover)
     end
    
     if pure.script.ui.getValue("CG LUT intensity") == 0 then
        ac.setPpColorGradingIntensity(0)
     else
        ac.setPpColorGradingIntensity(pure.script.ui.getValue("CG LUT intensity"))
     end

     ac.setTrueEmissiveMultiplier(0.2)
     --ac.setEmissiveMultiplier(0.05)
     ac.setAmbientColor(pure.light.getAmbient() * 1 + (pure.script.ui.getValue("Minimum ambient light")/100)*(1-pure.mod.twilight(0)))
end

function setGlare(index)
    _l_glarestyleLUTresult = _l_glareStyleCPP:get(index)
    glareThresholdStart  = _l_glarestyleLUTresult[1]
    glareThresholdEnd = _l_glarestyleLUTresult[14]
      glareLuminanceStart  = _l_glarestyleLUTresult[2]
      glareLuminanceEnd  = _l_glarestyleLUTresult[3]
      glareBloomGammaStart  = _l_glarestyleLUTresult[4]
      glareBloomGammaEnd = _l_glarestyleLUTresult[5]
      glareBloomLuminanceStart = _l_glarestyleLUTresult[6]
      glareBloomLuminanceEnd  = _l_glarestyleLUTresult[7]
      glareStarLuminanceStart = _l_glarestyleLUTresult[8]
      glareStareLuminanceEnd = _l_glarestyleLUTresult[9]
      glareStarSoftnessStart = _l_glarestyleLUTresult[10]
      glareStarSoftnessEnd = _l_glarestyleLUTresult[11]
      glareGaussRadiusStart = _l_glarestyleLUTresult[12]
      glareGaussRadiusEnd = _l_glarestyleLUTresult[13]
      glarebrightPass = _l_glarestyleLUTresult[15]
      glareShapeStarLengthStart =_l_glarestyleLUTresult[16]
      glareShapeStarLengthEnd=_l_glarestyleLUTresult[17]
      glareShapeStarSecondaryLengthStart=_l_glarestyleLUTresult[18]
      glareShapeStarSecondaryLengthEnd=_l_glarestyleLUTresult[19]

      glareShapeStarStreaks = _l_glarestyleLUTresult[20]

    --glareShapeAnamorphic = _l_glarestyleLUTresult[20]
    glareShapeGhostLuminanceStart = _l_glarestyleLUTresult[21]
    glareShapeGhostLuminanceEnd = _l_glarestyleLUTresult[22]
    glareShapeGhostHaloLuminanceStart = _l_glarestyleLUTresult[23]
    glareShapeGhostHaloLuminanceEnd=_l_glarestyleLUTresult[24]
    glareShapeGhostDistortionStart=_l_glarestyleLUTresult[25]
    glareShapeGhostDistortionEnd = _l_glarestyleLUTresult[26]
    glareShapeGhostSharpenessStart=_l_glarestyleLUTresult[27]
    glareShapeGhostSharpenessEnd=_l_glarestyleLUTresult[28]
    glareShapeAfterimageLength = _l_glarestyleLUTresult[29]
    glareAnamorphic = _l_glarestyleLUTresult[30]
    

      --ac.debug("glareGaussRadiusEnd",glareGaussRadiusEnd)
end

--local baseSat = 1
local dayDrop = 1
local SunDrop = 1
local zenithSat = 1
local BaseProgression = 1
local cbeAdjust = 1
--local overcastBoost = 1
--local saturation = 1
local nightPercentage = 0.9
--local ClampedSat = 1
local saturation = 1
local cbeDVibrance = 0

function SaturationProgressionMod(inputSat)
--baseSat = inputSat
dayDrop =0.01 * (1-pure.world.getCloudCoverage())
SunDrop = 0.02 * CAMfacesSUN() * math.max(0.5, Pure_get_Overcast())

zenithSat = inputSat-dayDrop
BaseProgression = pure.mod.dayCurve(inputSat,zenithSat)
cbeAdjust = 0.05 * normalisedCBE
cbeDVibrance = 0.05 * normalisedCBEcrossover
--overcastBoost = 0.04 * Pure_get_Overcast() * pure.mod.dayCurve(0,1,0.5)
saturation = BaseProgression + (0.04 * Pure_get_Overcast() * pure.mod.dayCurve(0,1,0.5)) - cbeAdjust - SunDrop
saturation = saturation - (0.1 * normalisedCBEcrossover)
--ClampedSat = math.clamp(saturation,satlow,satHigh)
 --ac.debug("saturation",math.clamp(saturation,satlow,satHigh))
--ac.debug("bias",baseBias)

pure.config.set("light.sun.speculars", pure.mod.dayCurve(1.2,2,0.5)+ (0.2 * polarizer) + (0.5 * CAMfacesSUNWorld()*polarizer) , true)

--ac.setSpecularColor(Pure_getColor(COLORS.LIGHTSOURCE)*10)
baseFilmicContrast = baseFilmicContrast + 0.05 * CAMfacesSUN() * occluded
--ac.debug("filmicContrast",baseFilmicContrast)
--tonemap_c13.values.c1= 1.2 + cbeDVibrance + SunDrop - 0.5 * pure.script.ui.getValue("Digital vibrance adjust") + 0.05 * badness
tonemap_c13.values.c1= 1.2 + cbeDVibrance + SunDrop + 0.05 * badness

--ac.debug("tonemap.c1",tonemap_c13.values.c1)

return math.clamp(saturation,satlow,satHigh)

end



function CAMfacesSUN()
    local hori = 0
    local vert = 0
    local _l_camSunFace = 0

    hori = correct_angle(__PURE__sun_heading_get() - (__PURE__cam_heading - 180) )
    if hori > 180 then hori = 360 - hori end
    hori = math.pow(math.max(0, 1 - hori / math.max(0.1, __PURE__camFOV)), 0.5)
    vert = correct_angle(__PURE__sun_angle_get() - math.min(__PURE__cam_angle,180))
    --ac.debug("vert",vert)
    --ac.debug("sunAngle",__PURE__sun_angle_get())
    --ac.debug("camAngle", math.clamp(__PURE__cam_angle,-500,500))
    if vert > 180 then vert = 360 - vert end
    vert = math.pow(math.max(0, 1 - vert / math.max(0.1, __PURE__camFOV)), 0.5)
    vert = math.clamp(vert,0.3,1)
    _l_camSunFace = hori * vert * (occluded) * (1-cloud_shadow)
    --ac.debug("occluded",occluded)
    --ac.debug("hori",hori)
    
    --ac.debug("camfacessun",_l_camSunFace)
   
  return math.clamp(_l_camSunFace,0,1)
end

function CAMfacesSUNWorld()

    hori = correct_angle( __PURE__sun_heading_get() - (__PURE__cam_heading - 180) )
    if hori > 180 then hori = 360 - hori end
    hori = math.pow(math.max(0, 1 - hori / math.max(0.1, __PURE__camFOV)), 0.5)
    vert = correct_angle( __PURE__sun_angle_get() - math.min(__PURE__cam_angle,180))
    if vert > 180 then vert = 360 - vert end
    vert = math.pow(math.max(0, 1 - vert / math.max(0.1, __PURE__camFOV)), 0.5)
    vert = math.clamp(vert,0.3,1)
    _l_camSunFace = hori * vert * (1-cloud_shadow)
    --ac.debug("occluded",occluded)
    --ac.debug("camfacessunWorld",_l_camSunFace)
   
  return math.clamp(_l_camSunFace,0,1)
end

function ApplyColorProfile(index)
    --ac.debug("index",index)
    if(index == 2) then
        _l_FilmStockLUT_result= _l_FilmStockCPP:get(1)

        filmTint.color = (rgb(_l_FilmStockLUT_result[1],_l_FilmStockLUT_result[2],_l_FilmStockLUT_result[3]))
        filmWB.temperature = _l_colorFade_LUT_result[9]
        filmWB.luminance = _l_FilmStockLUT_result[5]
        filmContrast.value = _l_FilmStockLUT_result[6]
        filmSepia.value = _l_FilmStockLUT_result[7]
        filmHUE.hue =_l_FilmStockLUT_result[8]
        FilmSat.value = _l_FilmStockLUT_result[9]
        filterFade.color =rgb(filterFade.color.r+_l_FilmStockLUT_result[10],filterFade.color.g+_l_FilmStockLUT_result[11],filterFade.color.b+_l_FilmStockLUT_result[12])
        filterFade.effectRatio = filterFade.effectRatio + _l_FilmStockLUT_result[13]
       
   

    else
      

        _l_FilmStockLUT_result= _l_FilmStockCPP:get(index)
        local filterCPP = selectLut(index)
        _l_FilterProfile_LUT_result = filterCPP:get(normalisedCBEcrossover)
        --ac.debug("filterLut",_l_FilterProfile_LUT_result[11])
        filmTint.color = (rgb(_l_FilterProfile_LUT_result[1],_l_FilterProfile_LUT_result[2],_l_FilterProfile_LUT_result[3]))
        filmWB.temperature = _l_FilterProfile_LUT_result[4]
        filmWB.luminance = _l_FilterProfile_LUT_result[5]
        filmContrast.value = _l_FilterProfile_LUT_result[6]
        filmSepia.value = _l_FilterProfile_LUT_result[7]
        filmHUE.hue =_l_FilterProfile_LUT_result[8]
        FilmSat.value = _l_FilterProfile_LUT_result[9]
        filterFade.color =rgb(filterFade.color.r+_l_FilterProfile_LUT_result[10],filterFade.color.g+_l_FilterProfile_LUT_result[11],filterFade.color.b+_l_FilterProfile_LUT_result[12])
        filterFade.effectRatio = filterFade.effectRatio + _l_FilterProfile_LUT_result[13]
        
end

end

function selectLut(index)

    
    if(index==1) then
        return _l_neutral_CPP
    elseif (index == 3) then
        return _l_WarmFilmic_CPP
    elseif (index == 4) then
        return _l_cool_CPP
    elseif (index == 5) then
        return _l_Csepia_CPP
    elseif (index == 6) then
        return _l_NFS_CPP
    elseif (index == 7) then
        return _l_Warm_CPP
    end
    return _l_FilmStockCPP
    
end

function dampen(old, new, dt)

    if(old < new) then
        return old + 2 * dt
    elseif (old > new) then
        return old - 2 * dt
    else
    return old
    end
end


if CSP_VERSION >= 2651 then -- CSP 0.2
  
   ac.onPostProcessing(C13_GlareExternal)
end




