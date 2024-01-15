Shader "Custom/Uv/Distortion"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _DistortTex ("Distortion Texture", 2D) = "white" { }
        _DistortAmount ("Distortion Amount", Range(0, 2)) = 0.5
        _DistortTexXSpeed ("Scroll speed X", Range(-1, 1)) = 0.2    
        _DistortTexYSpeed ("Scroll speed Y", Range(-1, 1)) = 0.2
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

            sampler2D _DistortTex;
            half4 _DistortTex_ST;
            half _DistortTexXSpeed, _DistortTexYSpeed, _DistortAmount;

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
                half2 uvDistTex : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.color = v.color;
                o.uvDistTex = TRANSFORM_TEX(v.uv, _DistortTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                i.uvDistTex.x += (_Time.y * _DistortTexXSpeed) % 1;
                i.uvDistTex.y += (_Time.y * _DistortTexYSpeed) % 1;
                half distortAmnt = (tex2D(_DistortTex, i.uvDistTex).r - 0.5) * 0.2 * _DistortAmount;
                i.uv.x += distortAmnt;
                i.uv.y += distortAmnt;

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
}