Import shipsnsailors

Const STATE_MENU:Int = 0
Const STATE_WAITING:Int = 1
Const STATE_MOVING:Int = 2
Const STATE_ATTACKING:Int = 3
Const STATE_END:Int = 4
Const STATE_UNIT_SELECT:Int = 5

Const STATE_ALIVE:Int = 0
Const STATE_DEAD:Int = 1


Class ShipNSailors Extends App

	Field game_state:Int = STATE_UNIT_SELECT
	Field game_map:TileMap
	Field player_army:List<Unit> = New List<Unit>()
	Field opponent_army:List<Unit> = New List<Unit>()
	Field active_unit:Unit
	Field moves:List<Position> = New List<Position>()
	Field attacks:List<Position> = New List<Position>()
	
	Field attack_img:Image 
	Field move_img:Image
	Field can_select_img:Image 
	
	Field attack_tiles:List<Tile> = New List<Tile>()
	Field move_tiles:List<Tile> = New List<Tile>()
	
	Field player_turn:Int
	
	Field end_button:Tile
	Field end_img:Image
	Field last_end:Float = 0.0
	
	Method OnCreate()
		Print "Creating Game"
		SetUpdateRate(15)
		
		attack_img = LoadImage("ATTACK_TILE.png")
		move_img = LoadImage("MOVE_TILE.png")
		can_select_img = LoadImage("CAN_SELECT.png")
		' build tile list
		Local tile_list:List<Tile> = New List<Tile>()
		Local grass_tile:Image = LoadImage("GRASS_TILE.png")
		Local flower_tile:Image = LoadImage("GRASS2_TILE.png")
		
		For Local i:Int = 0 Until MAP_H
			For Local j:Int = 0 Until MAP_W
				'Print i + " " + j + " adding image"
				If (i = 7 And j = 3) Or (i = 3 And j = 7)
					tile_list.AddLast(New Tile(j * TILE_W, i * TILE_H, flower_tile))
				Else
					tile_list.AddLast(New Tile(j * TILE_W, i * TILE_H, grass_tile))
				End
			End
		End
		 
		game_map = New TileMap(MAP_W, MAP_H, tile_list)
		
		' Build unit list 
		Local peasant_img:Image = LoadImage("PEASANT.png")
		Local spearman_img:Image = LoadImage("SPEARMAN.png")
		
		For Local m:Int = 2 Until 7
			If (m Mod 2 = 0)
				player_army.AddLast(New Unit(m, "peasant", m * TILE_W, MAP_H * TILE_H - 48, New Stats("Peasant", 7, 1, 1, 3, peasant_img)))
				opponent_army.AddLast(New Unit(m, "peasant", m * TILE_W, 0, New Stats("Peasant", 7, 1, 1, 3, peasant_img)))
			Else
				player_army.AddLast(New Unit(m, "spearman", m * TILE_W, MAP_H * TILE_H - 48, New Stats("Spearman", 10, 3, 2, 2, spearman_img)))
				opponent_army.AddLast(New Unit(m, "spearman", m * TILE_W, 0, New Stats("Spearman", 10, 3, 2, 2, spearman_img)))
			End
		End
		
		' Create the end button
		end_img = LoadImage("END_TURN.png")
		end_button = New Tile(490, 360, end_img.GrabImage(0, 48 * player_turn, 108, 48), 108, 48)
		' set our first player to go first
		player_turn = 0
	End
	
	Method OnUpdate()
		RemoveDead()
		
		Local current_army:List<Unit>
		Local enemy_army:List<Unit>
		If player_turn = 0
			current_army = player_army
			enemy_army = opponent_army
		Else
			current_army = opponent_army
			enemy_army = player_army
		End
		
		Select game_state
			Case STATE_UNIT_SELECT
				If (TouchDown(0))
					ChooseUnit(current_army)
				End
			Case STATE_MOVING
				If (TouchDown(0))
					ChooseMove(current_army)
				End
			Case STATE_ATTACKING
				If (TouchDown(0))
					ChooseAttack(enemy_army)
				End
		End
		' End Turn at any time
		If (TouchDown(0))
			If (end_button.Clicked(TouchX(0), TouchY(0)) And (Millisecs() - last_end > 1000))
				last_end = Millisecs()
				EndTurn()
			End
		End
	End
	
	Method OnRender()
		Cls(128, 128, 128)
		'Print "clear screen"
		PushMatrix()
		game_map.Draw()
		For Local o_unit:Unit = Eachin opponent_army
			o_unit.Draw()
			If player_turn = 1 And o_unit.moved = 0
				DrawImage(can_select_img, o_unit.pos.x, o_unit.pos.y)
			End
		End
		For Local p_unit:Unit = Eachin player_army
			p_unit.Draw()
			If player_turn = 0 And p_unit.moved = 0
				DrawImage(can_select_img, p_unit.pos.x, p_unit.pos.y)
			End
		End
		end_button.Draw()
		Select game_state
			Case STATE_MOVING
				active_unit.DrawActive(490, 50)
				For Local move:Tile = Eachin move_tiles
					move.Draw()
				End
			Case STATE_ATTACKING
				active_unit.DrawActive(490, 50)
				For Local attack:Tile = Eachin attack_tiles
					attack.Draw()
				End
		End
		
		
		PopMatrix()
	End

	Method ChooseUnit(current_army:List<Unit>) 
		For Local some_unit:Unit = Eachin current_army
			If (some_unit.Clicked(TouchX(0), TouchY(0)) And some_unit.moved = 0)
				active_unit = some_unit
				Print active_unit.name
				game_state = STATE_MOVING
				Print "State changed to moving"
				moves = active_unit.FindMoves()
				FilterMoves()
				move_tiles = New List<Tile>()
				For Local move:Position = Eachin moves
					move_tiles.AddLast(New Tile(move.x, move.y, move_img))
				End
			End
		End
	End
	
	Method ChooseMove(current_army:List<Unit>)
		For Local move:Tile = Eachin move_tiles
			If (move.Clicked(TouchX(0), TouchY(0)))
				active_unit.Move(move.pos)
				game_state = STATE_ATTACKING
				Print "State changed to attacking"
				attacks = active_unit.FindAttacks(current_army)
				FilterAttacks()
				attack_tiles = New List<Tile>()
				For Local attack:Position = Eachin attacks
					attack_tiles.AddLast(New Tile(attack.x, attack.y, attack_img))
				End
			End
		End
	End
	
	Method ChooseAttack(enemy_army:List<Unit>)
		For Local attack:Tile = Eachin attack_tiles
			If (attack.Clicked(TouchX(0), TouchY(0)) And game_state = STATE_ATTACKING)
				For Local enemy:Unit = Eachin enemy_army
					If attack.pos.Same(enemy.pos)
						enemy.Damaged(active_unit.Attack())
					End
				End
				game_state = STATE_UNIT_SELECT
			End
		End
	End
	
	Method FilterMoves()
		For Local move:Position = Eachin moves
			For Local player_unit:Unit = Eachin player_army
				If ((move.x = player_unit.pos.x) And
					(move.y = player_unit.pos.y))
					moves.Remove(move)
				End
			End
			For Local opponent_unit:Unit = Eachin opponent_army
				If ((move.x = opponent_unit.pos.x) And
					(move.y = opponent_unit.pos.y))
					moves.Remove(move)
				End
			End
			If ((move.x > SCREEN_W - TILE_W) Or (move.x < 0) Or
				(move.y > SCREEN_H - TILE_H) Or (move.y < 0))
				moves.Remove(move)
			End
		End
	End
	
	Method FilterAttacks()
		For Local attack:Position = Eachin attacks
			If ((attack.x > SCREEN_W - TILE_W) Or (attack.x < 0) Or
				(attack.y > SCREEN_H - TILE_H) Or (attack.y < 0))
				attacks.Remove(attack)
			End
		End
	End
	
	Method RemoveDead()
		For Local some_unit:Unit = Eachin opponent_army
			If some_unit.IsDead()
				opponent_army.Remove(some_unit)
			End
		End
		For Local some_unit:Unit = Eachin player_army
			If some_unit.IsDead()
				player_army.Remove(some_unit)
			End
		End
	End
	
	Method EndTurn()
		If (player_turn = 0)
			player_turn = 1
			For Local some_unit:Unit = Eachin opponent_army
				some_unit.moved = 0
			End
		Else
			player_turn = 0
			For Local some_unit:Unit = Eachin player_army
				some_unit.moved = 0
			End
		End
		Print "Current Player: " + player_turn + " "
		end_button = New Tile(490, 360, end_img.GrabImage(0, 48 * player_turn, 108, 48), 108, 48)
		game_state = STATE_UNIT_SELECT
	End

End


Function Main()
	New ShipNSailors()
End


