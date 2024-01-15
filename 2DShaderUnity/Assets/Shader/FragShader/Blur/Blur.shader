Shader "Custom/Frag/Blur"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _BlurIntensity ("Blur Intensity", Range(0, 100)) = 10
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha

        ZWrite off
        Cull off

        Pass
        {

            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma shader_feature BLURISHD_ON

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _BlurIntensity;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }
            half4 Blur(half2 uv, sampler2D source, half Intensity)
            {
                half step = 0.00390625f * Intensity;
                half4 result = half4(0, 0, 0, 0);
                half2 texCoord = half2(0, 0);
                texCoord = uv + half2(-step, -step);
                result += tex2D(source, texCoord);
                texCoord = uv + half2(-step, 0);
                result += 2.0 * tex2D(source, texCoord);
                texCoord = uv + half2(-step, step);
                result += tex2D(source, texCoord);
                texCoord = uv + half2(0, -step);
                result += 2.0 * tex2D(source, texCoord);
                texCoord = uv;
                result += 4.0 * tex2D(source, texCoord);
                texCoord = uv + half2(0, step);
                result += 2.0 * tex2D(source, texCoord);
                texCoord = uv + half2(step, -step);
                result += tex2D(source, texCoord);
                texCoord = uv + half2(step, 0);
                result += 2.0 * tex2D(source, texCoord);
                texCoord = uv + half2(step, -step);
                result += tex2D(source, texCoord);
                result = result * 0.0625;
                return result;
            }
            half BlurHD_G(half bhqp, half x)
            {
                return exp( - (x * x) / (2.0 * bhqp * bhqp));
            }
            half4 BlurHD(half2 uv, sampler2D source, half Intensity, half xScale, half yScale)
            {
                int iterations = 16;
                int halfIterations = iterations / 2;
                half sigmaX = 0.1 + Intensity * 0.5;
                half sigmaY = sigmaX;
                half total = 0.0;
                half4 ret = half4(0, 0, 0, 0);
                for (int iy = 0; iy < iterations; ++iy)
                {
                    half fy = BlurHD_G(sigmaY, half(iy) - half(halfIterations));
                    half offsetY = half(iy - halfIterations) * 0.00390625 * xScale;
                    for (int ix = 0; ix < iterations; ++ix)
                    {
                        half fx = BlurHD_G(sigmaX, half(ix) - half(halfIterations));
                        half offsetX = half(ix - halfIterations) * 0.00390625 * yScale;
                        total += fx * fy;
                        ret += tex2D(source, uv + half2(offsetX, offsetY)) * fx * fy;
                    }
                }
                return ret / total;
            }
            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                #if !BLURISHD_ON
                    col = BlurHD(i.uv, _MainTex, _BlurIntensity, 1, 1) * i.color;
                #else
                    col = Blur(i.uv, _MainTex, _BlurIntensity) * i.color;
                #endif

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}