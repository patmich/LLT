package 
{
	import mx.graphics.codec.PNGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.BlurFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.GlowFilter;
	import flash.display.Shader;
	import flash.display.ShaderJob;

	/**
	 * ...
	 * @author 
	 */
	public class Main 
	{
		private var _input:String;
		private var _output:String;
		private var _dpi:int;
		private var _padding:int;
		private var _passCount:int;
		
		[Embed(source="GlowPicker.pbj", mimeType="application/octet-stream")] 
		private var GlowPicker:Class; 
			
		public function Main():void 
		{
			
		}
		public function onInvokeEvent(invocation:InvokeEvent):void 
		{
			var loader:Loader = new Loader();
			if (invocation.arguments.length != 5)
			{
				NativeApplication.nativeApplication.exit();
				return;
			}

			_input = invocation.arguments[0];
			_output = invocation.arguments[1];
			_dpi = invocation.arguments[2];
			_padding = invocation.arguments[3];
			_passCount = invocation.arguments[4];
			
			trace(_input + " " + _output + " " + _dpi + " " + _padding + " " + _passCount);
			
			loader.load(new URLRequest(_input));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
		}
		private function loaded(e:Event):void 
		{
			var loaderInfo:LoaderInfo = (e.target as LoaderInfo);
			loaderInfo.loader.removeEventListener(Event.COMPLETE, loaded);
			var stage:MovieClip = loaderInfo.content as MovieClip;
			for (var i:int = 1; i <= stage.totalFrames; i++)
			{
				stage.gotoAndStop(i);
				if (stage.numChildren != 1)
					continue;
					
				var rect:Rectangle = stage.getBounds(stage);
				var scale:Number = _dpi / 72;
				var scaleX:Number = Math.ceil(stage.width * scale) / stage.width;
				var scaleY:Number = Math.ceil(stage.height * scale) / stage.height;
				var boundRect:Rectangle = new Rectangle(0, 0, Math.round(stage.width * scaleX + 2*_padding),  Math.round(stage.height * scaleY + 2*_padding));

				var bitmapData:BitmapData = new BitmapData(boundRect.width, boundRect.height, true, 0x00FFFFFF);
				bitmapData.draw(stage, new Matrix(scaleX, 0, 0, scaleY, -rect.left * scaleX + _padding, -rect.top * scaleY + _padding), null, null, null, false);
				Save(bitmapData, stage.currentLabel);
				
				var glowBitmapData:BitmapData = new BitmapData(boundRect.width, boundRect.height, true, 0x00FFFFFF);
				glowBitmapData.draw(bitmapData, null, new ColorTransform(1, 1, 1, 0, 0, 0, 0, 255)); 
				for (var j:int = 0; j < 5; j++)
				{
					glowBitmapData = GlowPickerPass(glowBitmapData, boundRect, true);
				}
				for (j = 0; j < _passCount; j++)
				{
					glowBitmapData = GlowPickerPass(glowBitmapData, boundRect, false);
				}
				Save(glowBitmapData, stage.currentLabel + "-info");
			}			
			
			NativeApplication.nativeApplication.exit();
		}
		private function Save(bitmapData:BitmapData, filename:String):void
		{
			var encoder:PNGEncoder = new PNGEncoder();
			var byteArray:ByteArray =  encoder.encode(bitmapData);

			var file:File = new File(_output + filename + ".png");
		
			var stream:FileStream = new FileStream();
			stream.open( file , FileMode.WRITE);
			stream.writeBytes ( byteArray, 0, byteArray.length ); 
			stream.close();
		}
		private function GlowPickerPass(bitmapData:BitmapData, boundRect:Rectangle, inner:Boolean):BitmapData
		{
			var color:Number = 0xFFFFFF;
            var alpha:Number = 1;
            var blurX:Number = 1.1;
            var blurY:Number = 1.1;
            var strength:Number = 1000;
            var inner:Boolean = inner;
            var knockout:Boolean = true;
            var quality:Number = BitmapFilterQuality.HIGH;
			
			var glowFilter:GlowFilter = new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
								  
			var glowBitmapData:BitmapData = new BitmapData(boundRect.width, boundRect.height, true);
			glowBitmapData.applyFilter(bitmapData, boundRect, new Point(), glowFilter);

			var glowPicker:Shader =  new Shader();
			glowPicker.byteCode = new GlowPicker();
			glowPicker.data.src.input = bitmapData;
			glowPicker.data.glow.input = glowBitmapData;
			
			var glowPickerBitmapData:BitmapData = new BitmapData(boundRect.width, boundRect.height, true, 0x00FFFFFF);
			var job:ShaderJob = new ShaderJob(glowPicker, glowPickerBitmapData);
			job.start(true);

			glowPickerBitmapData.colorTransform(boundRect, new ColorTransform(1, 1, 1, 0, 0, 0, 0, 255));
			bitmapData.colorTransform(boundRect, new ColorTransform(1, 1, 1, 0, 0, 0, 0, 255));
			bitmapData.draw(glowPickerBitmapData);

			return bitmapData;
		}
	}
}