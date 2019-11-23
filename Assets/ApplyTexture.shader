Shader "Custom/ApplyTexture"
{
    Properties // Varibles
	{
		_MainTex("Main Texture(RBG)", 2D) = "White"{} // Allows for a texture property
		_Color("Color", Color) = (1,1,1,1) // Allows for a colour property
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM // Allows talk between the two languages (shader lab and nvidia C for graphics)
			// Function defines - defines the name for the vertex and fragment functions

			#pragma vertex vert // Define for the building function

			#pragma fragment frag // Define for the colouring function


			#include "UnityCG.cginc" // Unity built in shader functions
			// Structs can get data like vertices's, normal, colour, uv
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			// Imports re import property from shader lab to nvidia cg
			float4 _Color;
			sampler2D _MainTex;

			// Vertex function builds the object

			v2f vert(appdata IN)
			{
				v2f OUT;

				OUT.pos = UnityObjectToClipPos(IN.vertex);
				OUT.uv = IN.uv;

				return OUT;
			}

			// Fragment function colours it IN

			fixed4 frag(v2f IN) : SV_Target
			{
				float4 texColor = tex2D(_MainTex, IN.uv);
				return texColor * _Color;
			}

			ENDCG
		}
	}
}
