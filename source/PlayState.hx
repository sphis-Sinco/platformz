package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

/**
 * @author Zaphod
 */
class PlayState extends FlxState
{
	static var _justDied:Bool = false;

	var _level:FlxTilemap;
	var _player:FlxSprite;
	var _exit:FlxSprite;
	var _scoreText:FlxText;
	var _status:FlxText;
	var _coins:FlxGroup;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = 0xffaaaaaa;

		_level = new FlxTilemap();
		_level.loadMapFromCSV(FileManager.getDataFile('level.csv'), FlxGraphic.fromClass(GraphicAuto), 0, 0, AUTO);
		add(_level);

		// Create the _level _exit
		_exit = new FlxSprite(35 * 8 + 1, 25 * 8);
		_exit.makeGraphic(14, 16, FlxColor.GREEN);
		_exit.exists = false;
		add(_exit);

		// Create _coins to collect (see createCoin() function below for more info)
		_coins = new FlxGroup();
		add(_coins);

		// read for custom values in the level data
		var x = 0;
		var y = 0;
		var maparray:Array<Dynamic> = FileManager.getDataFile('level.csv').split(',');
		for (i in maparray)
		{
			switch (maparray[i])
			{
				case "2":
					createCoin(x, y);
			}

			x++;
			if (x > 40)
			{
				y++;
				x = 0;
			}
		}

		// Create _player
		_player = new FlxSprite(FlxG.width / 2 - 5);
		_player.makeGraphic(8, 8, FlxColor.RED);
		_player.maxVelocity.set(80, 200);
		_player.acceleration.y = 200;
		_player.drag.x = _player.maxVelocity.x * 4;
		add(_player);

		_scoreText = new FlxText(2, 2, 80, "SCORE: " + (_coins.countDead() * 100));
		_scoreText.setFormat(null, 8, FlxColor.WHITE, null, NONE, FlxColor.BLACK);
		add(_scoreText);

		_status = new FlxText(FlxG.width - 160 - 2, 2, 160, "Collect coins.");
		_status.setFormat(null, 8, FlxColor.WHITE, RIGHT, NONE, FlxColor.BLACK);

		if (_justDied)
		{
			_status.text = "Aww, you died!";
		}

		add(_status);
	}

	override public function update(elapsed:Float):Void
	{
		_player.acceleration.x = 0;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			_player.acceleration.x = -_player.maxVelocity.x * 4;
		}

		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			_player.acceleration.x = _player.maxVelocity.x * 4;
		}

		if (FlxG.keys.anyJustPressed([SPACE, UP, W]) && _player.isTouching(FLOOR))
		{
			_player.velocity.y = -_player.maxVelocity.y / 2;
		}

		super.update(elapsed);
		FlxG.overlap(_coins, _player, getCoin);
		FlxG.collide(_level, _player);
		FlxG.overlap(_exit, _player, win);

		if (_player.y > FlxG.height)
		{
			_justDied = true;
			FlxG.resetState();
		}
	}

	/**
	 * Creates a new coin located on the specified tile
	 */
	function createCoin(X:Int, Y:Int):Void
	{
		var coin:FlxSprite = new FlxSprite(X * 8 + 3, Y * 8 + 2);
		coin.makeGraphic(2, 4, 0xffffff00);
		_coins.add(coin);
	}

	function win(Exit:FlxObject, Player:FlxObject):Void
	{
		_status.text = "Yay, you won!";
		_scoreText.text = "SCORE: 5000";
		_player.kill();
	}

	function getCoin(Coin:FlxObject, Player:FlxObject):Void
	{
		Coin.kill();
		_scoreText.text = "SCORE: " + (_coins.countDead() * 100);

		if (_coins.countLiving() == 0)
		{
			_status.text = "Find the exit";
			_exit.exists = true;
		}
	}
}