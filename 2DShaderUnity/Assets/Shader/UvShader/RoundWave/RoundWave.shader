Shader "Custom/Uv/RoundWave"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _RoundWaveStrength ("Wave Strength", Range(0, 1)) = 0.7
        _RoundWaveSpeed ("Wave Speed", Range(0, 5)) = 2
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

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST,_MainTex_TexelSize;
            half _RoundWaveStrength, _RoundWaveSpeed;

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
                half xWave = ((0.5 * _MainTex_ST.x) - i.uv.x);
                half yWave = ((0.5 * _MainTex_ST.y) - i.uv.y) * (_MainTex_TexelSize.w / _MainTex_TexelSize.z);
                half ripple = -sqrt(xWave * xWave + yWave * yWave);
                i.uv += (sin((ripple + _Time.y * (_RoundWaveSpeed / 10.0)) / 0.015) * (_RoundWaveStrength / 10.0)) % 1;

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}