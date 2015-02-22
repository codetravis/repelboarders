Import mojo

Const MAP_W:Int = 10
Const MAP_H:Int = 10

Const TILE_W:Int = 48 
Const TILE_H:Int = 48

Const SCREEN_W:Int = 480
Const SCREEN_H:Int = 480

Class Position
	Field x:Float
	Field y:Float
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
	
	Method Set(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
	
	Method Same:Bool(pos:Position)
		If (Self.x = pos.x And
			Self.y = pos.y)
			Return True
		Else
			Return False
		End
	End
	
End


Class Unit
	Field name:String
	Field id:Int
	Field pos:Position
	Field unit_stats:Stats
	Field moved:Int
	
	Method New(id:Int, name:String, x:Float, y:Float, u_stats:Stats)
		' Use type to load the attributes
		Self.name = name
		Self.pos = New Position(x, y)
		Self.unit_stats = u_stats
		Self.moved = 0
	End
	
	Method Draw()
		DrawImage(unit_stats.img, pos.x, pos.y, 0.0, 1.0, 1.0)
		SetColor(0, 255, 0)
		DrawRect(pos.x + 2, pos.y + 44, (40 * Float(unit_stats.health)/Float(unit_stats.max_health)), 2)
		SetColor(255, 255, 255)
	End
	
	Method DrawActive(x:Float, y:Float)
		DrawImage(unit_stats.img, x, y, 0.0, 1.0, 1.0)
		DrawText(name, x, y + 50)
		DrawText("HP: " + unit_stats.health + "/" + unit_stats.max_health, x, y + 60)
		DrawText("Attack: " + unit_stats.attack, x, y + 70)
		DrawText("Range: " + unit_stats.range, x, y + 80)
		DrawText("Speed: " + unit_stats.speed, x, y + 90)
	End
	
	Method Move(pos:Position)
		Self.pos = pos
		Self.moved = 1
	End
	
	Method Clicked:Bool(x:Float, y:Float)
		If((x > pos.x) And (x < pos.x + TILE_W) And
		   (y > pos.y) And (y < pos.y + TILE_H))
			Return True
		End
		Return False
	End
	
	Method FindMoves:List<Position>()
		Local moves:List<Position> = New List<Position>()
		If unit_stats.speed > 0
			For Local i:Int = 0 Until unit_stats.speed + 1
				For Local j:Int = 0 Until unit_stats.speed + 1
					If (((i > 0) Or (j > 0)) And (i + j <= unit_stats.speed))
						moves.AddLast(New Position(pos.x + i * TILE_W, pos.y + j * TILE_H))
						moves.AddLast(New Position(pos.x - i * TILE_W, pos.y + j * TILE_H))
						moves.AddLast(New Position(pos.x + i * TILE_W, pos.y - j * TILE_H))
						moves.AddLast(New Position(pos.x - i * TILE_W, pos.y - j * TILE_H))
					End
				End
			End
		End
		Return moves
	End
	
	Method FindAttacks:List<Position>(friendlies:List<Unit>)
		Local attacks:List<Position> = New List<Position>()
		' Find all possible attacks
		If (unit_stats.range > 0 And unit_stats.attack > 0)
			For Local i:Int = 0 Until unit_stats.range + 1
				For Local j:Int = 0 Until unit_stats.range + 1
					If (((i > 0) Or (j > 0)) And (i + j <= unit_stats.range))
						attacks.AddLast(New Position(pos.x + i * TILE_W, pos.y + j * TILE_H))
						attacks.AddLast(New Position(pos.x - i * TILE_W, pos.y + j * TILE_H))
						attacks.AddLast(New Position(pos.x + i * TILE_W, pos.y - j * TILE_H))
						attacks.AddLast(New Position(pos.x - i * TILE_W, pos.y - j * TILE_H))
					End
				End
			End
		End
		' Filter out attacks that would hit friendly units if we are doing damage
		If (unit_stats.attack > 0)
			For Local friend:Unit = Eachin friendlies
				For Local attack:Position = Eachin attacks
					If (attack.Same(friend.pos))
						attacks.Remove(attack)
					End
				End
			End
		End
		Return attacks
	End
	
	Method Attack:Int()
		Return unit_stats.attack
	End
	
	Method Damaged:Int(damage:Int)
		unit_stats.health = unit_stats.health - damage
		Return unit_stats.health
	End
	
	Method IsDead:Bool()
		If (unit_stats.health <= 0)
			Return True
		Else
			Return False
		End
	End
	
	Method LevelUp()
		unit_stats.level += 1
		unit_stats.max_health += unit_stats.level
		unit_stats.health = unit_stats.max_health
		unit_stats.attack += (unit_stats.level/2)
	End

End

Class Stats
	Field type:String
	Field health:Int
	Field max_health:Int
	Field attack:Int
	Field range:Int
	Field speed:Int
	Field level:Int
	Field experience:Int
	Field img:Image
	
	Method New(type:String, health:Int, attack:Int, range:Int, speed:Int, img:Image, level:Int = 0, experience:Int = 0)
		Self.type = type
		Self.health = health + level
		Self.max_health = health + level 
		Self.attack = attack + (level/2)
		Self.range = range
		Self.speed = speed
		Self.img = img
		Self.level = level
		Self.experience = experience
	End
	
End


Class TileMap
	Field width:Int
	Field height:Int
	Field tile_map:List<Tile>
	
	Method New(width:Int, height:Int, tile_map:List<Tile>)
		Self.width = width
		Self.height = height
		Self.tile_map = tile_map
	End
	
	Method Draw()
		For Local square:Tile = Eachin tile_map
			square.Draw()
		End
	End
	
End

Class Tile
	Field img:Image
	Field pos:Position
	Field width:Int
	Field height:Int
	
	Method New(x:Float, y:Float, img:Image, width:Int=TILE_W, height:Int=TILE_H)
		Self.pos = New Position(x, y)
		Self.img = img
		Self.width = width
		Self.height = height
	End
	
	Method Draw()
		DrawImage(img, pos.x, pos.y)
	End
	
	Method Clicked:Bool(x:Float, y:Float)
		If((x > pos.x) And (x < pos.x + width) And
		   (y > pos.y) And (y < pos.y + height))
			Return True
		End
		Return False
	End
End