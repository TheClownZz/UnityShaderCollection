Shader "Custom/Frag/Aberration"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _ChromAberrAmount ("ChromAberr Amount", Range(0, 1)) = 1
        _ChromAberrAlpha ("ChromAberr Alpha", Range(0, 1)) = 0.4
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

            half _ChromAberrAmount, _ChromAberrAlpha;


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
                half4 r = tex2D(_MainTex, i.uv + half2(_ChromAberrAmount / 10, 0)) * i.color;
                half4 b = tex2D(_MainTex, i.uv + half2(-_ChromAberrAmount / 10, 0)) * i.color;
                col = half4(r.r * r.a, col.g, b.b * b.a, max(max(r.a, b.a) * _ChromAberrAlpha, col.a));
                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}