Shader "Custom/Frag/MotionBlur"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _MotionBlurAngle ("Motion Blur Angle", Range(-1, 1)) = 0.1
        _MotionBlurDist ("Motion Blur Distance", Range(-3, 3)) = 1.25
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

            half _MotionBlurAngle, _MotionBlurDist;


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
                _MotionBlurAngle = _MotionBlurAngle * 3.1415926;
                #define rot(n) mul(n, half2x2(cos(_MotionBlurAngle), -sin(_MotionBlurAngle), sin(_MotionBlurAngle), cos(_MotionBlurAngle)))
                _MotionBlurDist = _MotionBlurDist * 0.005;

                col.rgb += tex2D(_MainTex, i.uv + rot(half2(-_MotionBlurDist, -_MotionBlurDist)));
                col.rgb += tex2D(_MainTex, i.uv + rot(half2(-_MotionBlurDist * 2, -_MotionBlurDist * 2)));
                col.rgb += tex2D(_MainTex, i.uv + rot(half2(-_MotionBlurDist * 3, -_MotionBlurDist * 3)));
                col.rgb += tex2D(_MainTex, i.uv + rot(half2(-_MotionBlurDist * 4, -_MotionBlurDist * 4)));
                col.rgb += tex2D(_MainTex, i.uv);
                col.rgb += tex2D(_MainTex, i.uv + rot(half2(_MotionBlurDist, _MotionBlurDist)));
                col.rgb += tex2D(_MainTex, i.uv + rot(half2(_MotionBlurDist * 2, _MotionBlurDist * 2)));
                col.rgb += tex2D(_MainTex, i.uv + rot(half2(_MotionBlurDist * 3, _MotionBlurDist * 3)));
                col.rgb += tex2D(_MainTex, i.uv + rot(half2(_MotionBlurDist * 4, _MotionBlurDist * 4)));
                col.rgb = col.rgb / 9;
                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}