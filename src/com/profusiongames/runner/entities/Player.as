package com.profusiongames.runner.entities 
{
	import com.profusiongames.runner.tiles.TileGroup;
	import flash.utils.getTimer;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author UnknownGuardian
	 */
	public class Player extends Sprite
	{
		private var _quad:Quad;
		
		private var _xSpeed:Number = 0;
		private var _ySpeed:Number = 0;
		private var _gravity:Number = 0.7;
		private var _jumpPower:Number = 6
		
		private var _hasLandedSinceJump:Boolean = false;
		private var _lastJumpTimestamp:int = 0
		private var _currentlyJumpIsDown:Boolean = false;
		private var _frameCountFromJump:int = 0;
		
		private var _animation:MovieClip;
		
		[Embed(source = "../../../../../lib/foreground/char/char.xml", mimeType = "application/octet-stream")]private var _animXML:Class;
		[Embed(source="../../../../../lib/foreground/char/char.png")]private var _animTexture:Class;
		
		
		[Embed(source="../../../../../lib/particles/burst/particle.pex", mimeType="application/octet-stream")]
		private static const BurstConfig:Class;
		 
		// embed particle texture
		[Embed(source="../../../../../lib/particles/burst/texture.png")]
		private static const BurstParticle:Class;
		private var _burstParticleSystem:PDParticleSystem;
		
		public function Player() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			
			
			
			var texture:Texture = Texture.fromBitmap(new _animTexture());
			var xmlData:XML = XML(new _animXML());
			var textureAtlas:TextureAtlas = new TextureAtlas(texture, xmlData);
			_animation = new MovieClip(textureAtlas.getTextures("dude"), 20);
			//addChild(_animation);
			_animation.currentFrame = 1;
			addChild(_animation);
			Starling.juggler.add(_animation);
			
			
			pivotX = _animation.width / 2;// _quad.width / 2;
			pivotY = _animation.height;// _quad.height;
			
			//blendMode = BlendMode.ADD;
			
			
			
			// instantiate embedded objects
			var psConfig:XML = XML(new BurstConfig());
			var psTexture:Texture = Texture.fromBitmap(new BurstParticle());
			 
			// create particle system
			_burstParticleSystem = new PDParticleSystem(psConfig, psTexture);
			parent.addChild(_burstParticleSystem);
			parent.setChildIndex(_burstParticleSystem, 1);
			Starling.juggler.add(_burstParticleSystem);
			_burstParticleSystem.blendMode = BlendMode.ADD;
			//_burstParticleSystem.start();
			
			
			
			
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, kDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, kUp);
		}
		
		private function kUp(e:KeyboardEvent):void 
		{
			_currentlyJumpIsDown = false;
		}
		
		private function kDown(e:KeyboardEvent):void 
		{
			_currentlyJumpIsDown = true;
			if(_hasLandedSinceJump)
				_lastJumpTimestamp = getTimer();
		}
		
		public function frame(collidedWith:TileGroup):void 
		{
			if (collidedWith != null)
			{
				y = collidedWith.getPlatformTop() + 1;//collidedWith.y - collidedWith.height + 1;
				
				collidedWith.bleedOn(this);
				
				_ySpeed = 0;
				_hasLandedSinceJump = true;
				
				if (getTimer() - _lastJumpTimestamp < 16 * 5)
				{
					_ySpeed = -_jumpPower;
					_burstParticleSystem.start(0.1);
				}
			
			}
			else if (_ySpeed < 0 && _currentlyJumpIsDown && _frameCountFromJump < 9)
			{
				_ySpeed -= 0.15 * (9 - _frameCountFromJump)////1 * Math.pow(1 - .05, (getTimer() - _lastJumpTimestamp));// / 200;
			}
			else
			{
				_ySpeed += _gravity; 
			}
			
			if (_ySpeed < 0)
				_frameCountFromJump++;
			else
				_frameCountFromJump = 0;
			
			
		
			y += _ySpeed;
			
			_burstParticleSystem.emitterX = x;
			_burstParticleSystem.emitterY = y;
		}
		
		public function get ySpeed():Number { return _ySpeed; }
		public function get xSpeed():Number { return _xSpeed; }
		public function set xSpeed(value:Number):void { _xSpeed = value; }
	}

}