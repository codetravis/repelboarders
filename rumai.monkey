Import repelboarders

Function AIHasUnits:Bool(ai_units:List<Unit>)
	Local available_units:List<Unit> = New List<Unit>()
	For Local ai_unit:Unit = Eachin ai_units
		If ai_unit.moved = 0
			available_units.AddLast(ai_unit)
		End
	End
	
	If available_units.Count() > 0
		Return True
	Else
		Return False
	End
End

Function DrunkSelect:Unit(ai_units:List<Unit>)
	' calculate a random number base on number of available units
	Local available_units:List<Unit> = New List<Unit>()
	For Local ai_unit:Unit = Eachin ai_units
		If ai_unit.moved = 0
			available_units.AddLast(ai_unit)
		End
	End 
	Local choice:Int = Int(Rnd(available_units.Count() - 1))
	' return move based on random number
	Return available_units.ToArray()[choice]
End

Function DrunkMove:Position(moves:List<Position>)
	' calculate a random number base on number of possible moves
	Local choice:Int = Int(Rnd(moves.Count() - 1))
	' return move based on random number
	Return moves.ToArray()[choice]
End

Function DrunkWeapon:Weapon(ai_unit:Unit)
	' just pick the first weapon, he is drunk
	Return ai_unit.armament.First()
End

Function DrunkAttack:Position(attacks:List<Position>)
		' calculate a random number base on number of possible attacks
	Local choice:Int = Int(Rnd(attacks.Count() - 1))
	' return move based on random number
	Return attacks.ToArray()[choice]
End