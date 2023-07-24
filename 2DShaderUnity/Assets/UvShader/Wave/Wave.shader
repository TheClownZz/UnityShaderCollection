Shader "Custom/Uv/Wave"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _WaveAmount ("Wave Amount", Range(0, 25)) = 7 
        _WaveSpeed ("Wave Speed", Range(0, 25)) = 10 
        _WaveStrength ("Wave Strength", Range(0, 25)) = 7.5 
        _WaveX ("Wave X Axis", Range(0, 1)) = 0 
        _WaveY ("Wave Y Axis", Range(0, 1)) = 0.5 

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
            float4 _MainTex_ST;

            float _WaveAmount, _WaveSpeed, _WaveStrength, _WaveX, _WaveY;

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
                float2 uvWave = half2(_WaveX * _MainTex_ST.x, _WaveY * _MainTex_ST.y) - i.uv;
                uvWave %= 1;
                uvWave.x *= _ScreenParams.x / _ScreenParams.y;
                float angWave = (sqrt(dot(uvWave, uvWave)) * _WaveAmount) - ((_Time.y * _WaveSpeed));
                i.uv = i.uv + uvWave * sin(angWave) * (_WaveStrength / 1000.0);

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}