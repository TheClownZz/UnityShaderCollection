Shader "Custom/Frag/SwapColor"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        [NoScaleOffset] _ColorSwapTex ("Color Swap Texture", 2D) = "black" { }
        [HDR] _ColorSwapRed ("Red Channel", Color) = (1, 1, 1, 1)
        _ColorSwapRedLuminosity ("Red luminosity", Range(-1, 1)) = 0.5
        [HDR] _ColorSwapGreen ("Green Channel", Color) = (1, 1, 1, 1)
        _ColorSwapGreenLuminosity ("Green luminosity", Range(-1, 1)) = 0.5
        [HDR] _ColorSwapBlue ("Blue Channel", Color) = (1, 1, 1, 1)
        _ColorSwapBlueLuminosity ("Blue luminosity", Range(-1, 1)) = 0.5
        _ColorSwapBlend ("Color Swap Blend", Range(0, 1)) = 0.75
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

            sampler2D _ColorSwapTex;
            half4 _ColorSwapRed, _ColorSwapGreen, _ColorSwapBlue;
            half _ColorSwapRedLuminosity, _ColorSwapGreenLuminosity, _ColorSwapBlueLuminosity, _ColorSwapBlend;

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

                half luminance = 0.3 * col.r + 0.59 * col.g + 0.11 * col.b;
                half4 swapMask = tex2D(_ColorSwapTex, i.uv);
                swapMask.rgb *= swapMask.a;
                half3 redSwap = _ColorSwapRed * swapMask.r * saturate(luminance + _ColorSwapRedLuminosity);
                half3 greenSwap = _ColorSwapGreen * swapMask.g * saturate(luminance + _ColorSwapGreenLuminosity);
                half3 blueSwap = _ColorSwapBlue * swapMask.b * saturate(luminance + _ColorSwapBlueLuminosity);
                swapMask.rgb = col.rgb * saturate(1 - swapMask.r - swapMask.g - swapMask.b);
                col.rgb = lerp(col.rgb, swapMask.rgb + redSwap + greenSwap + blueSwap, _ColorSwapBlend);

                return col;
            }

            ENDCG
        }
    }
}