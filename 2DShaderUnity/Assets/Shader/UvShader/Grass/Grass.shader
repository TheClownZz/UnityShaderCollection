Shader "Custom/Uv/Grass"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _GrassSpeed ("Speed", Range(0, 5)) = 2
        _GrassWind ("Bend amount", Range(0, 50)) = 20
        _GrassManualAnim ("Manual Anim Value", Range(-1, 1)) = 1
        _GrassRadialBend ("Radial Bend", Range(0.0, 5.0)) = 0.1 //145

        _CenterX ("CenterX", Range(0, 1)) = 0.5
        _CenterY ("CenterY", Range(0, 1)) = 0.1
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
            #pragma shader_feature MANUALWIND_ON

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _GrassSpeed, _GrassWind, _GrassManualAnim, _GrassRadialBend;
            half _CenterX, _CenterY;
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
                half windOffset = sin(_Time * _GrassSpeed * 10);
                half2 center = half2(_CenterX, _CenterY);
                float2 uvRect = i.uv;
                
                #if !MANUALWIND_ON
                    i.uv.x = fmod(abs(lerp(i.uv.x, i.uv.x + (_GrassWind * 0.01 * windOffset), uvRect.y)), 1);
                #else
                    i.uv.x = fmod(abs(lerp(i.uv.x, i.uv.x + (_GrassWind * 0.01 * _GrassManualAnim), uvRect.y)), 1);
                    windOffset = _GrassManualAnim;
                #endif
                half2 delta = i.uv - center;
                half delta2 = dot(delta.xy, delta.xy);
                half2 delta_offset = delta2 * windOffset;
                i.uv = i.uv + half2(delta.y, -delta.x) * delta_offset * _GrassRadialBend;
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}