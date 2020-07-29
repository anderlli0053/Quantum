shader_type spatial;

/*
	Simple Interior Mapping by Yui Kinomoto @arlez80
	Warning:
		This shader will be generate rooms that parallel with axis.

	シンプルインテリアマッピング by あるる（きのもと 結衣） @arlez80
	注意：
		このシェーダーは軸と平行な部屋しか生成しません。回転しても部屋は回転しません。
		回転版もそのうち作ります。

	MIT License
*/

// 3面分テクスチャ
uniform sampler2D tex_ceil;
uniform sampler2D tex_floor;
uniform sampler2D tex_wall;
// 部屋サイズ
uniform float d = 1.0;
// ズレ
uniform vec4 offset = vec4( 0.0, 0.0, 0.0, 0.0 );
// 中の面ごとにライト計算をする
uniform bool detail_light = false;
// 座標
varying vec4 local_vertex_pos;

/**
 * Vertex Shader
 */
void vertex( )
{
	local_vertex_pos = ( vec4( VERTEX, 0.0 ) + offset );
}

/**
 * 面チェック
 * （平行面しかチェックしていないので、回転させても変わらない）
 */
void check_surface( int i, float ray_dir, float surface, inout float min_t, inout int id )
{
	float old_min_t = min_t;
	bool is_flip = ray_dir < 0.0;
	float t = - ( surface + mix( 0.0, 1.0, is_flip ) * d ) / ray_dir;
	min_t = min( min_t, t );
	id = max( id, ( int( is_flip ) + i * 2 ) * int( min_t < old_min_t ) );
}

/**
 * Fragment Shader
 */
void fragment( )
{
	vec4 vertex_pos = WORLD_MATRIX * local_vertex_pos;
	vec4 world_vertex = vec4( VERTEX, 1.0 ) * INV_CAMERA_MATRIX + vertex_pos + WORLD_MATRIX[3];
	vec4 ray_dir = normalize( world_vertex - CAMERA_MATRIX[3] );
	vec4 surface = mod( ( vertex_pos + offset ), -vec4( d, d, d, d ) );

	float min_t = 1e10;
	int id = -1;
	check_surface( 0, ray_dir.x, surface.x, min_t, id );
	check_surface( 1, ray_dir.y, surface.y, min_t, id );
	check_surface( 2, ray_dir.z, surface.z, min_t, id );

	vec4 hit = vertex_pos + min_t * ray_dir;
	// 色決定
	ALBEDO = (
		// X+ X-
		texture( tex_wall, vec2( hit.z, -hit.y ) ).xyz * mix( 0.0, 1.0, id == 0 )
	+	texture( tex_wall, vec2( -hit.z, -hit.y ) ).xyz * mix( 0.0, 1.0, id == 1 )
		// Y+ Y-
	+	texture( tex_ceil, vec2( hit.x, hit.z ) ).xyz * mix( 0.0, 1.0, id == 2 )
	+	texture( tex_floor, vec2( hit.x, hit.z ) ).xyz * mix( 0.0, 1.0, id == 3 )
		// Z+ Z-
	+	texture( tex_wall, vec2( -hit.x, -hit.y ) ).xyz * mix( 0.0, 1.0, id == 4 )
	+	texture( tex_wall, vec2( hit.x, -hit.y ) ).xyz * mix( 0.0, 1.0, id == 5 )
	);
	// 法線
	NORMAL = mix(
		NORMAL,
			INV_CAMERA_MATRIX[0].xyz * mix( mix( 0.0, 1.0, id == 1 ), -1.0, id == 0 )
		+	INV_CAMERA_MATRIX[1].xyz * mix( mix( 0.0, 1.0, id == 3 ), -1.0, id == 2 )
		+	INV_CAMERA_MATRIX[2].xyz * mix( mix( 0.0, 1.0, id == 5 ), -1.0, id == 4 )
		,
		detail_light
	);
	// 深度: TODO
}
