package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.desktop.NativeApplication;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.filters.DropShadowFilter;
	import mx.graphics.codec.PNGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.geom.Matrix;
	import flash.text.TextFieldAutoSize;
	import flash.filters.GlowFilter;
	import flash.text.TextLineMetrics;
	
	public class EMSwfText_Rasterizer extends MovieClip 
	{
		private var _output : String;
		
		private static var _filtersClass = 
		{
			"DropShadowFilter" : flash.filters.DropShadowFilter,
			"GlowFilter" : flash.filters.GlowFilter
		};
		
		public function EMSwfText_Rasterizer() 
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, Init); 
		}
		private function Init(invocation:InvokeEvent):void
		{
			var xmlPath:String = "";
			
			if(invocation.arguments.length == 0)
			{
				_output = "/Users/patricemichaud/LLT6/Temp/ui/";
				xmlPath = "/Users/patricemichaud/LLT6/Assets/Data/Fonts/FontTest.emfont";
			}
			else
			{
				xmlPath = invocation.arguments[0];
				_output = invocation.arguments[1];
			}
			
			var file:File = new File(xmlPath);
		
			var stream:FileStream = new FileStream();
			stream.open( file , FileMode.READ);
			var xml_:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			
			var textField:TextField = new TextField();
			var textFormat:TextFormat = new TextFormat();
			
			Parse(xml_, textField, textFormat);
			
			var fontId:String = xml_.FontId;
			textFormat.kerning = false;
			textFormat.size = xml_.RasterSize;
			
			textField.defaultTextFormat = textFormat;
			textField.autoSize = TextFieldAutoSize.LEFT;
			
			textField.width = 0;
			textField.height = 0;
			textField.text = " ";
			
			var spaceWidth:int = textField.width - 4;
			var spaceHeight:int = textField.height - 4;
			var lineMetrics:TextLineMetrics = textField.getLineMetrics(0);
			var lineHeight:int = lineMetrics.ascent + lineMetrics.descent + lineMetrics.leading;
			this.addChild(textField);

			var chars:XML = <Chars></Chars>;
			
			var charSet:String = xml_.CharSet;
			for each(var range : String in charSet.replace(" ", "").split(','))
			{
				var rangeSplit:Array = range.split('-');
				var start:int = rangeSplit[0];
				var end:int = rangeSplit[0];
				if(rangeSplit.length == 2)
				{
					end = rangeSplit[1];
				}
				
				for(var i:int = start; i <= end; i++)
				{
					textField.width = 0;
					textField.height = 0;

					textField.text = "\n " + String.fromCharCode(i) + " \n";
					
					var bitmapData:BitmapData = new BitmapData(textField.width - 4, textField.height - 4, true, 0x00FFFFFF);
					bitmapData.draw(textField, new Matrix(1, 0, 0, 1, -2, -2), null, null, null, false);

					var xmin:uint = 0xFFFFFFFF;
					var xmax:uint = 0;
					var ymin:uint = 0xFFFFFFFF;
					var ymax:uint = 0;
					
					for(var y:int = 0; y < bitmapData.height; y++)
					{
						for(var x:int = 0; x < bitmapData.width; x++)
						{
							var pix:uint = bitmapData.getPixel32(x, y);
							if((pix & 0xFF000000) > 0)
							{
								if(x > xmax)
								{
									xmax = x;
								}
								if(x < xmin)
								{
									xmin = x;
								}
								if(y > ymax)
								{
									ymax = y;
								}
								if(y < ymin)
								{
									ymin = y;
								}
							}
						}
					}
					
					var offsetLeft:int = xmin - (spaceWidth + 2);
					var offsetRight:int = (textField.width - (spaceWidth + 2)) - xmax;
					var offsetTop:int = ymin - (lineHeight + 2);
					var width:int = xmax - xmin + 1;
					var height:int = ymax - ymin + 1;
			
					var entry:XML = <CharInfo>
										<Code>{i}</Code>
										<OffsetLeft>{offsetLeft}</OffsetLeft>
										<OffsetRight>{offsetRight}</OffsetRight>
										<OffsetTop>{offsetTop}</OffsetTop>
										<Width>{width}</Width>
										<Height>{height}</Height>
									</CharInfo>;
					
					chars.appendChild(entry);
					bitmapData = new BitmapData(xmax - xmin + 1, ymax - ymin + 1, true, 0x00FFFFFF);
					bitmapData.draw(textField, new Matrix(1, 0, 0, 1, -xmin - 2, -ymin - 2), null, null, null, false);						
					
					Save(bitmapData, i.toString());
				}
			}
			
			var font:XML = 	<EMFontDefinition>
								<FontId>{fontId}</FontId>
								<LineHeight>{lineHeight}</LineHeight>
								{chars}
							</EMFontDefinition>;
								
			
			file = new File(_output + "definition.xml");
		
			stream = new FileStream();
			stream.open( file , FileMode.WRITE);
			stream.writeUTFBytes(font);
			stream.close();
								
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
		
		public static function Parse(xml_:XML, textField:TextField, textFormat:TextFormat) : void
		{
			textFormat.font = xml_.FontName;
			textFormat.color = xml_.Color;

			var filters = [];
			for each(var filter:XML in xml_.Filters.Filter)
			{
				var filterInstance : Object = new _filtersClass[filter.Name];

				for each(var prop:XML in filter.children())
				{
					try
					{
						filterInstance[prop.name()] = prop;
					}
					catch(e:Error)
					{
						
					}
				}
				
				filters.push(filterInstance);
			}
			textField.filters = filters;
		}
	}
	
}
