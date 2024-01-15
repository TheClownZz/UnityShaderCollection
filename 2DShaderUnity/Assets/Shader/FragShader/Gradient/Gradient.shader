Shader "Custom/Frag/Gradient"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _GradBlend ("Gradient Blend", Range(0, 1)) = 1
        _GradTopLeftCol ("Top Color", Color) = (1, 0, 0, 1)
        _GradTopRightCol ("Top Color 2", Color) = (1, 1, 0, 1)
        _GradBotLeftCol ("Bot Color", Color) = (0, 0, 1, 1)
        _GradBotRightCol ("Bot Color 2", Color) = (0, 1, 0, 1)
        _GradBoostX ("Boost X axis", Range(0.1, 5)) = 1.2
        _GradBoostY ("Boost Y axis", Range(0.1, 5)) = 1.2
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
            #pragma shader_feature GRADIENT2COL
            #pragma shader_feature RADIALGRADIENT

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST, _MainTex_TexelSize;

            half _GradBlend, _GradBoostX, _GradBoostY;
            half4 _GradTopRightCol, _GradTopLeftCol, _GradBotRightCol, _GradBotLeftCol;
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

            half3 GetPixel(in int offsetX, in int offsetY, half2 uv, sampler2D tex)
            {
                return tex2D(tex, (uv + half2(offsetX * _MainTex_TexelSize.x, offsetY * _MainTex_TexelSize.y))).rgb;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                half2 tiledUvGrad = half2(i.uv.x / _MainTex_ST.x, i.uv.y / _MainTex_ST.y);
                #if GRADIENT2COL
                    _GradTopRightCol = _GradTopLeftCol;
                    _GradBotRightCol = _GradBotLeftCol;
                #endif
                #if RADIALGRADIENT
                    half radialDist = 1 - length(tiledUvGrad - half2(0.5, 0.5));
                    radialDist *= (_MainTex_TexelSize.w / _MainTex_TexelSize.z);
                    radialDist = saturate(_GradBoostX * radialDist);
                    half4 gradientResult = lerp(_GradTopLeftCol, _GradBotLeftCol, radialDist);
                #else
                    half gradXLerpFactor = saturate(pow(tiledUvGrad.x, _GradBoostX));
                    half4 gradientResult = lerp(lerp(_GradBotLeftCol, _GradBotRightCol, gradXLerpFactor),
                    lerp(_GradTopLeftCol, _GradTopRightCol, gradXLerpFactor), saturate(pow(tiledUvGrad.y, _GradBoostY)));
                #endif
                gradientResult = lerp(col, gradientResult, _GradBlend);
                col.rgb = gradientResult.rgb * col.a;
                col.a *= gradientResult.a;
                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}