class_name IsometricHelper
extends RefCounted

## Utility class for 2D Isometric projections (2:1 standard isometric ratio)

const TILE_WIDTH: float = 76.0
const TILE_HEIGHT: float = 38.0


## Converts 2D cartesian grid coordinates into 2D isometric screen space coordinates
static func cartesian_to_isometric(cart: Vector2) -> Vector2:
	return Vector2(
		(cart.x - cart.y) * (TILE_WIDTH * 0.5),
		(cart.x + cart.y) * (TILE_HEIGHT * 0.5)
	)


## Converts 2D isometric screen space coordinates back into 2D cartesian grid coordinates
static func isometric_to_cartesian(iso: Vector2) -> Vector2:
	return Vector2(
		(iso.x / (TILE_WIDTH * 0.5) + iso.y / (TILE_HEIGHT * 0.5)) * 0.5,
		(iso.y / (TILE_HEIGHT * 0.5) - iso.x / (TILE_WIDTH * 0.5)) * 0.5
	)
