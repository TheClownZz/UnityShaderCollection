Shader "Custom/Uv/FillAmount"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _ClipUvLeft ("Clipping Left", Range(0, 1)) = 0 //102
        _ClipUvRight ("Clipping Right", Range(0, 1)) = 0 //103
        _ClipUvUp ("Clipping Up", Range(0, 1)) = 0 //104
        _ClipUvDown ("Clipping Down", Range(0, 1)) = 0 //105

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

            half _ClipUvLeft, _ClipUvRight, _ClipUvUp, _ClipUvDown;

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
                half2 tiledUv = half2(i.uv.x / _MainTex_ST.x, i.uv.y / _MainTex_ST.y);
                clip((1 - _ClipUvUp) - tiledUv.y);
                clip(tiledUv.y - _ClipUvDown);
                clip((1 - _ClipUvRight) - tiledUv.x);
                clip(tiledUv.x - _ClipUvLeft);

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}