Import shipsnsailors

Const STATE_MENU:Int = 0
Const STATE_CAMPAIGN:Int = 1
Const STATE_MOVING:Int = 2
Const STATE_ATTACKING:Int = 3
Const STATE_BUILD:Int = 4
Const STATE_UNIT_SELECT:Int = 5
Const STATE_FINISHED:Int = 6

Const STATE_ALIVE:Int = 0
Const STATE_DEAD:Int = 1


Class RepelBoarders Extends App

	Field game_state:Int = STATE_MENU
	Field game_map:TileMap
	Field player_army:List<Unit> = New List<Unit>()
	Field opponent_army:List<Unit> = New List<Unit>()
	Field active_unit:Unit
	Field moves:List<Position> = New List<Position>()
	Field attacks:List<Position> = New List<Position>()
	
	' Selection Box images
	Field attack_img:Image 
	Field move_img:Image
	Field can_select_img:Image
	' Title and finish screen images
	Field title_screen:Image
	Field title_header:Image
	Field fight_img:Image
	Field fight_button:Tile
	Field finish_flags:Image
	
	Field attack_tiles:List<Tile> = New List<Tile>()
	Field move_tiles:List<Tile> = New List<Tile>()
	
	Field player_turn:Int
	
	Field end_button:Tile
	Field end_img:Image
	Field last_end:Float = 0.0
	
	Method OnCreate()
		Print "Creating Game"
		SetUpdateRate(15)
		
		title_screen = LoadImage("images/TITLE_SCREEN.png")
		title_header = LoadImage("images/TITLE_HEADER.png")
		fight_img = LoadImage("images/FIGHT_BUTTON.png")
		' create the begin "FIGHT" button
		fight_button = New Tile(200, 380, fight_img, 240, 80)
		finish_flags = LoadImage("images/FINISH_FLAGS.png")
		
		attack_img = LoadImage("images/ATTACK_TILE.png")
		move_img = LoadImage("images/MOVE_TILE.png")
		can_select_img = LoadImage("images/CAN_SELECT.png")
		' build tile list
		Local tile_list:List<Tile> = New List<Tile>()
		Local deck_tile:Image = LoadImage("images/DARK_DECK.png")
		Local cannon_tile:Image = LoadImage("images/CANNON_DECK_TILE.png")
		
		For Local i:Int = 0 Until MAP_H
			For Local j:Int = 0 Until MAP_W
				'Print i + " " + j + " adding image"
				If (j = 0 And (i Mod 3) = 0)
					tile_list.AddLast(New Tile(j * TILE_W, i * TILE_H, cannon_tile))
				Else
					tile_list.AddLast(New Tile(j * TILE_W, i * TILE_H, deck_tile))
				End
			End
		End
		 
		game_map = New TileMap(MAP_W, MAP_H, tile_list)
		
		' Build unit list 
		Local marine_img:Image = LoadImage("images/RED_MARINE.png")
		Local pirate_img:Image = LoadImage("images/BLUE_PIRATE.png")
		Local sailor_img:Image = LoadImage("images/RED_SAILOR.png")
		Local bucaneer_img:Image = LoadImage("images/BLUE_BUCANEER.png")
		
		
		For Local m:Int = 2 Until 7
			If (m Mod 2 = 0)
				player_army.AddLast(New Unit(m, "pirate", m * TILE_W, MAP_H * TILE_H - 48, New Stats("Pirate", 6, 5, 1, 3, pirate_img)))
				opponent_army.AddLast(New Unit(m, "sailor", m * TILE_W, 0, New Stats("Sailor", 8, 2, 1, 3, sailor_img)))
			Else
				player_army.AddLast(New Unit(m, "bucaneer", m * TILE_W, MAP_H * TILE_H - 48, New Stats("Bucaneer", 10, 4, 2, 2, bucaneer_img)))
				opponent_army.AddLast(New Unit(m, "marine", m * TILE_W, 0, New Stats("Marine", 10, 3, 3, 2, marine_img)))
			End
		End
		
		' Create the end turn button
		end_img = LoadImage("images/END_TURN.png")
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
			Case STATE_MENU
				If (TouchDown(0) And fight_button.Clicked(TouchX(0), TouchY(0)))
					game_state = STATE_UNIT_SELECT
				End
			Case STATE_CAMPAIGN
			
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
			If (TouchDown(0) And end_button.Clicked(TouchX(0), TouchY(0)) And (Millisecs() - last_end > 1000))
				last_end = Millisecs()
				EndTurn()
			End
		End
		
		If player_army.Count() = 0 Or opponent_army.Count() = 0
			game_state = STATE_FINISHED
		End
	End
	
	Method OnRender()
		Cls(128, 128, 128)
		'Print "clear screen"
		PushMatrix()
		If game_state = STATE_MENU
			DrawImage(title_screen, 56, 426, 90.0, 1.0, 1.0)
			DrawImage(title_header, 104, 10)
			fight_button.Draw()
		Else
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
			If game_state <> STATE_FINISHED
				end_button.Draw()
			End
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
				Case STATE_FINISHED
					DrawImage(finish_flags.GrabImage(84 * player_turn, 0, 84, 156), 180, 100)
					DrawText("Finished Game", 220, 25)
				
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
						Local enemy_hp:Int = enemy.Damaged(active_unit.Attack())
						If (enemy_hp <= 0)
							active_unit.LevelUp()
						End
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


' This is an extension to the base game of repel boarders that
' allows the loading of campaign files and puts in a 
' armory/barracks for players to build their crew with

' Read in a file containing an army

' Display all units with their values

' Display all weapons with their values

Function Main()
	New RepelBoarders()
End


