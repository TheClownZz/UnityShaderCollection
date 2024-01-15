Shader "Custom/Frag/ColorRamp"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        [ShaderGradient] _ColorRampTexGradient ("Color ramp Gradient", 2D) = "white" { }
        [NoScaleOffset] _ColorRampTex ("Color ramp Texture", 2D) = "white" { }
        _ColorRampLuminosity ("Color ramp luminosity", Range(-1, 1)) = 0 
        _ColorRampBlend ("Color Ramp Blend", Range(0, 1)) = 1 

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
            #pragma shader_feature GRADIENTCOLORRAMP_ON

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _ColorRampTex, _ColorRampTexGradient;
            half _ColorRampLuminosity, _ColorRampBlend;

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

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                half luminance = 0;

                luminance = 0.3 * col.r + 0.59 * col.g + 0.11 * col.b;
                luminance = saturate(luminance + _ColorRampLuminosity);
                #if GRADIENTCOLORRAMP_ON
                    col.rgb = lerp(col.rgb, tex2D(_ColorRampTexGradient, half2(luminance, 0)).rgb, _ColorRampBlend);
                #else
                    col.rgb = lerp(col.rgb, tex2D(_ColorRampTex, half2(luminance, 0)).rgb, _ColorRampBlend);
                #endif

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}